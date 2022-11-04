local _, Addon = ...
local Vendor = Addon.Features.Vendor
local locale = Addon:GetLocale()
local Colors = Addon.CommonUI.Colors
local Layouts = Addon.CommonUI.Layouts
local RuleItem = Mixin({}, Addon.CommonUI.Mixins.Tooltip)

local AddonColors = Addon.Colors
AddonColors.ENABLED_RULE_BACK = CreateColor(0, 1, 0, .125)
AddonColors.HOVER_RULE_BACK = CreateColor(1, 1, 0, .10)

local UI = {
    SetColor = function(item, name)
        local color = Colors:Get(name)
        local type = item:GetObjectType()

        if (type == "FontString") then
            item:SetTextColor(color:GetRGBA())
        elseif (type == "Texture" or type == "Line") then
            item:SetColorTexture(color:GetRGBA())
        end
    end
}

-- Helper for debugging
local function debug(msg, ...)
    Addon:Debug("ruleitem", msg, ...)
end

function RuleItem:OnLoad()
end

function RuleItem:OnModelChange(model)
    debug("OnModelChange(%s)", model.Description or "<unknown>")

    self.name:SetText(model.Name)
    if (type(model.Description) == "string") then
        self.description:SetWordWrap(true)
        self.description:SetText(model.Description)
    else
        self.description:Hide()
    end

    self:CreateParams()
    self:ShowParams(false)
end

function RuleItem:OnShow()
    self:SetColors()
end

function RuleItem:OnClick()
    if (self:GetChecked()) then
        self.backdrop:Show()
    else
        self.backdrop:Hide()
    end

    self:SetColors()
    self:ShowParams(self:GetChecked())
end

function RuleItem:_OnEnter()
    self:SetColors()
end

function RuleItem:_OnLeave()
    self:SetColors()
end

function RuleItem:SetActive(active)
    if (active) then
        self:SetChecked(true)
    else
        self:SetChecked(false)
    end
    self:ShowParams(active)
end

function RuleItem:SetColors()
    local showBackdrop = false
    if (self:GetChecked()) then
        UI.SetColor(self.name, "SELECTED_TEXT")
        UI.SetColor(self.description, "SELECTED_SECONDARY_TEXT")
        UI.SetColor(self.backdrop, "ENABLED_RULE_BACK")
        showBackdrop = true
    elseif (self:IsMouseOver()) then
        UI.SetColor(self.name, "HOVER_TEXT")
        UI.SetColor(self.description, "HOVER_SECONDARY_TEXT")
        UI.SetColor(self.backdrop, "HOVER_RULE_BACK")
        showBackdrop = true
    else
        UI.SetColor(self.name, "TEXT")
        UI.SetColor(self.description, "SECONDARY_TEXT")
    end

    if (showBackdrop) then
        self.backdrop:Show()
    else
        self.backdrop:Hide()
    end
end

function RuleItem:HasTooltip()
end

function RuleItem:OnTooltip(tooltip)
end

function RuleItem:OnSizeChanged()
    xpcall(Layouts.Stack, CallErrorHandler, self, self.stack, 6, 4)
end


function RuleItem:CreateParams()
    local rule = self:GetModel()
    if (type(rule.Params) == "table") then
        self.params = {}
        for _, param in ipairs(rule.Params) do
            local frame = Vendor.CreateRuleParameter(self, param)
            table.insert(self.stack, frame)
            self.params[param.Key] = frame
        end
    end
end

function RuleItem:ShowParams(show)
    debug("showParams: %s", tostring(show))

    if (self.params) then
        for _, param in pairs(self.params) do
            if (show) then 
                param:Show()
            else
                param:Hide()
            end
        end
    end

    self:OnSizeChanged()
end

function RuleItem:SetParameters(params)
    debug("Set parameters", self.params)

    if (self.params) then
        for key, param in pairs(self.params) do
            debug("Checking parameter: %s", key)
            if (type(params) == "table") then
                param:SetValue(params[key])
            else
                param:SetDefault()
            end
        end
    end

    self:ShowParams(self:GetChecked())
end

Vendor.RuleItem = RuleItem