local _, Addon = ...
local RulesFeature = { NAME = "Rules", VERSION = 1 }
local TEST_CATEGORY = 1
local TEST_ID = "test.id"
local TEST_NAME = "<test-rule>"
local TEST_CATEGORY_NAME = "<test>"

function RulesFeature:OnInitialize()
    self:Debug("Initialize Rules Feature")
    return
        -- Internal API
        {
            F_ValidateRule = self.ValidateRule,
            F_CreateRulesEngine = self.CreateRulesEngine,
            F_GetRuleMatches = self.GetMatches
        }
end

--[[
    Validate the sepcified script, returns true/false and a message. 
]]
function RulesFeature:ValidateRule(script, engine)
    self:Debug("Validating rule script (no cached values)")

    if (not engine and not self.validateEngine) then
        self.validateEngine = Addon:CreateRulesEngine()
    end

    return Addon:ValidateRuleAgainstBags(engine or self.validateEngine, script)
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

--[[
    Create new instaence of the rules engine
]]
function RulesFeature:CreateRulesEngine()
    return Addon:CreateRulesEngine()
end

function RulesFeature:OnTerminate()
    self.validateEngine = nil
    self.matchEngine = nil
end

Addon.Features.Rules = RulesFeature