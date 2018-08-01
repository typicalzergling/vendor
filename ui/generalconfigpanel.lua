local Addon, L, Config = _G[select(1,...).."_GET"]()

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
    Addon:Debug("Showing rules dialog")
    VendorRulesDialog:Toggle()
end

--*****************************************************************************
-- Called to push the settings from our page into the addon
--*****************************************************************************
function GeneralPanel.Apply(self)
    Addon:Debug("Applying sell panel configuration")
    Config:SetValue(SETTING_AUTOSELL, self.AutoSell.State:GetChecked())
    Config:SetValue(SETTING_TOOLTIP, self.Tooltip.State:GetChecked())
    Config:SetValue(SETTING_TOOLTIP_RULE, self.Tooltip.State:GetChecked() and self.TooltipRule.State:GetChecked())
    Config:SetValue(SETTING_ENABLE_BUYBACK, self.AutoSell.State:GetChecked() and self.enableBuyback.State:GetChecked());
end

--*****************************************************************************
-- Pull the value from the config into the panel.
--*****************************************************************************
function GeneralPanel.Set(self)
    Addon:Debug("Setting sell panel config")
    self.AutoSell.State:SetChecked(not not Config:GetValue(SETTING_AUTOSELL));
    self.Tooltip.State:SetChecked(not not Config:GetValue(SETTING_TOOLTIP));
    self.TooltipRule.State:SetChecked(not not Config:GetValue(SETTING_TOOLTIP_RULE));
    self.enableBuyback.State:SetChecked(not not Config:GetValue(SETTING_ENABLE_BUYBACK));
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
    self.TooltipRule.Label:SetText(L.OPTIONS_SETTINGNAME_EXTRARULEINFO);
    self.TooltipRule.Text:SetText(L.OPTIONS_SETTINGDESC_EXTRARULEINFO);
    self.Tooltip.OnStateChange =
        function(checkbox, state)
           GeneralPanel.updateSubItems(self);
        end

    self.OpenBindings:SetText(L["OPTIONS_SHOW_BINDINGS"]);
    self.OpenRules:SetText(L["OPTIONS_OPEN_RULES"]);
end
