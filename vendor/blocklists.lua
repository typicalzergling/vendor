local AddonName, Addon = ...
local L = Addon:GetLocale()

local BlockList = {}
function BlockList:Create(_listType, _profile)
    local instance = {
        listType = _listType,
        profile = _profile,
    };

   setmetatable(instance, self)
   self.__index = self
   return instance
end

function BlockList:Add(itemId)
    -- Validate ItemId
    if not Addon:IsItemIdValid(itemId) then
        Addon:Debug("blocklists", "Invalid Item ID: %s", tostring(itemId))
        return false
    end


    local list = self.profile:GetList(self.listType);
    if (not list[itemId]) then
        list[itemId] = true;
        Addon:Debug("blocklists", "Added %d to '%s' list", itemId, self.listType);
        self.profile:SetList(self.listType, list);
    end

    -- If it was in the other list, remove it.
    if self.listType == Addon.c_AlwaysSellList thenb
         -- Remove from Never Sell list
        local other = self.profile:GetList(Addon.c_NeverSellList);
        if (other[itemId]) then
            other[itemId] = nil;
            self.profile:SetList(Addon.c_NeverSellList, other);
            Addon:Debug("blocklists", "Removed %d to '%s' list", itemId, Addon.c_NeverSellList);
        end
    elseif self.listType == Addon.c_NeverSellList then
        -- Remove from Always sell list
        local other =self.profile:GetList(Addon.c_AlwaysSellList);
        if (other[itemId]) then
            other[itemId] = nil;
            self.profile:SetList(Addon.c_AlwaysSellList, other);
            Addon:Debug("blocklists", "Removed %d to '%s' list", itemId, Addon.c_AlwaysSellList);
        end
    end

    return false;
end

function BlockList:Remove(itemId)
    local list = self.profile:GetList(self.listType);
    if (list[itemId]) then
        list[itemId] = nil;
        Addon:Debug("BlockLists", "Removed %d from '%s' list", itemId, self.listType);
        self.profile:SetList(self.listType, list);
        return true;
    end
    return false;
end

function BlockList:Contains(itemId)
    local list = self.profile:GetList(self.listType);
    return list[itemId] == true;
end

function BlockList:GetContents()
    --todo: this should be a clone of the table
    return self.profile:GetList(self.listType);
end

function BlockList:GetType()
    return self.listType;
end

function BlockList:IsType(listType)
    return (self.listType == listType);
end


-- Manages the always-sell and never-sell blocklists.
-- Consider - adding "toggle" as a method on config can (and should) fire a config change.

-- Returns 1 if item was added to the list.
-- Returns 2 if item was removed from the list.
-- Returns nil if no action taken.
function Addon:ToggleItemInBlocklist(list, item)
    local id = self:GetItemIdFromString(item)
    if not id then return nil end

    -- Get existing blocklist id
    local existinglist = Addon:GetBlocklistForItem(id)

    -- Add it to the specified list.
    -- If it already existed, remove it from that list.
    if list == existinglist then
        Addon:GetList(list):Remove(id)
    else
        Addon:GetList(list):Add(id)
    end
end

-- Quick direct accessor for Never Sell List
function Addon:IsItemIdInNeverSellList(id)
    local list = self:GetList(self.c_NeverSellList);
    return list:Contains(id);

end

-- Quick direct accessor for Always Sell List
function Addon:IsItemIdInAlwaysSellList(id)
    local list = self:GetList(self.c_AlwaysSellList);
    return list:Contains(id);
end

-- Returns whether an item is in the list and which one.
function Addon:GetBlocklistForItem(item)
    local id = self:GetItemIdFromString(item)
    if id then
        if self:IsItemIdInNeverSellList(id) then
            return self.c_NeverSellList
        elseif self:IsItemIdInAlwaysSellList(id) then
            return self.c_AlwaysSellList
        else
            return nil
        end
    end
    return nil
end

-- Returns the list of items on the corresponding blocklist
function Addon:GetBlocklist(list)
    local list = self:GetList(list);
    return list:GetContents();
end

-- Permanently deletes the associated blocklist.
function Addon:ClearBlocklist(list)
    if ((list == self.c_AlwaysSellList) or
        (list == self.c_NeverSellList)) then
        Addon:GetProfile():SetList(list, {});
        -- Blocklist changed, so clear the Tooltip cache.
        self:ClearTooltipResultCache()
        return;
    end

    error(string.format("There is not '%s' list", list));
end

-- Retrieve the specified list
function Addon:GetList(listType)
    if ((listType == self.c_AlwaysSellList) or
        (listType == self.c_NeverSellList)) then
        return BlockList:Create(listType, self:GetProfile());
    end

    error(string.format("There is not '%s' list", listType));    
end

function Addon:RemoveInvalidEntriesFromBlocklist(listType)
    local list = self:GetList(listType)
    if not list then return end
    local contents = list:GetContents()
    if not contents then return end
    -- Find all bad entries.
    local invalid = {}
    for id, _ in pairs(contents) do
        if type(id) == "number" and not self:IsItemIdValid(id) then
            table.insert(invalid, id)
        end
    end

    -- Remove said bad entries.
    for _, id in pairs (invalid) do
        self:Debug("default", "Removing invalid ItemID: %s from %s list.", tostring(id), tostring(listType))
        list:Remove(id)
    end
end

function Addon:RemoveInvalidEntriesFromAllBlocklists()
    local success, msg = pcall(
    function () 
    self:RemoveInvalidEntriesFromBlocklist(self.c_NeverSellList)
    self:RemoveInvalidEntriesFromBlocklist(self.c_AlwaysSellList)
    end)
    Addon:Print("Success = %s, msg = %s", tostring(success), tostring(msg))
end