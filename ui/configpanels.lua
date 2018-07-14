Vendor = Vendor or {}
Vendor.ConfigPanel = Vendor.ConfigPanel or {}
local L = Vendor:GetLocalizedStrings()

function Vendor.ConfigPanel.SetVersionInfo(self)
    if (self.VersionInfo) then
        local addonVerison = GetAddOnMetadata("Vendor", "Version")
        --@debug@
        addonVersion = "(Working)"
        --@end-debug@
    	self.VersionInfo:SetText(addonVersion)
    end
end

function Vendor.ConfigPanel.OnCheckboxChange(self)
    local callback = self:GetParent().OnStateChange
    if (callback and (type(callback) == "function")) then
        callback(self, self:GetChecked())
    end
end

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

    local function updatePanels(self, config)
        Vendor.ConfigPanel.Repair.Set(VendorRepairConfigPanel, config)
        Vendor.ConfigPanel.Sell.Set(VendorSellConfigPanel, config)
        Vendor.ConfigPanel.Perf.Set(VendorPerfConfigPanel, config)
        if (VendorDebugConfigPanel and Vendor.ConfigPanel.Debug) then
            Vendor.ConfigPanel.Debug.Set(VendorDebugConfigPanel, config)
        end
    end

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:SetScript("OnEvent", function(self) updatePanels(self, Vendor:GetConfig())  end)
    Vendor:GetConfig():AddOnChanged(function(...) updatePanels(self, ...) end)
    print("adding parent pane;")
    InterfaceOptions_AddCategory(self)
end

function Vendor.ConfigPanel.InitChildPanel(self)
    self.parent = L["ADDON_NAME"]
    self.name = self.Title:GetText()
    InterfaceOptions_AddCategory(self)
end
