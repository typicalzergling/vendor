local _, Addon = ...
local locale = Addon:GetLocale()
local MainFeature = {
    NAME = "Vendor", 
    VERSION = 1,
	DEPENDENCIES = { "Rules",  "Settings", "Lists" }
}

--[[ Called when feature is initialized ]]
function MainFeature:OnInitialize()
	--self:ShowDialog("lists")
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
	end
	self.dialog:Show()
end

Addon.Features.Vendor = MainFeature