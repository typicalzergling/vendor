local _, Addon = ...
local Settings = Addon.Features.Settings
local DebugSettings =  Mixin({}, Addon.UseProfile)
local INDENT = { left = 16 }

--[[ Gets the name of this setting ]]
function DebugSettings:GetName()
	return "debug_settings"
end

--[[ Gets the text of this setting page ]]
function DebugSettings:GetText()
	return "Debug"
end

--[[ Gets the summary of his setting list (opttional) ]]
function DebugSettings:GetSummary()
	return nil
end

local function createChannelToggle(channel)
    return Settings.CreateSetting(nil, Addon:IsDebugChannelEnabled(channel),
        function()
            return Addon:IsDebugChannelEnabled(channel)
        end,
        function(value)
            Addon:SetDebugChannel(channel, value == true)
        end)
end

--[[ Creates the list for this settings page ]]
function DebugSettings:CreateList(parent)
	local list = Settings.CreateList(parent)
    local indent = { left = 16 }
    list:AddHeader("Channels")

    for _, channel in ipairs(Addon:GetDebugChannels()) do
        local toggle = createChannelToggle(channel)
        local setting = list:AddSetting(toggle, string.upper(channel))
        setting.Margins = indent
    end

	return list;
end

function DebugSettings:GetOrder()
	return 100000
end

Settings.Categories.Debug = DebugSettings