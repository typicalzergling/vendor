local _, Addon = ...;
local AutoScrollbarMixin = {}

local function scrollbarHide(self)
	local control = self:GetParent();

	-- If the scrollbar is being hiddem we can have whole space.
	control:SetPoint("BOTTOMRIGHT", control:GetParent(),  -5, 4);
	control:GetScrollChild():SetWidth(control:GetWidth());
	if (self._sbbg) then
		self._sbbg:Hide();
	end
	getmetatable(self).__index.Hide(self);
end

local function scrollbarShow(self)
	local control = self:GetParent();

	-- If the scrollbar is showing we need to subtract it's width.
	control:SetPoint("BOTTOMRIGHT", control:GetParent(), "BOTTOMRIGHT", -self:GetWidth(), 4);
	control:GetScrollChild():SetWidth(control:GetWidth() - 5);
	if (self._sbbg) then
		self._sbbg:Show();
	end
	getmetatable(self).__index.Show(self);
end

function AutoScrollbarMixin:AdjustScrollBar(control, autoHide)
	local scrollbar = control.ScrollBar;
	local up = scrollbar.ScrollUpButton;
	local down = scrollbar.ScrollDownButton;
	local bg = self.scrollbarBackground;

	if (not bg) then	
		bg = control:CreateTexture(nil, "BACKGROUND", -2);
		bg:SetColorTexture(0.0, 0.0, 0.0, 0.50);
	end

	scrollbar:ClearAllPoints();
	scrollbar:SetPoint("TOPLEFT", control, "TOPRIGHT", -5, -up:GetHeight());
	scrollbar:SetPoint("BOTTOMLEFT", control, "BOTTOMRIGHT", -5, down:GetHeight());

	up:ClearAllPoints();
	up:SetPoint("BOTTOM", scrollbar, "TOP");

	down:ClearAllPoints();
	down:SetPoint("TOP", scrollbar,"BOTTOM");

	bg:ClearAllPoints();
	bg:SetPoint("TOPLEFT", up, "LEFT");
	bg:SetPoint("BOTTOMRIGHT", down, "RIGHT");

	scrollbar.Hide = scrollbarHide;
	scrollbar.Show = scrollbarShow;
	scrollbar._sbbg = bg;

	if (autoHide) then
		control.scrollBarHideable = 1;
		scrollbarHide(scrollbar);
	else	
		scrollbarShow(scrollbar);
	end
end

function AutoScrollbarMixin:GetContainerWidth(control)
	local width = control:GetWidth();
	if (control.ScrollBar and control.ScrollBar:IsShown()) then
		return (width - 5 - control.ScrollBar:GetWidth());
	end
end

Addon.Controls = Addon.Controls or {};
Addon.Controls.AutoScrollbarMixin = AutoScrollbarMixin;