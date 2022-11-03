local _, Addon = ...
local locale = Addon:GetLocale()
local Url = {}
local TEXT_KEY = {}

function Url:OnLoad()
    self:SetUrl(self.Url)
    self:SetBlinkSpeed(0);
end

function Url:SetUrl(url)
    if (not url) then
        url = self.Url
    end

    local text = locale:GetString(url) or url or "<error>"
    rawset(self, TEXT_KEY, text)
    self:SetText(text)
end

function Url:OnChar()
    self:SetText(rawget(self, TEXT_KEY))
end

function Url:OnTextChanged()
    self:SetText(rawget(self, TEXT_KEY))
end

function Url:OnEditFocusGained()
    self:HighlightText();
end

function Url:OnEditFocusLost()
    self:HighlightText(0,0);
end

Addon.CommonUI.Url = Url