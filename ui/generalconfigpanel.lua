local Addon, L, Config = _G[select(1,...).."_GET"]()

local SETTING_AUTOSELL = Addon.c_Config_AutoSell
local SETTING_TOOLTIP = Addon.c_Config_Tooltip
local SETTING_TOOLTIP_RULE = Addon.c_Config_Tooltip_Rule

Addon.ConfigPanel = Addon.ConfigPanel or {}
Addon.ConfigPanel.General = {

    --*****************************************************************************
    -- Called when the enabled state of "auto-repair" to keep the state
    -- of hte sub-options in sync.
    --*****************************************************************************
    updateTooltipRule = function(self, repairState)
        if (not repairState) then
            self.TooltipRule.State:Disable()
        else
            self.TooltipRule.State:Enable()
        end
    end,

    --*****************************************************************************
    -- Called to handle a click on the "open rules" dialog
    --*****************************************************************************
    OnOpenRules = function()
        Addon:Debug("Showing rules dialog")
        Addon.RulesDialog.Toggle()
    end,

    --*****************************************************************************
    -- Called to handle a click on the "open bindings" button
    --*****************************************************************************
    OnOpenBindings = function()
        Addon:Debug("Showing key bindings")
        Vendor.OpenKeybindings_Cmd()
    end,

    --*****************************************************************************
    -- Called to push the settings from our page into the addon
    --*****************************************************************************
    Apply = function(self)
        Addon:Debug("Applying sell panel configuration")
        Config:SetValue(SETTING_AUTOSELL, self.AutoSell.State:GetChecked())
        Config:SetValue(SETTING_TOOLTIP, self.Tooltip.State:GetChecked())
        Config:SetValue(SETTING_TOOLTIP_RULE, self.Tooltip.State:GetChecked() and self.TooltipRule.State:GetChecked())
    end,

    --*****************************************************************************
    -- Pull the value from the config into the panel.
    --*****************************************************************************
    Set = function(self)
        Addon:Debug("Setting sell panel config")
        self.AutoSell.State:SetChecked(not not Config:GetValue(SETTING_AUTOSELL))
        self.Tooltip.State:SetChecked(not not Config:GetValue(SETTING_TOOLTIP))
        self.TooltipRule.State:SetChecked(not not Config:GetValue(SETTING_TOOLTIP_RULE))
        Addon.ConfigPanel.General.updateTooltipRule(self, self.Tooltip.State:GetChecked())        
    end,

    --*****************************************************************************
    -- Called to sync the values on our page with the config.
    --*****************************************************************************
    Init = function(self)
        self.Title:SetText(L["OPTIONS_HEADER_SELLING"])
        self.HelpText:SetText(L["OPTIONS_DESC_SELLING"])

        self.AutoSell.Text:SetText(L["OPTIONS_SETTINGDESC_AUTOSELL"])
        self.AutoSell.Label:SetText(L["OPTIONS_SETTINGNAME_AUTOSELL"])

        self.Tooltip.Text:SetText(L["OPTIONS_SETTINGDESC_TOOLTIP"])
        self.Tooltip.Label:SetText(L["OPTIONS_SETTINGNAME_TOOLTIP"])
        self.TooltipRule.Label:SetText(L["OPTIONS_SETTINGNAME_RULE_ON_TOOLTIP"])
        self.Tooltip.OnStateChange =
            function(checkbox, state)
               Addon.ConfigPanel.General.updateTooltipRule(self, state)
            end
        
        self.OpenBindings:SetText(L["OPTIONS_SHOW_BINDINGS"])
        self.OpenRules:SetText(L["OPTIONS_OPEN_RULES"])
    end,
}
