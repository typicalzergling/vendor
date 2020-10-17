--[[===========================================================================
    | Copyright (c) 2018
    |
    | RulesList:
    |
    ========================================================================--]]

local AddonName, Addon = ...
local L = Addon:GetLocale()
local Config = Addon:GetConfig()

Addon.RulesList = {}
Addon.Rules = Addon.Rules or {};
local Rules = Addon.Rules;
local Package = select(2, ...);
local RulesList = Addon.RulesList;

local function findRuleConfig(ruleId, rulesConfig)
    local id = string.lower(ruleId);
    for index, entry in ipairs(rulesConfig) do
        if ((type(entry) == "string") and (string.lower(entry) == id)) then
            return index, entry;
        elseif ((type(entry) == "table") and entry.rule) then
            if (string.lower(entry.rule) == id) then
                return index, entry
            end
        end
    end
end

function RulesList:SetConfigState(configState)
    if (self.ruleType) then
        local ruleConfig = configState or Config:GetRulesConfig(self.ruleType);
        self:ForEach(
            function(item)
                local index, config = findRuleConfig(item:GetRuleId(), ruleConfig);
                if (index and config) then
                    item:SetConfig(config, index);
                else
                    item:SetConfig();
                end
            end);
    end
end

function RulesList:SetDefaultConfig()
    if (self.ruleType) then
        self:SetConfigState(Config:GetDefaultRulesConfig(self.ruleType));
    end
end

function RulesList:UpdateConfig()
    if (self.ruleType) then
        local config = {};
        self:ForEach(
            function(item)
                local entry = item:GetConfig();
                if (entry) then
                    table.insert(config, entry);
                end
            end)

        Config:SetRulesConfig(self.ruleType, config);
    end
end

function RulesList:CreateItem(ruleDef)
    local item = Mixin(CreateFrame("Button", nil, self, "Vendor_Rule_Template"), Package.RuleItem);
    item:SetRule(ruleDef);
    return item;
end

function RulesList:RefreshItem(item, ruleDef)
    item:SetRule(ruleDef);
end

function RulesList:OnUpdateItem(item, isFirst, isLast)
   item:ShowDivider(not isLast);
    item:SetMove(not isFirst, not isLast);
end

function RulesList:OnViewBuilt()
    self:SetConfigState();
end

function RulesList:CompareItems(itemA, itemB)
    local selA = itemA:GetSelected();
    local selB = itemB:GetSelected(); -- todo make this isselected

    -- Push selected items to the front of the list
    if (selA and not selB) then
        return true;
    elseif (not selA and selB) then
        return false;
    elseif (not selA) then
        -- Both aren't selected, use the definiton index.
        return itemA:GetModelIndex() < itemB:GetModelIndex();
    end

    -- Both are selected, use the config index
    return itemA:GetConfigIndex() < itemB:GetConfigIndex();
end

function RulesList.OnLoad(self)
    Mixin(self, RulesList, Package.ListBase);
    self:AdjustScrollbar();
    if (not self.ruleType) then
        self.ruleType = self:GetParent().ruleType;
    end
    if (self.ruleType) then
        Config:AddOnChanged(function() self:SetConfigState(); end);
        Rules.OnDefinitionsChanged:Add(function() self:UpdateView(Rules.GetDefinitions(self.ruleType)); end);
    end
end

function RulesList:OnShow()
    self:Update();
end

function RulesList:RefreshView()
    if (self.ruleType) then
        self:UpdateView(Rules.GetDefinitions(self.ruleType));
        self:SetConfigState();
    end
end

function RulesList:ChangeRuleOrder(item, adjustment)
    if (self:MoveItem(item, item:GetIndex() + adjustment)) then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
    end
end

-- Export to Public
Addon.Public.Rules = Addon.Rules
Addon.Public.RulesList = Addon.RulesList