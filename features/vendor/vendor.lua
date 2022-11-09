local _, Addon = ...
local locale = Addon:GetLocale()
local UI = Addon.CommonUI.UI
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

function MainFeature:GetDialog()
	if (not self.dialog) then
		local BUTTONS = {
			close = { label = CLOSE, handler = "Hide" }
		}	
		self.dialog = UI.Dialog(nil, "Vendor_MainDialog", self.MainDialog, BUTTONS)
	end

	return self.dialog
end

function MainFeature:ShowDialog(tabId)
	local dialog = self:GetDialog()
	if (type(tabId) == "string") then
		dialog:NavigateTo(tabId)
	end

	dialog:Show()
end

function MainFeature:ToggleDialog()
	self:GetDialog():Toggle()
end

Addon.Features.Vendor = MainFeature