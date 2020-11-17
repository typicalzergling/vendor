--[[===========================================================================
    |
    ========================================================================--]]

local _, Addon = ...
local TabFrameMixin = {};

-- Check if the id matches the specified argument
local function idPredicate(frame, key, id)
    return (frame:GetID() == id);
end

--[[===========================================================================
    | Initialize the array of tabs
    ========================================================================--]]
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

--[[===========================================================================
    | Changes teh active tab
    ========================================================================--]]
function TabFrameMixin:SetActiveTab(tabId, quiet)
    if (tabId ~= tfCurrentTab) then
        if ((type(quiet) ~= "boolean") or (quiet ~= true)) then
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
        end
        
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

--[[===========================================================================
    | Retrieves the current tab
    ========================================================================--]]
function TabFrameMixin:GetActiveTab()
    return self.tfCurrentTab;
end

--[[===========================================================================
    | Retrieve the tab with associated id
    ========================================================================--]]
function TabFrameMixin:GetTab(tabId)
    return table.find(self.tfTabs, idPredicate, tabId);
end

--[[===========================================================================
    | Gets the panel associated with te specified tab.
    ========================================================================--]]
function TabFrameMixin:GetTabPanel(tabId)
    return table.find(self.tfPanels, idPredicate, tabId);
end

Addon.Controls = Addon.Controls or {}
Addon.Controls.TabFrameMixin = TabFrameMixin;
