-- Merchant event handling.
local AddonName, Addon = ...
local L = Addon:GetLocale()

local threadName = Addon.c_ItemSellerThreadName
local AUTO_SELL_START = Addon.Events.AUTO_SELL_START
local AUTO_SELL_COMPLETE = Addon.Events.AUTO_SELL_COMPLETE
local AUTO_SELL_ITEM = Addon.Events.AUTO_SELL_ITEM

local isMerchantOpen = false
local isAutoSelling = false

-- When the merchant window is opened, we will attempt to auto repair and sell.
function Addon:OnMerchantShow()
    self:Debug("autosell", "Merchant opened.")
    isMerchantOpen = true
    local profile = self:GetProfile();

    -- Do auto-repair if enabled
    if profile:GetValue(Addon.c_Config_AutoRepair) then
        self:AutoRepair()
    end

    -- Do auto-selling if enabled
    if profile:GetValue(Addon.c_Config_AutoSell) then
        self:AutoSell()
    end
end

function Addon:OnMerchantClosed()
    self:Debug("autosell", "Merchant closed.")
    isMerchantOpen = false
end

-- For checking to make sure merchant window is open prior to selling anything.
function Addon:IsMerchantOpen()
    if Addon.IsDebug and Addon:GetDebugSetting("simulate") then return true end
    return isMerchantOpen
end

-- Do Autorepair. If using guild funds and guild funds don't cover the repair, we will use our own funds.
function Addon:AutoRepair()
    local cost, canRepair = GetRepairAllCost()
    if canRepair then
        local profile = self:GetProfile();
        -- Guild repair is not supported on Classic. The API method "CanGuidlBankRepair" is missing.
        if not Addon.IsClassic and profile:GetValue(Addon.c_Config_GuildRepair) and CanGuildBankRepair() and GetGuildBankWithdrawMoney() >= cost then
            -- use guild repairs
            RepairAllItems(true)
            self:Print(string.format(L["MERCHANT_REPAIR_FROM_GUILD_BANK"], self:GetPriceString(cost)))
        else
            -- use own funds
            RepairAllItems()
            self:Print(string.format(L["MERCHANT_REPAIR_FROM_SELF"], self:GetPriceString(cost)))
        end
    end
end

-- This returns true if we are in the middle of autoselling.
function Addon:IsAutoSelling()
    -- We are selling if we have a thread active.
    return not not self:GetThread(threadName)
end

-- If this merchant has no items it is not a sellable merchant (such as an autohammer).
function Addon:CanSellAtMerchant()
    return GetMerchantNumItems() > 0
end

local function setIsAutoSelling(isSelling, limit)
    if (isSelling ~= isAutoSelling) then
        isAutoSelling = isSelling
        if (isAutoSelling) then
            Addon:Debug("autosell", "firing starting event")
            Addon:RaiseEvent(AUTO_SELL_START, limit)
        else
            Addon:Debug("autosell", "firing ending event")
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
function Addon:AutoSell()
    -- Start selling on a thread.
    -- If coroutine already exists no need to create another one.
    if self:GetThread(threadName) then
        return
    end

    -- Create the coroutine.
    local thread = function ()
        local numSold = 0
        local totalValue = 0
        local profile = Addon:GetProfile();
        local sellLimitEnabled = profile:GetValue(Addon.c_Config_SellLimit)
        local sellLimitMaxItems = Addon.c_BuybackLimit
        local sellThrottle = profile:GetValue(Addon.c_Config_SellThrottle)

        if (sellLimitEnabled) then
            setIsAutoSelling(true, sellLimitMaxItems)
        else
            setIsAutoSelling(true, 0)
        end

        -- If this merchant has no items it is not a sellable merchant (such as an autohammer), so terminate.
        if not Addon:CanSellAtMerchant() then
            Addon:Debug("autosell", "Cannot sell at merchant, aborting autosell.")
            setIsAutoSelling(false)
            return
        end

        -- Loop through every bag slot once.
        self:Debug("autosell", "Starting bag scan...")
        for bag=0, NUM_BAG_SLOTS do
            for slot=1, C_Container.GetContainerNumSlots(bag) do                


                -- If the cursor is holding anything then we cant' sell. Yield and check again next cycle.
                -- We must do this before we get the item info, since the user may have changed what item is in this slot.
                while GetCursorInfo() do

                    -- It is possible the merchant window closes while the user is holding an item, so check for termination condition before yielding.
                    if not self:IsMerchantOpen() then
                        printSellSummary(numSold, totalValue)
                        return
                    end

                    self:Debug("autosell", "Cursor is holding something; waiting to sell..")
                    coroutine.yield()
                end

                -- Get Item properties and evaluate
                local _, item, itemCount = xpcall(Addon.GetItemPropertiesFromBagAndSlot, CallErrorHandler, Addon, bag, slot)
                local _, result, ruleid, rule = xpcall(Addon.EvaluateItem, CallErrorHandler, Addon, item)

                -- Determine if it is to be sold
                -- Result of 0 is no action, 1 is sell, 2 is delete.
                -- We will attempt to sell to-delete items if they are sellable.
                if result >= 1 and not item.IsUnsellable then
                    -- UseContainerItem is really just a limited auto-right click, and it will equip/use the item if we are not in a merchant window!
                    -- So before we do this, make sure the Merchant frame is still open. If not, terminate the coroutine.
                    if not self:IsMerchantOpen() then
                        printSellSummary(numSold, totalValue)
                        setIsAutoSelling(false)
                        return
                    end

                    -- Still open, so OK to sell it.
                    if not Addon.IsDebug or not Addon:GetDebugSetting("simulate") then
                        C_Container.UseContainerItem(bag, slot)
                        Addon:RaiseEvent(AUTO_SELL_ITEM, item.Link, numSold, sellLimitMaxItems)
                    else
                        self:Print("Simulating selling of: %s", tostring(item.Link))
                        Addon:RaiseEvent(AUTO_SELL_ITEM, item.Link, numSold, sellLimitMaxItems)
                    end

                    -- Record sell data
                    local netValue = item.UnitValue * itemCount
                    self:Print(L["MERCHANT_SELLING_ITEM"], tostring(item.Link), self:GetPriceString(netValue), tostring(rule))
                    numSold = numSold + 1
                    totalValue = totalValue + netValue

                    -- Add to history
                    Addon:AddEntryToHistory(item.Link, Addon.ActionType.SELL, rule, ruleid, itemCount, netValue)

                    -- Check for sell limit
                    if sellLimitEnabled and sellLimitMaxItems <= numSold then
                        self:Print(L["MERCHANT_SELL_LIMIT_REACHED"], sellLimitMaxItems)
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
    self:AddThread(thread, threadName)
end

-- Confirms the popup if an item will be non-tradeable when sold, but only when we are auto-selling it.
function Addon:AutoConfirmSellTradeRemoval(link)
    if self:IsAutoSelling() then
        self:Print(L["MERCHANT_AUTO_CONFIRM_SELL_TRADE_REMOVAL"], link)
        SellCursorItem()
    end
end

-- Convert price to a pretty string
-- To reduce spam we don't show copper unless it is the only unit of measurement (i.e. < 1 silver)
-- Gold:    FFFFFF00
-- Silver:  FFFFFFFF
-- Copper:  FFAE6938
function Addon:GetPriceString(price, all)
    if not price then
        return "<missing>"
    end

    local copper, silver, gold, str
    copper = price % 100
    price = math.floor(price / 100)
    silver = price % 100
    gold = math.floor(price / 100)

    str = {}
    if gold > 0 or all then
        table.insert(str, "|cFFFFD100")
        table.insert(str, gold)
        table.insert(str, "|r|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:4:0|t  ")

        table.insert(str, "|cFFE6E6E6")
        table.insert(str, string.format("%02d", silver))
        table.insert(str, "|r|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:4:0|t  ")

        if (all) then
            table.insert(str, "|cFFC8602C")
            table.insert(str, copper)
            table.insert(str, "|r|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:4:0|t")
        end

    elseif silver > 0 then
        table.insert(str, "|cFFE6E6E6")
        table.insert(str, silver)
        table.insert(str, "|r|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:4:0|t  ")

    else
        -- Show copper if that is the only unit of measurement.
        table.insert(str, "|cFFC8602C")
        table.insert(str, copper)
        table.insert(str, "|r|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:4:0|t")
    end

    -- Return the concatenated string using the efficient function for it
    return table.concat(str)
end