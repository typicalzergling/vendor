local _, Addon = ...
local VariableList = {}

function VariableList:IsReadOnly()
    return false
end

function VariableList:GetId()
end

function VariableList:GetName()
end

function VariableList:GetItems()
end

function VariableList:Contains(item)
end

function VariableList:Remove(item)
end

function VariableList:Add(item)
end

--[[ Create a new profile list ]]
function Addon.Features.Lists.CreateVariableList(list)
    local obj = CreateFromMixins(VariableList, CallbackRegistryMixin)
    obj:Init(list)
    return obj
end