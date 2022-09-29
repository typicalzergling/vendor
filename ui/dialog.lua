local _, Addon = ...;
local Dialog = {};
local locale = Addon:GetLocale();

local AUTO_HOOK_HANDLERS = { "OnHide", "OnShow", "OnDragStart", "OnDragStart", "OnMouseDown", "OnMouseUp", "OnLeave", "OnEnter", "OnClickl" }

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
	function eventThunk(target, event, ...)
		if (type(target[event]) == "function") then
			Addon.Invoke(target, event, ...)
		end
	end

	implementation = impl or frame.Implementation;
	if (type(context) ~= "string") then
		context = frame.Namespace
	end

	if (implementation and (type(implementation) == "string")) then
		local mixin = findObject(implementation, context);
		assert(mixin and (type(mixin) == "table"), string.format("Expected implementation to be a valid table: '%s/%s'", context or "", impl or "<unknown>"))
		Mixin(frame, mixin);
		Addon.Invoke(frame, "OnLoad", frame)
		Addon.LocalizeFrame(frame)

		-- Auto connect script handlers (temp delgate on property)
		if (frame._autoHookHandlers) then
			for name, handler in pairs(mixin) do
				-- Hook widget handlers
				if (type(handler) == "function") and (name ~= "OnLoad") and frame:HasScript(name) then
					frame:SetScript(name, function (target, ...)
						Addon.Invoke(target, handler, target, ...)
					end)
				end

				-- Hook WOW events "ON_<EVENT_NAME>"
				if (type(handler) == "function") and (string.find(name, "ON_") == 1) then
					print("REGISTER-EVENT", name)
				end
			end
		end

		-- Listen for events
		if (type(frame.Events) == "table") then			
			frame:SetScript("OnEvent", eventThunk)
			for _, event in ipairs(frame.Events) do
				frame:RegisterEvent(event)
			end
		end

		-- A wrapepr around invoke
		frame.Invoke = function(target, handler, ...)
			if (type(handler) ~= "string") then
				error("The handler argument to 'Invoke' must be a string")
			else
				Addon.Invoke(target, handler, target, ...)
			end
		end
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

	self._autoHookHandlers = true
	Addon.LoadImplementation(self)
	Addon.LocalizeFrame(self)
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