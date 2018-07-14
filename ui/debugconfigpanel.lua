local Addon, L = _G[select(1,...).."_GET"]()

Addon.ConfigPanel = Addon.ConfigPanel or {}
Addon.ConfigPanel.Debug = {}

--*****************************************************************************
-- Called to sync the values on our page with the config.
--*****************************************************************************
function Addon.ConfigPanel.Debug.Set(self, config)
    Addon:Debug("Setting debug options panel values")
    self.Debug.State:SetChecked(not not config:GetValue("debug"))
    self.DebugRules.State:SetChecked(not not config:GetValue("debugrules"))
end

--*****************************************************************************
-- Called to apply the values on our page into to the config
--*****************************************************************************
function Addon.ConfigPanel.Debug.Apply(self, config)
    Addon:Debug("Applying debugging panel options")
    config:SetValue("debug", self.Debug.State:GetChecked())
    config:SetValue("debugrules", self.DebugRules.State:GetChecked())
end

--*****************************************************************************
-- Initialize the state of the panel
--*****************************************************************************
function Addon.ConfigPanel.Debug.Init(self)
    self.Title:SetText("Debugging")
    self.HelpText:SetText("<< Debugging options decription >>")
    self.Debug.Label:SetText("Debug Mode")
    self.Debug.Text:SetText("Toggles Debug Mode. Enables generic debugging settings and behaviors.")
    self.DebugRules.Label:SetText("Rule Debugging")
    self.DebugRules.Text:SetText("Toggles debugging mode for rules This will output LOTS of messages to console.")
end
