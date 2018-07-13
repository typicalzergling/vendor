
-- Evaluating items for selling.
Vendor = Vendor or {}

function Vendor:GetRulesConfig()
	if (not Vendor_RulesConfig) then
		Vendor_RulesConfig = Vendor.DeepTableCopy(Vendor.DefaultRulesConfig)
	end
	return Vendor_RulesConfig
end

-- Called when our rule configuration has changed
local function onRulesConfigUpdated(ruleManager, config)
    print("---- onRulesConfigUpdated", ruleManager, config)
    if (ruleManager) then
        print("---- UPDATING RULES MANAGER")
		ruleManager:UpdateConfig(config:GetRulesConfig())
	end
end

-- Rules for determining if an item should be sold.
-- TODO: Make this a dynamic system with default rules and allow user-supplied rules.
function Vendor:EvaluateItemForSelling(item)
    -- Check some cases where we know we should never ever sell the item
    if not item then
        return false
    end

    -- If have not yet initialized, or the config has changed we need to build our list of "keep" rules
    -- we always add the check against the neversell list no matter what the options says
    if (not self.ruleManager) then
        self.ruleManager = Vendor.RuleManager:Create(Vendor.RuleFunctions);
        local _, _, _, version = GetBuildInfo()
        if (version < 80000) then
	        self.ruleManager:AddConstant("CURRENT_EXPANSION", LE_EXPANSION_LEGION)
	   	else
	        self.ruleManager:AddConstant("CURRENT_EXPANSION", LE_EXPANSION_8_0)
	   	end

        local config = self:GetConfig()
	   	config:AddOnChanged(function (c) onRulesConfigUpdated(self.ruleManager, c) end)
	   	onRulesConfigUpdated(self.ruleManager, config)
    end

    -- Determine if we should keep this item or not
    local result, fromRule, _, ruleName = self.ruleManager:Run(item)
    if (result == Vendor.RULE_ACTION_SELL) then
        Vendor:DebugRules("Selling '%s' due to rule '%s'", item.Name, fromRule)
    	return true, fromRule, ruleName
    elseif (result == Vendor.RULE_ACTION_KEEP) then
        Vendor:DebugRules("Keeping '%s' due to rule '%s'", item.Name, fromRule)
    	return false, fromRule, ruleName
    elseif (result == Vendor.RULE_ACTION_PROMPT) then
    	assert(false, "Not Yet Implemented")
    end

    -- Doesn't fit one of our above sell criteria so we keep it.
    return false, nil, nil
end


