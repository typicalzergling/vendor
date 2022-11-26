local _, Addon = ...
local Vendor = Addon.Features.Vendor
local Colors = Addon.CommonUI.Colors
local UI = Addon.CommonUI.UI
local DEBOUNCE_TIME = 2.0

--[[==== RuleParameter ========================================================]]
local RuleParameter = {}

--[[ Default rule parameter layout simply chooses the talest item ]]
function RuleParameter:Layout()
    local height = self:GetHeight()

    for _, child in ipairs({ self:GetChildren() }) do
        local ch = child:GetHeight()
        if (ch > height) then
            height = ch
        end
    end

    for _, region in ipairs({ self:GetRegions() }) do
        local rh = region:GetHeight()
        if (rh > height) then
            height = rh
        end
    end

    self:SetHeight(height)
end

--[[ Sets the callback for the parameter changed ]]
function RuleParameter:SetCallback(callback)
    self.callback = callback
end

--[[ Invokes the parameter changed callback ]]
function RuleParameter:InvokeCallback(...)
    if (type(self.callback) == "function") then
        pcall(self.callback, self, ...)
    end
end

--[[ Get the default value for this parameter ]]
function RuleParameter:GetDefault()
    local default = self.Parameter.Default

    if (type(default) == "function") then
        return default()
    elseif (type(default) ~= "nil") then
        return default
    else
        local type = self.Parameter.Type
        if (type == "boolean") then
            return false
        elseif (type == "number" or type == "numeric") then
            return 0
        else
            return 0
        end
    end

    error("Unable to determine the default value :: " .. self.Parameter.Key)
end

function RuleParameter:SetDefault()
    self:SetValue(self:GetDefault())
end

--[[==== BooleanParameter =====================================================]]
local BooleanParameter = Addon.DeepTableCopy(RuleParameter)

--[[ Initializes a boolean param ]]
function BooleanParameter:SetParam(param)
    self.name:SetText(param.Name)

    local value = self.value
    Mixin(value, Addon.CommonUI.Mixins.Border)
    value:OnBorderLoaded(nil, Colors.CHECKBOX_BORDER, Colors.CHECKBOX_BACK)
    self.checked = false

    value:SetScript("OnClick", function()
            self:SetValue(not self.checked)
            self:InvokeCallback()
        end)

    value:SetScript("OnEnter", function(value)
            UI.SetColor(self.name, "TEXT")
            value:SetBorderColor(Colors.CHECKBOX_HOVER_BORDER)
            value:SetBackgroundColor(Colors.CHECKBOX_HOVER_BACK)
        end)

    value:SetScript("OnLeave", function(value)
        UI.SetColor(self.name, "SECONDARY_TEXT")
        value:SetBorderColor(Colors.CHECKBOX_BORDER)
            value:SetBackgroundColor(Colors.CHECKBOX_BACK)
        end)
end

--[[ Sets the value of a boolean param ]]
function BooleanParameter:SetValue(value)
    if (value and not self.checked) then
        self.checked = value
        self.value.check:Show()
    elseif (not value and self.checked) then
        self.checked = value
        self.value.check:Hide()
    end
end

--[[ Get the value of a boolean param ]]
function BooleanParameter:GetValue()
    return self.checked
end

--[[==== NumberParameter ======================================================]]

local NumberParameter = Mixin({}, RuleParameter, Addon.CommonUI.Mixins.Debounce)

--[[ Handle one time initialization of a numeric perameter ]]
function NumberParameter:OnLoad()
    local value = self.value    
    Mixin(value, Addon.CommonUI.Mixins.Border)
    value:OnBorderLoaded(nil, "EDIT_BORDER", "EDIT_BACK")
    value:SetTextColor(Colors.EDIT_REST:GetRGBA())
    value:SetJustifyH("RIGHT")

    value:SetScript("OnEditFocusGained", GenerateClosure(self.OnFocus, self))
    value:SetScript("OnEditFocusLost", GenerateClosure(self.OnBlur, self))
    value:SetScript("OnTextChanged", GenerateClosure(self.OnValueChanged, self))
end

--[[ Handle this parameter gaining focus ]]
function NumberParameter:OnFocus()
    local value = self.value

    value:SetBorderColor("EDIT_HIGHLIGHT")
    UI.SetColor(self.name, "TEXT")
    UI.SetColor(value, "EDIT_TEXT")
    value:HighlightText()
end

--[[ Handle this parameter losing focus ]]
function NumberParameter:OnBlur()
    local value = self.value

    UI.SetColor(self.name, "SECONDARY_TEXT")
    UI.SetColor(value, "EDIT_REST")
    value:SetBorderColor("EDIT_BORDER")
    value:ClearHighlightText()
    if (self.dirty) then
        self.dirty = false
        self:DebounceNow()
    end
    self.current = nil
end

--[[ Handle the value changing ]]
function NumberParameter:OnValueChanged()
    local value = self.value:GetNumber()
    if (value ~= self.current) then
        self.dirty = true
        self:Debounce(DEBOUNCE_TIME, self.InvokeCallback)
    end
end

--[[ Initialize to the paramter ]]
function NumberParameter:SetParam(param)
    self.name:SetFormattedText("%s:", param.Name)
end

--[[ Set the parameter to the current value ]]
function NumberParameter:SetValue(value)
    assert(type(value) == "number", "Expected a number value")

    if (value ~= self.current) then
        self.current = value
        self.value:SetText(tostring(value))
    end
end

--[[ Retrieve the current value ]]
function NumberParameter:GetValue()
    local value= self.value:GetNumber()
    if (type(value) ~= "number") then
        return self:GetDefault()
    end

    return value
end

--[[==== StringParameter ======================================================]]

local StringParameter = Mixin({}, RuleParameter, Addon.CommonUI.Mixins.Debounce)

--[[ Handle one time initialization of this parameter ]]
function StringParameter:OnLoad()
    local value = self.value
    Mixin(value, Addon.CommonUI.Mixins.Border)
    value:OnBorderLoaded(nil, "EDIT_BORDER", "EDIT_BACK")
    value:SetTextColor(Colors.EDIT_REST:GetRGBA())
    value:SetJustifyH("RIGHT")

    value:SetScript("OnEditFocusGained", GenerateClosure(self.OnFocus, self))
    value:SetScript("OnEditFocusLost", GenerateClosure(self.OnBlur, self))
    value:SetScript("OnTextChanged", GenerateClosure(self.OnValueChanged, self))
end

--[[ Called when this parameter gains focus ]]
function StringParameter:OnFocus()
    local value = self.value

    value:SetBorderColor("EDIT_HIGHLIGHT")
    UI.SetColor(self.name, "TEXT")
    UI.SetColor(value, "EDIT_TEXT")
    value:HighlightText()
end

--[[ Called when this parameter loses focus ]]
function StringParameter:OnBlur()
    local value = self.value

    UI.SetColor(self.name, "SECONDARY_TEXT")
    UI.SetColor(value, "EDIT_REST")
    value:SetBorderColor("EDIT_BORDER")
    value:ClearHighlightText()
    if (self.dirty) then
        self:DebounceNow()
        self.dirty = false
    end
    self.current = nil
end

--[[ Handle the value of a paramter changing ]]
function StringParameter:OnValueChanged()
    local value = self:GetValue()
    if (value ~= self.current) then
        self.dirty = true
        self:Debounce(DEBOUNCE_TIME, self.InvokeCallback)
    end
end

--[[ Initialize this parameter from the rule ]]
function StringParameter:SetParam(param)
    assert(param.Type == "string", "Why are we initializing on a non-number")
    self.name:SetFormattedText("%s:", param.Name)
end

--[[ Sets the value for this edit field ]]
function StringParameter:SetValue(value)
    if value == nil then
        value = ""
    elseif (type(value) ~= "string") then
        value = tostring(value)
    end

    if (value ~= self.current) then
        self.current = value
        print("stringparam", value, self.value, self.current)
        self.value:SetText(value)
    end
end

--[[ Gets the current value of this parameter ]]
function StringParameter:GetValue()
    local val = self.value:GetText()
    if (val == nil) then
        return ""
    end
    return val
end

--[[=========================================================================]]

--[[ Create a new rule parameter ]]
function Vendor.CreateRuleParameter(parent, param)
    local frame
    local impl
    if (param.Type == "numeric" or param.Type == "number") then
        impl = NumberParameter
        frame = CreateFrame("Frame", nil, parent, "RuleParam_Number")
    elseif (param.Type == "boolean") then
        impl = BooleanParameter
        frame = CreateFrame("Frame", nil, parent, "RuleParam_Boolean")
    elseif (param.Type == "string") then
        impl = StringParameter
        frame = CreateFrame("Frame", nil, parent, "RuleParam_String")
    end

    assert(frame, "Unknwon parameter type: " .. tostring(param.Type))
    Addon.CommonUI.UI.Attach(frame, impl)
    frame:SetParam(param)
    frame.Parameter = param

    return frame
end
