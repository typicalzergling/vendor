local _, Addon = ...;
local Edit = {};
local EditHost = {};

function Edit:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	self:GenerateCallbackEvents({ "OnChange", "OnTab" });
end

function Edit:OnDisable()
	local color = self.disabledColor or DISABLED_FONT_COLOR;
	self:SetTextColor(color.r, color.g, color.b);
end

function Edit:OnEnable()
	local color = self.textColor or HIGHLIGHT_FONT_COLOR;
	self:SetTextColor(color.r, color.g, color.b);
end

function Edit:OnFocus()
	self:UpdatePlaceholder(true);
end

function Edit:GetPlaceholder()
	return self.Placeholder or
		self:GetParent().Placeholder or 
		self:GetParent():GetParent().Placeholder;
end

function Edit:UpdatePlaceholder(forceOff)
	local placeholder= self:GetPlaceholder();
	if (placeholder) then
		local text = self:GetText();
		if (not forceOff and (not self:HasFocus() and (not text or (string.len(text) == 0)))) then
			placeholder:Show();
		else
			placeholder:Hide();
		end
	end
end

function Edit:OnBlur()
	self:UpdatePlaceholder();
end

function Edit:OnShow()
	self:UpdatePlaceholder();
end

local function handleTimer(edit)
	if (edit.timer) then
		edit.timer:Cancel();
		edit.timer = nil;
	end

	local text = edit:GetText();
	if (not edit.lastText or (text ~= edit.lastText)) then
		edit.lastText = text;
		edit:TriggerEvent("OnChange", text);
	end
end

function Edit:OnChange()
	if (self.timer) then
		self.timer:Cancel();
	end

	self:UpdatePlaceholder();
	self.timer = C_Timer.NewTimer(0.25, function() handleTimer(self) end);
end

function EditHost:OnLoad()
	self:OnBackdropLoaded();
	if (self.Scroll) then
		self:AdjustScrollBar();
		ScrollFrame_OnLoad(self.Scroll);		
		self.Edit = self.Scroll:GetScrollChild();
	end

	local placeholder = self.Edit:GetPlaceholder();
	if (placeholder) then
		placeholder.LocKey = self.PlaceholderKey;
	end

	local label = self.Label;
	if (label) then 
		label.LocKey = self.LabelKey;
	end
end

function EditHost:GetControl()
	return self.Edit;
end

function EditHost:SetText(text)
	self.Edit.lastText = text;
	self.Edit:SetText(text);
end

function EditHost:SetNumber(number)
	assert(type(number) == "number");
	assert(self.Edit:IsNumeric());
	self.Edit.lastText = tostring(number);
	self.Edit:SetNumber(number);
end

function EditHost:GetText()
	return self.Edit:GetText();
end

function EditHost:GetNumber()
	assert(self.Edit:IsNumeric());
	return self.Edit:GetNumber();
end

function EditHost:RegisterCallback(event, ...)
	return self.Edit:RegisterCallback(event, ...);
end

function EditHost:UnregisterCallback(event, ...)
	return self.Edit:UnregisterCallback(event, ...);
end

function EditHost:Disable()
	self.Edit:Disable();
	if (self.Label) then
		self.Label:SetTextColor(DISABLED_FONT_COLOR.r, DISABLED_FONT_COLOR.g, DISABLED_FONT_COLOR.b);
	end
end

function EditHost:Enable()
	self.Edit:Enable();
	if (self.Label) then
		self.Label:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
end

local function scrollbarHide(self)
	local control = self:GetParent();

	-- If the scrollbar is being hiddem we can have whole space.
	control:SetPoint("BOTTOMRIGHT", control:GetParent(),  -5, 4);
	control:GetScrollChild():SetWidth(control:GetWidth());
	control:GetParent().scrollbarBackground:Hide();
	getmetatable(self).__index.Hide(self);
end

local function scrollbarShow(self)
	local control = self:GetParent();

	-- If the scrollbar is showing we need to subtract it's width.
	control:SetPoint("BOTTOMRIGHT", control:GetParent(), "BOTTOMRIGHT", -self:GetWidth(), 4);
	control:GetScrollChild():SetWidth(control:GetWidth() - 5);
	control:GetParent().scrollbarBackground:Show();
	getmetatable(self).__index.Show(self);
end

function EditHost:AdjustScrollBar()
	local control = self.Scroll;
	local scrollbar = control.ScrollBar;
	local up = scrollbar.ScrollUpButton;
	local down = scrollbar.ScrollDownButton;
	local bg = self.scrollbarBackground;

	scrollbar:ClearAllPoints();
	scrollbar:SetPoint("TOPLEFT", control, "TOPRIGHT", -5, -(up:GetHeight()));
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
	control.scrollBarHideable = 1;
	scrollbarHide(scrollbar);
end

Addon.Controls = Addon.Controls or {};
Addon.Controls.EditHost = EditHost;
Addon.Controls.Edit = Edit;