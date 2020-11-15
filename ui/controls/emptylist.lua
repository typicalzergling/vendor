local _, Addon = ...;
local EmptyListMixin = {};

--[[===========================================================================
	| Shows or hides the empty text
	========================================================================--]]
function EmptyListMixin:ShowEmptyText(show)
	local empty = self.EmptyText;
	if (empty) then
		if (show) then
			empty:Show()
		else
			empty:Hide()
		end
	end
end
	
--[[===========================================================================
	| Modifies the empty text
	========================================================================--]]
function EmptyListMixin:SetEmptyText(text)
	if (self.EmptyText) then
		self.EmptyText:SetText(text or "")
	end
end

--[[===========================================================================
	| Retrives the empty text
	========================================================================--]]
function EmptyListMixin:GetEmptyText()
	if (self.EmptyText) then
		return self.EmptyText:GetText() or ""
	end
	return nil
end

Addon.Controls = Addon.Controls or {}
Addon.Controls.EmptyListMixin = EmptyListMixin;