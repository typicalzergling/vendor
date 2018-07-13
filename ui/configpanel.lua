
Vendor = Vendor or {}
Vendor.ConfigPanel = {}

function Vendor.ConfigPanel.OnLoad(self)
    local L = Vendor:GetLocalizedStrings()
    self.name = L["ADDON_NAME"]
    self.Title:SetText(string.format("%s (%s%s%s)", L["ADDON_NAME"], GREEN_FONT_COLOR_CODE, GetAddOnMetadata("Vendor", "Version"), FONT_COLOR_CODE_CLOSE))
    self.okay = function() Vendor:Debug("vendor interface panel: ok") end
    self.cancel = function() Vendor:Debug("vendor interface panel: cancel") end
    InterfaceOptions_AddCategory(self)

    print("in onload")

    self.AutoSell.Label:SetText(L["OPTIONS_SETTINGNAME_AUTOSELL"])
    self.AutoSell.Text:SetText(L["OPTIONS_SETTINGDESC_AUTOSELL"])

    self.AutoRepair.Label:SetText(L["OPTIONS_SETTINGNAME_AUTOREPAIR"])
    self.AutoRepair.Text:SetText(L["OPTIONS_SETTINGDESC_AUTOREPAIR"])

end

