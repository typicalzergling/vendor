local _, Addon = ...
local L = Addon:GetLocale()
local HiddenRuleSettings = {}
local UI = Addon.CommonUI.UI
local Layouts = Addon.CommonUI.Layouts
local RuleType = Addon.RuleType
local PAGE_PADDING = 0
local PAGE_SPACING = 10

--@debug@
local function debugp(msg, ...) Addon:Debug("hiddenrules", msg, ...) end
--@end-debug@

--[[ Load the hidden rule settings page ]]
function HiddenRuleSettings:OnLoad()
    UI.Enable(self.unhide, false)
    self.hidden:Sort(function(a, b)
            if (a.Source ~= b.Source) then
                if (a.IsSystem and not b.IsSystem) then
                    return true
                end

                if (a.IsExtension and not b.IsSystem) then
                    return true
                end

                if (b.IsSystem or b.IsExtension) then
                    return false
                end
            end

            if (a.Name ~= b.Name) then
                return a.Name < b.Name
            end

            return a.Id < b.Id
        end)
end

--[[ Called when the page is shown ]]
function HiddenRuleSettings:OnShow()
    self.hidden:Rebuild()
    self.hidden:EnsureSelection()
	Addon:RegisterCallback(RuleEvents.CONFIG_CHANGED, self, function() 
            self.hidden:Rebuild()
        end)
end

--[[ Called when the settings are hidden ]]
function HiddenRuleSettings:OnHide()
	Addon:UnregisterCallback(RuleEvents.CONFIG_CHANGED, self)
end

--[[ Gets the list of hidden rules ]]
function HiddenRuleSettings:GetHiddenRules()
    local hidden = {}
    local rules = Addon:GetFeature("Rules"):GetRules(nil, true)
    local config = Addon.RuleConfig:Get(Addon.RuleType.HIDDEN)

    for _, rule in ipairs(rules) do
        if (config:Contains(rule.Id)) then
            table.insert(hidden, rule)
        end
    end

    debugp("Return %s hidden rules", table.getn(hidden))
    return hidden
end

--[[ Handle selection changes ]]
function HiddenRuleSettings:OnSelection()
    local selection = self.hidden:GetSelected()
    UI.Enable(self.unhide, selection ~= nil)
end

--[[ Remove the selected rule from the hidden list ]]
function HiddenRuleSettings:OnUnhideRule()
    local selection = self.hidden:GetSelected()
    if (selection) then
        debugp("Removing rule '%s' [%s] from the hidden list", selection.Name, selection.Id)
        local hidden = Addon.RuleConfig:Get(Addon.RuleType.HIDDEN)
        hidden:Remove(selection.Id)
        hidden:Commit()
    end
end

--[[ Handle our layout ]]
function HiddenRuleSettings:OnSizeChanged(width)
    Layouts.Stack(self, self.stack, PAGE_PADDING, PAGE_SPACING, width)
end

--[[=========================================================================]]

local HiddenRuleItem = Mixin({}, Addon.CommonUI.SelectableItem)
local ITEM_PADDING = { left = 16, right = 16, top = 4, bottom = 4 }
local ITEM_SPACING = 2

--[[ Called when the model changes ]]
function HiddenRuleItem:OnModelChange(model)
    self.text:SetText(model.Name)
    if (type(model.Description) == "string" and string.len(model.Description) ~= 0) then
        self.secondary:SetText(model.Description)
        self.secondary:Show()
    else
        self.secondary:Hide()
    end

    if (model.Type == RuleType.SELL) then
        self.ruleType:SetFormattedText(L.SETTINGS_HIDDENRULES_TYPE_FMT, L.RULE_TYPE_SELL_NAME)
    elseif (model.Type == RuleType.KEEP) then
        self.ruleType:SetFormattedText(L.SETTINGS_HIDDENRULES_TYPE_FMT, L.RULE_TYPE_KEEP_NAME)
    elseif (model.Type == RuleType.Destroy) then
        self.ruleType:SetFormattedText(L.SETTINGS_HIDDENRULES_TYPE_FMT, L.RULE_TYPE_DESTORY_NAME)
    else
        self.ruleType:Hide()
    end
end

--[[ Called handle the layout for our item ]]
function HiddenRuleItem:Layout(width)
    Layouts.Stack(self, self.stack, ITEM_PADDING, ITEM_SPACING, width)
end

--[[ We do not have a tooltip ]]
function HiddenRuleItem:HasTooltip()
    return false
end

Addon.Features.Rules.HiddenRuleItem = HiddenRuleItem
Addon.Features.Rules.HiddenRuleSettings = {
    Create = function(parent)
        local frame = CreateFrame("Frame", nil, parent or UIParent, "Rules_HiddenSettings")
        UI.Attach(frame, HiddenRuleSettings)
        return frame
    end
}
