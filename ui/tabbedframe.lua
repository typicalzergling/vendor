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
    --tab = assert(self:FindTab(tabId), string.format("Unable to locate TAB(%d)", tabId));
    --tab:SetText(tabName)
    --PanelTemplates_TabResize(tab, 0)
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
            --tab.activeBg:Show();
            --tab.normalBg:Hide();
            if (tab.Spacers) then 
                for _, spacer in ipairs(tab.Spacers) do
                    spacer:Show()
                end
            end
        else
            --tab.activeBg:Hide();
            --tab.normalBg:Show();
            if (tab.Spaces) then
                for _, spacer in ipairs(tab.Spacers) do
                    spacer:Hide()
                end
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

-- Check if the id matches the specified argument
local function idPredicate(frame, key, id)
    return (frame:GetID() == id);
end

local TabFrameMixin = {};

-- Initializes the tabs
function TabFrameMixin:InitializeTabs(tabs, panels, active)
    assert(type(tabs) == "table", "Expected 'tabs' to be an array of tab frames");
    assert(type(panels) == "table", "Expected 'panels' to be an array of panel frames");
    assert(table.getn(tabs) == table.getn(panels), string.format("The length of 'tabs' is diffrent than the length of 'panels' (%d ~= %d)", #tabs, #panels));
    
    self.tfTabs = tabs or {};
    self.tfPanels = panels or {}; 
    table.forEach(self.tfTabs, PanelTemplates_TabResize, 0);
    self.selectedTab = math.min(#self.Tabs, selectedTab or 0);
    PanelTemplates_SetNumTabs(self, table.getn(self.Tabs));
    PanelTemplates_UpdateTabs(self);
    if (table.getn(tabs)) then
        self:SetActiveTab(active or tabs[1]:GetID());
    end
end

-- Sets the active tab 
function TabFrameMixin:SetActiveTab(tabId)
    if (tabId ~= tfCurrentTab) then
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
        local tab = assert(self:GetTab(tabId), string.format("Expected %d tab to be valid", tabId));
        PanelTemplates_Tab_OnClick(tab, self);
        
        table.forEach(self.tfPanels, 
            function(panel)
                if (panel:GetID() == tabId) then
                    panel:Show();
                else
                    panel:Hide();
                end
            end);

        self.tfCurrentTab = tabId;
    end
end

function TabFrameMixin:GetActiveTab()
    return self.tfCurrentTab;
end

-- Get the tab by id
function TabFrameMixin:GetTab(tabId)
    return table.find(self.tfTabs, idPredicate, tabId);
end

-- Gets the panel by id
function TabFrameMixin:GetTabPanel(tabId)
    return table.find(self.tfPanels, idPredicate, tabId);
end

Package.TabbedFrame = TabbedFrame;
Package.TabFrameMixin = TabFrameMixin;
