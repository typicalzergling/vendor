-- Merchant event handling.
local AddonName, Addon = ...
local L = Addon:GetLocale()
local debugp = function (...) Addon:Debug("autosell", ...) end

local Merchant = {
    NAME = "Merchant",
    VERSION = 1,
    DEPENDENCIES = {
        "History",
    },
}

local threadName = Addon.c_ItemSellerThreadName
local AUTO_SELL_START = Addon.Events.AUTO_SELL_START
local AUTO_SELL_COMPLETE = Addon.Events.AUTO_SELL_COMPLETE
local AUTO_SELL_ITEM = Addon.Events.AUTO_SELL_ITEM

local isMerchantOpen = false
local isAutoSelling = false

-- When the merchant window is opened, we will attempt to auto repair and sell.
function Merchant.OnMerchantShow()
    debugp("Merchant opened.")
    isMerchantOpen = true
    local profile = Addon:GetProfile();

    -- Do auto-repair if enabled
    if profile:GetValue(Addon.c_Config_AutoRepair) then
        Merchant:AutoRepair()
    end

    -- Do auto-selling if enabled
    if profile:GetValue(Addon.c_Config_AutoSell) then
        Merchant:AutoSell()
    end
end

function Merchant.OnMerchantClosed()
    debugp("Merchant closed.")
    isMerchantOpen = false
end

-- For checking to make sure merchant window is open prior to selling anything.
function Merchant:IsMerchantOpen()
    if Addon.IsDebug and Addon:GetDebugSetting("simulate") then return true end
    return isMerchantOpen
end

-- Do Autorepair. If using guild funds and guild funds don't cover the repair, we will use our own funds.
function Merchant:AutoRepair()
    local cost, canRepair = GetRepairAllCost()
    if canRepair then
        local profile = Addon:GetProfile();
        -- Guild repair is not supported on Classic. The API method "CanGuildBankRepair" is missing.
        if not Addon.Systems.Info.IsClassicEra and profile:GetValue(Addon.c_Config_GuildRepair) and CanGuildBankRepair() and GetGuildBankWithdrawMoney() >= cost then
            -- use guild repairs
            RepairAllItems(true)
            Addon:Print(string.format(L["MERCHANT_REPAIR_FROM_GUILD_BANK"], Addon:GetPriceString(cost)))
        else
            -- use own funds
            RepairAllItems()
            Addon:Print(string.format(L["MERCHANT_REPAIR_FROM_SELF"], Addon:GetPriceString(cost)))
        end
    end
end

-- This returns true if we are in the middle of autoselling.
function Merchant:IsAutoSelling()
    -- We are selling if we have a thread active.
    return not not Addon:GetThread(threadName)
end

-- If this merchant has no items it is not a sellable merchant (such as an autohammer).
function Merchant:CanSellAtMerchant()
    return GetMerchantNumItems() > 0
end

local function setIsAutoSelling(isSelling, limit)
    if (isSelling ~= isAutoSelling) then
        isAutoSelling = isSelling
        if (isAutoSelling) then
            debugp("firing starting event")
            Addon:RaiseEvent(AUTO_SELL_START, limit)
        else
            debugp("firing ending event")
            Addon:RaiseEvent(AUTO_SELL_COMPLETE)
        end
    end
end

local function printSellSummary(num, value)
    if num > 0 then
        Addon:Print(L["MERCHANT_SOLD_ITEMS"], tostring(num), Addon:GetPriceString(value))
    end
end

-- Selling happens on a thread (coroutine) for UI responsiveness and to avoid being throttled by Blizzard.
-- We have to be careful of two scenarios when selling:
-- 1) The user is moving things around in the bag. This can mess up our selling. The mitigation is to wait anytime something
--    is being held by the cursor.
-- 2) As a result of #1, this can change what needs to be sold. Therefore we will evaluate every item just-in time to eliminate
--    Each sell cycle will go through every bag slot once and evaluate it for selling. If the user moves an item, it may be
--    skipped from the sell if it moved from a yet-to-be-checked slot to an already-checked slot. We could be more robust here
--    and watch for these events and re-scan, but that's making things significantly more complex for an edge case that doesnt
--    really matter. Worst-case, the user re-opens the merchant window.
-- Tiggered manually flag is to give additional feedback during the auto-selling.
function Merchant:AutoSell()
    -- Start selling on a thread.
    -- If coroutine already exists no need to create another one.
    if Addon:GetThread(threadName) then
        return
    end

    -- Create the coroutine.
    local thread = function ()
        local numSold = 0
        local totalValue = 0
        local profile = Addon:GetProfile();
        local sellLimitEnabled = profile:GetValue(Addon.c_Config_SellLimit)
        local sellLimitMaxItems = Addon.c_BuybackLimit
        local sellThrottle = profile:GetValue(Addon.c_Config_SellThrottle) or 1

        if (sellLimitEnabled) then
            setIsAutoSelling(true, sellLimitMaxItems)
        else
            setIsAutoSelling(true, 0)
        end

        -- If this merchant has no items it is not a sellable merchant (such as an autohammer), so terminate.
        if not Merchant:CanSellAtMerchant() then
            Addon:Debug("autosell", "Cannot sell at merchant, aborting autosell.")
            setIsAutoSelling(false)
            return
        end

        -- Loop through every bag slot once.
        debugp("Starting bag scan...")
        for bag=0, Addon:GetNumTotalEquippedBagSlots() do
            for slot=1, Addon:GetContainerNumSlots(bag) do                

                -- If the cursor is holding anything then we cant' sell. Yield and check again next cycle.
                -- We must do this before we get the item info, since the user may have changed what item is in this slot.
                while GetCursorInfo() do

                    -- It is possible the merchant window closes while the user is holding an item, so check for termination condition before yielding.
                    if not Merchant:IsMerchantOpen() then
                        printSellSummary(numSold, totalValue)
                        return
                    end

                    debugp("Cursor is holding something; waiting to sell..")
                    coroutine.yield()
                end

                -- Refresh and get the data entry for this slot.
                local _, entry =  xpcall(Addon.GetItemResultForBagAndSlot, CallErrorHandler, Addon, bag, slot, true)

                -- Determine if it is to be sold
                -- Result of 0 is no action, 1 is sell, 2 is delete.
                -- We will attempt to sell to-delete items if they are sellable.
                if entry and entry.Result.Action ~= Addon.ActionType.NONE and not entry.Item.IsUnsellable then

                    -- UseContainerItem is really just a limited auto-right click, and it will equip/use the item if we are not in a merchant window!
                    -- So before we do this, make sure the Merchant frame is still open. If not, terminate the coroutine.
                    if not Merchant:IsMerchantOpen() then
                        printSellSummary(numSold, totalValue)
                        setIsAutoSelling(false)
                        return
                    end

                    -- Still open, so OK to sell it.
                    if not Addon.IsDebug or not Addon:GetDebugSetting("simulate") then
                        Addon:UseContainerItem(bag, slot)
                        Addon:RaiseEvent(AUTO_SELL_ITEM, entry.Item.Link, numSold, sellLimitMaxItems)
                    else
                        Addon:Print("Simulating selling of: %s", tostring(item.Link))
                        Addon:RaiseEvent(AUTO_SELL_ITEM, entry.Item.Link, numSold, sellLimitMaxItems)
                    end

                    -- Record sell data
                    local netValue = entry.Item.TotalValue
                    Addon:Print(L["MERCHANT_SELLING_ITEM"], tostring(entry.Item.Link), Addon:GetPriceString(netValue), tostring(entry.Result.Rule))
                    numSold = numSold + 1
                    totalValue = totalValue + netValue

                    -- Add to history
                    Addon:AddEntryToHistory(entry.Item.Link, Addon.ActionType.SELL, entry.Result.Rule, entry.Result.RuleID, entry.Item.Count, netValue)

                    -- Check for sell limit
                    if sellLimitEnabled and sellLimitMaxItems <= numSold then
                        Addon:Print(L["MERCHANT_SELL_LIMIT_REACHED"], sellLimitMaxItems)
                        printSellSummary(numSold, totalValue)
                        setIsAutoSelling(false)
                        return
                    end

                    -- Yield per throttling setting.
                    if numSold % sellThrottle == 0 then
                        coroutine.yield()
                    end
                end
            end
        end

        printSellSummary(numSold, totalValue)
        setIsAutoSelling(false)
    end  -- Coroutine end

    -- Add thread to the thread queue and start it.
    Addon:AddThread(thread, threadName)
end

-- Confirms the popup if an item will be non-tradeable when sold, but only when we are auto-selling it.
function Merchant.AutoConfirmSellTradeRemoval(link)
    if Merchant:IsAutoSelling() then
        Addon:Print(L["MERCHANT_AUTO_CONFIRM_SELL_TRADE_REMOVAL"], link)
        SellCursorItem()
    end
end

function Merchant:OnInitialize()
    Addon:RegisterEvent("MERCHANT_SHOW", Merchant.OnMerchantShow)
    Addon:RegisterEvent("MERCHANT_CLOSED", Merchant.OnMerchantClosed)
    Addon:RegisterEvent("MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL", Merchant.AutoConfirmSellTradeRemoval)
end

function Merchant:OnTerminate()
end

Addon.Features.Merchant = Merchant