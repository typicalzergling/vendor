local _, Addon = ...
local locale = Addon:GetLocale()
local MainFeature = {
    NAME = "Vendor", 
    VERSION = 1,
	DEPENDENCIES = { "Rules",  "Settings" }
}

--[[ Called when feature is initialized ]]
function MainFeature:OnInitialize()
	self:ShowDialog()
end

--[[ Callback for when the feature is terminated ]]
function MainFeature:OnTerminate()
end

function MainFeature:ShowDialog(tabId)
	if (not self.dialog) then
		self.dialog = self:CreateDialog("VendorMainDialog", "Vendor_MainDialog", self.MainDialog)
	end

	if (type(tabId) == "string") then
		self.dialog:NavigateTo(tabId)
	else
		self.dialog:Show()
	end
end

Addon.Features.Vendor = MainFeature