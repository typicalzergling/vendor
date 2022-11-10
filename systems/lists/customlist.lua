local _, Addon = ...
local CustomList = {}
local Lists = Addon.Systems.Lists
local ListEvents = Lists.ListEvents
local ChangeType = Lists.ChangeType

--[[ Initialize this list ]]
function CustomList:Init(manager, listId)
    self.manager = manager
    self.listId = listId
end

--[[ Return the type of this list ]]
function CustomList:GetType()
    return Lists.ListType.CUSTOM
end

--[[ You can modify the system lists ]]
function CustomList:IsReadOnly()
    return false
end

--[[ Getsthe ID for this list ]]
function CustomList:GetId()
    return self.listId
end

--[[ Gets the name for this list ]]
function CustomList:GetName()
    local list = self.manager:Get(self.listId)
    return list.Name
end

--[[ Called the set the name of the list ]]
function CustomList:SetName(name)
    if (type(name) ~= "string") or (string.len(name) == 0) then
        error("A list must have a valid name")
    end

    if (name ~= self:GetName()) then
        self.manager:Update(self.listId, { Name = name })
        Addon:RaiseEvent(ListEvents.CHANGED, self, ChangeType.OTHER, item)
    end
end

--[[ Gets the description for this list ]]
function CustomList:GetDescription()
    local list = self.manager:Get(self.listId)
    return list.Description
end

--[[ Sets the description ]]
function CustomList:SetDescription(description)
    if (description ~= self:GetDescription()) then
        if (not description or type(description) ~= "string") then
            description = ""
        end

        self.manager:Update(self.listId, { Description = description })
        Addon:RaiseEvent(ListEvents.CHANGED, self, ChangeType.OTHER, item)
    end
end

--[[ Retrieves the contents of this list ]]
function CustomList:GetContents()
    local items = {}
    local contents = self.manager:GetContents(self.listId)

    for id, val in pairs(contents) do
        if (val and C_Item.DoesItemExistByID(id)) then
            table.insert(items, id)
        end
    end

    return items
end

--[[ Return true if the ist contains this item ]]
function CustomList:Contains(item)
    item = Lists.GetItemId(item)
    if (not C_Item.DoesItemExistByID(item)) then
        return false
    end

    local contents = self.manager:GetContents(self.listId)
    return (contents[item] == true)
end

--[[ Remove the specified item from the list ]]
function CustomList:Remove(item)
    item = Lists.GetItemId(item)

    local contents = self.manager:GetContents(self.listId)    
    if (contents[item]) then
        contents[item] = nil
        self.manager:SetContents(self.listId, contents)
        Addon:Debug("customlists", "Remved item '%s' to custom list '%s'", item, self.listId)
        Addon:RaiseEvent(ListEvents.CHANGED, self, ChangeType.REMOVED, item)
        return true
    end

    return false
end

--[[ Adds an item to the list ]]
function CustomList:Add(item)
    item = Lists.GetItemId(item)

    local contents = self.manager:GetContents(self.listId)
    if (contents[item] ~= true) then
        contents[item] = true
        self.manager:SetContents(self.listId, contents)
        Addon:Debug("customlists", "Added item '%s' to custom list '%s'", item, self.listId)
        Addon:RaiseEvent(ListEvents.CHANGED, self, ChangeType.ADDED, item)
        return true
    end

    return false
end

--[[ Create a new custom list ]]
function Lists:CreateCustomList(listId)
    assert(self.customLists)
    if (not self.customLists:Exists(listId)) then
        error("Attempt to create a non-existing list : [" .. tostring(listId) .. "]")
    end

    return CreateAndInitFromMixin(CustomList, self.customLists, listId)
end