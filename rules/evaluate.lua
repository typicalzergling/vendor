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

-- Simple helper function which handles enumerating bags and running the function.
local function withEachBagAndItem(func, startBag, endBag)
    assert(type(func) == "function");
    for bag=startBag, endBag do
        for slot=1, GetContainerNumSlots(bag) do
            local item = Addon:GetItemPropertiesFromBag(bag, slot);
            if (item) then
                if not func(item, bag, slot) then
                    return false;
                end
            end
        end
    end
    return true;
end

--[[===========================================================================
    | GetMatchesForRule:
    |   Evaluate the given parameters against all the items your bag, this used
    |   to show matches in the edit rule dialog. The return value is a table with
    |   all the links in.  This bypasses the rule manager since we know exactly
    |   what we're evaluating.
    =============================================================================]]
function Addon:GetMatchesForRule(engine, ruleId, ruleScript, parameters)
    Addon:DebugRules("Evaluating '%s' against bags (no-cache)", ruleId);
    local rulesEngine = engine or self:CreateRulesEngine();
    local results = {};

    -- Make sure we've got a category
    rulesEngine:RemoveCategory(1);
    rulesEngine:CreateCategory(1, "<test>");

    local result, message = rulesEngine:AddRule(1, { Id = ruleId, Name = ruleId, Script = ruleScript }, parameters);
    if (result) then
        withEachBagAndItem(
            function(item)
                local result = rulesEngine:Evaluate(item);
                if (result) then
                    table.insert(results, item.Link);
                end
                return true;
           end, 0, NUM_BAG_SLOTS);
    else
        Addon:DebugRules("The rule '%s' failed to parse: %s", ruleId, message);
    end

    Addon:DebugRules("Complete evaluation of rule '%s' with %d matches", ruleId, #results);
    return results;
end

--[[===========================================================================
    | ValidateRuleAgainstBags:
    |   Use the players bags to validate the rule, this hopefully catches anything
    |   wrong with rule.  I am assuming that they want to match an item contained
    |   inside of their bags.
    ===========================================================================--]]
function Addon:ValidateRuleAgainstBags(engine, script)
    Addon:Debug("Validating script against bags (no-cache)");
    local rulesEngine = engine or self:CreateRulesEngine();
    local message = "";
    local valid = withEachBagAndItem(
        function(item)
            local r, m = engine:ValidateScript(item, script);
            if (not r) then message = m end;
            return r;
        end, 0, NUM_BAG_SLOTS);

    return valid, message;
end

--[[===========================================================================
    | GetRuleStatus:
    |   Returns the status of rules
    ===========================================================================--]]
function Addon:GetRuleStatus(ruleId)
    if (not self.ruleManager or not self.ruleManager.rulesEngine) then
        return nil;
    end

    local status = self.ruleManager.rulesEngine:GetRuleStatus(ruleId);
    if (status and (#status == 1)) then
        return unpack(status[1]);
    end
end

--[[===========================================================================
    | LookForItemsInBank:
    |   Evaluates all of the items in the bank against the rules, and returns
    |   the matches.
    ===========================================================================--]]
function Addon:LookForItemsInBank()
    if (not self.ruleManager) then
        self.ruleManager = Addon.RuleManager:Create();
    end

    local items = {};
    withEachBagAndItem(
        function (item, bag, slot)
            local sell = self.ruleManager:Run(item);
            if (sell) then
                table.insert(items, { bag, slot, item.Link });
            end
            return true;
        end,
        (NUM_BAG_SLOTS + 1),  (NUM_BAG_SLOTS + GetNumBankSlots()));
    return items;
end
