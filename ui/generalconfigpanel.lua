local AddonName, Addon = ...
local L = Addon:GetLocale()

local SETTING_AUTOSELL = Addon.c_Config_AutoSell
local SETTING_TOOLTIP = Addon.c_Config_Tooltip
local SETTING_TOOLTIP_RULE = Addon.c_Config_Tooltip_Rule;
local SETTING_ENABLE_BUYBACK = Addon.c_Config_SellLimit;

Addon.ConfigPanel = Addon.ConfigPanel or {}
Addon.ConfigPanel.General = {}
local GeneralPanel = Addon.ConfigPanel.General;

--*****************************************************************************
-- Called when the state of our two big settings tooltip and auto sell change
-- allowing us update the state of the sub settings.
--*****************************************************************************
function GeneralPanel.updateSubItems(self)
    -- Tooltip sub-setting
    if (not self.Tooltip.State:GetChecked()) then
        self.TooltipRule.State:Disable();
    else
        self.TooltipRule.State:Enable()
    end
end

--*****************************************************************************
-- Called to handle a click on the "open rules" dialog
--*****************************************************************************
function GeneralPanel.OnOpenRules()
    Addon:DebugChannel("config", "Showing rules dialog")
    VendorRulesDialog:Show()
end


--*****************************************************************************
-- Called to handle a click on the Open Keybindings button
--*****************************************************************************
function GeneralPanel.OpenBindings()
    Addon:DebugChannel("config", "Showing key bindings")
    Addon:OpenKeybindings_Cmd()
end

--[[===========================================================================
    | ResetRules:
    |   Resets the rule to defauls.
    =========================================================================]]
function GeneralPanel.ResetRules()
    local defaults = Addon.DefaultConfig.Rules;
    local profile = Addon:GetProfile();

    profile:SetRules(Addon.c_RuleType_Sell, defaults.sell or {});
    profile:SetRules(Addon.c_RuleType_Keep, defaults.keep or {});
    profile:SetRules(Addon.c_RuleType_Scrap, defaults.scrap or {});
    Addon:Print("The rules have been reset to the defaults");
end

--[[===========================================================================
    | ApplyDefaults:
    |   Resets all of the addons settings to the defaults.
    =========================================================================]]
    function GeneralPanel.ApplyDefaults()
    Addon.ConfigPanel:SetDefaults();
    Addon:Print("All settings have been reset to the defaults");
end

--*****************************************************************************
-- Called to push the settings from our page into the addon
--*****************************************************************************
function GeneralPanel.Apply(self)
    Addon:DebugChannel("config", "Applying sell panel configuration");

    local profile = Addon:GetProfile();
    profile:SetValue(SETTING_AUTOSELL, self.AutoSell.State:GetChecked())
    profile:SetValue(SETTING_TOOLTIP, self.Tooltip.State:GetChecked())
    profile:SetValue(SETTING_TOOLTIP_RULE, self.Tooltip.State:GetChecked() and self.TooltipRule.State:GetChecked())
    profile:SetValue(SETTING_ENABLE_BUYBACK, self.AutoSell.State:GetChecked() and self.enableBuyback.State:GetChecked());
end

--[[===========================================================================
    | Default:
    |   Applies the default setting values for this page.
    =========================================================================]]
function GeneralPanel.Default()
    local profile = Addon:GetProfile();
    local defaults = Addon.DefaultConfig.Settings;

    profile:SetValue(SETTING_AUTOSELL, defaults[SETTING_AUTOSELL])
    profile:SetValue(SETTING_TOOLTIP, defaults[SETTING_TOOLTIP])
    profile:SetValue(SETTING_TOOLTIP_RULE, defaults[SETTING_TOOLTIP_RULE])
    profile:SetValue(SETTING_ENABLE_BUYBACK, defaults[SETTING_ENABLE_BUYBACK]);
end

--*****************************************************************************
-- Pull the value from the config into the panel.
--*****************************************************************************
function GeneralPanel.Set(self)
    Addon:DebugChannel("config", "Setting sell panel config");

    local profile = Addon:GetProfile();
    self.AutoSell.State:SetChecked(profile:GetValue(SETTING_AUTOSELL));
    self.Tooltip.State:SetChecked(profile:GetValue(SETTING_TOOLTIP));
    self.TooltipRule.State:SetChecked(profile:GetValue(SETTING_TOOLTIP_RULE));
    self.enableBuyback.State:SetChecked(profile:GetValue(SETTING_ENABLE_BUYBACK));
    GeneralPanel.updateSubItems(self, self.Tooltip.State:GetChecked());
end

--*****************************************************************************
-- Called to sync the values on our page with the config.
--*****************************************************************************
function GeneralPanel.Init(self)
    self.Title:SetText(L["OPTIONS_HEADER_SELLING"]);
    self.HelpText:SetText(L["OPTIONS_DESC_SELLING"]);

    self.AutoSell.Text:SetText(L["OPTIONS_SETTINGDESC_AUTOSELL"]);
    self.AutoSell.Label:SetText(L["OPTIONS_SETTINGNAME_AUTOSELL"]);
    self.enableBuyback.Label:SetText(L.OPTIONS_SETTINGNAME_BUYBACK);
    self.enableBuyback.Text:SetText(L.OPTIONS_SETTINGDESC_BUYBACK);

    self.Tooltip.Text:SetText(L["OPTIONS_SETTINGDESC_TOOLTIP"]);
    self.Tooltip.Label:SetText(L["OPTIONS_SETTINGNAME_TOOLTIP"]);
    self.TooltipRule.Label:SetText(L["OPTIONS_SETTINGNAME_EXTRARULEINFO"]);
    self.TooltipRule.Text:SetText(L["OPTIONS_SETTINGDESC_EXTRARULEINFO"]);
    self.Tooltip.OnStateChange =
        function(checkbox, state)
           GeneralPanel.updateSubItems(self);
        end

    self.openBindings:SetText(L["OPTIONS_SHOW_BINDINGS"]);
    self.openRules:SetText(L["OPTIONS_OPEN_RULES"]);
    self.resetRules:SetText("Default Rules");
    self.resetSettings:SetText("Default settings");
end

-- Export to public
if not Addon.Public.ConfigPanel then Addon.Public.ConfigPanel = {} end
Addon.Public.ConfigPanel.General = Addon.ConfigPanel.General