local AddonName, Addon = ...;
local Dialog = {};
local locale = Addon:GetLocale();

local AUTO_HOOK_HANDLERS = { "OnHide", "OnShow", "OnDragStart", "OnDragStart", "OnMouseDown", "OnMouseUp", "OnLeave", "OnEnter", "OnClick" }

-- Locate and object/mixin from the addon.
local function findObject(name, context)
	local container = Addon;
	if (type(context) == "string") then
		container = Addon[context];
	end

	if (type(container) ~= "table") then
		return nil
	end

	return container[name];
end

function Addon.LoadImplementation(frame, namespace, class)
	class = class or frame.Implementation;
	if (type(namespace) ~= "string") then
		namespace = frame.Namespace
	end

	if (type(class) == "string") then
		local mixin = findObject(class, namespace)
		if (not mixin or (type(mixin) ~= "table")) then
			error(string.format("Unable to locate implementation '%s' from '%s'",
				class or 'NIL', namespace or AddonName))
		end
		Addon.AttachImplementation(frame, mixin, (namespace == "CommonUI") or frame._autoHookHandlers)
	else
		error("Expected object name for implementation")
	end
end

-- Simple helper function for laoding an implementation into the frame
function Addon.AttachImplementation(frame, mixin, hook)
	if (not mixin or (type(mixin) ~= "table")) then
		error("Expected implementation to be a table")
	end

	Mixin(frame, mixin);
	Addon.LocalizeFrame(frame)
	local events = false

	-- Auto connect script handlers (temp delgate on property)
	if (hook) then
		for name, handler in pairs(mixin) do
			if (type(handler) == "function") then
				-- Hook widget handlers
				-- TODO, in release build don't thunk
				if (name ~= "OnLoad") and frame:HasScript(name) then
					frame:SetScript(name, function (target, ...)
						frame:Invoke(handler, ...)
					end)
				end

				if (Addon:RaisesEvent(name)) then
					Addon:RegisterCallback(name, frame, handler)
				end

				-- Hook WOW events "ON_<EVENT_NAME>"
				if (string.find(name, "ON_") == 1) then
					events = true
					frame:RegisterEvent(string.sub(name, 3))
				end
			end
		end

		-- Listen for events (deprecated method)
		if (type(frame.Events) == "table") then
			for _, event in ipairs(frame.Events) do
				events = true
				frame:RegisterEvent(event)
			end
		end

		-- If we are listening to wow events create an event handler
		if (events) then
			frame:SetScript("OnEvent", function(this, event, ...)
				local func = this["ON_" .. name]
				if (not func) then
					func = this[name]
				end

				if (type(func) == "function") then
					this:Invoke(func, ...)
				end
			end)
		end
	end

		-- A wrapper around invoke
		frame.Invoke = function(target, handler, ...)
			if (type(handler) == "string") or (type(handler) == "function") then
				Addon.Invoke(target, handler, ...)
			else
				error("The handler argument to 'Invoke' must be a string or a table")	
			end
		end

		frame:Invoke("OnLoad")
end

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