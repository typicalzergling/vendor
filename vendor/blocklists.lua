local AddonName, Addon = ...
local L = Addon:GetLocale()
local ListType = Addon.ListType
local SystemListId = Addon.SystemListId
local customListDefintions = Addon.SavedVariable:new("CustomLists")
local EMPTY = {}

local function isValidListType(listType)
    return (listType == ListType.CUSTOM) or
        (listType == ListType.EXTENSION) or
        (listType == ListType.SELL) or
        (listType == ListType.KEEP) or
        (listType == listType.DESTORY)
end

local function isSystemListType(listType)
    return (listType == ListType.SELL) or
        (listType == ListType.KEEP) or
        (listType == ListType.DESTROY)
end

local function getListFromProfile(listType)
    assert(isSystemListType(listType), "Only system lists are kept in the profile")
    local profile = Addon:GetProfileManager():GetProfile()
    return profile:GetList(listType)
end

local function commitListToProfile(listType, list)
    assert(isSystemListType(listType), "Only system lists are kept in the profile")
    local profile = Addon:GetProfileManager():GetProfile()
    profile:SetList(listType, list or EMPTY)
end

local function getExtensionList(listId)
end

local function getCustomList(listName)
end

local function commitCustomList(listName, list)
end

local function removeFromList(list, itemId)
    if (not list or (type(list) ~= "table")) then
        return false
    end

    if (list[itemId]) then
        list[itemId] = nil
        return true
    end

    return false
end

local function addToList(list, itemId)
    assert(type(list) == "table", "the list should already be defined")
    if (not list[itemId]) then
        list[itemId] = true
        return true
    end    
    return false
end

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
        Addon:Debug("blocklists", "Invalid Item ID: %s", itemId)
        return false
    end

    table.forEach(self, print, "BlockList:Add")
    local list = self.get()
    if (addToList(list, itemId)) then
        Addon:Debug("blocklists", "Added %s to '%s' list [%s]", itemId, self.listType. self.listId);
        self:commit(list)
    end

    return false;
end

function BlockList:Remove(itemId)
    local list = self.get()
    if (removeFromList(list, itemId)) then
        Addon:Debug("blocklists", "Removed %s from '%s' list [%s]", itemId, self.listType, self.listId)
        self.commit(list)
        return true
    end
    return false;
end

function BlockList:Contains(itemId)
    local list = self.get() or EMPTY
    return list[itemId] == true;
end

function BlockList:GetContents()
    local list = self.get();
    return list or EMPTY
end

function BlockList:GetItems()
    local items = {};
    local ids = self.get() or EMPTY
    for id, _ in pairs(ids) do
        if (C_Item.DoesItemExistByID(id)) then
            table.insert(items, id);
        end
    end
    return items;
end

function BlockList:GetType()
    return self.listType;
end

function BlockList:IsType(listType)
    return (self.listType == listType)
end

function BlockList:GetId()
    return self.listId
end

function BlockList:Clear()
    Addon:Debug("blocklists", "Cleared list '%s' [%s]", self.listType, self.listId)
    self:commit(EMPTY)
end

function BlockList:RemoveInvalid()
    local ids = self.get() or EMPTY
    local prune = {}
    for id, state in pairs(ids) do
        if ((type(id) ~= "number") or not state or not C_Item.DoesItemExistByID(id)) then
            table.insert(prune, id)
        end        
    end
    
    if (table.getn(prune)) then
        Addon:Debug("blocklists", "Pruining %d invalid items from the list '%s' [%s]", table.getn(prune), self.listType, self.listId)
        for _, id in ipairs(prune) do
            list[id] = nil
        end
        self:commit(list)
    end
end

local SystemBlockList = {}

function SystemBlockList:GetOthers()
    local lists = {}
    if (self.listType == ListType.SELL) then
        lists[ListType.KEEP] = getListFromProfile(ListType.KEEP)
        lists[ListType.DESTROY] = getListFromProfile(ListType.DESTROY)
    elseif (self.listType == ListType.KEEP) then
        lists[ListType.SELL] = getListFromProfile(ListType.SELL)
        lists[ListType.DESTROY] = getListFromProfile(ListType.DESTROY)
    else
        lists[ListType.SELL] = getListFromProfile(ListType.SELL)
        lists[ListType.KEEP] = getListFromProfile(ListType.KEEP)
    end

    return lists
end

function SystemBlockList:Add(itemId)
    table.forEach(self, print, "SystemBlockList:Add")
    -- Validate ItemId
    if not Addon:IsItemIdValid(itemId) then
        Addon:Debug("blocklists", "Invalid Item ID: %s", tostring(itemId))
        return false
    end

    local list = self.get()
    if (addToList(list, itemId)) then
        Addon:Debug("blocklists", "Added %d to '%s' list [%s]", itemId, self.listType, self.listId);
        self.commit(list)
    end

    for ty, list in pairs(self:GetOthers()) do 
        if (removeFromList(list, itemId)) then
            commitListToProfile(ty, list)
        end
    end
end

--[[static]] function SystemBlockList:New(listType)
    assert(isSystemListType(listType), "The list type must be a system list")

    -- Determine the list id
    if (listType == ListType.SELL) then
        listId = SystemListId.SELL or SystemListId.ALWAYS
    elseif (listType == ListType.KEEP) then
        listId = SystemListId.KEEP or SystemListId.NEVER
    else
        listId = SystemListId.DESTROY
    end

    -- Create our instance.
    local instance = 
    {
        listType = listType,
        listId = listId,
        commit = function(list) 
            commitListToProfile(listType, list) 
        end,
        get = function()
            return getListFromProfile(listType)
        end,
    }

    return Addon.object("SystemBlockList", instance, table.merge(BlockList, SystemBlockList))
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

    -- Check if the list is Sell and the item is Unsellable
    -- If so, change the list type to Destroy
    if list == Addon.ListType.SELL then
        local isUnsellable = select(11, GetItemInfo(id)) == 0
        if isUnsellable then
            self:Print(L.CMD_LISTTOGGLE_UNSELLABLE, link)
            list = Addon.ListType.DESTROY
        end
    end

    -- Add it to the specified list.
    -- If it already existed, remove it from that list.
    if list == existinglist then
        Addon:GetList(list):Remove(id)
        return 2
    else
        Addon:GetList(list):Add(id)
        return 1
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
            if (isSystemListType(list)) then
                if Addon:IsItemInList(id, list) then
                    return list
                end
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
    if (isSystemListType(list)) then
        SystemBlockList:New(listType):Clear()
        self:ClearTooltipResultCache()
        return
    end

    error(string.format("There is not '%s' list", list));
end

-- Retrieve the specified list
function Addon:GetList(listType)
    if (isSystemListType(listType)) then
        return SystemBlockList:New(listType)        
    end

    error(string.format("There is no '%s' list", listType or ""));    
end

function Addon:RemoveInvalidEntriesFromBlocklist(listType)
    local list = self:GetList(listType)
    list:RemoveInvalid()
end

function Addon:RemoveInvalidEntriesFromAllBlocklists()
    self:RemoveInvalidEntriesFromBlocklist(ListType.SELL)
    self:RemoveInvalidEntriesFromBlocklist(ListType.KEEP)
    self:RemoveInvalidEntriesFromBlocklist(ListType.DESTROY)
end