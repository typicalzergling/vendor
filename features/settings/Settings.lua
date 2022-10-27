local _, Addon = ...
local locale = Addon:GetLocale()
local SettingsFeature = {
    NAME = "Settings", 
    VERSION = 1,
}

--[[
    Called when feature is initialized
]]
function SettingsFeature:OnInitialize()
    self:Debug("Initialize settings feature")

    self:CreateGeneralSettings()
end

--[[
    Creates the settings objects and caches them, this invokes each
    categroy to retrieve the list of settings
]]
function SettingsFeature:CreateSettings()
    if (not self.settings) then
        self.settings = {}
        if type(self.Categories) == "table" then
            for _, category in pairs(self.Categories) do
                local settings = category:CreateSettings()
                if (settings and table.getn(settings)) then
                    for _, setting in ipairs(settings) do
                        local key = string.lower(setting:GetName())
                        assert(self.settings[key] == nil, "A ssetting with the name " .. key .. " already exists")
                        self.settings[key] = setting
                    end
                end
            end
        end
    end
end

--[[ Retrieves a setting with te specified name ]]
function SettingsFeature:GetSetting(name)
    if (self.settings) then
        local setting = self.settings[string.lower(name)]
        if (setting ~= nil) then
            return
        end
    end

    self:Debug("Setting '%s' was requested but doesn't exist", name)
    return nil -- no such setting
end

--[[
     Retrieves a list of all the settings supported, this is an ordered list of items
     based on the categoriies order.  each entry also has a function to create the list
]]
function SettingsFeature:GetSettings()
    self:CreateSettings()

    local settings = {}
    if type(self.Categories) == "table" then
        for _, category in pairs(self.Categories) do
            table.insert(settings, {
                Key = category:GetName(),
                Text = category:GetText(),
                Order = category:GetOrder() or 1000,
                CreateList = function()
                    return category:CreateList()
                end
            })
        end
    end

    table.sort(settings, function(a, b)
            return (a.Order < b.Order)
        end)

    return settings
end

function SettingsFeature:CreateGeneralSettings()
    local list = self.CreateList()
    list:SetWidth(340)
    list:SetHeight(250)

    list:AddHeader("OPTIONS_CATEGORY_SELLING", "OPTIONS_DESC_SELLING")
    
    local autosell = self.CreateSetting(Addon.c_Config_AutoSell, true)
    list:AddSetting(autosell, "OPTIONS_SETTINGNAME_AUTOSELL", "OPTIONS_SETTINGDESC_AUTOSELL")

    local buyback = self.CreateSetting(Addon.c_Config_MaxSellItems, true,
        function()
            return Addon:GetProfile():GetValue(Addon.c_Config_MaxSellItems) ~= 0
        end,
        function(value)
            if (value) then
                Addon:GetProfile():SetValue(Addon.c_Config_MaxSellItems, Addon.c_BuybackLimit)
            else
                Addon:GetProfile():SetValue(Addon.c_Config_MaxSellItems, 0)
            end
        end)
    list:AddSetting(buyback, "OPTIONS_SETTINGNAME_BUYBACK", "OPTIONS_SETTINGDESC_BUYBACK", autosell)

    list:AddHeader("OPTIONS_CATEGORY_REPAIR", "OPTIONS_DESC_REPAIR")

    local autorepair = self.CreateSetting(Addon.c_Config_AutoRepair, true)
    list:AddSetting(autorepair, "OPTIONS_SETTINGNAME_AUTOREPAIR", "OPTIONS_SETTINGDESC_AUTOREPAIR")

    local guildrepair = self.CreateSetting(Addon.c_Config_GuildRepair, true)
    list:AddSetting(guildrepair, "OPTIONS_SETTINGNAME_GUILDREPAIR", "OPTIONS_SETTINGDESC_GUILDREPAIR")

    list:SetPoint("CENTER")
    list:Hide()
end

--[[
    Callback for when our profile changes
]]
function Settings:OnProfileChanged(profile)
    self:Debug("Profile changed")
end

--[[
    Callback for when the feature is terminated
]]
function SettingsFeature:OnTerminate()
end


Addon.Features.Settings = SettingsFeature