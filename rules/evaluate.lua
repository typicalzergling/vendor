-- Evaluating items for selling.
Vendor = Vendor or {}

-- Adds a system rule of the specified type to the given rule manager.
function Vendor:AddSystemRule(ruleManager, ruleType, ruleId, insets)
    local ruleInfo = Vendor:GetSystemRuleDefinition(ruleType, ruleId, insets)
    if (ruleInfo ~= nil) then
        Vendor:DebugRules("Adding system rule '%s' to the '%s' list", ruleInfo.Id, ruleType)
        ruleManager:AddRule(ruleInfo.Id, ruleInfo.Script)
    else
        Vendor:DebugRules("Failed to find sytem rule '%s' from '%s' list", ruleId, ruleType)
    end
end

-- Adds all of the rules from the specified config into the rule maanger
function Vendor:ApplyRuleConfig(ruleManager, ruleType, config)
    if (Vendor:TableSize(config) == 0) then return end  
    for _, rule in ipairs(config) do
        if (type(rule) == "table") then
            self:AddSystemRule(ruleManager, ruleType, rule.rule, rule)
        elseif (type(rule) == "string") then
            self:AddSystemRule(ruleManager, ruleType, rule)
        end
    end
end

-- Adds all of the locked system rules of a given type to the rules
function Vendor:ApplyLockedSystemRules(ruleManager, ruleType)
    for _, ruleInfo in ipairs(Vendor:GetLockedSystemRules(ruleType)) do
        Vendor:DebugRules("Adding locked system rule '%s' to the '%s' list", ruleInfo.Id, ruleType)
        ruleManager:AddRule(ruleInfo.Id, ruleInfo.Script)
    end
end

-- Called when our rule configuration has changed
function Vendor:OnRuleConfigUpdated()
    self.keepRules = nil
    self.sellRules = nil
end

-- Rules for determining if an item should be sold.
-- TODO: Make this a dynamic system with default rules and allow user-supplied rules.
function Vendor:EvaluateItemForSelling(item)

    -- Check some cases where we know we should never ever sell the item
    --    1 - The item is nil, well we can't sell nothing
    --    2 - It's got no value to the vendor, so we can't sell it
    if not item then
        return false
    end

    -- If have not yet initialized, or the config has changed we need to build our list of "keep" rules
    -- we always add the check against the neversell list no matter what the options says
    if (not self.keepRules) then
        self.keepRules = Vendor.RuleManager:Create(Vendor.RuleFunctions);
        self:ApplyLockedSystemRules(self.keepRules, Vendor.c_RuleType_Keep)
        self:ApplyRuleConfig(self.keepRules, Vendor.c_RuleType_Keep, self.db.profile.rules.keep)

        local customKeep = self.db.profile.rules.custom.keep;
        if (Vendor:TableSize(customKeep) ~= 0) then
            Vendor:DebugRules("Have custom keep rules to apply")
        end     
    end

    -- If we have not yet initialized, or the settings have changed build our list of selling rules.
    -- We always add the always sell rule, no mater what our config says
    if (not self.sellRules) then
        self.sellRules = Vendor.RuleManager:Create(Vendor.RuleFunctions);
        self:ApplyLockedSystemRules(self.sellRules, Vendor.c_RuleType_Sell)
        self:ApplyRuleConfig(self.sellRules, Vendor.c_RuleType_Sell, self.db.profile.rules.sell)

        local customSell = self.db.profile.rules.custom.sell;
        if (Vendor:TableSize(customSell) ~= 0) then
            Vendor:DebugRules("Have custom sell rules to apply")
        end
    end
    
    -- Determine if we should keep this item or not
    local keep, fromRule = self.keepRules:Run(item)
    if keep then
        Vendor:DebugRules("Keeping '%s' due to rule '%s'", item.Name, fromRule)
        return false, fromRule
    end
    
    -- Determine if we should sell this item or not.
    local sell, fromRule = self.sellRules:Run(item)
    if sell then
        Vendor:DebugRules("Selling '%s' due to rule '%s'", item.Name, fromRule)
        return true, fromRule
    end

    -- Doesn't fit one of our above sell criteria so we keep it.
    return false, nil
end


