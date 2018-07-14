-- Merchant event handling.
local L = Vendor:GetLocalizedStrings()

local threadName = "ItemSeller"

-- When the merchant window is opened, we will attempt to auto repair and sell.
function Vendor:OnMerchantShow()
    self:Debug("Merchant opened.");

    -- Do auto-repair
    self:AutoRepair()

    -- Do auto-selling
    self:AutoSell()
end

-- Believe this is fired when attempting to sell an item that can still be traded to someone else.
-- For now we will capture the event.
function Vendor:OnEndBoundTradeable(event, ...)
	self:Print("OnEndBoundTradeable fired. Arguments:")
	for k, v in ipairs({...}) do
		self:Print("    Arg %s: %s", tostring(k), tostring(v))
	end
	
	-- If this is what we think it is, this may auto-confirm it while we are selling:
	-- ConfirmBindOnUse()
end

-- For checking to make sure merchant window is open prior to selling anything.
function Vendor:IsMerchantOpen()
    if MerchantFrame and MerchantFrame.IsVisible then
        return MerchantFrame:IsVisible()
    else
        self:Debug("MerchantFrame not found! Assuming it is not visible.")
        return false
    end
end

-- Do Autorepair. If using guild funds and guild funds don't cover the repair, we will use our own funds.
function Vendor:AutoRepair()
    local config = self:GetConfig()
    if not config:GetValue("autorepair") then return end

    local cost, canRepair = GetRepairAllCost()
    if canRepair then
        if config:GetValue("guildrepair") and CanGuildBankRepair() and GetGuildBankWithdrawMoney() >= cost then
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
function Vendor:IsAutoSelling()
	-- We are selling if we have a thread active.
	return not not self:GetThread(threadName)
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
function Vendor:AutoSell()
    if not self:GetConfig():GetValue("autosell") then return end

    -- Start selling on a thread.
    -- If coroutine already exists no need to create another one.
    if self:GetThread(threadName) then
        return
    end

    -- Create the coroutine.
    local thread = coroutine.create( function ()
        local numSold = 0
        local totalValue = 0
        local config = self:GetConfig()

        -- Loop through every bag slot once.
        for bag=0, NUM_BAG_SLOTS do
            for slot=1, GetContainerNumSlots(bag) do

                -- If the cursor is holding anything then we cant' sell. Yield and check again next cycle.
                -- We must do this before we get the item info, since the user may have changed what item is in this slot.
                while GetCursorInfo() do

                    -- It is possible the merchant window closes while the user is holding an item, so check for termination condition before yielding.
                    if not self:IsMerchantOpen() then
                        if numSold > 0 then
                            self:Print(string.format(L["MERCHANT_SOLD_ITEMS"], tostring(numSold), self:GetPriceString(totalValue)))
                        end
                        return
                    end

                    self:Debug("Cursor is holding something; waiting to sell..")
                    coroutine.yield()
                end

                -- Get Item properties and run sell rules.
                local item = self:GetItemPropertiesFromBag(bag, slot)
                local sellItem = self:EvaluateItemForSelling(item)
                if item then
                    self:Debug("Evaluated: "..tostring(item.Link).." = "..tostring(sellItem))
                end

                -- Determine if it is to be sold
                if sellItem then

                    -- UseContainerItem is really just a limited auto-right click, and it will equip/use the item if we are not in a merchant window!
                    -- So before we do this, make sure the Merchant frame is still open. If not, terminate the coroutine.
                    if not self:IsMerchantOpen() then
                        if numSold > 0 then
                            self:Print(string.format(L["MERCHANT_SOLD_ITEMS"], tostring(numSold), self:GetPriceString(totalValue)))
                        end
                        return
                    end

                    -- Still open, so OK to sell it.
                    self:Print(string.format(L["MERCHANT_SELLING_ITEM"], tostring(item.Link), self:GetPriceString(item.NetValue)))
                    UseContainerItem(bag, slot)
                    numSold = numSold + 1
                    totalValue = totalValue + item.NetValue

                    -- Yield per throttling setting.
                    if numSold % config:GetValue("sell_throttle") == 0 then
                        coroutine.yield()
                    end
                end
            end
        end

        if numSold > 0 then
            self:Print(string.format(L["MERCHANT_SOLD_ITEMS"], tostring(numSold), self:GetPriceString(totalValue)))
        end
    end)  -- Coroutine end

    -- Add thread to the thread queue and start it.
    self:AddThread(thread, threadName)
end
