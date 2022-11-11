local _, Addon = ...
local Vendor = Addon.Features.Vendor
local locale = Addon:GetLocale()
local Colors = Addon.CommonUI.Colors
local Layouts = Addon.CommonUI.Layouts
local RuleItem = Mixin({}, Addon.CommonUI.Mixins.Tooltip)
local UI = Addon.CommonUI.UI

local ITEM_PADDING = { 
    left = 24, -- Acccount for the icon
    right = 6,
    top = 6,
    bottom = 6
}

local COLORS = {
    normal = {
        name = "TEXT",
        description = "SECONDARY_TEXT",
        back = "TRANSPARENT",
    },
    hover = {
        name = "HOVER_TEXT",
        description = "HOVER_SECONDARY_TEXT",
        back = "HOVER_BACKGROUND",
    },
    active = {
        name = "TEXT",
        description = "SECONDARY_TEXT",
        back = "ACTIVE_RULE_BACK",
    },
    activeHover = {
        name = "SELECTED_TEXT",
        description = "SELECTED_SECONDARY_TEXT",
        back = "ACTIVE_RULE_HOVER_BACK",
    },
    unhealty = {
        name = "DISABLED_TEXT",
        description = "DISABLED_TEXT",
        back = "UNHEALTHY_RULE_BACK",
    },
    unhealthyHover = {
        name = "DISABLED_TEXT",
        description = "DISABLED_TEXT",
        back = "UNHEALTHY_RULE_HOVER_BACK",
    },
    migrate = {
        name = "DISABLED_TEXT",
        description = "DISABLED_TEXT",
        back = "MIGRATE_RULE_BACK",
    },
    migrateHover = {
        name = "DISABLED_TEXT",
        description = "DISABLED_TEXT",
        back = "MIGRATE_RULE_HOVER_BACK",
    }
}

-- Helper for debugging
local function debug(msg, ...)
    Addon:Debug("ruleitem", msg, ...)
end

function RuleItem:OnLoad()
    self.active = false
    self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    self:SetColors("normal")
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
end

--[[ Handle clicks on this rule itme ]]
function RuleItem:OnClick(button)
    if (button == "RightButton") then
        self:Edit()
    else
        self:SetActive(not self:IsActive())
        self:Save()
    end
end

function RuleItem:OnEnter()
    self:SetColors()
    self:TooltipEnter()
end

function RuleItem:OnLeave()
    self:SetColors()
    self:TooltipLeave()
end

function RuleItem:SetActive(active)
    self.active = (active == true)
    self:ShowParams(active)

    if (self.active) then
        self.check:Show()
    else
        self.check:Hide()
    end
    self:SetColors()
end

--[[ Determine if this rule is active ]]
function RuleItem:IsActive()
    return self.active == true
end

function RuleItem:IsUnhealthy()
    return false
end

function RuleItem:NeedsMigration()
    return false
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
    if (self.ruleConfig) then
        local params = self:GetParameters()
        local ruleId = self:GetRuleId()

        Addon:DebugForEach("profile", params)

        if self:IsActive() then
            debug("SaveRule :: %s [%s]", ruleId, tostring(params))
            self.ruleConfig:Set(ruleId, params)
        else
            debug("SaveRule :: %s [disabled]", ruleId)
            self.ruleConfig:Remove(ruleId)
        end
        self.ruleConfig:Commit()
    end
end

--[[ Called to edit this rule, this will show the dialog with current paramters ]]
function RuleItem:Edit()
    local params = self:GetParameters()

    local editDialog = Addon:GetFeature("Dialogs")
    editDialog:ShowEditRule(self:GetRuleId(), params)
end

--[[ Determine the colors for this item ]]
function RuleItem:SetColors()
    local active = self:IsActive()
    local unhealthy = self:IsUnhealthy()
    local migrate = self:NeedsMigration()
    local colors = COLORS.normal

    if (self:IsMouseOver()) then
        if (active) then
            colors = COLORS.activeHover
        elseif (unhealthy) then
            colors = COLORS.unhealthyHover
        elseif (migrate) then
            colors = COLORS.migrateHover
        else
            colors = COLORS.hover
        end
    else
        if (active) then
            colors = COLORS.active
        elseif (unhealthy) then
            colors = COLORS.unhealty
        elseif (migrate) then
            colors = COLORS.migrate
        else
            colors = COLORS.normal
        end
    end

    if (colors) then
        UI.SetColor(self.name, colors.name)
        UI.SetColor(self.description, colors.description)
        UI.SetColor(self.backdrop, colors.back)
    end
end

function RuleItem:HasTooltip()
    return true
end

function RuleItem:OnTooltip(tooltip)
end

function RuleItem:OnSizeChanged()
    Layouts.Stack(self, self.stack, ITEM_PADDING, 4)
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