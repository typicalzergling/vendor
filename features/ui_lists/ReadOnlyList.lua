local _, Addon = ...

local ReadOnlyList = {}

function ReadOnlyList:IsReadOnly()
    return true
end

function ReadOnlyList:GetId()
end

function ReadOnlyList:GetName()
end

function ReadOnlyList:GetItems()
end

function ReadOnlyList:Contains(item)
end

function ReadOnlyList:Remove(item)
end

function ReadOnlyList:Add(item)
end

--[[ Create a new profile list ]]
function Addon.Features.Lists.CreateReadOnlyList(list)
    local obj = CreateFromMixins(ReadOnlyList, CallbackRegistryMixin)
    obj:Init(list)
    return obj
end