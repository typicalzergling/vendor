--[[
    ProfileList

    THis is a list which is backed by the profile, these are the built in
    system lists.
]]

local _, Addon = ...
local SystemList = {}
local Lists = Addon.Systems.Lists
local ListEvents = Lists.ListEvents
local SystemListId = Addon.SystemListId
local ChangeType = Lists.ChangeType

local LIST_INFO  = {
    [SystemListId.NEVER] = {
        Name  = "NEVER_SELL_LIST_NAME",
        Description = "NEVER_SELL_LIST_TOOLTIP",
        Key = "list:keep",
    },
    [SystemListId.ALWAYS] = {
        Name  = "ALWAYS_SELL_LIST_NAME",
        Description = "ALWAYS_SELL_LIST_TOOLTIP",
        Key = "list:sell"
    },
    [SystemListId.DESTROY] = {
        Name  = "ALWAYS_DESTROY_LIST_NAME",
        Description = "ALWAYS_DESTROY_LIST_TOOLTIP",
        Key = "list:destroy"
    }
}

--[[ Initialize this list ]]
function SystemList:Init(listId)
    self.info = LIST_INFO[listId]
    self.id = listId
end

--[[ Return the type of this list ]]
function SystemList:GetType()
    return Lists.ListType.SYSTEM
end

--[[ You can modify the system lists ]]
function SystemList:IsReadOnly()
    return false
end

--[[ Getsthe ID for this list ]]
function SystemList:GetId()
    return self.id
end

--[[ Gets the name for this list ]]
function SystemList:GetName()
    return self.info.Name
end

--[[ Gets the description for this list ]]
function SystemList:GetDescription()
    return self.info.Description
end

--[[ Retrieves the contents of this list ]]
function SystemList:GetContents()
    local result = {}
    local profile = Addon:GetProfile()
    local items = profile:GetValue(self.info.Key)

    if (type(items) == "table") then
        for id, val in pairs(items) do
            if (val and C_Item.DoesItemExistByID(id)) then
                table.insert(result, id)
            end
        end
    end

    return result
end

--[[ Return true if the ist contains this item ]]
function SystemList:Contains(item)
    item = Lists.GetItemId(item)
    if (not C_Item.DoesItemExistByID(item)) then
        return false
    end

    local profile = Addon:GetProfile()
    local items = profile:GetValue(self.info.Key)
    if (type(items) == "table") then
        return items[item] == true
    end

    return false
end

--[[ Remove the specified item from the list ]]
function SystemList:Remove(item)
    item = Lists.GetItemId(item)

    local profile = Addon:GetProfile()
    local items = profile:GetValue(self.info.Key)
    if (type(items) == "table") then
        if (items[item]) then
            items[item] = nil
            profile:SetValue(self.info.Key, items)            
            Lists:OnSystemListChange(self, ChangeType.REMOVED, item)
            Addon:RaiseEvent(ListEvents.CHANGED, self, ChangeType.REMOVED, item)
            return true
        end
    end

    return false
end

--[[ Adds an item to the list ]]
function SystemList:Add(item)
    local profile = Addon:GetProfile()
    item = Lists.GetItemId(item)

    local items = profile:GetValue(self.info.Key)
    if (type(items) ~= "table") then
        items = { [item] = true }
    elseif (not items[item]) then
        items[item] = true
    else
        -- We don't need to makea  change
        items = nil
    end

    if (items) then
        profile:SetValue(self.info.Key, items)
        Lists:OnSystemListChange(self, ChangeType.ADDED, item)
        Addon:RaiseEvent(ListEvents.CHANGED, self, ChangeType.ADDED, item)
        return true
    end

    return false
end

--[[ Create a new profile list ]]
function Lists:CreateSystemList(listId)
    if (not LIST_INFO[listId]) then
        error("Usage: CreateSystemList( SystemListId ")
    end
    return CreateAndInitFromMixin(SystemList, listId)
end