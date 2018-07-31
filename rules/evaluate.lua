local Addon, L = _G[select(1,...).."_GET"]()
local Package = select(2, ...);

-- Evaluating items for selling.

-- Rules for determining if an item should be sold.
function Addon:EvaluateItemForSelling(item)
    -- Check some cases where we know we should never ever sell the item
    if not item then
        return false, nil, nil
    end

    -- If have not yet initialized, or the config has changed we need to build our list of "keep" rules
    -- we always add the check against the neversell list no matter what the options says
    if (not self.ruleManager) then
        self.ruleManager = Addon.RuleManager:Create();
    end

    -- Determine if we should keep this item or not
    return self.ruleManager:Run(item)
end

-- Evaluate the given parameters against all the items your bag, this used to show matches in the
-- edit rule dialog. The return value is a table with all the links in.  This bypasses the rule
-- manager since we know exactly what we're evaluating.
function Addon:GetMatchesForRule(ruleId, ruleScript, parameters)
    Addon:DebugRules("Evaluating '%s' against bags (no-cache)", ruleId);
    local rulesEngine = CreateRulesEngine(Addon.RuleFunctions, false);
    local results = {};

    -- Add any extension functions to the instance.
    if (Package.Extensions) then
        rulesEngine:AddFunctions(Package.Extensions:GetFunctions());
    end

    rulesEngine:CreateCategory(1, "<test>");
    local result, message = rulesEngine:AddRule(1, { Id = ruleId, Name = ruleId, Script = ruleScript }, parameters);
    if (result) then
        for bag=0,NUM_BAG_SLOTS do
            for slot=1, GetContainerNumSlots(bag) do
                local item = Addon:GetItemPropertiesFromBag(bag, slot);
                if (item) then
                    local result = rulesEngine:Evaluate(item);
                    if (result) then
                        table.insert(results, item.Link);
                    end
                end
            end
        end
    else
        Addon:DebugRules("The rule '%s' failed to parse: %s", ruleId, message);
    end

    Addon:DebugRules("Complete evaluation of rule '%s' with %d matches", ruleId, #results);
    return results;
end

-- Retrieves the status of the secified rule
function Addon:GetRuleStatus(ruleId)
    if (not self.ruleManager or not self.ruleManager.rulesEngine) then
        return nil;
    end

    local status = self.ruleManager.rulesEngine:GetRuleStatus(ruleId);
    if (status and (#status == 1)) then
        return unpack(status[1]);
    end
end
