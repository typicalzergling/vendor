local Addon, L, Config = _G[select(1,...).."_GET"]()
local Package = select(2, ...);
local KEEP_TABID = 1;
local SELL_TABID = 2;
local CUSTOM_TABID = 4;
local SCRAP_TABID = 3;
local LISTS_TABID = 5;
local RulesDialog = {};

function RulesDialog.OnLoad(self)
    Mixin(self, Package.TabbedFrame, RulesDialog);
    self:SetClampedToScreen(true)
    self.Caption:SetText(L["CONFIG_DIALOG_CAPTION"])

    -- Setup the panels
    self:SetupTab(KEEP_TABID, "CONFIG_DIALOG_KEEPRULES_TAB", "CONFIG_DIALOG_KEEPRULES_TEXT")
    self:SetupTab(SELL_TABID, "CONFIG_DIALOG_SELLRULES_TAB", "CONFIG_DIALOG_SELLRULES_TEXT")
    self:SetupTab(CUSTOM_TABID, "CONFIG_DIALOG_CUSTOMRULES_TAB", "CONFIG_DIALOG_CUSTOMRULES_TEXT")
    self:SetupTab(SCRAP_TABID, "CONFIG_DIALOG_SCRAPRULES_TAB", "CONFIG_DIALOG_SCRAPRULES_TEXT")
    self:SetupTab(LISTS_TABID, "CONFIG_DIALOG_LISTS_TAB", "CONFIG_DIALOG_LISTS_TEXT")
    self.createNewRule:SetText(L.CREATE_BUTTON);

	-- For classic disable the scrap tab
	if (Addon.IsClassic) then
		local scrapTab = self.ScrapTab;
		Addon:Print("Disabling ScrapTab: " .. scrapTab:GetName());
		if (scrapTab) then
			scrapTab:Disable();
			scrapTab:Hide();
		end
	end

    -- Initialize the tabs
    self:InitTabs(SELL_TABID);
end

function RulesDialog:SetupTab(tabId, tabName, helpText)
    self:InitTab(tabId, L[tabName]);

    local panel = assert(self:FindPanel(tabId), string.format("Unable to locate PANEL(%d)", tabId));
    if (panel) then
        if (panel.TopText and helpText) then
            panel.TopText:SetText(L[helpText]);
        end

        if (tabId == LISTS_TABID) then
            panel.alwaysSellLabel:SetText("Always Sell:");
            panel.alwaysKeepLabel:SetText("Always Keep:");
        end
    end
end

function RulesDialog:OnShow()
    self.KeepPanel.list:RefreshView();
    self.SellPanel.list:RefreshView();
    self.ScrapPanel.list:RefreshView();
end

function RulesDialog:SetDefaults()
    Addon:DebugRules("Restoring rule configuration to the default")
    self.SellPanel.list:SetDefaultConfig();
    self.ScrapPanel.list:SetDefaultConfig();
end

function RulesDialog:OnOk()
    Addon:DebugRules("Applying new rule configuration")
    Config:BeginBatch()
        self.SellPanel.list:UpdateConfig();
        self.KeepPanel.list:UpdateConfig();
        self.ScrapPanel.list:UpdateConfig();
    Config:EndBatch()
    --HideParentPanel(self.Container)
end

function RulesDialog:Toggle()
    if (self:IsShown()) then
        self:Hide()
    else
        self:Show()
    end
end

Addon.RulesDialog = RulesDialog;
