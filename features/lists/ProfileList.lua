--[[
    ProfileList

    THis is a list which is backed by the profile, these are the built in
    system lists.
]]
local _, Addon = ...
local ProfileList = {}

--[[ Helper to determine the item id ]]
local function getItemId(item)
    -- It can be an item mixin
    if (type(item) == "table") then
        return item:GetItemId()
    elseif (type(item) ~= "number") then
        error("Usage: Contains( ItemMixin or number) - " .. tostring(item))
    end
    return item
end

--[[ Initialize this list ]]
function ProfileList:Init(list)
    CallbackRegistryMixin.OnLoad(self)
    self:GenerateCallbackEvents({"OnChanged"})
    self.list = list
end

--[[ You can modify the system lists ]]
function ProfileList:IsReadOnly()
    return false
end

--[[ Getsthe ID for this list ]]
function ProfileList:GetId()
    return self.list.Id
end

--[[ Gets the name for this list ]]
function ProfileList:GetName()
    return self.list.Name
end

--[[ Retrieves the contents of this list ]]
function ProfileList:GetContents()
    local result = {}
    local profile = Addon:GetProfile()
    local items = profile:GetValue(self.list.Key)

    if (type(items) == "table") then
        for id, val in pairs(items) do
            if (val and C_Item.DoesItemExistByID(id)) then
                table.insert(result, id)
            end
        end
    end

    return result
end

--[[ Return true if the list contains this item ]]
function ProfileList:Contains(item)
    item = getItemId(item)
    if (not C_Item.DoesItemExistByID(item)) then
        return false
    end

    local profile = Addon:GetProfile()
    local items = profile:GetValue(self.list.Key)
    if (type(items) == "table") then
        return items[item] == true
    end

    return false
end

--[[ Remove the specified item from the list ]]
function ProfileList:Remove(item)
    item = getItemId(item)

    local profile = Addon:GetProfile()
    local items = profile:GetValue(self.list.Key)
    if (type(items) == "table") then
        if (items[item]) then
            items[item] = nil
            profile:SetValue(self.list.Key, items)
            self:TriggerEvent("OnChanged", self, "REMOVED", item)
            return true
        end
    end

    return false
end

--[[ Adds an item to the list ]]
function ProfileList:Add(item)
    local profile = Addon:GetProfile()
    item = getItemId(item)

    local items = profile:GetValue(self.list.Key)
    if (type(items) ~= "table") then
        items = { [item] = true }
    elseif (not items[item]) then
        items[item] = true
    else
        -- We don't need to makea  change
        items = nil
    end

    if (items) then
        profile:SetValue(self.list.Key, items)
        self:TriggerEvent("OnChanged", self, "ADDED", item)
        return true
    end

    return false
end

--[[ Create a new profile list ]]
function Addon.Features.Lists.CreateProfileList(list)
    local obj = CreateFromMixins(ProfileList, CallbackRegistryMixin)
    obj:Init(list)
    return obj
end