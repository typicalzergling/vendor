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
    self.active = false
    self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    self:InitTooltip()
end

function RuleItem:OnModelChange(model)
    self.name:SetText(model.Name)
    if (type(model.Description) == "string") then
        self.description:SetWordWrap(true)
        self.description:SetText(model.Description)
    else
        self.description:Hide()
    end

    self:CreateParams()
    self:ShowParams(self:IsActive())
end

--[[ When we are shown make sure out colors up to date ]]
function RuleItem:OnShow()
    self:SetColors()
end

--[[ Handle clicks on this rule itme ]]
function RuleItem:OnClick(button)
    if (button == "RightButton") then
        self:Edit()
    else
        self.active = not self.active
        self:SetColors()
        self:ShowParams(self.active)
        self:Save()
    end
end

function RuleItem:OnEnter()
    self:SetColors()
end

function RuleItem:OnLeave()
    self:SetColors()
end

function RuleItem:SetActive(active)
    self.active = active == true
    self:ShowParams(active)
    self:SetColors()
end

--[[ Determine if this rule is active ]]
function RuleItem:IsActive()
    return self.active == true
end

--[[ Get the id for this rule ]]
function RuleItem:GetRuleId()
    local model = self:GetModel()
    return model.Id
end

--[[ Sets the config for this item ]]
function RuleItem:SetConfig(config)
    self.ruleConfig = config

    local ruleId = self:GetRuleId()
    local ruleConfig = config:Get(ruleId)
    if (type(ruleConfig) == "table") then
        self:SetParameters(ruleConfig)
        self:SetActive(true)
    elseif (type(ruleConfig) == "string") then
        self:SetParameters()
        self:SetActive(true)
    else
        self:SetActive(false)
    end
end

--[[ Called to save the state of this rule ]]
function RuleItem:Save()
    local params = self:GetParameters()
    local ruleId = self:GetRuleId()

    if self:IsActive() then
        debug("SaveRule :: %s [%s]", ruleId, tostring(params))
    else
        debug("SaveRule :: %s [disabled]", ruleId)
    end
end

--[[ Called to edit this rule, this will show the dialog with current paramters ]]
function RuleItem:Edit()
    local params = self:GetParameters()

    local editDialog = Addon:GetFeature("Dialogs")
    editDialog:ShowEditRule(self:GetRuleId(), params)
end

function RuleItem:SetColors()
    local showBackdrop = false
    if (self:IsActive()) then
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

--[[ Create the parameters for this rule ]]
function RuleItem:CreateParams()
    local rule = self:GetModel()

    if (type(rule.Params) == "table") then
        local save = function()
                self:Save()
            end

        self.params = {}        
        for _, param in ipairs(rule.Params) do
            local frame = Vendor.CreateRuleParameter(self, param)
            frame:SetDefault()
            frame:SetCallback(save)
            table.insert(self.stack, frame)
            self.params[param.Key] = frame
        end
    end
end

--[[ Display the parameters for this rule ]]
function RuleItem:ShowParams(show)
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

--[[ Sets the parameters for this rule ]]
function RuleItem:SetParameters(params)
    if (self.params) then
        for key, param in pairs(self.params) do
            if (type(params) == "table") then
                param:SetValue(params[key])
            else
                param:SetDefault()
            end
        end
    end
end

--[[ Retrive the parameters for this rule ]]
function RuleItem:GetParameters()
    if (self.params) then
        local params = {}
        for key, param in pairs(self.params) do
            params[key] = param:GetValue()
        end
        return params
    end

    return nil
end

Vendor.RuleItem = RuleItem