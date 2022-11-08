local _, Addon = ...
local locale = Addon:GetLocale()
local Settings = Addon.Features.Settings
local GeneralSettings =  Mixin({}, Addon.UseProfile)
local INDENT = { left = 16 }

--[[ Gets the name of this setting ]]
function GeneralSettings:GetName()
	return "general_settings"
end

--[[ Gets the text of this setting page ]]
function GeneralSettings:GetText()
	return locale["OPTIONS_CATEGORY_GENERAL"]
end

--[[ Gets the summary of his setting list (opttional) ]]
function GeneralSettings:GetSummary()
	return nil
end

--[[ Creates the list for this settings page ]]
function GeneralSettings:CreateList(parent)
	local list = Settings.CreateList(parent)

	-- merchant and minimap button
	local minimap = Settings.CreateSetting(Addon.c_Config_Minimap, false)
	list:AddSetting(minimap, "OPTIONS_SETTINGNAME_MINIMAP", "OPTIONS_SETTINGDESC_MINIMAP")

	self:CreateSell(list)
	self:CreateRepair(list)
	self:CreateTooltip(list)

	return list;
end

function GeneralSettings:GetOrder()
	return 250
end

--[[ Adds the selling settings to the settings list ]]
function GeneralSettings:CreateSell(list)
	list:AddHeader("OPTIONS_CATEGORY_SELLING", "OPTIONS_DESC_SELLING")
 
	local autosell = Settings.CreateSetting(Addon.c_Config_AutoSell, true)
	local setting = list:AddSetting(autosell, "OPTIONS_SETTINGNAME_AUTOSELL", "OPTIONS_SETTINGDESC_AUTOSELL")
	setting.Margins = INDENT

	local buyback = Settings.CreateSetting(Addon.c_Config_MaxSellItems, true)
	setting = list:AddSetting(buyback, "OPTIONS_SETTINGNAME_BUYBACK", "OPTIONS_SETTINGDESC_BUYBACK", autosell)
	setting.Margins = INDENT

end

--[[ Adds the repair settings to the list ]]
function GeneralSettings:CreateRepair(list)
    list:AddHeader("OPTIONS_CATEGORY_REPAIR", "OPTIONS_DESC_REPAIR")

    local autorepair = Settings.CreateSetting(Addon.c_Config_AutoRepair, true)
    local setting = list:AddSetting(autorepair, "OPTIONS_SETTINGNAME_AUTOREPAIR", "OPTIONS_SETTINGDESC_AUTOREPAIR")
	setting.Margins = INDENT

    local guildrepair = Settings.CreateSetting(Addon.c_Config_GuildRepair, true)
    setting = list:AddSetting(guildrepair, "OPTIONS_SETTINGNAME_GUILDREPAIR", "OPTIONS_SETTINGDESC_GUILDREPAIR", autorepair)
	setting.Margins = INDENT
end

--[[ Adds the tooltip settings to the list ]]
function GeneralSettings:CreateTooltip(list)
    list:AddHeader("OPTIONS_CATEGORY_TOOLTIP", "OPTIONS_DESC_TOOLTIP")

    local tooltip = Settings.CreateSetting(Addon.c_Config_Tooltip, true)
    local setting = list:AddSetting(tooltip, "OPTIONS_SETTINGNAME_TOOLTIP", "OPTIONS_SETTINGDESC_TOOLTIP")
	setting.Margins = INDENT

    local tooliupRule = Settings.CreateSetting(Addon.c_Config_GuildRepair, true)
    setting = list:AddSetting(tooliupRule, "OPTIONS_SETTINGNAME_EXTRARULEINFO", "OPTIONS_SETTINGDESC_EXTRARULEINFO", tooltip)
	setting.Margins = INDENT
end

Settings.Categories.General = GeneralSettings