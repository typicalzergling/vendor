local AddonName, Addon = ...
local L = Addon:GetLocale()
local ListType = Addon.ListType
local SystemListId = Addon.SystemListId
local EMPTY = {}

-- TODO: Clear result cache anytime any block list changes
-- Since that can alter the result of one or more rules.
-- Addon:ClearItemResultCache()
-- Since block lists are part of the profile, we can simplify this further to...
-- Anytime the active profile changes or the profile changes, clear the result cache.

local function isValidListType(listType)
    return (listType == ListType.CUSTOM) or
        (listType == ListType.EXTENSION) or
        (listType == ListType.SELL) or
        (listType == ListType.KEEP) or
        (listType == ListType.DESTORY)
end

local function isSystemListType(listType)
    return (listType == ListType.SELL) or
        (listType == ListType.KEEP) or
        (listType == ListType.DESTROY)
end

local function mapListIdToListType(listId) 
    -- Determine the list id
    if ((listId == SystemListId.SELL) or (listId == SystemListId.ALWAYS)) then
        return ListType.SELL
    elseif ((listId == SystemListId.KEEP) or (listId == SystemListId.NEVER)) then
        return ListType.KEEP
    elseif (listId == SystemListId.DESTROY) then
        return ListType.DESTROY
    end

    return nil
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

local function getCustomList(listId)
    assert(string.len(listId) ~= 0, "The list must have an ID")
    local listMgr = Addon:GetListManager()
    local items, exists =  listMgr:GetListContents(listId)
    assert(exists)
    return items or EMPTY
end

local function commitCustomList(listId, list)
    assert(string.len(listId) ~= 0, "The list must have an ID") 
    local listMgr = Addon:GetListManager()
    listMgr:UpdateListContents(listId, list)
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
    Addon:Debug("test", "BlockList:Add(%s, %s)", self, itemId)
    -- Validate ItemId
    if not C_Item.DoesItemExistByID(itemId) then
        Addon:Debug("blocklists", "Invalid Item ID: %s", itemId)
        return false
    end

    local list = self.get()
    if (addToList(list, itemId)) then
        Addon:Debug("blocklists", "Added %s to '%s' list [%s]", itemId, self.listType, self.listId);
        self.commit(list)
    end

    -- Remove cached items with this id so they refresh.
    Addon:ClearItemResultCacheByItemId(itemId)
    return false;
end

function BlockList:Remove(itemId)
    local list = self.get()
    if (removeFromList(list, itemId)) then
        Addon:Debug("blocklists", "Removed %s from '%s' list [%s]", itemId, self.listType, self.listId)
        self.commit(list)
        return true
    end

    -- Remove cached items with this id so they refresh.
    Addon:ClearItemResultCacheByItemId(itemId)
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

function BlockList:IsReadOnly()
    return false;
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

    return Addon.object("SystemBlockList", instance, Addon.TableMerge(BlockList, SystemBlockList))
end

local CustomBlockList = {}

function CustomBlockList:GetName()
    return (self.listName or "<unknown>")
end

--[[static]] function CustomBlockList:New(id, name)
    assert(string.len(id) ~= 0, "A custom block list must have a name")
    assert(string.len(name) ~= 0, "A custom block list must have a name")

    local instance = 
    {
        listType = ListType.CUSTOM,
        listId = id,
        listName = name,
        commit = function(list)            
            commitCustomList(id, list)
        end,
        get = function()
            return getCustomList(id)
        end
    }

    return Addon.object("CustomBlockList", instance, Addon.TableMerge(BlockList, CustomBlockList))
end

local ExtensionList = {}

function ExtensionList:IsReadOnly()
    return true
end

function ExtensionList:GetSource()
    return self.source.Name or "<unknown>"
end

--[[static]] function ExtensionList:New(list)
    local instance = 
    {
        listType = ListType.EXTENSION,
        listId = list.Id,
        listName = list.Name,
        source = list.Extension,
        get = function()
            local items = list.Items
            if (type(items) == "table") then
                return items
            elseif (type(items) == "function") then
                local result, items = xpcall(items, CallErrorHandler)
                if (not result) then
                    return EMPTY
                else
                    local ids = {}
                    for _, id in ipairs(items or EMPTY) do
                        if (type(id) == "number") then
                            ids[id] = true
                        end
                    end
                    return ids
                end
            else
                return EMPTY
            end
        end,
        commit = function()
            assert(false, "Extension lists are read-only and should never be modified.")
        end
    }

    return Addon.object("ExtensionList", instance, Addon.TableMerge(BlockList, ExtensionList))
end


-- Manages the always-sell and never-sell blocklists.
-- Consider - adding "toggle" as a method on config can (and should) fire a config change.

-- Returns 1 if item was added to the list.
-- Returns 2 if item was removed from the list.
-- Returns nil if no action taken.
function Addon:ToggleItemInBlocklist(list, item)
    local id = self:GetItemIdFromString(item)
    if not id then return nil end

    local systemLists = Addon:GetSystemLists()

    -- Find the list the item is in
    local existingList
    for listId, list in pairs(systemLists) do
        if (list:Contains(id)) then
            existingList = listId
            break
        end
    end

    -- Check if the list is Sell and the item is Unsellable
    -- If so, change the list type to Destroy
    if list == Addon.SystemListId.ALWAYS then
        local isUnsellable = select(11, GetItemInfo(id)) == 0
        if isUnsellable then
            self:Print(L.CMD_LISTTOGGLE_UNSELLABLE, link)
            list = Addon.SystemListId.DESTROY
        end
    end

    -- Add it to the specified list.
    -- If it already existed, remove it from that list.
    if existingList and list == existinglist then
        systemLists[list]:Remove(id)
        Addon:ClearItemResultCacheByItemId(id)
        return 2
    else
        systemLists[list]:Add(id)
        Addon:ClearItemResultCacheByItemId(id)
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
        -- Clear the entire cache in this case.
        Addon:ClearItemResultCache()
        return
    end

    error(string.format("There is not '%s' list", list));
end

--[[
function Addon:GetList(listType)
    -- Check for system list
    if (isSystemListType(listType)) then
        return SystemBlockList:New(listType)        
    end

    if (type(listType) == "string") then        
        -- Check for system list
        for name, value in pairs(ListType) do
            if (isSystemListType(value) and (listType == string.lower(value))) then
                return SystemBlockList:New(value)
            end
        end

        local systemListType = mapListIdToListType(listType);
        if (systemListType) then
            return SystemBlockList:New(systemListType)
        end

        -- Check for custom list
        local list = Addon:GetListManager():GetList(listType)
        if (list) then
            return CustomBlockList:New(list.Id, list.Name)    
        end
        
        -- Check for extension list
        local list = Addon:GetExtensionManger():GetList(listType)
        if (list) then
            return ExtensionList:New(list)
        end
    end

    Addon:Debug("lists", "There is no '%s' list", listType or "");
    return nil
end

function Addon:RemoveInvalidEntriesFromBlocklist(listType)
    local list = self:GetList(listType)
    list:RemoveInvalid()
en]]

function Addon:RemoveInvalidEntriesFromAllBlocklists()
    self:RemoveInvalidEntriesFromBlocklist(ListType.SELL)
    self:RemoveInvalidEntriesFromBlocklist(ListType.KEEP)
    self:RemoveInvalidEntriesFromBlocklist(ListType.DESTROY)
end