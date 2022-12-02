local _, Addon = ...
local L = Addon:GetLocale()
local Settings = Addon.Features.Settings
local QuickSettings =  Mixin({}, Addon.UseProfile)

--[[ Gets the name of this setting ]]
function QuickSettings:GetName()
	return "quick_settings"
end

--[[ Gets the text of this setting page ]]
function QuickSettings:GetText()
	return L.OPTIONS_CATEGORY_QUICK
end

--[[ Gets the summary of his setting list (opttional) ]]
function QuickSettings:GetSummary()
	return L.OPTIONS_DESC_QUICK
end

function QuickSettings:GetOrder()
	return 1
end

--[[ Checks if auto-sell is enabled ]]
local function isAutoSellEnabled(self)
    local autosell, buyback = self:GetProfileValues(Addon.c_Config_AutoSell, Addon.c_Config_SellLimit)
    if (type(buyback) == "number") then
        buyback = (buyback ~= 0)
    end

    return autosell and buyback
end

--[[ Checks if the auto-repair quick setting should be enabled ]]
local function isAutorepairEnabled(self)
    local autorepair, guildrepair = self:GetProfileValues(Addon.c_Config_AutoRepair, Addon.c_Config_GuildRepair)
    return (autorepair and guildrepair)
end

--[[ Creates the list for this settings page ]]
function QuickSettings:CreateList(parent)
	local list = Settings.CreateList(parent)

    -- Quick setting for auto-sell, this enables auto sell with the buyback limit
    local sell = Settings.CreateSetting(nil, isAutoSellEnabled(self),
        function() return isAutoSellEnabled(self) end,
        function(value)
            if value then
                self:SetProfileValue(Addon.c_Config_SellLimit, true)
                self:SetProfileValue(Addon.c_Config_AutoSell, true)
            else
                self:SetProfileValue(Addon.c_Config_AutoSell, false)
            end
        end)
    local setting = list:AddSetting(sell, "QUICK_SELL_SETTING", "QUICK_SELL_SETTING_HELP")
    setting.isNew = false

    -- Quick repair setting, this also enables guild repair
    local repair = Settings.CreateSetting(nil, isAutorepairEnabled(self),
        function() return isAutorepairEnabled(self) end,
        function(value)
            local profile = Addon:GetProfile()
            if (value) then
                profile:SetValue(Addon.c_Config_AutoRepair, true)
                profile:SetValue(Addon.c_Config_GuildRepair, true)
            else
                profile:SetValue(Addon.c_Config_AutoRepair, false)
            end
        end)
    setting = list:AddSetting(repair, "QUICK_REPAIR_SETTING", "QUICK_REPAIR_SETTING_HELP")
    setting.isNew = false

    -- Quick setting for Minimapbutton
    local minimapbutton = Addon.Features.MinimapButton:CreateSettingForMinimapButton()
    setting = list:AddSetting(minimapbutton, "OPTIONS_SETTINGNAME_MINIMAP", "QUICK_MINIMAP_SETTING_HELP")
    setting.isNew = false

    -- Quick setting for Merchantbutton
    local merchantbutton = Addon.Features.MerchantButton:CreateSettingForMerchantButton()
    setting = list:AddSetting(merchantbutton, "OPTIONS_SETTINGNAME_MERCHANT", "QUICK_MERCHANT_SETTING_HELP")
    setting.isNew = true

	return list;
end

Settings.Categories.Quick = QuickSettings