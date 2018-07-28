--[[===========================================================================
    | Copyright (c) 2018
    |
    | TabbedFrame:
    |
    ========================================================================--]]

local Package = select(2, ...);
local TabbedFrame = {};

function TabbedFrame:FindTab(tabId)
    if (self.Tabs) then
        for _, tab in ipairs(self.Tabs) do
            if (tab:GetID() == tabId) then
                return tab;
            end
        end
    end
end

function TabbedFrame:FindPanel(tabId)
    if (self.Panels) then
        for _, panel in ipairs(self.Panels) do
            if (panel:GetID() == tabId) then
                return panel;
            end
        end
    end
end

--=========================================================================
-- Initialize the tab, and panel frame within the dialog
--=========================================================================
function TabbedFrame:InitTab(tabId, tabName)
    tab = assert(self:FindTab(tabId), string.format("Unable to locate TAB(%d)", tabId));
    tab:SetText(tabName)
    PanelTemplates_TabResize(tab, 0)
end

--=========================================================================
-- Changes between tabs in the dialog, shows the proper panel hides the
-- reset, shows/hide frame components so the dialog looks correct.
--=========================================================================
function TabbedFrame:ShowTab(tab)
    local tabId = tab:GetID();
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    PanelTemplates_Tab_OnClick(tab, self);

    -- Update our tabs, spaces, and backgrounds
    for _, tab in ipairs(self.Tabs) do
        if (tab:GetID() == tabId) then
            tab.activeBg:Show();
            tab.normalBg:Hide();
            for _, spacer in ipairs(tab.Spacers) do
                spacer:Show()
            end
        else
            tab.activeBg:Hide();
            tab.normalBg:Show();
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
end

function TabbedFrame:InitTabs(selectedTab)
    PanelTemplates_SetNumTabs(self, table.getn(self.Tabs))
    self.selectedTab = math.min(#self.Tabs, selectedTab);
    PanelTemplates_UpdateTabs(self)
    self:ShowTab(self.Tabs[self.selectedTab]);
end

Package.TabbedFrame = TabbedFrame;
