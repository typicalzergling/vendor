local AddonName, Addon = ...;
local HtmlView = {};

local function scrollbarHide(self)
	local control = self:GetParent();
	local parent = control:GetParent();
	local offset = control.containerPadding or  0;

	control.Background:Hide();
	control:GetScrollChild():SetWidth(control:GetWidth());
	getmetatable(self).__index.Hide(self);
end

local function scrollbarShow(self)
	local control = self:GetParent();
	local parent = control:GetParent();
	local offset = control.containerPadding or  0;

	control.Background:Show();
	control:GetScrollChild():SetWidth(control:GetWidth() - (self:GetWidth() + 6));
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
	self:SetPoint("TOPRIGHT", control, "TOPRIGHT", 0, -(up:GetHeight() - 6));
	self:SetPoint("BOTTOMRIGHT", control, "BOTTOMRIGHT", 0, down:GetHeight() - 6)

	up:ClearAllPoints();
	up:SetPoint("BOTTOMLEFT", self, "TOPLEFT");
	up:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT");

	down:ClearAllPoints();
	down:SetPoint("TOPLEFT", self, "BOTTOMLEFT");
	down:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT");

	local bg = control.Background;
	if (not bg) then
		bg = self:CreateTexture(nil, "BACKGROUND")
		bg:SetColorTexture(0.20, 0.20, 0.20, 0.3)
		control.Background = bg
	end

	bg:ClearAllPoints();
	bg:SetPoint("LEFT", up, "LEFT");
	bg:SetPoint("RIGHT", down, "RIGHT");
	bg:SetPoint("TOP", up, "CENTER");
	bg:SetPoint("BOTTOM", down, "CENTER");	
	bg:Hide();

	self.Show = scrollbarShow;
	self.Hide = scrollbarHide;
	
	--control.scrollBarHideable = 1;	
	self:Hide();
end

local function finalizeScrollbar(self)
	local control = self:GetParent();
	self.ChildWidth = control:GetWidth() - self:GetWidth() - 6
	control:GetScrollChild():SetWidth(self.ChildWidth)
end

function HtmlView:OnLoad()
	ScrollFrame_OnLoad(self);
	setupScrollbar(self.ScrollBar);

	self:RegisterEvent("ADDON_LOADED");
	self:SetScript("OnEvent", 
		function(self, event, addon)
			if (addon ~= AddonName) then
				return;
			end

			finalizeScrollbar(self.ScrollBar);
			self:UnregisterEvent(event);
		end);
end

function HtmlView:SetHtml(html)
	self:GetScrollChild():SetText(html or "");
end

Addon.Controls = Addon.Controls or {};
Addon.Controls.HtmlView = HtmlView;