Vendor = Vendor or {}
Vendor.ConfigPanel = Vendor.ConfigPanel or {}
local L = Vendor:GetLocalizedStrings()

--*****************************************************************************
-- Sets the version infromation on the version widget which is present
-- on all of the config pages.
--*****************************************************************************
function Vendor.ConfigPanel.SetVersionInfo(self)
    if (self.VersionInfo) then
    	self.VersionInfo:SetText(Vendor:GetVersion())
    end
end

--*****************************************************************************
-- Called when on of the check boxes in our base template is clicked, this
-- forwards the to a handler if it was provied.
--*****************************************************************************
function Vendor.ConfigPanel.OnCheckboxChange(self)
    local callback = self:GetParent().OnStateChange
    if (callback and (type(callback) == "function")) then
        callback(self, self:GetChecked())
    end
end

--*****************************************************************************
-- Called when the value of slider has changed and delegates to the parent
-- handler if oen was provied.
--*****************************************************************************
function Vendor.ConfigPanel.OnSliderValueChange(self)
    local callback = self:GetParent().OnValueChanged
	if (callback and (type(callback) == "function")) then
		callback(self:GetParent(), self:GetValue())
	end
end

--*****************************************************************************
-- Handles the initialization of the main configruation panel
--*****************************************************************************
function Vendor.ConfigPanel.InitMainPanel(self)
    self.name = L["ADDON_NAME"]
    self.okay =
        function()
            local config = Vendor:GetConfig()
            config:BeginBatch()
                Vendor.ConfigPanel.Sell.Apply(VendorSellConfigPanel, config)
                Vendor.ConfigPanel.Repair.Apply(VendorRepairConfigPanel, config)
                Vendor.ConfigPanel.Perf.Apply(VendorPerfConfigPanel, config)
                if (VendorDebugConfigPanel and Vendor.ConfigPanel.Debug) then
                    Vendor.ConfigPanel.Debug.Apply(VendorDebugConfigPanel, config)
                end
            config:EndBatch()
        end

    -- Simple helper function which handles pushing the config
    -- to each one of our panels.
    local function updatePanels(self, config)
        Vendor.ConfigPanel.Repair.Set(VendorRepairConfigPanel, config)
        Vendor.ConfigPanel.Sell.Set(VendorSellConfigPanel, config)
        Vendor.ConfigPanel.Perf.Set(VendorPerfConfigPanel, config)
        if (VendorDebugConfigPanel and Vendor.ConfigPanel.Debug) then
            Vendor.ConfigPanel.Debug.Set(VendorDebugConfigPanel, config)
        end
    end

    self:RegisterEvent("PLAYER_LOGIN")
    self:SetScript("OnEvent", function(self, event)
            updatePanels(self, Vendor:GetConfig())
            self:UnregisterEvent(event)
        end)
    Vendor:GetConfig():AddOnChanged(function(...) updatePanels(self, ...) end)
    InterfaceOptions_AddCategory(self)
end

--*****************************************************************************
-- Handle the initialization of a child configuration panel.
--*****************************************************************************
function Vendor.ConfigPanel.InitChildPanel(self)
    self.parent = L["ADDON_NAME"]
    self.name = self.Title:GetText()
    InterfaceOptions_AddCategory(self)
end
