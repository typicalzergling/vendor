local AddonName, Addon = ...
local L = Addon:GetLocale()

Addon.ConfigPanel = Addon.ConfigPanel or {}
local configPanels = {};

--*****************************************************************************
-- Sets the version infromation on the version widget which is present
-- on all of the config pages.
--*****************************************************************************
function Addon.ConfigPanel.SetVersionInfo(self)
    if (self.VersionInfo) then
        self.VersionInfo:SetText(Addon:GetVersion())
    end
end

--*****************************************************************************
-- Called when on of the check boxes in our base template is clicked, this
-- forwards the to a handler if it was provied.
--*****************************************************************************
function Addon.ConfigPanel.OnCheckboxChange(self)
    local callback = self:GetParent().OnStateChange
    if (callback and (type(callback) == "function")) then
        callback(self, self:GetChecked())
    end
end

--*****************************************************************************
-- Called when the value of slider has changed and delegates to the parent
-- handler if one was provied.
--*****************************************************************************
function Addon.ConfigPanel.OnSliderValueChange(self)
    local callback = self:GetParent().OnValueChanged
    if (callback and (type(callback) == "function")) then
        callback(self:GetParent(), self:GetValue())
    end
end

--*****************************************************************************
-- Handles the enabling/disabing of a slider template, we change the text 
-- color of all parts of template so it looks disabled. We hide some
-- parts of UX which aren't interesting if it's disabled.
--*****************************************************************************
function Addon.ConfigPanel.SetSliderEnable(slider, enabled)
    if (enabled) then
        slider.Label:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
        slider.Text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
        slider.DisplayValue:Show();
        slider.Value:Enable();
    else
        slider.Value:Disable();
        slider.DisplayValue:Hide();
        slider.Label:SetTextColor(DISABLED_FONT_COLOR.r, DISABLED_FONT_COLOR.g, DISABLED_FONT_COLOR.b);
        slider.Text:SetTextColor(DISABLED_FONT_COLOR.r, DISABLED_FONT_COLOR.g, DISABLED_FONT_COLOR.b);
    end
end

local function invokePanelMethod(method, panel, ...)
    local fn = panel[method];
    if (type(fn) == "function") then
        local result, msg = xpcall(fn, CallErrorHandler, panel, ...);
        if (not result) then
            Addon:Debug("config", "Failed to invoke '%s' on '%s': %s%s|r", method, panel.PanelType, RED_FONT_COLOR_CODE, msg);
            return false;
        else
            Addon:Debug("config", "Succesfully invoked '%s' on '%s'", method, panel.PanelType);
        end
    end

    return true;
end

local function applySubclass(panel, name)
    local subclass = Addon.ConfigPanel[name];
    if (type(subclass) == "table") then
        Mixin(panel, subclass);
        panel.PanelType = name;
    else
        panel.PanelType = "<unknown>";
    end

    return panel;
end

function Addon.ConfigPanel:Save()
    Addon:Debug("config", "Apply panel settings (%d panels)", table.getn(configPanels));
    for _, panel in ipairs(configPanels) do
        invokePanelMethod("Apply", panel);
    end
end

function Addon.ConfigPanel.OnShow(self)
    invokePanelMethod("Set", self);
end

function Addon.ConfigPanel:SetDefaults()
    Addon:Debug("config", "Apply default settings (%d panels)", table.getn(configPanels));
    for _, panel in ipairs(configPanels) do
        invokePanelMethod("Default", panel);
    end

    self:Refresh();
end

function Addon.ConfigPanel:Cancel()
    Addon:Debug("config", "Cancel panel settings (%d panels)", table.getn(configPanels));
    for _, panel in ipairs(configPanels) do
        invokePanelMethod("Cancel", panel);
    end
end

function Addon.ConfigPanel:Refresh()
    Addon:Debug("config", "Refresh panel settings (%d panels)", table.getn(configPanels));
    for _, panel in ipairs(configPanels) do
        invokePanelMethod("Set", panel);
    end
end

function Addon.ConfigPanel:AddPanel(panel, name)
    applySubclass(panel, name);
    local title = "<unknown>";
    if (panel.Title) then
        title = panel.Title:GetText();
    end

    invokePanelMethod("Init", panel);
    Addon.ConfigPanel.SetVersionInfo(panel);

    panel.parent = L["ADDON_NAME"];
    panel.name = panel.Title:GetText();
    panel:SetScript("OnShow", Addon.ConfigPanel.OnShow);
    InterfaceOptions_AddCategory(panel);    
    table.insert(configPanels, panel);

    Addon:Debug("config", "Add panel '%s' [%s] (%d panels)", title, name, table.getn(configPanels));
end

--*****************************************************************************
-- Handles the initialization of the main configruation panel
--*****************************************************************************
function Addon.ConfigPanel.InitMainPanel(self, name)
    self.name = L["ADDON_NAME"]
    self:SetScript("OnShow", Addon.ConfigPanel.OnShow);
    applySubclass(self, name);
    
    invokePanelMethod("Init", self);
    Addon.ConfigPanel.SetVersionInfo(self);
    InterfaceOptions_AddCategory(self);

    self.okay = function() Addon.ConfigPanel:Save() end;
    self.default = function() Addon.ConfigPanel:Defaults() end;
    self.refresh = function() Addon.ConfigPanel:Refresh() end;
    self.cancel = function() Addon.ConfigPanel:Cancel() end;

    table.insert(configPanels, self);
    Addon:Debug("config", "Initialize main panel: %s", name);
end

-- Must make this public.
-- This is tricky becuase all the child panels have already been created.
assert(Addon.Public.ConfigPanel)
Addon:MergeTable(Addon.Public.ConfigPanel, Addon.ConfigPanel)