local _, Addon = ...
local locale = Addon:GetLocale()
local Vendor = Addon.Features.Vendor
local MainDialog = {}

function MainDialog:OnInitDialog(dialog)
	dialog:SetCaption("ADDON_NAME")

	local tabs = self.tabs
	tabs:AddTab("rules", "CONFIG_DIALOG_RULES_TAB", "Vendor_RulesTab", self.RulesTab)

	-- If the lists feature is enabled add the tab
	if (Addon:IsFeatureEnabled("lists")) then
		local lists = Addon:GetFeature("lists")
		tabs:AddTab(lists:GetTab())
	end

	tabs:AddTab("audit", "CONFIG_DIALOG_AUDIT_TAB", "Vendor_HistoryTab", self.HistoryTab, 1)
	tabs:AddTab("profiles", "OPTIONS_PROFILE_TITLE", "Vendor_ProfilesTab", "Features.Vendor.ProfilesTab", 1)
	tabs:AddTab("settings", "RULES_DIALOG_CONFIG_TAB", "Vendor_SettingsTab", self.SettingsTab, 1)
	tabs:AddTab("help", "EDITRULE_HELP_TAB_NAME", "Vendor_HelpTab", self.HelpTab, 1)
	tabs:ShowTab("rules")
end

function MainDialog:NavigateTo(tabId)
	self.tabs:ShowTab(tabId)
	self:Show()
end

function MainDialog:OnImport()
	local feature = Addon:GetFeature("import")
	print("onimport - ", feature)
	if (feature) then
		feature:ShowImportDialog()
	end
end

Vendor.MainDialog = MainDialog