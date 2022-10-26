local _, Addon = ...
local locale = Addon:GetLocale()
local Group = {}

--[[ Initialize a group ]]
function Group:Init(setting)
end

function Addon.Features.Settings.CreateGroup(setting)
    return CreateFromMixins(Group, setting)
end