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

Lists.ListType = {
    SYSTEM = "system-list",
    CUSTOM = "custom-list",
    EXTENSION = "extension-list"
}

--[[ Initialize the list feature ]]
function Lists:OnInitialize()
    self.customLists = self.GetCustomLists()
    self.lists = {}
    self:BuildSystemLists()
    self:RegisterFuncstions()
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
            Type = self.ListType.SYSTEM,
            Key = "list:keep",
        },
        {
            Id = SystemListId.ALWAYS,
            Name  = locale["ALWAYS_SELL_LIST_NAME"],
            Description = locale["ALWAYS_SELL_LIST_TOOLTIP"],
            Type = self.ListType.SYSTEM,
            Key = "list:sell"
        },
        {
            Id = SystemListId.DESTROY,
            Name  = locale["ALWAYS_DESTROY_LIST_NAME"],
            Description = locale["ALWAYS_DESTROY_LIST_TOOLTIP"],
            Type = self.ListType.SYSTEM,
            Key = "list:destroy"
        }
    }

    for _, list in ipairs(self.systemLists) do
        local systemList = self.CreateProfileList(list)
        systemList:RegisterCallback("OnChanged", self.UpdateSystemLists, self)
        self.lists[list.Id] = systemList
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
end

--[[ Get the specfied list ]]
function Lists:GetList(listId)
    -- Check if we already have an instance of this list
    if (self.lists[listId]) then
        return self.lists[listId]
    end

    -- Resovle a custom list
    local list = self.customLists:Get(listId)
    if (list) then
        return self.CreateVariableList(list)
    end

    return nil
end

-- todo move to helpers
local function merge(t, ...)
    t = t or {}
    for _, o in ipairs({...}) do
        if (type(o) == "table") then
            for k,v in pairs(o) do
                t[k] = v
            end
        end
    end
    return t
end

--[[ Get all of the lists ]]
function Lists:GetLists()
    local lists = {}

    for _, list in ipairs(self.systemLists) do
        table.insert(lists, list)
    end

    for _, list in ipairs(self.customLists:GetLists()) do
        table.insert(lists, merge(nil, list, { Type = ListType.CUSTOM }))
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