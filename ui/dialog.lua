local _, Addon = ...;
local Dialog = {};
local locale = Addon:GetLocale();

local function invoke(object, method, ...)
	local fn = object[method];
	if (fn and (type(fn) == "function")) then
		xpcall(fn, CallErrorHandler, ...);
	end
end

-- Locate and object/mixin from the addon.
local function findObject(name, context)
	local container = Addon;
	if (type(context) == "string") then
		container = Addon[context] or {};
		end
	return container[name];
end

-- Simple helper function for laoding an implementation into the frame
Addon.LoadImplementation = function(frame, context, impl)
	implementation = impl or frame.Implementation;
	if (implementation and (type(implementation) == "string")) then
		local mixin = findObject(implementation, context);
		assert(mixin and (type(mixin) == "table"), "Expected implementation to be a valid table");
		Mixin(frame, mixin);
		invoke(mixin, "OnLoad", frame);
	end
end;

-- Called when the dialog is loaded
function Dialog:OnLoad()
	Mixin(self, Dialog);

	-- Set our caption if we have one
	local caption = self.CaptionKey;
	if (caption and (type(caption) == "string")) then
		self.header:Setup(locale[caption]);
	end

	Addon.LocalizeFrame(self);
	Addon.LoadImplementation(self);

	self:SetScript("OnShow", function() 
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN); 
		invoke(self, "OnShow", self);
	end);

	self:SetScript("OnHide", function() 
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE); 
		invoke(self, "OnHide", self);
	end);
end

-- Changes the caption of the dialog.
function Dialog:SetCaption(caption)
	self.header:Setup(caption);
end

-- Toggle the visibility of this dialog
function Dialog:Toggle()
	if (not self:IsShown()) then
		self:Show();		
	else
		self:Hide();
	end
end

Addon.Public.Dialog = Dialog;
Addon.Public.LoadImplementation = Addon.LoadImplementation;