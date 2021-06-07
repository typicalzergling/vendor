local _, Addon = ...;
local Dialog = {};
local locale = Addon:GetLocale();

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
	if (type(context) ~= "string") then
		context = frame.Namespace
	end
	if (implementation and (type(implementation) == "string")) then
		local mixin = findObject(implementation, context);
		assert(mixin and (type(mixin) == "table"), string.format("Expected implementation to be a valid table: '%s/%s'", context or "", impl or "<unknown>"))
		Mixin(frame, mixin);
		Addon.Invoke(frame, "OnLoad", frame);
	end
end;

-- Called when the dialog is loaded
function Dialog:OnLoad()
	Mixin(self, Dialog);

	-- Set our caption if we have one
	local caption = self.CaptionKey;
	if (type(caption) == "string") then
		self.header:Setup(locale[caption]);
	end

	Addon.LoadImplementation(self);
	Addon.LocalizeFrame(self);

	self:SetScript("OnShow", function() 
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN); 
		Addon.Invoke(self, "OnShow", self);
	end);

	self:SetScript("OnHide", function() 
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE); 
		Addon.Invoke(self, "OnHide", self);
	end);

	if (type(self.OnUpdate) == "function") then
		self:SetScript("OnUpdate", self.OnUpdate)
	end

	if (type(self.OnEvent) == "function") then
		self:SetScript("OnEvent", self.OnEvent)
	end

	if (type(self.Events) == "table") then
		for _, evt in ipairs(self.Events) do
			self:RegisterEvent(evt)
		end
	end
end

-- Changes the caption of the dialog.
function Dialog:SetCaption(caption)
	if (type(locale[caption]) == "string") then
		self.header:Setup(locale[caption])
	else
		self.header:Setup(caption or "");
	end
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