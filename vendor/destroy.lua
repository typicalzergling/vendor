-- Merchant event handling.
local AddonName, Addon = ...
local L = Addon:GetLocale()

-- This will hold the item link of whatever item we are trying to delete.
-- This is so when we do the delete confirmation, we only confirm deletion
-- for the item we are actually trying to delete.
local currentDestroyedItem = nil

-- Blizzard Protected DeleteCursorItem() in 9.0.2, which means we can't auto-delete items anymore.
-- So this will Find items and destroy them, and then report how many more items remain to be destroyed.
-- There's 1 destroy per event. RIP. Thx Blizzard.
-- Since destruction is quite serious we want to make sure any item we are destroying matches a destroy rule immediately prior
-- to destroying it. This is not as performant as it could be, but lets be real, destruction is a rare thing, so lets err on
-- the side of safety rather than performance.
function Addon:DestroyNextItem()
    for bag=0, NUM_TOTAL_EQUIPPED_BAG_SLOTS  do
        for slot=1, C_Container.GetContainerNumSlots(bag) do

            -- If the cursor is holding anything then we can't pick it up to delete. Yield and check again next cycle.
            if GetCursorInfo() then
                self:Print(L.ITEM_DESTROY_CANCELLED_CURSORITEM)
                return
            end

            -- Refresh and get the data entry for this slot.
            local entry =  xpcall(Addon.RefreshBagAndSlot, CallErrorHandler, Addon, bag, slot)
            if entry and entry.Result.Action == Addon.ActionType.DESTROY then
                currentDestroyedItem = entry.Item.Link
                self:Print(L.ITEM_DESTROY_CURRENT, tostring(currentDestroyedItem), tostring(entry.Result.Rule))
                if not Addon.IsDebug or not Addon:GetDebugSetting("simulate") then
                    C_Container.PickupContainerItem(bag, slot)
                    DeleteCursorItem()
                    Addon:AddEntryToHistory(currentDestroyedItem, Addon.ActionType.DESTROY, entry.Result.Rule, entry.Result.RuleID, entry.Item.Count, 0)
                else
                    self:Print("Simulating deletion of: %s", tostring(currentDestroyedItem))
                end
                currentDestroyedItem = nil

                -- Return now, because Blizzard only allows one deletion per action.
                return true
            end
        end
    end
    return false
end

-- Wrapper for item destruction and reporting items that remain.
function Addon:DestroyItems()
    if Addon:DestroyNextItem() then
        -- see if we have more items remaining
        local count, value, tosell, todestroy, sellitems, destroyitems = Addon:GetEvaluationStatus()
        if todestroy > 0 then
            self:Print(L.ITEM_DESTROY_MORE_ITEMS, todestroy)
        end
    else
        -- No items were destroyed.
        self:Print(L.ITEM_DESTROY_NONE_REMAIN)
    end
end
