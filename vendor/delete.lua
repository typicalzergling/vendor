-- Merchant event handling.
local AddonName, Addon = ...
local L = Addon:GetLocale()
local Config = Addon:GetConfig()

local threadName = Addon.c_ItemDeleterThreadName


-- This returns true if we are in the middle of autoselling.
function Addon:IsDeleting()
    -- We are deleting if we have a thread active.
    return not not self:GetThread(threadName)
end

local function PrintDeleteSummary(num)
    if num > 0 then
        Addon:Print(L["DELETE_DELETED_ITEMS"], tostring(num))
    end
end

-- This will hold the item link of whatever item we are trying to delete.
-- This is so when we do the delete confirmation, we only confirm deletion
-- for the item we are actually trying to delete.
local currentDeletedItem = nil

function Addon:AutoDeleteItems()
    -- Start deleting
    if self:GetThread(threadName) then
        return
    end

    -- Create the coroutine.
    local thread = function ()
        local numDeleted = 0

        -- Loop through every bag slot once.
        for bag=0, NUM_BAG_SLOTS do
            for slot=1, GetContainerNumSlots(bag) do

                -- If the cursor is holding anything then we can't pick it up to delete. Yield and check again next cycle.
                while GetCursorInfo() do
                    self:Debug("delete", "Cursor is holding something; waiting to delete..")
                    coroutine.yield()
                end

                -- Get Item properties and run sell rules.
                local item, itemCount = self:GetItemPropertiesFromBag(bag, slot)
                local result = self:EvaluateItem(item)

                -- Result of 0 is no action, 1 is sell, 2 is must be deleted.
                -- So we only try to sell if Result is exactly 1.
                if result == 2 then
                    currentDeletedItem = item.Link
                    self:Print(L["DELETE_DELETING_ITEM"], tostring(currentDeletedItem))
                    PickupContainerItem(bag, slot)
                    DeleteCursorItem()
                    currentDeletedItem = nil
                    numDeleted = numDeleted + 1
                    
                    -- Yield per throttling setting.
                    if numDeleted % self.c_DeleteThottle == 0 then
                        coroutine.yield()
                    end
                end
            end
        end

        PrintDeleteSummary(numDeleted)
    end  -- Coroutine end

    -- Add thread to the thread queue and start it.
    self:AddThread(thread, threadName)
end

-- Add Thread Callback, when Itemseller is done running, we will run the deleter.
-- This avoids both of them running simultaneously.
Addon:AddThreadCompletionCallback(Addon.c_ItemSellerThreadName, function() Addon:AutoDeleteItems() end)
