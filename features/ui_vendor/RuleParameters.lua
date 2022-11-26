local _, Addon = ...
local Vendor = Addon.Features.Vendor
local Colors = Addon.CommonUI.Colors

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
            value:SetBorderColor(Colors.CHECKBOX_HOVER_BORDER)
            value:SetBackgroundColor(Colors.CHECKBOX_HOVER_BACK)
        end)

    value:SetScript("OnLeave", function(value)
            value:SetBorderColor(Colors.CHECKBOX_BORDER)
            value:SetBackgroundColor(Colors.CHECKBOX_BACK)
        end)
end

--[[ Sets teh value of a boolean param ]]
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
local NumberParameter = Addon.DeepTableCopy(RuleParameter)

function NumberParameter:SetParam(param)
    self.name:SetFormattedText("%s:", param.Name)

    self.value:SetNumeric()
    self.value.Handler = function()
            self:InvokeCallback()
        end
end

function NumberParameter:SetValue(value)
    assert(type(value) == "number")
    self.value:SetText(tostring(value))
end

function NumberParameter:GetValue()
    local text = self.value:GetNumber()
    if (type(text) == "number") then
        return text
    else
        return self:GetDefault()
    end
end

--[[==== StringParameter ======================================================]]
local StringParameter = Addon.DeepTableCopy(RuleParameter)

function StringParameter:SetParam(param)
    self.name:SetFormattedText("%s:", param.Name)
    self.value.control:SetJustifyH("RIGHT")

    self.value.control:SetScript("OnEscapePressed", EditBox_ClearFocus)
    self.value.control:SetScript("OnEditFocusGained", EditBox_HighlightText)
    self.value.control:SetScript("OnEditFocusLost", EditBox_ClearHighlight)
end

function StringParameter:SetValue(value)
    print("stringparam", value)
    if value == nil then
        value = ""
    elseif (type(value) ~= "string") then
        value = tostring(value)
    end

    print("stringparam", value, self.value)
    self.value:SetText(value)
end

function StringParameter:OnParamChanged(text)
    self:InvokeCallback()
end

function StringParameter:GetValue()
    local val = self.value:GetText()
    if (val == nil) then
        return ""
    end
    return val
end

--[[ Create a new rule parameter ]]
function Vendor.CreateRuleParameter(parent, param)
    local frame
    if (param.Type == "numeric" or param.Type == "number") then
        frame = Mixin(CreateFrame("Frame", nil, parent, "RuleParam_Number"), NumberParameter)
    elseif (param.Type == "boolean") then
        frame = Mixin(CreateFrame("Frame", nil, parent, "RuleParam_Boolean"), BooleanParameter)
    elseif (param.Type == "string") then
        frame = Mixin(CreateFrame("Frame", nil, parent, "RuleParam_String"), StringParameter)
    end

    assert(frame, "Unknwon parameter type: " .. param.Type)
    Addon.CommonUI.DialogBox.Colorize(frame)
    frame:SetParam(param)
    frame.Parameter = param

    return frame
end
