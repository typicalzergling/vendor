-- Merchant event handling.
local AddonName, Addon = ...
local L = Addon:GetLocale()
local Config = Addon:GetConfig()

local function PrintDestroySummary(num)
    Addon:Print(L.ITEM_DESTROY_SUMMARY, tostring(num))
end

-- This will hold the item link of whatever item we are trying to delete.
-- This is so when we do the delete confirmation, we only confirm deletion
-- for the item we are actually trying to delete.
local currentDestroyedItem = nil

-- Blizzard Protected DeleteCursorItem() in 9.0.2, which means we can't auto-delete items anymore.
-- So this will
function Addon:DestroyItems()
    self:Print(L.ITEM_DESTROY_STARTED)
    local numDestroyed = 0
    for bag=0, NUM_BAG_SLOTS do
        for slot=1, GetContainerNumSlots(bag) do

            -- If the cursor is holding anything then we can't pick it up to delete. Yield and check again next cycle.
            if GetCursorInfo() then
                self:Print(L.ITEM_DESTROY_CANCELLED_CURSORITEM)
                return
            end

            -- Get Item properties and run sell rules.
            local item, itemCount = self:GetItemPropertiesFromBag(bag, slot)
            local result = self:EvaluateItem(item)

            -- Result of 0 is no action, 1 is sell, 2 is must be deleted.
            -- So we only try to sell if Result is exactly 1.
            if result == 2 then
                currentDestroyedItem = item.Link
                self:Print(L.ITEM_DESTROY_CURRENT, tostring(currentDestroyedItem))
                if not Addon.IsDebug or not Addon:GetDebugSetting("simulate") then
                    PickupContainerItem(bag, slot)
                    DeleteCursorItem()
                else
                    self:Print("Simulating deletion of: %s", tostring(currentDestroyedItem))
                end
                currentDestroyedItem = nil
                numDestroyed = numDestroyed + 1
            end
        end
    end
    PrintDestroySummary(numDestroyed)
end
