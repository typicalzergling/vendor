-- Merchant event handling.
local AddonName, Addon = ...
local L = Addon:GetLocale()

local Destroy = {
    NAME = "Destroy",
    VERSION = 1,
    DEPENDENCIES = {
    },
}

local DESTROY_START = Addon.Events.DESTROY_START
local DESTROY_COMPLETE = Addon.Events.DESTROY_COMPLETE

function Destroy:OnInitialize()
end

function Destroy:OnTerminate()
end

-- Blizzard Protected DeleteCursorItem() in 9.0.2, which means we can't auto-delete items anymore.
-- So this will Find items and destroy them, and then report how many more items remain to be destroyed.
-- There's 1 destroy per event. RIP. Thx Blizzard.
-- Since destruction is quite serious we want to make sure any item we are destroying matches a destroy rule immediately prior
-- to destroying it. This is not as performant as it could be, but lets be real, destruction is a rare thing, so lets err on
-- the side of safety rather than performance.
function Destroy:DestroyNextItem()
    Addon:RaiseEvent(DESTROY_START)
    for bag=0, Addon:GetNumTotalEquippedBagSlots()  do
        for slot=1, Addon:GetContainerNumSlots(bag) do

            -- If the cursor is holding anything then we can't pick it up to delete. Yield and check again next cycle.
            if GetCursorInfo() then
                Addon:Print(L.ITEM_DESTROY_CANCELLED_CURSORITEM)
                return
            end

            -- Refresh and get the data entry for this slot.
            local _, entry =  xpcall(Addon.RefreshBagAndSlot, CallErrorHandler, Addon, bag, slot, true)
            if entry and entry.Result.Action == Addon.ActionType.DESTROY then
                Addon:Print(L.ITEM_DESTROY_CURRENT, tostring(entry.Item.Link), tostring(entry.Result.Rule))
                if not Addon.IsDebug or not Addon:GetDebugSetting("simulate") then
                    Addon:PickupContainerItem(bag, slot)
                    DeleteCursorItem()
                    Addon:AddEntryToHistory(entry.Item.Link, Addon.ActionType.DESTROY, entry.Result.Rule, entry.Result.RuleID, entry.Item.Count, 0)
                else
                    Addon:Print("Simulating deletion of: %s", tostring(entry.Item.Link))
                end

                -- Return now, because Blizzard only allows one deletion per action.
                Addon:RaiseEvent(DESTROY_COMPLETE, entry.Item.Link)
                return true
            end
        end
    end
    Addon:RaiseEvent(DESTROY_COMPLETE)
    return false
end

-- Wrapper for item destruction
function Destroy:DestroyItems()
    if not Destroy:DestroyNextItem() then
        -- No items were destroyed.
        Addon:Print(L.ITEM_DESTROY_NONE_REMAIN)
    end
end


Addon.Features.Destroy = Destroy