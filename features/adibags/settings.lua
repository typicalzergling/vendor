local _, Addon = ...
local locale = Addon:GetLocale()
local UI = Addon.CommonUI.UI
local Layouts = Addon.CommonUI.Layouts
local Settings = Addon.Features.Settings
local UI = Addon.CommonUI.UI
local Colors = Addon.CommonUI.Colors;
local Adibags = Addon.Features.Adibags

local ENABLED_FILTERS = Adibags.c_EnabledFiltersKey
local ENABLE_SELL = Adibags.c_EnableSellFilter
local ENABLE_DESTROY = Adibags.c_EnableDestroyFilter

--@debug@
local function debugp(msg, ...) Addon:Debug("adibags", msg, ...) end
--@end-debug@

local AdibagsSettings = {}
local RuleItem = Mixin({}, Addon.CommonUI.SelectableItem)

--[[=======================================================================--]]

function RuleItem:OnModelChange(model)
    UI.Show(self.check, model.Enabled == true)
    UI.SetText(self.text, model.Text)
    UI.SetText(self.ruleType, "ADIBAGS_RULETYPE_" .. string.upper(model.Type))
end

--[[ We do not have a tooltip ]]
function RuleItem:HasTooltip()
    local model = self:GetModel()
    return (type(model.Description) == "string") and string.len(model.Description) ~= 0
end

function RuleItem:OnTooltip(tooltip)
    local model = self:GetModel()

    local text = locale:GetString(model.Description) or model.Description
    local textColor = Colors:Get("SECONDARY_TEXT")

    local name = locale:GetString(model.Text) or model.Text
    local nameColor = Colors:Get("SELECTED_PRIMARY_TEXT")
    
    tooltip:SetText(name, nameColor:GetRGB())
    tooltip:AddLine(text, textColor.r, textColor.g, textColor.b, true)
    tooltip:AddLine(" ")
    tooltip:AddDoubleLine(
        locale:GetString("ADIBAGS_TOOLTIP_TYPE"), 
        locale:GetString("ADIBAGS_TOOLTIPTYPE_" .. string.upper(model.Type)),
        nameColor.r, nameColor.g, nameColor.b,
        textColor.r, textColor.g, textColor.b
    )
end

--[[=======================================================================--]]

--[[ Load the hidden rule settings page ]]
function AdibagsSettings:OnLoad()
    local settings = Addon:GetFeature("Settings")

    local enableJunk = Settings.CreateSetting(
        "adibags-enable-junk",
        true,
        function()
            local profile = Addon:GetProfile()
            return profile:GetValue(ENABLE_SELL) or false
        end,
        function(value)
            local profile = Addon:GetProfile()
            profile:SetValue(ENABLE_SELL, value)
        end
    )

    local enableDestroy = Settings.CreateSetting(
        "adibags-enable-destroy",
        true,
        function()
            local profile = Addon:GetProfile()
            return profile:GetValue(ENABLE_DESTROY) or false
        end,
        function(value)
            local profile = Addon:GetProfile()
            profile:SetValue(ENABLE_DESTROY, value)
        end
    )

    table.insert(self.stack, 2, Settings.CreateCheckbox(enableJunk, "ADIBAGS_JUNK_LABEL", "ADIBAGS_JUNK_TEXT", self))
    local destroyCheckbox = Settings.CreateCheckbox(enableDestroy, "ADIBAGS_DESTROY_LABEL", "ADIBAGS_DESTROY_TEXT", self)
    destroyCheckbox.Margins = { bottom = 12 }
    table.insert(self.stack, 3, destroyCheckbox)

end

--[[ Called when the page is shown ]]
function AdibagsSettings:OnShow()
    local selected = self.rules:GetSelected()
    if (not selected) then
        self.enableFilter:Disable()
        self.disableFilter:Disable()
    else
    end
end

--[[ Called when the settings are hidden ]]
function AdibagsSettings:OnHide()
end

--[[ Handle our layout ]]
function AdibagsSettings:OnSizeChanged(width, height)
    local height = Layouts.Stack(self, self.stack, 0, 10, width)
    self.rules:SetPoint("TOP", 0,  -(height + 12))
end

function AdibagsSettings:OnSelection()
    local selected = self.rules:GetSelected()
    UI.Enable(self.enableFilter, selected.Enabled ~= true)
    UI.Enable(self.disableFilter, selected.Enabled == true)
end

function AdibagsSettings:UpdateItem(model, state)
    if (model.Enabled ~= state) then
        model.Enabled = state
        local profile = Addon:GetProfile()
        local enabled = profile:GetValue(ENABLED_FILTERS) or {}
        if (state) then
            enabled[model.Id] = true
        else
            enabled[model.Id] = nil
        end
        profile:SetValue(ENABLED_FILTERS, enabled)

        local item = self.rules:FindItem(model)
        if (item) then
            item:OnModelChange(model)
        end

        UI.Enable(self.enableFilter, model.Enabled ~= true)
        UI.Enable(self.disableFilter, model.Enabled == true)    
    end
end

function AdibagsSettings:OnEnableFilter()
    local selected = self.rules:GetSelected()
    if (selected) then
        self:UpdateItem(selected, true)
    end
end

function AdibagsSettings:OnDisableFilter()
    local selected = self.rules:GetSelected()
    if (selected) then
        self:UpdateItem(selected, false)
    end
end

function AdibagsSettings:GetRules()
    debugp("Get Rules")
    
    local rules = Addon:GetFeature("rules"):GetRules()
    local profile = Addon:GetProfile()
    local enabled = profile:GetValue(ENABLED_FILTERS) or {}
    local items = {}

    for _, rule in ipairs(rules) do
        if (not rule.Locked) then

            table.insert(items, {
                Text = rule.Name,
                Description = rule.Description,
                Id = rule.Id,
                Type = rule.Type,
                Enabled = enabled[rule.Id] == true,
            })
        end
    end

    table.sort(items, 
        function (a, b)
            if (a.Type ~= b.Type) then
                return a.Type > b.Type
            end

            return a.Text > b.Text
        end)

    return items
end

Addon.Features.Adibags.Settings = AdibagsSettings
Addon.Features.Adibags.SettingsRuleItem = RuleItem