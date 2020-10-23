local AddonName, Addon = ...;
local HtmlView = {};

local function scrollbarHide(self)
	local control = self:GetParent();
	local parent = control:GetParent();
	local offset = control.containerPadding or  0;

	control:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -offset, offset);
	control.Background:Hide();
	control:GetScrollChild():SetWidth(control:GetWidth());
	--control.Content:SetWidth(control:GetWidth());
	getmetatable(self).__index.Hide(self);
end

local function scrollbarShow(self)
	local control = self:GetParent();
	local parent = control:GetParent();
	local offset = control.containerPadding or  0;

	control:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -(self:GetWidth() + (2 * offset)), offset);
	control.Background:Show();
	control:GetScrollChild():SetWidth(control:GetWidth());
	--control.Content:SetWidth(control:GetWidth());
	getmetatable(self).__index.Show(self);
end

local function setupScrollbar(self)
	local control = self:GetParent();
	local offset = control.containerPadding or  0;
	local adjustX = control.adjustX or 0;
	local adjustY = control.adjustY or 0;

	-- We want to anchor the scrollbar to our right side, when it's 
	-- visible we reduce the size of our parent account for it.
	local up = self.ScrollUpButton;
	local down = self.ScrollDownButton;

	self:ClearAllPoints();
	self:SetPoint("TOPLEFT", control, "TOPRIGHT", offset + adjustX, -(up:GetHeight() - adjustY + 1));
	self:SetPoint("BOTTOMLEFT", control, "BOTTOMRIGHT", offset + adjustX, down:GetHeight() - adjustY - 1);

	up:ClearAllPoints();
	up:SetPoint("BOTTOMLEFT", self, "TOPLEFT");
	up:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT");

	down:ClearAllPoints();
	down:SetPoint("TOPLEFT", self, "BOTTOMLEFT");
	down:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT");

	local bg = control.Background;
	bg:ClearAllPoints();
	bg:SetPoint("LEFT", up, "LEFT");
	bg:SetPoint("RIGHT", down, "RIGHT");
	bg:SetPoint("TOP", up, "CENTER");
	bg:SetPoint("BOTTOM", down, "CENTER");	
	bg:Hide();

	self.Show = scrollbarShow;
	self.Hide = scrollbarHide;
	
	control.scrollBarHideable = 1;	
	self:Hide();
end

local function finalizeScrollbar(self)
	local control = self:GetParent();

	self.ChildWidth = control:GetWidth() - self:GetWidth() - 
		(2 * (control.containerPadding or  0));
	control:GetScrollChild():SetWidth(self.ChildWidth);
end

function HtmlView:OnLoad()
	ScrollFrame_OnLoad(self.Scroll);
	setupScrollbar(self.Scroll.ScrollBar);
	self.Bg:SetAlpha(0.6);

	self:RegisterEvent("ADDON_LOADED");
	self:SetScript("OnEvent", 
		function(self, event, addon)
			if (addon ~= AddonName) then
				return;
			end

			finalizeScrollbar(self.Scroll.ScrollBar);
			self:UnregisterEvent(event);
		end);
end

function HtmlView:SetHtml(html)
	self.Scroll:GetScrollChild():SetText(html or "");
end

Addon.Controls = Addon.Controls or {};
Addon.Controls.HtmlView = HtmlView;