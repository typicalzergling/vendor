local AddonName, Addon = ...
local L = Addon:GetLocale()
local ListType = Addon.ListType;

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

    -- If this is a built in list type, remove the item from the other list types.
    if self.listType == ListType.SELL or self.listType == ListType.KEEP or self.listType == ListType.DESTROY then
        if self.listType ~= ListType.SELL then
            Addon:GetList(ListType.SELL):Remove(itemId)
        end
        if self.listType ~= ListType.KEEP then
            Addon:GetList(ListType.KEEP):Remove(itemId)
        end
        if self.listType ~= ListType.DESTROY then
            Addon:GetList(ListType.DESTROY):Remove(itemId)
        end
    end

    return false;
end

function BlockList:Remove(itemId)
    local list = self.profile:GetList(self.listType);
    if (list[itemId]) then
        list[itemId] = nil;
        Addon:Debug("blocklists", "Removed %d from '%s' list", itemId, self.listType);
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

function BlockList:GetItems()
    local items = {};
    local ids = self.profile:GetList(self.listType);
    if (ids) then
        for id in pairs(ids) do
            if (C_Item.DoesItemExistByID(id)) then
                table.insert(items, id);
            end
        end
    end
    return items;
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

-- Generic list accessor
function Addon:IsItemInList(id, listType)
    local list = Addon:GetList(listType)
    if not list then return false end
    return list:Contains(id)
end

-- Quick direct accessor for Keep List
function Addon:IsItemIdInNeverSellList(id)
    return self:IsItemInList(id, ListType.KEEP)
end

-- Quick direct accessor for Sell List
function Addon:IsItemIdInAlwaysSellList(id)
    return self:IsItemInList(id, ListType.SELL)
end

-- Quick direct accessor for Destroy List
function Addon:IsItemIdInAlwaysDestroyList(id)
    return self:IsItemInList(id, ListType.DESTROY)
end

-- Returns whether an item is in the list and which one.
function Addon:GetBlocklistForItem(item)
    local id = self:GetItemIdFromString(item)
    if id then
        for _, list in pairs(ListType) do
            if Addon:IsItemInList(id, list) then
                return list
            end
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
    if ((list == ListType.SELL) or
        (list == ListType.KEEP) or
        (list == ListType.DESTROY)) then
        Addon:GetProfile():SetList(list, {});
        -- Blocklist changed, so clear the Tooltip cache.
        self:ClearTooltipResultCache()
        return;
    end
    error(string.format("There is not '%s' list", list));
end

-- Retrieve the specified list
function Addon:GetList(listType)
    if ((listType == ListType.SELL) or
        (listType == ListType.KEEP) or
        (listType == ListType.DESTROY)) then
        return BlockList:Create(listType, self:GetProfile());
    end

    error(string.format("There is no '%s' list", listType or ""));    
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
        Addon:Debug("blocklists", "Removing invalid ItemID: %s from %s list.", tostring(id), tostring(listType))
        list:Remove(id)
    end
end

function Addon:RemoveInvalidEntriesFromAllBlocklists()
    self:RemoveInvalidEntriesFromBlocklist(ListType.SELL)
    self:RemoveInvalidEntriesFromBlocklist(ListType.KEEP)
    self:RemoveInvalidEntriesFromBlocklist(ListType.DESTROY)
end