local _, Addon = ...
local locale  = Addon:GetLocale()
local UI = Addon.CommonUI.UI
local Colors = Addon.CommonUI.Colors
local TabControl = {}
local TOGGLE_PAD_X = 3
local TOGGLE_PAD_Y = 3

local Switch = Mixin({}, Addon.CommonUI.Mixins.Border, CallbackRegistryMixin)
Switch:GenerateCallbackEvents({ "OnChange", "OnFocus", "OnBlur", "OnTab" });

function Switch:OnLoad()
    CallbackRegistryMixin.OnLoad(self)
    self:OnBorderLoaded(nil, Colors.SWTICH_BORDER, Colors.SWITCH_BACKGROUND)

    self.toggle = self:CreateTexture("OVERLAY")
    self.enabled = true
    self.on = false

    self:SetScript("OnEnter", self.Update)
    self:SetScript("OnLeave", self.Update)
end

function Switch:OnShow()
    self:OnSizeChanged(self:GetWidth(), self:GetHeight())
    self:Update()
end

function Switch:SetValue(on)
    self.on = not not on
    self:Update()
end

function Switch:GetValue()
    return type(self.on) == "boolean" and self.on == true
end

function Switch:OnSizeChanged(width, height)
    self.toggle:SetWidth((width / 2) - (2 * TOGGLE_PAD_X))
    self.toggle:SetHeight(height - (2 * TOGGLE_PAD_Y))
end

function Switch:OnClick()
    if (not self.on) then
        self.on = true
    else
        self.on = false
    end

    self:Update()
    self:TriggerEvent("OnChange", self.on)
end

--[[ Update the state of the toggle ]]
function Switch:Update()
    local toggle = self.toggle
    if (not self.enabled) then
        self:SetBorderColor(Colors.SWITCH_DISABLED)
        self:SetBackgroundColor(Colors.TRANSPARENT)
        toggle:Hide()
    else
        self.toggle:Show()
        toggle:ClearAllPoints()

        if (self.on == true) then
            toggle:SetPoint("RIGHT", self, "RIGHT", -TOGGLE_PAD_X, 0)
            toggle:SetColorTexture(Colors.SWTICH_TOGGLE_ON:GetRGBA())
            self:SetBackgroundColor(Colors.SWITCH_BACKGROUND_ON)
        else
            self.toggle:SetPoint("LEFT", self, "LEFT", TOGGLE_PAD_X, 0)
            toggle:SetColorTexture(Colors.SWITCH_TOGGLE_OFF:GetRGBA())
            self:SetBackgroundColor(Colors.SWITCH_BACKGROUND)
        end

        if (self:IsMouseOver()) then
            self:SetBorderColor(Colors.SWITCH_BORDER_HOVER)
        else 
            self:SetBorderColor(Colors.SWTICH_BORDER)
        end
    end
end

Addon.CommonUI.Switch = Switch