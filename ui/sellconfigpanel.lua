
Vendor = Vendor or {}
Vendor.ConfigPanel = Vendor.ConfigPanel or {}
local L = Vendor:GetLocalizedStrings()
Vendor.ConfigPanel.Sell = {}

--*****************************************************************************
-- Called to handle a click on the "open rules" dialog
--*****************************************************************************
function Vendor.ConfigPanel.Sell.OnOpenRules()
    Vendor:Debug("Showing rules dialog")
    Vendor:ShowRulesDialog()
end

--*****************************************************************************
-- Called to handle a click on the "open bindings" button
--*****************************************************************************
function Vendor.ConfigPanel.OnOpenBindings()
    Vendor:Debug("Showing key bindings")
end

--*****************************************************************************
-- Called to push the settings from our page into the addon
--*****************************************************************************
function Vendor.ConfigPanel.Sell.Apply(self, config)
    Vendor:Debug("Applying sell panel configuration")
    config:SetValue("autosell", self.AutoSell.State:GetChecked())
end

--*****************************************************************************
-- Pull the value from the config into the panel.
--*****************************************************************************
function Vendor.ConfigPanel.Sell.Set(self, config)
    Vendor:Debug("Setting sell panel config")
    self.AutoSell.State:SetChecked(not not config:GetValue("autosell"))
end

--*****************************************************************************
-- Called to sync the values on our page with the config.
--*****************************************************************************
function Vendor.ConfigPanel.Sell.Init(self)
    self.Title:SetText(L["OPTIONS_HEADER_SELLING"])
    self.HelpText:SetText(L["OPTIONS_DESC_SELLING"])
    self.AutoSell.Text:SetText(L["OPTIONS_SETTINGDESC_AUTOSELL"])
    self.AutoSell.Label:SetText(L["OPTIONS_SETTINGNAME_AUTOSELL"])
    self.OpenBindings:SetText(L["OPTIONS_SHOW_BINDINGS"])
    self.OpenRules:SetText(L["OPTIONS_OPEN_RULES"])

end
