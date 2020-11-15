local _, Addon = ...
local L = Addon:GetLocale()
local Url = {}

--[[============================================================================
    | Called whe our template is loaded.
    ==========================================================================]]
function Url:OnLoad()
    -- Set the text to the url key
    local key = self.UrlKey;
    if (type(key) == "string") then
        self.text = L[key];
    else
        self.text = "";
    end

    self:SetText(self.text);
    self:SetBlinkSpeed(0);
    self:SetAutoFocus(false);
    self:SetScript("OnChar", self.RestoreText);
    self:SetScript("OnTextChanged", self.RestoreText);
    self:SetScript("OnEditFocusGained", self.OnFocus);
    self:SetScript("OnEditFocusLost", self.OnBlur);
end

--[[============================================================================
    | Helper to set the text what it was
    ==========================================================================]]
function Url:RestoreText()
    self:SetText(self.text or "");
end

--[[============================================================================
    | When we gain focus highlight the while string
    ==========================================================================]]
function Url:OnFocus()
    self:HighlightText();
end

--[[============================================================================
    | When we lose focus, de-highlight the item
    ==========================================================================]]
function Url:OnBlur()
    self:HighlightText(0,0);
end

Addon.Controls = Addon.Controls or {}
Addon.Controls.Url = Url
