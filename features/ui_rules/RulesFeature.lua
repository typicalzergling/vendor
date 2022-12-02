local _, Addon = ...
local L = Addon:GetLocale()
local RulesFeature = { NAME = "Rules", VERSION = 1, DEPENDENCIES = { "Settings"} }
local TEST_CATEGORY = 1
local TEST_ID = "test.id"
local TEST_NAME = "<test-rule>"
local TEST_CATEGORY_NAME = "<test>"
local EVENTS = { "OnRuleDefinitionCreated", "OnRuleDefinitionUpdated", "OnRuleDefinitionDeleted", "OnRuleFunctionsChanged" }
local RuleType = Addon.RuleType
local RuleSource = Addon.RuleSource

function RulesFeature:OnInitialize()
    Addon:Debug("rules", "Initialize Rules Feature")
    Addon:GenerateEvents(EVENTS)

    local settings = Addon:GetFeature("Settings")
    settings:RegisterPage(L.OPTIONS_CATEGORY_HIDDENRULES, L.OPTIONS_DESC_HIDDENRULES, self.CreateHiddenRulePage)
end

--[[
    Validate the sepcified script, returns true/false and a message. 
]]
function RulesFeature:ValidateRule(script, parameters)
    Addon:Debug("rules", "Validating rule script (no cached values)")

    if (not engine and not self.validateEngine) then
        self.validateEngine = Addon:CreateRulesEngine()
    end

    return Addon:ValidateRuleAgainstBags(engine or self.validateEngine, script, parameters)
end

--[[
    Get the items that match the for the specified script
]]
function RulesFeature:GetMatches(script, parameters)
    if (not self.matchEngine) then
        self.matchEngine = self:CreateRulesEngine()
        --self.matchEngine:Addategory(TTEST_CATEGORY, TEST_CATEGORY_NAME)
    end

    local results = Addon:GetMatchesForRule(self.matchEngine, TEST_ID, script, parameters or {})
    --self.matchEngine:RemoveRule(TEST_ID)

    return results
end

--@debug@--
-- Validae the rule type
local function isValidRuleType(type)
    return not type or
        type == RuleType.SELL or
        type == RuleType.KEEP or
        type == RuleType.DESTROY
end
--@end-debug@

--[[
    Retrieves all the rules, with an optional type match
]]
function RulesFeature:GetRules(ruleType, all)
    --@debug@
    assert(isValidRuleType(ruleType), "An invalid rule type was provided :: " .. tostring(type))
    --@end-debug@

    local hidden = Addon.RuleConfig:Get(RuleType.HIDDEN)
    local rules = {}

    for _, rule in ipairs(Addon.Rules.GetDefinitions()) do
        if (not ruleType or ruleType == rule.Type) then
            if (not all and hidden:Contains(rule.Id)) then
                Addon:Debug("rulez", "Excluding hidden rule '%s'", rule.Id)
            elseif (not all and rule.Locked == true) then
                Addon:Debug("rulez", "Excluding locked rule '%s'", rule.Id)
            else
                Addon:Debug("rulez", "Including rule '%s'", rule.Id)
                if (rule.Source == Addon.RuleSource.SYSTEM) then
                    rule.IsSystem = true
                elseif (rule.Source == Addon.RuleSource.EXTENSION) then
                    rule.IsExtension = true
                end
        
                table.insert(rules, rule)
            end
        end
    end

    return rules
end

function RulesFeature:GetConfig(type)
    return Addon.RuleConfig:Get(type)
end

--[[
    Locates a rule with the specified Id, the rule is returned with
    "IsSystem" and "IsExtension" set as appropriate
]]
function RulesFeature:FindRule(ruleId)
    local rule, type = Addon.Rules.GetDefinition(ruleId, nil, true)
    if (rule) then
        rule = Addon.DeepTableCopy(rule)
        if (type == "SYSTEM") then
            rule.IsSystem = true
            rule.Source = RuleSource.SYSTEM
        elseif (type == "EXT") then
            rule.IsExtension = true
            rule.Source = RuleSource.EXTENSION
        else
            rule.Source = RuleSource.CUSTOM
        end
    end

    return rule
end

--[[
    Called to delete a rule from the custom definitions, the rule MUST be a 
    custom rule for this to do anything.
]]
function RulesFeature:DeleteRule(rule)
    local ruleId = rule
    if type(ruleId) == "table" then
        ruleId = rule.Id
    end
    assert(type(ruleId) == "string", "Invalid input to DeleteRule")
    local deletedRule = Addon.Rules.DeleteDefinition(ruleId)
    if (deletedRule) then
        Addon:RaiseEvent("OnRuleDefinitionDeleted", deletedRule)
    end
end

--[[
    Called to save/create a rule, setting create to true forces a new rule
    to be created, otherwise it will be created if there is no 'Id' provided
]]
function RulesFeature:SaveRule(rule, create)
    local ruleId = rule.Id or "NEW"
    local new = false
    Addon:Debug("rules", "Saving rule '%s'", ruleId)

    -- Create a new rule if we need to
    if (not rule.Id or create) then
        rule.Id = string.lower(Addon.RuleManager.CreateCustomRuleId())
        new = true
    end

    Addon.Rules.UpdateDefinition(rule)
    if (new) then
        Addon:RaiseEvent("OnRuleDefinitionCreated", rule)
    else
        Addon:RaiseEvent("OnRuleDefinitionUpdated", rule)
    end

    return self:FindRule(rule.Id)
end

--[[
    Create new instaence of the rules engine
]]
function RulesFeature:CreateRulesEngine()
    return Addon:CreateRulesEngine()
end

function RulesFeature:OnTerminate()
    self.validateEngine = nil
    self.matchEngine = nil

    Addon:RemoveEvents(EVENTS)
end

Addon.Features.Rules = RulesFeature