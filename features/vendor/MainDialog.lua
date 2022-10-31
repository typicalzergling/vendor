local _, Addon = ...
local locale = Addon:GetLocale()
local Vendor = Addon.Features.Vendor
local MainDialog = {}

local BUTTONS = {
    close = { label = CLOSE, handler = "Hide" }
}

function MainDialog:OnInitDialog(dialog)
	dialog:SetCaption("ADDON_NAME")
	dialog:SetButtons(BUTTONS)

	local tabs = self.tabs
	tabs:AddTab("rules", "-rules-", "Vendor_RulesTab", self.RulesTab)
	tabs:AddTab("lists", "-lists-", "Vendor_ListsTab", {})
	tabs:AddTab("audit", "-audit-", "", {})
	tabs:AddTab("profiles", "-profiles-", "", {})
	tabs:AddTab("settings", "-settings-", "Vendor_SettingsTab", self.SettingsTab)
	tabs:AddTab("help", "-help-", "", {})

	local t = tabs:ShowTab("rules"):GetFrame()
	Addon.CommonUI.DialogBox.Colorize(t)
end

function MainDialog:NavigateTo(tabId)
	self.tabs:ShowTab(tabId)
	self:Show()
end

Vendor.MainDialog = MainDialog