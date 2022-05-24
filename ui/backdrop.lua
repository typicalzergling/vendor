local _, Addon = ...;
local VendorBackdrop = {}

function VendorBackdrop:InitBackdrop()
	self:OnBackdropLoaded();
	
	if (self.backdropBorderColor) then
		local alpha = self.backdropBorderColorAlpha or 1
		local color = self.backdropBorderColor or RED_FONT_COLOR
		self:SetBackdropBorderColor(color.r, color.g, color.b, alpha)
	end

	if (self.backdropColor) then 
		local alpha = self.backdropColorAlpha or 1
		local color = self.backdropColor or RED_FONT_COLOR
		self:SetBackdropColor(color.r, color.g, color.b, alpha)
	end	
end

Addon.Controls = Addon.Controls or {}
Addon.Controls.VendorBackdrop = VendorBackdrop