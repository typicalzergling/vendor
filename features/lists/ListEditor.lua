--[[
    ListEditor

    This class provides the editing functionatlity for a list, this provides
    a layer which transactions the changes to the list, but looks like a 
    list to all of the infrastructure.
]]

local _, Addon = ...
local locale  = Addon:GetLocale()

local ListEditor = {}
local Lists = nil
local ListType = nil
local ChangeType = nil


--[[ Called to mark the list as dirty (internal)]]
local function ListEditor_SetDirty(self)
    if (not self.dirty) then
        self.dirty = true
        self:TriggerEvent("OnDirty", true)
    end
end

--[[ Called to clear the dirty state on this editor ]]
local function ListEditor_ClearDirty(self)
    if (self.dirty) then
        self.dirty = false
        self:TriggerEvent("OnDirty",false)
    end
end

--[[ Initialize this list, setting copy to true will cause this to create a new list ]]
local function ListEditor_Init(self, list, copy)
    Lists = Addon.Features.Lists
    ListType = Addon.Systems.Lists.ListType
    ChangeType = Addon.Systems.Lists.ChangeType

    CallbackRegistryMixin.OnLoad(self)
    self:GenerateCallbackEvents({"OnChanged", "OnDirty"})

    self.dirty = false
    self.changes = {}

    if (list) then
        self.name = list:GetName()
        self.description = list:GetDescription()
        self.contents = list:GetContents()

        if (copy ~= true) then
            self.list = list
        else
            self.name = locale:FormatString("COPY_LIST_FMT1", list:GetName())
            for _, id in ipairs(self.contents) do
                self.changes[id] = ChangeType.ADDED
            end
            self.contents = {}
            ListEditor_SetDirty(self)
        end
    else
        self.contents = {}
    end

    -- System list change when the profile is updated
    Addon:RegisterCallback("OnProfileChanged", self, function()
            if (list and list:GetType() == ListType.SYSTEM) then
                self.contents = list:GetContents()
                self:TriggerEvent("OnChanged")
            end
        end)
end

--[[ Called the cleanup any edit state ]]
function ListEditor:Cleanup()
    Addon:UnregisterCallback("OnProfileChanged", self)
end

--[[ You can modify the system lists ]]
function ListEditor:IsReadOnly()
    if (not self.list) then
        return false
    end

    return self.list:IsReadOnly()
end

--[[ Getsthe ID for this list ]]
function ListEditor:GetId()
    if (not self.list) then
        return nil
    end

    return self.list:GetId()
end

--[[ Gets the name for this list ]]
function ListEditor:GetName()
    return self.name or ""
end

--[[ Called to change the name of this list ]]
function ListEditor:SetName(name)
    --@debug@
    assert(self:CanChangeProperties())
    --@end-debug@

    if (name ~= self.name) then
        self.name = name or ""
        ListEditor_SetDirty(self)
        self:TriggerEvent("OnChanged", self, "REMOVED", item)
    end
end

--[[ Gets the description for this list ]]
function ListEditor:GetDescription()
    return self.description or ""
end

--[[ Called to change the description of this list ]]
function ListEditor:SetDescription(description)
    --@debug@
    assert(self:CanChangeProperties())
    --@end-debug@

    if (description ~= self.description) then
        if (not description or string.len(description) == 0) then
            self.description = nil
        else
            self.description = description
        end
        ListEditor_SetDirty(self)
        self:TriggerEvent("OnChanged", self, "REMOVED", item)
    end
end

--[[ Gets the type for this list ]]
function ListEditor:GetType()
    if (not self.list) then
        return ListType.CUSTOM
    end

    return self.list:GetType()
end

--[[ Retrieves the contents of this list ]]
function ListEditor:GetContents()
    local contents = {}
    local changes = self.changes
    
    for _, id in ipairs(self.contents) do
        if (not changes[id]) then
            table.insert(contents, id)
        end
    end

    for id, change in pairs(changes) do
        if (change == ChangeType.ADDED) then
            table.insert(contents, id)
        end
    end

    return contents
end

--[[ Return true if the ist contains this item ]]
function ListEditor:Contains(item)
    local change = self.changes[item]
    if (change == ChangeType.ADDED) then
        return true
    elseif (change == ChangeType.REMOVED) then
        return false
    end

    for _, id in ipairs(self.contents) do
        if (id == item) then
            return true
        end
    end

    return false
end

--[[ Remove the specified item from the list ]]
function ListEditor:Remove(item)
    if (self.changes[item] == ChangeType.ADDED) then
        self.changes[item] = nil
    else
        self.changes[item] = ChangeType.REMOVED
    end

    ListEditor_SetDirty(self)
    self:TriggerEvent("OnChanged", self, "REMOVED", item)
end

--[[ Adds an item to the list ]]
function ListEditor:Add(item)
    if (self.changes[item] == ChangeType.REMOVED) then
        self.changes[item] = nil
    else
        self.changes[item] = ChangeType.ADDED
    end

    ListEditor_SetDirty(self)
    self:TriggerEvent("OnChanged")
end

---[[ Commits the changes to the underlying list ]]
function ListEditor:Commit()
    local list = self.list

    if (not self.list) then
        self.list = Addon:CreateList(self.name, self.description)
        list = self.list
    elseif (self:CanChangeProperties()) then
        list:SetName(self.name)
        list:SetDescription(self.description)
    end

    for id, change in pairs(self.changes) do
        if (change  == ChangeType.ADDED) then
            list:Add(id)
        elseif (change == ChangeType.REMOVED) then
            list:Remove(id)
        end
    end

    ListEditor_ClearDirty(self)
end

--[[ True if the list can be saved ]]
function ListEditor:CanCommit()
    if (self.dirty) then
        -- The name must be non-empty to be able to be saved
        if (not self.name or string.len(self.name) == 0) then
            return false
        end
    end

    return true
end

--[[ True if the list can be deleted ]]
function ListEditor:CanDelete()
    return self:GetType() == ListType.CUSTOM
end

--[[ Gets the dirty state for this list editor ]]
function ListEditor:IsDirty()
    return self.dirty or false
end

--[[ Checkes if you can change the list properties name/description ]]
function ListEditor:CanChangeProperties()
    return self:GetType() == ListType.CUSTOM
end

--[[ Checks if you can change the list by modifying the contents ]]
function ListEditor:CanModifyContents()
    return not self.list or not self.list:IsReadOnly()
end

--[[  Check if this a new list ]]
function ListEditor:IsNew()
    return not self.list
end

--[[ Create a new profile list ]]
function Addon.Features.Lists.CreateEditor(list, copy)
    local obj = CreateFromMixins(ListEditor, CallbackRegistryMixin)
    ListEditor_Init(obj, list, copy)
    return obj
end