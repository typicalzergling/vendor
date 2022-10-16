local _, Addon = ...
local locale = Addon:GetLocale()
local Colors = Addon.CommonUI.Colors
local CommandButton = Mixin({}, Addon.CommonUI.Mixins.Border)

--[[===========================================================================
  |
  | KeyValues:
  |     Label - the string (or localized key) for the button text
  |     Help - The alpha level to apply (opt)
  |     Handler - The color to apply (opt)
  |===========================================================================]]

function CommandButton:OnLoad()
    self:OnBorderLoaded(nil, Colors.BUTTON_BORDER, Colors.BUTTON_BACK)
    self.text:SetTextColor(Colors.BUTTON_TEXT:GetRGBA())
    self:SetLabel(self.Label)
end

function CommandButton:SetLabel(label)
    local loc = locale[label] or label
    if (type(loc) == "string") then
        self.text:SetText(loc)
        self.text:SetTextColor(Colors.BUTTON_TEXT:GetRGBA())
    else
        -- Debug else case
        self.text:SetText("<error>")
        self.text:SetTextColor(1, 0, 0)
    end

    self:SetText(self.text:GetText())
end

function CommandButton:SetHelp(help)
    self.Help = help
end

function CommandButton:OnEnter()
    self:SetBorderColor(Colors.BUTTON_HOVER_BORDER)
    self:SetBackgroundColor(Colors.BUTTON_HOVER_BACK)
    self.text:SetTextColor(Colors.BUTTON_HOVER_TEXT:GetRGBA())

    -- If we have a tooltop then show it
    if (type(self.Help) == "string") then
        local tooltip = locale[button.Help] or self.Help
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -4)
        GameTooltip:SetText(toltip, Colors.BUTTON_TEXT:GetRGBA())
        GameTooltip:Show()
    end
end

function CommandButton:OnLeave()
    self:SetBackgroundColor(Colors.BUTTON_BACK)
    self:SetBorderColor(Colors.BUTTON_BORDER)
    self.text:SetTextColor(Colors.BUTTON_TEXT:GetRGBA())

    -- If we are the owner of the tooltip hide it
    if (GameTooltip:GetOwner() == self) then
        GameTooltip:Hide()
    end
end

function CommandButton:OnDisable()
    self:SetBackgroundColor(Colors.BUTTON_DISABLED_BACK)
    self:SetBorderColor(Colors.BUTTON_DISABLED_BORDER)
    self.text:SetTextColor(Colors.BUTTON_DISABLED_TEXT:GetRGBA())
end

function CommandButton:OnEnable()
    self:SetBackgroundColor(Colors.BUTTON_BACK)
    self:SetBorderColor(Colors.BUTTON_BORDER)
    self.text:SetTextColor(Colors.BUTTON_TEXT:GetRGBA())
end

function CommandButton:OnClick()
    if (self.Handler) then
        Addon.Invoke(button:GetParent(), self.Handler, self)
    end
end

Addon.CommonUI.CommandButton = CommandButton
