local AddonName, Addon = ...
local L = Addon:GetLocale()

local Package = select(2, ...);
local KEEP_TABID = 1;
local SELL_TABID = 2;
local CUSTOM_TABID = 3;
local LISTS_TABID = 4;
local RulesDialog = {};

function RulesDialog.OnLoad(self)
    Mixin(self, Package.TabbedFrame, RulesDialog);
    self:SetClampedToScreen(true)

    -- Setup the panels
    self:SetupTab(KEEP_TABID, "CONFIG_DIALOG_KEEPRULES_TEXT")
    self:SetupTab(SELL_TABID, "CONFIG_DIALOG_SELLRULES_TEXT")
    self:SetupTab(CUSTOM_TABID, "CONFIG_DIALOG_CUSTOMRULES_TEXT")
    self:SetupTab(LISTS_TABID, "CONFIG_DIALOG_LISTS_TEXT")
    self.createNewRule:SetText(L.CREATE_BUTTON);

    -- Initialize the tabs
    self:InitTabs(SELL_TABID);

    table.insert(UISpecialFrames, self:GetName());
    self:RegisterForDrag("LeftButton");

    table.forEach(self.Tabs, PanelTemplates_TabResize, 0);
end

function RulesDialog:SetupTab(tabId, helpText)
    self:InitTab(tabId, L[tabName]);

    local panel = assert(self:FindPanel(tabId), string.format("Unable to locate PANEL(%d)", tabId));
    if (panel) then
        if (panel.TopText and helpText) then
            panel.TopText:SetText(L[helpText]);
        end

        if (tabId == LISTS_TABID) then
            panel.alwaysSellLabel:SetText(L["CONFIG_DIALOG_LISTS_ALWAYS_LABEL"]);
            panel.alwaysKeepLabel:SetText(L["CONFIG_DIALOG_LISTS_NEVER_LABEL"]);
        end
    end
end

function RulesDialog:OnShow()
end

function RulesDialog:OnOk()
    Addon:Debug("rulesdialog", "Applying new rule configuration")
    self.SellPanel.list:UpdateConfig();
    self.KeepPanel.list:UpdateConfig();
end

-- Export to Public
Addon.Public.RulesDialog = RulesDialog
Addon.RulesDialog = RulesDialog;
