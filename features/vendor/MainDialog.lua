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
	tabs:AddTab("rules", "CONFIG_DIALOG_RULES_TAB", "Vendor_RulesTab", self.RulesTab)
	tabs:AddTab("lists", "CONFIG_DIALOG_LISTS_TAB", "Vendor_ListsTab", {})
	tabs:AddTab("audit", "CONFIG_DIALOG_AUDIT_TAB", "Vendor_HistoryTab", self.HistoryTab)
	tabs:AddTab("profiles", "OPTIONS_PROFILE_TITLE", "", {})
	tabs:AddTab("settings", "RULES_DIALOG_CONFIG_TAB", "Vendor_SettingsTab", self.SettingsTab)
	tabs:AddTab("help", "EDITRULE_HELP_TAB_NAME", "Vendor_HelpTab", self.HelpTab)
	tabs:ShowTab("rules")
end

function MainDialog:NavigateTo(tabId)
	self.tabs:ShowTab(tabId)
	self:Show()
end

Vendor.MainDialog = MainDialog