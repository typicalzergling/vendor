local AddonName, Addon = ...
local L = Addon:GetLocale()
local Config = Addon:GetConfig()

local SETTING_MAX_ITEMS_TO_SELL = Addon.c_Config_MaxSellItems;
local SETTING_ENABLE_BUYBACK = Addon.c_Config_SellLimit; 
local MAX_ITEMS_TO_SELL = 144;
local MIN_ITEMS_TO_SELL = 1;

Addon.ConfigPanel = Addon.ConfigPanel or {}
Addon.ConfigPanel.Debug = {}

--*****************************************************************************
-- Called to sync the values on our page with the config.
--*****************************************************************************
function Addon.ConfigPanel.Debug.Set(self, config)
    Addon:Debug("Setting debug options panel values") 
    self.Debug.State:SetChecked(Addon:IsDebugChannelEnabled("default"));
    self.DebugRules.State:SetChecked(Addon:IsDebugChannelEnabled("rules"));
end

--*****************************************************************************
-- Called to apply the values on our page into to the config
--*****************************************************************************
function Addon.ConfigPanel.Debug.Apply(self, config)
    Addon:Debug("Applying debugging panel options")
    Addon:SetDebugChannel("default", self.Debug.State:GetChecked());
    Addon:SetDebugChannel("rules", self.DebugRules.State:GetChecked());
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

-- Export to public
if not Addon.Public.ConfigPanel then Addon.Public.ConfigPanel = {} end
Addon.Public.ConfigPanel.Debug = Addon.ConfigPanel.Debug