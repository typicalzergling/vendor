local AddonName, Addon = ...
local L = Addon:GetLocale()
local SettingsPanel = {}

local SETTINGS_DATA = 
{
	{
		name = "OPTIONS_CATEGORY_GENERAL",
		template = "Vendor_Settings_General"
	},
	{
		name = "OPTIONS_CATEGORY_SELLING",
		template = "Vendor_Settings_Sell"
	},
	{
		name = "OPTIONS_CATEGORY_REPAIR",
		template = "Vendor_Settings_Repair"
	},
	{
		name = "OPTIONS_CATEGORY_TOOLTIP",
		template = "Vendor_Settings_Tooltip"
	},
	{
		name = "OPTIONS_CATEGORY_PERFORMANCE",
		template = "Vendor_Settings_Performance"
	},
	{
		name = "OPTIONS_CATEGORY_ADVANCED",
		template = "Vendor_Settings_Advanced"
	},
	{
		name = "OPTIONS_CATEGORY_DEBUG",
		template = "Vendor_Settings_Debug"
	},
}

function SettingsPanel:OnLoad()
	self:SetPages();

	self:SetScript("OnShow", self.OnShow)
	self:SetScript("OnHide", self.OnHide)

	self.Categories.OnSelection = function(_, index) 
        self:ShowPage(index)
    end	
end

function SettingsPanel:OnShow()
	Addon:Debug("settings", "Setting tab show")
	if (not self.page) then
		self.Categories:SetText(L[SETTINGS_DATA[1].name])
		self:ShowPage(1)
	else
		self.page:Show()
	end
end

function SettingsPanel:OnHide()
	if (self.page) then
		self.page:Hide()
	end
end

function SettingsPanel:SetPages()
	local items = {}
	for index,panel in ipairs(SETTINGS_DATA) do
		items[index] = L[panel.name];
	end
	self.Categories:SetItems(items);
end

function SettingsPanel:ShowPage(index)
	Addon:Debug("settings", "Showing new settings page %d", index)
	local current = self.page
	local entry = SETTINGS_DATA[index]
	local frame = entry.frame

	-- Create the paanel on demand (should we also destroy them?)
	if (not frame) then
		Addon:Debug("settings", "Creating frame for '%s'", entry.template)
		frame = CreateFrame("Frame", nil, self.Outline, entry.template)
		Addon.LocalizeFrame(frame)
		frame:SetPoint("TOPLEFT", self.Outline)
		frame:SetPoint("BOTTOMRIGHT", self.Outline)

		if (type(frame.OnShow) == "function") then
			frame:SetScript("OnShow", frame.OnShow)
		end

		if (type(frame.OnHide) == "function") then
			frame:SetScript("OnHide", frame.OnHide)
		end

		entry.frame = frame
	end

	-- Adjust the visiblity of the pages
	if (self.page) then
		self.page:Hide()
	end
	frame:Show()
	self.page = frame
end


Addon.Panels = Addon.Panels or {}
Addon.Panels.Settings = SettingsPanel