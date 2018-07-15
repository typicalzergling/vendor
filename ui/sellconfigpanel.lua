local Addon, L = _G[select(1,...).."_GET"]()

Addon.ConfigPanel = Addon.ConfigPanel or {}
Addon.ConfigPanel.Sell = {}

--*****************************************************************************
-- Called to handle a click on the "open rules" dialog
--*****************************************************************************
function Addon.ConfigPanel.Sell.OnOpenRules()
    Addon:Debug("Showing rules dialog")
    Addon.RulesDialog.Toggle()
end

--*****************************************************************************
-- Called to handle a click on the "open bindings" button
--*****************************************************************************
function Addon.ConfigPanel.OnOpenBindings()
    Addon:Debug("Showing key bindings")
end

--*****************************************************************************
-- Called to push the settings from our page into the addon
--*****************************************************************************
function Addon.ConfigPanel.Sell.Apply(self, config)
    Addon:Debug("Applying sell panel configuration")
    config:SetValue("autosell", self.AutoSell.State:GetChecked())
end

--*****************************************************************************
-- Pull the value from the config into the panel.
--*****************************************************************************
function Addon.ConfigPanel.Sell.Set(self, config)
    Addon:Debug("Setting sell panel config")
    self.AutoSell.State:SetChecked(not not config:GetValue("autosell"))
end

--*****************************************************************************
-- Called to sync the values on our page with the config.
--*****************************************************************************
function Addon.ConfigPanel.Sell.Init(self)
    self.Title:SetText(L["OPTIONS_HEADER_SELLING"])
    self.HelpText:SetText(L["OPTIONS_DESC_SELLING"])
    self.AutoSell.Text:SetText(L["OPTIONS_SETTINGDESC_AUTOSELL"])
    self.AutoSell.Label:SetText(L["OPTIONS_SETTINGNAME_AUTOSELL"])
    self.OpenBindings:SetText(L["OPTIONS_SHOW_BINDINGS"])
    self.OpenRules:SetText(L["OPTIONS_OPEN_RULES"])
end
