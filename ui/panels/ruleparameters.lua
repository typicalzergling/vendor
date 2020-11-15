local _, Addon = ...
Addon.Panels = Addon.Panels or {}
local NumericParameter = {}
local PARAM_KEY = {}
	
function NumericParameter:SetParameter(param)
	rawset(self, PARAM_KEY, param)

	local edit = self.Edit:GetControl();
	edit:SetNumeric(true);
	edit:SetFontObject(GameFontHighlightSmall)
	edit:SetMaxLetters(8)
	edit:SetJustifyH("RIGHT")

	self.H:SetText(param.Name or "")
	self.Edit:SetNumber(self:GetDefaultValue())
end

function NumericParameter:GetDefaultValue()
	local param = assert(rawget(self, PARAM_KEY))
	local value = nil;

	if (type(param.Default) == "function") then
		success, value = xpcall(param.Default, CallErrorHandler);
	elseif (type(param.Default) == "number") then
		value = param.Default;
	else
		value = 0;
	end 

	return value or 0;
end

function NumericParameter:GetValue()
	local param = assert(rawget(self, PARAM_KEY))
	local value = self.Edit:GetNumber();
	if (value == nil or (self.Edit:GetText() == "")) then
		value = self:GetDefaultValue();
	end 
	
	return (value or 0)
end

function NumericParameter:SetValue(value)
	local param = assert(rawget(self, PARAM_KEY))
	if (value == nil or (type(value) ~= "number")) then
		value = self:GetDefaultValue();
	end
	
	self.Edit:SetNumber(value);
end

function NumericParameter:AddListener(...)
	self.Edit:RegisterCallback("OnChange", ...)
end

function NumericParameter:RemoveListener(...)
	self.Edit:UnregisterCallback("OnChange", ...)
end

Addon.Panels.NumericParameter = NumericParameter