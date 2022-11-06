local _, Addon = ...
local CloseButton = Mixin({}, Addon.CommonUI.Mixins.Border, Addon.CommonUI.Mixins.Tooltip)
local Colors = Addon.CommonUI.Colors
local UI = Addon.CommonUI.UI

function CloseButton:OnLoad()
    self:OnBorderLoaded(nil, Colors.TRANSPARENT, Colors.TRANSPARENT)
    self:InitTooltip()
end

function CloseButton:OnEnter()
    UI.SetColor(self.text, "BUTTON_HOVER_TEXT")
    self:SetBackgroundColor(Colors:Get("BUTTON_HOVER_BACK"))
    self:SetBorderColor(Colors:Get("BUTTON_HOVER_BORDER"))
end

function CloseButton:OnLeave()
    UI.SetColor(self.text, "BUTTON_TEXT")
    self:SetBackgroundColor(Colors.TRANSPARENT)
    self:SetBorderColor(Colors.TRANSPARENT)
end

function CloseButton:OnTooltip(tooltip)
    tooltip:SetText(CLOSE)
end

function CloseButton:OnClick()
    self:GetParent():GetParent():Hide()
end

Addon.CommonUI.CloseButton = CloseButton