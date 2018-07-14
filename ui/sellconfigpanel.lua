
Vendor = Vendor or {}
Vendor.ConfigPanel = Vendor.ConfigPanel or {}
local L = Vendor:GetLocalizedStrings()
Vendor.ConfigPanel.Sell = {}

function Vendor.ConfigPanel.Sell.OnOpenRules()
    Vendor:Debug("Showing rules dialog")
    Vendor:ShowRulesDialog()
end

function Vendor.ConfigPanel.OnOpenBindings()
    Vendor:Debug("Show keybindings dialog")
end

function Vendor.ConfigPanel.Sell.Apply(self, config)
    Vendor:Debug("Applying selling configuration")
    config:SetValue("autosell", self.AutoSell.State:GetChecked())
end

function Vendor.ConfigPanel.Sell.Set(self, config)
    self.AutoSell.State:SetChecked(not not config:GetValue("autosell"))
end

function Vendor.ConfigPanel.Sell.Init(self)
    self.Title:SetText(L["OPTIONS_HEADER_SELLING"])
    self.HelpText:SetText(L["OPTIONS_DESC_SELLING"])
    self.AutoSell.Text:SetText(L["OPTIONS_SETTINGDESC_AUTOSELL"])
    self.AutoSell.Label:SetText(L["OPTIONS_SETTINGNAME_AUTOSELL"])
    self.OpenBindings:SetText(L["OPTIONS_SHOW_BINDINGS"])
    self.OpenRules:SetText(L["OPTIONS_OPEN_RULES"])

end
