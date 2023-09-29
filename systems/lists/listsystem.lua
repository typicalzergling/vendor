local _, Addon = ...
local ListSystem = {}

ListSystem.ListEvents = {
    ADDED = "OnListAdded",
    REMOVED = "OnListRemoved",
    CHANGED = "OnListChanged",
}

ListSystem.ChangeType = {
    ADDED = "ADDED",
    REMOVED = "REMOVED",
    OTHER = "OTHER"
}

ListSystem.ListType = {
    SYSTEM = 1,
    CUSTOM = 2,
    EXTENSION = 3,
}

--[[ Retrieve our depenedencies ]]
function ListSystem:GetDependencies()
    return { "rules", "savedvariables", "profile" }
end

--[[ Retrieves the events we produce ]]
function ListSystem:GetEvents()
    return ListSystem.ListEvents
end

--[[ Startup our system ]]
function ListSystem:Startup(register)
    self.customLists = ListSystem:CreateCustomListManager()
    self:RegisterFunctions()

    register({ "GetList", "GetLists", "CreateList", "DeleteList", "GetSystemLists" })
end

--[[ Shutdown our system ]]
function ListSystem:Shutdown()
    self:UnregisterFunctions()
end

--[[ Attempt to find the list with the specified id ]]
function ListSystem:GetList(listId)
    -- Step 1 - Check if it's a system list it
    for _, systemListId in pairs(Addon.SystemListId) do
        if (listId == systemListId) then
            return self:CreateSystemList(listId)
        end
    end

    -- Step 2 - Check custom lists
    if (self.customLists:Exists(listId)) then
        return self:CreateCustomList(listId)
    end

    return nil
end

--[[ Retrieve all of the list we know about ]]
function ListSystem:GetLists()
    local lists = {}
    
    -- Start with the system lists
    for _, systemListId in pairs(Addon.SystemListId) do
        table.insert(lists, self:CreateSystemList(systemListId))
    end

    -- Custom lists
    for _, customList in ipairs(self.customLists:GetLists()) do
        table.insert(lists, self:CreateCustomList(customList.Id))
    end

    return lists
end

--[[ Retrieve only the system lists ]]
function ListSystem:GetSystemLists()
    local lists = {}
    
    -- Start with the system lists
    for _, systemListId in pairs(Addon.SystemListId) do
        lists[systemListId] = self:CreateSystemList(systemListId)
    end

    return lists
end

--[[ Creates a custom list ]]
function ListSystem:CreateList(name, description)
    if (type(name) ~= "string") or (string.len(name) == 0) then
        error("A list must have a valid name")
    end

    local listDef = self.customLists:Create(name, description)
    local list = self:CreateCustomList(listDef.Id)
    Addon:RaiseEvent(ListSystem.ListEvents.ADDED, list)

    return list
end

--[[ Handle deleting a list ]]
function ListSystem:DeleteList(listId)
    local list = self:GetList(listId)

    if (not list) then
        error("There is not list : " .. tostring(listId))
    end

    if (list:GetType() ~= ListSystem.ListType.CUSTOM) then
        error("Only custom list can be deleted - " .. list:GetName())
    end

    self.customLists:Delete(list:GetId())
    Addon:RaiseEvent(ListSystem.ListEvents.REMOVED, list)
end

--[[ Called when a system list has changed, allows us to force mutual exclusion ]]
function ListSystem:OnSystemListChange(list, changeType, itemId)
    if (changeType ~= ListSystem.ChangeType.ADDED) then
        return
    end

    local listId = list:GetId()
    for _, systemListId in pairs(Addon.SystemListId) do
        if (systemListId ~= listId) then
            local systemList = ListSystem:CreateSystemList(systemListId)
            if (systemList:Remove(itemId)) then
                Addon:Debug("lists", "Removing item '%s' from list '%s' because it was added to '%s'", itemId, systemListId, listId)
            end
        end
    end
end

--[[ Helper to determine the item id ]]
function ListSystem.GetItemId(item)
    -- It can be an item mixin
    if (type(item) == "table" and type(item.GetItemId) == "function") then
        return item:GetItemId()
    elseif (type(item) ~= "number") then
        error("Usage: Contains( ItemMixin or number) - " .. tostring(item))
    end

    return item
end


Addon.Systems.Lists = ListSystem