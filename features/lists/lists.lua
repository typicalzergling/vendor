local _, Addon = ...
local locale = Addon:GetLocale()
local ListType = Addon.ListType
local SystemListId = Addon.SystemListId

local Lists = { 
    NAME = "Lists", 
    VERSION = 1, 
    DEPENDECIES = { "Rules" },
    EVENTS = { "OnListAdded", "OnListChanged", "OnListDeleted" },
}

--[[ Initialize the list feature ]]
function Lists:OnInitialize()
    self.listManager = Addon:GetListManager()
    self.lists = {}
    self.cache = {}

    self.listManager:RegisterCallback("OnListChanged",
        function(id, action)
            local list = self.listManager:GetList(id)
            self.lists[id] = list
            
            if (action == "ADDED") then
                Addon:RaisesEvent("OnListAdded", list)
            elseif (action == "UPDATED") then
                Addon:RaisesEvent("OnListUpdated", list)
            elseif (action == "DELETED") then
                Addon:RaisesEvent("OnListDeleted", list)
            end
        end, self)

    self:BuildSystemLists()
end

--[[ 
    Creates the system lists, those lists have special systmentaics since, those
    lists remove items from the other lists
]]
function Lists:BuildSystemLists()
    self.systemLists = {
        {
            Id = SystemListId.NEVER,
            Name  = locale["NEVER_SELL_LIST_NAME"],
            Description = locale["NEVER_SELL_LIST_TOOLTIP"],
            Type = 1,
            Key = "list:keep",
        },
        {
            Id = SystemListId.ALWAYS,
            Name  = locale["ALWAYS_SELL_LIST_NAME"],
            Description = locale["ALWAYS_SELL_LIST_TOOLTIP"],
            Type = 1,
            Key = "list:sell"
        },
        {
            Id = SystemListId.DESTROY,
            Name  = locale["ALWAYS_DESTROY_LIST_NAME"],
            Description = locale["ALWAYS_DESTROY_LIST_TOOLTIP"],
            Type = 1,
            Key = "list:destroy"
        }
    }

    for _, list in ipairs(self.systemLists) do
        local systemList = self.CreateProfileList(list)
        systemList:RegisterCallback("OnChanged", self.UpdateSystemLists, self)
        self.cache[list.Id] = systemList
    end
end

--[[ 
    The system lists are mutually exclusive, meaning an item can only exist
    one list, so when it is added we need to remove it from the other lists
]]
function Lists:UpdateSystemLists(list, operation, id)
    self:Debug("System list '%s' has changed [%s, %s]", list:GetId(), operation, tostring(id))

    if (operation == "ADDED") then
        for _, systemList in ipairs(self.systemLists) do
            if (systemList.Id ~= list:GetId()) then
                local toCheck = self:GetList(systemList.Id)
                if (toCheck and toCheck:Contains(id)) then
                    self:Debug("Removing %s from '%s' because it was added to '%s'", tostring(id), systemList.Id, list:GetId())
                    toCheck:Remove(id)
                end
            end
        end
    end
end

--[[ Adds the rule functions related to lists ]]
function Lists:AddFunctions()
end

--[[ Teminate the lists feature ]]
function Lists:OnTerminate()
    if (self.listManager) then        
        local manager = self.listManager

        self.listManager = nil
        manager:UnregisterCallback("OnListChanged", self)
    end
end

--[[ Get the specfied list ]]
function Lists:GetList(listId)
    -- The system lists are ALWAYS in the cache
    if (self.cache[listId]) then
        return self.cache[listId]
    end

    -- Check if we already have an instance of this list
    if (self.lists[listId]) then
        return self.lists[listId]
    end

    -- Resovle a custom list
    local list = self.listManager:GetList(listId)
    if (list) then
        local obj = self.CreateVariableList(list)
        self.lists[listId] = obj
        return obj
    end

    return nil
end

--[[ Get all of the lists ]]
function Lists:GetLists()
    local lists = {}

    for _, list in ipairs(self.systemLists) do
        table.insert(lists, list)
    end

    for _, list in ipairs(self.listManager:GetLists()) do
        list.Type = 2
        table.insert(lists, list)
    end

    return lists
end

--[[  Retrieve the lists tab ]]
function Lists:GetTab()
    return {
            Id = "lists",
            Name = "CONFIG_DIALOG_LISTS_TAB",
            Template = "Vendor_Lists_Tab",
            Class = self.ListsTab
        }
end

Addon.Features.Lists = Lists