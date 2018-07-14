Vendor = Vendor or {}
Vendor.ConfigPanel = Vendor.ConfigPanel or {}
local L = Vendor:GetLocalizedStrings()

local MAX_SELL_THROTTLE = 5
local MIN_SELL_THROTTLE = 1
local MAX_TIME_THROTTLE = 2.0
local MIN_TIME_THROTTLE = 0.0
local TIME_MULT = 10

Vendor.ConfigPanel.Perf = {}
function Vendor.ConfigPanel.Perf.Set(self, config)
    Vendor:Debug("Setting performance panel config")

    local time = math.max(MIN_TIME_THROTTLE, math.min(MAX_TIME_THROTTLE, config:GetValue("throttle_time") or 0))
    self.TimeThrottle.Value:SetValue(time * TIME_MULT)
    self.TimeThrottle.DisplayValue:SetFormattedText("%0.1f", time)

    local sell = math.max(MIN_SELL_THROTTLE, math.min(MAX_SELL_THROTTLE, config:GetValue("sell_throttle") or 0))
    self.SellThrottle.Value:SetValue(sell)
    self.SellThrottle.DisplayValue:SetFormattedText("%0d", sell)
end

function Vendor.ConfigPanel.Perf.Apply(self, config)
    Vendor:Debug("Applying performance options")
    config:SetValue("sell_throttle", self.SellThrottle.Value:GetValue())
    config:SetValue("throttle_time", self.TimeThrottle.Value:GetValue() / TIME_MULT)
end

function Vendor.ConfigPanel.Perf.Init(self)
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
    self.TimeThrottle.Text:SetText(L["OPTIONS_SETTINGDESC_SELL_THROTTLE"])
    self.TimeThrottle.Value:SetMinMaxValues(MIN_TIME_THROTTLE * TIME_MULT, MAX_TIME_THROTTLE * TIME_MULT)
    self.TimeThrottle.Max:SetFormattedText("%0.1f", MAX_TIME_THROTTLE)
    self.TimeThrottle.Min:SetFormattedText("%0.1f", MIN_TIME_THROTTLE)
    self.TimeThrottle.Value:SetValueStep(1)
    self.TimeThrottle.OnValueChanged =
        function(self, value)
            self.DisplayValue:SetFormattedText("%0.1f", value / 10)
        end
end
