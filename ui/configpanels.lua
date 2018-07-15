local Addon, L, Config = _G[select(1,...).."_GET"]()

Addon.ConfigPanel = Addon.ConfigPanel or {}

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
-- Handles the initialization of the main configruation panel
--*****************************************************************************
function Addon.ConfigPanel.InitMainPanel(self)
    self.name = L["ADDON_NAME"]
    self.okay =
        function()
            local config = Addon:GetConfig()
            config:BeginBatch()
                Addon.ConfigPanel.General.Apply(VendorGeneralConfigPanel)
                Addon.ConfigPanel.Repair.Apply(VendorRepairConfigPanel, config)
                Addon.ConfigPanel.Perf.Apply(VendorPerfConfigPanel, config)
                if (VendorDebugConfigPanel and Addon.ConfigPanel.Debug) then
                    Addon.ConfigPanel.Debug.Apply(VendorDebugConfigPanel, config)
                end
            config:EndBatch()
        end

    -- Simple helper function which handles pushing the config
    -- to each one of our panels.
    local function updatePanels(self, config)
        Addon.ConfigPanel.Repair.Set(VendorRepairConfigPanel, config)
        Addon.ConfigPanel.General.Set(VendorGeneralConfigPanel)
        Addon.ConfigPanel.Perf.Set(VendorPerfConfigPanel, config)
        if (VendorDebugConfigPanel and Addon.ConfigPanel.Debug) then
            Addon.ConfigPanel.Debug.Set(VendorDebugConfigPanel, config)
        end
    end

    self:RegisterEvent("PLAYER_LOGIN")
    self:SetScript("OnEvent", function(self, event)
            updatePanels(self, Addon:GetConfig())
            self:UnregisterEvent(event)
        end)
    Addon:GetConfig():AddOnChanged(function(...) updatePanels(self, ...) end)
    InterfaceOptions_AddCategory(self)
end

--*****************************************************************************
-- Handle the initialization of a child configuration panel.
--*****************************************************************************
function Addon.ConfigPanel.InitChildPanel(self)
    self.parent = L["ADDON_NAME"]
    self.name = self.Title:GetText()
    InterfaceOptions_AddCategory(self)
end
