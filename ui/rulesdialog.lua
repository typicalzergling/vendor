local Addon, L, Config = _G[select(1,...).."_GET"]()

local RULE_TYPE_KEEP = Addon.c_RuleType_Keep
local RULE_TYPE_SELL = Addon.c_RuleType_Sell
local RULE_TYPE_CUSTOM = "Custom"
local PANEL_BACKGROUND_COLOR = { 1.0, 1.0, 1.0, 0.15 }
local PANEL_BORDER_COLOR =  { 0.6, 0.6, 0.6, 1 }
local RULES_DIALOG_LOC_SETTING = "rulesdialog_position"

Addon.RulesDialog = {
    
    --=========================================================================
    -- Given a frame which represents a rules list this pushes the values 
    -- into our settings. 
    --=========================================================================
    UpdateRuleConfig = function(frame)
        Addon:DebugRules("Applying config for rule type '%s'", frame.RuleType)
        Config:SetRulesConfig(frame.RuleType, getRuleConfigFromList(frame))
    end,

    --=========================================================================
    -- Initialize the tab, and panel frame within the dialog
    --=========================================================================
    InitTab = function(self, id, tabName, helpText)
        local function findById(frames, id)
            for _, f in ipairs(frames) do
                if (f:GetID() == id) then
                    return f
                end
            end
        end

        tab = findById(self.Tabs, id)
        assert(tab ~= nil, string.format("Unable to locate TAB(%d)", id))
        tab:SetText(L[tabName])
        PanelTemplates_TabResize(tab, 0)

        panel = findById(self.Panels, id)
        assert(panel ~= nil, string.format("Unable to locate PANEL(%d)", id))
        panel.TopText:SetText(L[helpText])
        if (panel.List) then
            panel.List:SetBackdropBorderColor(unpack(PANEL_BORDER_COLOR))
            panel.List:SetBackdropColor(unpack(PANEL_BACKGROUND_COLOR))
        end
    end,

    --=========================================================================
    -- When the frame has been moved this is called to save the location
    -- into our config so we remember the position for the next interface load
    --=========================================================================
    SavePosition = function(self)
        if (self:GetNumPoints() == 1) and (self:GetParent() == UIParent) then
            local point = { self:GetPoint(1) }
            if (point) then
                if (#point == 5) then
                    table.remove(point, 2)
                end
                Config:SetValue(RULES_DIALOG_LOC_SETTING, point)
            end                
        end            
    end,

    --=========================================================================
    -- Resets the dialogs position back to the default (center of the scren)
    --=========================================================================
    ResetPosition = function(self)
        Vendor:Debug("Resetting position of the rules dialog")
        Config:SetValue(RULES_DIALOG_LOC_SETTING, nil)
    end,

    --=========================================================================
    -- Initialize all of the parts of our dialog and setup all of the callbacks
    --=========================================================================
    OnLoad = function(self)
        self.Caption:SetText(L["CONFIG_DIALOG_CAPTION"])

        -- Setup the panels
        Addon.RulesDialog.InitTab(self, 1, "CONFIG_DIALOG_KEEPRULES_TAB", "CONFIG_DIALOG_KEEPRULES_TEXT")
        Addon.RulesDialog.InitTab(self, 2, "CONFIG_DIALOG_SELLRULES_TAB", "CONFIG_DIALOG_SELLRULES_TEXT")
        Addon.RulesDialog.InitTab(self, 3, "CONFIG_DIALOG_CUSTOMRULES_TAB", "CONFIG_DIALOG_CUSTOMRULES_TEXT")

        -- Initialize the tabs
        PanelTemplates_SetNumTabs(self, table.getn(self.Tabs))
        self.selectedTab = 2
        PanelTemplates_UpdateTabs(self)
        Addon.RulesUI.RuleDialog_ShowTab(self, self.selectedTab)

        -- Setup dialog location persistence
        local function setDialogLocation() 
                local point = Config:GetValue(RULES_DIALOG_LOC_SETTING)
                if (not self:IsShown() or (point == nil)) then
                    self:ClearAllPoints()
                    if (point and (type(point) == "table") and (#point == 4)) then
                        Addon:Debug("Setting rules dialog position (p=%s, rp=%s, x=%d, y=%d)", unpack(point))
                        self:SetPoint(point[1], UIParent, point[2], point[3], point[4])
                    else
                        Addon:Debug("Setting rules dialog to the center")
                        self:SetPoint("CENTER", UIParent)
                    end
                end
            end

        Addon:RegisterEvent("PLAYER_LOGIN", setDialogLocation)
        Config:AddOnChanged(setDialogLocation)
    end,

    --=========================================================================
    -- Handles making sure everything is updated when the dialog is shown.
    --=========================================================================
    PrepareToShow = function(self)
        self.SellPanel.List:SetRuleConfig(Config:GetRulesConfig(RULE_TYPE_SELL))
        self.KeepPanel.List:SetRuleConfig(Config:GetRulesConfig(RULE_TYPE_KEEP))
    end,

    --=========================================================================
    -- Changes between tabs in the dialog, shows the proper panel hides the 
    -- reset, shows/hide frame components so the dialog looks correct.
    --=========================================================================
    ShowTab = function(self, tabId)
        -- Update our tabs and spaces
        for _, tab in ipairs(self.Tabs) do
            if (tab:GetID() == tabId) then
                for _, spacer in ipairs(tab.Spacers) do
                    spacer:Show()
                end
            else
                for _, spacer in ipairs(tab.Spacers) do
                    spacer:Hide()
                end
            end
        end

        -- Update our panels
        for _, panel in ipairs(self.Panels) do
            if (panel:GetID() == tabId) then
                panel:Show()
            else
                panel:Hide()
            end
        end
    end,

    --=========================================================================
    -- Returns the configuration (in the dialog) to the defaults this does
    -- not change the settings until the user clicks "Ok"
    --=========================================================================
    SetDefaults = function(self)
        Addon:DebugRules("Restoring rule configuration to the default")
        self.SellPanel.List:SetRuleConfig(Config:GetDefaultRulesConfig(RULE_TYPE_SELL))
        self.KeepPanel.List:SetRuleConfig(Config:GetDefaultRulesConfig(RULE_TYPE_KEEP))
    end,

    --=========================================================================
    -- Called to handle the "OK" button
    --=========================================================================
    OnOk = function(self)
        Addon:DebugRules("Applying new rule configuration")
        Config:BeginBatch()
            Addon.RulesDialog.UpdateRuleConfig(self.SellPanel.List)
            Addon.RulesDialog.UpdateRuleConfig(self.KeepPanel.List)
        Config:EndBatch()
        HideParentPanel(self.Container)
    end,

    --=========================================================================
    -- Toggles the visibility of the rules dialog, if the dialog is currently
    -- visible this is the as clicking cancel.
    --=========================================================================
    Toggle = function()
        local dialog = VendorRulesDialog
        if (dialog:IsShown()) then
            dialog:Hide()
        else
            dialog:Show()
        end
    end,
}
