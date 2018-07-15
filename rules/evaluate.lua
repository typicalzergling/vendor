local Addon, L = _G[select(1,...).."_GET"]()

-- Evaluating items for selling.

function Addon:GetRulesConfig()
    if (not Vendor_RulesConfig) then
        Vendor_RulesConfig = Addon.DeepTableCopy(Addon.DefaultRulesConfig)
    end
    return Vendor_RulesConfig
end

-- Called when our rule configuration has changed
local function onRulesConfigUpdated(ruleManager, config)
    if (ruleManager) then
        ruleManager:UpdateConfig(config:GetRulesConfig())
    end
end

-- Rules for determining if an item should be sold.
-- TODO: Make this a dynamic system with default rules and allow user-supplied rules.
function Addon:EvaluateItemForSelling(item)
    -- Check some cases where we know we should never ever sell the item
    if not item then
        return false
    end

    -- If have not yet initialized, or the config has changed we need to build our list of "keep" rules
    -- we always add the check against the neversell list no matter what the options says
    if (not self.ruleManager) then
        self.ruleManager = Addon.RuleManager:Create(Addon.RuleFunctions);
        
        -- For now we will treat current expansion as Legion. We have no rules which use this, and no custom rules yet.
        -- TODO: Update this to be BFA once it lands.
        --local _, _, _, version = GetBuildInfo()
        --if (version < 80000) then
            self.ruleManager:AddConstant("CURRENT_EXPANSION", LE_EXPANSION_LEGION)
        --   else
        --    self.ruleManager:AddConstant("CURRENT_EXPANSION", LE_EXPANSION_BATTLE_FOR_AZEROTH)
        --   end

        local config = self:GetConfig()
           config:AddOnChanged(function (c) onRulesConfigUpdated(self.ruleManager, c) end)
           onRulesConfigUpdated(self.ruleManager, config)
    end

    -- Determine if we should keep this item or not
    local result, fromRule, _, ruleName = self.ruleManager:Run(item)
    if (result == Addon.RULE_ACTION_SELL) then
        Addon:DebugRules("Selling '%s' due to rule '%s'", item.Name, fromRule)
        return true, fromRule, ruleName
    elseif (result == Addon.RULE_ACTION_KEEP) then
        Addon:DebugRules("Keeping '%s' due to rule '%s'", item.Name, fromRule)
        return false, fromRule, ruleName
    elseif (result == Addon.RULE_ACTION_PROMPT) then
        assert(false, "Not Yet Implemented")
    end

    -- Doesn't fit one of our above sell criteria so we keep it.
    return false, nil, nil
end


