local _, Addon = ...
local locale = Addon:GetLocale()
local Settings = Addon.Features.Settings
local GeneralSettings =  Mixin({}, Addon.UseProfile)

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
function GeneralSettings:CreateList()
	local list = Settings.CreateList()

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
	list:AddSetting(autosell, "OPTIONS_SETTINGNAME_AUTOSELL", "OPTIONS_SETTINGDESC_AUTOSELL")

	local buyback = Settings.CreateSetting(Addon.c_Config_MaxSellItems, true,
		function()
			return self:GetProfileValue(Addon.c_Config_MaxSellItems) ~= 0
		end,
		function(value)
			local items = Addon.c_BuybackLimit
			if (not value) then
				items = 0
			end

			self:SetProfileValue(Addon.c_Config_MaxSellItems, items)
		end)

	list:AddSetting(buyback, "OPTIONS_SETTINGNAME_BUYBACK", "OPTIONS_SETTINGDESC_BUYBACK", autosell)
end

--[[ Adds the repair settings to the list ]]
function GeneralSettings:CreateRepair(list)
    list:AddHeader("OPTIONS_CATEGORY_REPAIR", "OPTIONS_DESC_REPAIR")

    local autorepair = self.CreateSetting(Addon.c_Config_AutoRepair, true)
    list:AddSetting(autorepair, "OPTIONS_SETTINGNAME_AUTOREPAIR", "OPTIONS_SETTINGDESC_AUTOREPAIR")

    local guildrepair = self.CreateSetting(Addon.c_Config_GuildRepair, true)
    list:AddSetting(guildrepair, "OPTIONS_SETTINGNAME_GUILDREPAIR", "OPTIONS_SETTINGDESC_GUILDREPAIR", autorepair)
end

--[[ Adds the tooltip settings to the list ]]
function GeneralSettings:CreateTooltip(list)
    list:AddHeader("OPTIONS_CATEGORY_TOOLTIP", "OPTIONS_DESC_TOOLTIP")

    local tooltip = self.CreateSetting(Addon.c_Config_Tooltip, true)
    list:AddSetting(tooltip, "OPTIONS_SETTINGNAME_TOOLTIP", "OPTIONS_SETTINGDESC_TOOLTIP")

    local tooliupRule = self.CreateSetting(Addon.c_Config_GuildRepair, true)
    list:AddSetting(tooliupRule, "OPTIONS_SETTINGNAME_EXTRARULEINFO", "OPTIONS_SETTINGDESC_EXTRARULEINFO", tooltip)
end

Settings.General = GeneralSettings