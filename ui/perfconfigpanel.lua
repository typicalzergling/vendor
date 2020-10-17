local AddonName, Addon = ...
local L = Addon:GetLocale()

Addon.ConfigPanel = Addon.ConfigPanel or {}
Addon.ConfigPanel.Perf = {}

local MAX_SELL_THROTTLE = 5
local MIN_SELL_THROTTLE = 1
local MAX_TIME_THROTTLE = 2.0
local MIN_TIME_THROTTLE = 0.0
local TIME_MULT = 10

--*****************************************************************************
-- Called to sync the values on our page with the config.
--*****************************************************************************
function Addon.ConfigPanel.Perf.Set(self, config)
    Addon:Debug("Setting performance panel config")

    local time = math.max(MIN_TIME_THROTTLE, math.min(MAX_TIME_THROTTLE, config:GetValue(Addon.c_Config_ThrottleTime) or 0))
    self.TimeThrottle.Value:SetValue(time * TIME_MULT)
    self.TimeThrottle.DisplayValue:SetFormattedText("%0.2f", time)

    local sell = math.max(MIN_SELL_THROTTLE, math.min(MAX_SELL_THROTTLE, config:GetValue(Addon.c_Config_SellThrottle) or 0))
    self.SellThrottle.Value:SetValue(sell)
    self.SellThrottle.DisplayValue:SetFormattedText("%0d", sell)
end

--*****************************************************************************
-- Called to push the values from page into the config
--*****************************************************************************
function Addon.ConfigPanel.Perf.Apply(self, config)
    Addon:Debug("Applying performance options")
    config:SetValue(Addon.c_Config_SellThrottle, self.SellThrottle.Value:GetValue())
    config:SetValue(Addon.c_Config_ThrottleTime, self.TimeThrottle.Value:GetValue() / TIME_MULT)
end

--*****************************************************************************
-- Called to setup our panel
--*****************************************************************************
function Addon.ConfigPanel.Perf.Init(self)
    self.Title:SetText(L["OPTIONS_CATEGORY_PERFORMANCE"])
    self.HelpText:SetText(L["OPTIONS_TITLE_PERFORMANCE"])

    self.SellThrottle.Label:SetText(L["OPTIONS_SETTINGNAME_SELL_THROTTLE"])
    self.SellThrottle.Text:SetText(L["OPTIONS_SETTINGDESC_SELL_THROTTLE"])
    self.SellThrottle.Value:SetMinMaxValues(MIN_SELL_THROTTLE, MAX_SELL_THROTTLE)
    self.SellThrottle.Value:SetValueStep(1)
    self.SellThrottle.Max:SetFormattedText("%d", MAX_SELL_THROTTLE)
    self.SellThrottle.Min:SetFormattedText("%d", MIN_SELL_THROTTLE)
    self.SellThrottle.OnValueChanged =
        function(self, value)
            self.DisplayValue:SetFormattedText("%0d", value)
        end

    self.TimeThrottle.Label:SetText(L["OPTIONS_SETTINGNAME_CYCLE_RATE"])
    self.TimeThrottle.Text:SetText(L["OPTIONS_SETTINGDESC_CYCLE_RATE"])
    self.TimeThrottle.Value:SetMinMaxValues(MIN_TIME_THROTTLE * TIME_MULT, MAX_TIME_THROTTLE * TIME_MULT)
    self.TimeThrottle.Max:SetFormattedText("%0.2f", MAX_TIME_THROTTLE)
    self.TimeThrottle.Min:SetFormattedText("%0.2f", MIN_TIME_THROTTLE)
    self.TimeThrottle.Value:SetValueStep(.5)
    self.TimeThrottle.OnValueChanged =
        function(self, value)
            self.DisplayValue:SetFormattedText("%0.2f", value / 10)
        end
end

-- Export to Public
if not Addon.Public.ConfigPanel then Addon.Public.ConfigPanel = {} end
Addon.Public.ConfigPanel.Perf = Addon.ConfigPanel.Perf