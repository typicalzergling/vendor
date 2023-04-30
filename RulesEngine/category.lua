local PackageName, Package = ...;
local CATEGORY_OBJECT_TYPE = (PackageName .. "::Category");

--[[===========================================================================
    | category_Find
    |   Searches this category for a rule which matches the specified id, if
    |   such a rule is found then this returns it, otherwise nil is returned.
    =======================================================================--]]
local function category_Find(self, id)
    assert(type(id) == "string" and string.len(id) ~= 0, "A valid rule identifier must be provided to search");

    for _, rule in ipairs(self.rules) do
        if (rule:CheckMatch(id)) then
            return rule
        end
    end
end

--[[===========================================================================
    | category_Add
    |   Adds the specified rule to the category, if the rule is already in
    |   the category list then this is noop, it will not add the rule a
    |   second time.
    =======================================================================--]]
local function category_Add(self, rule)
    assert(rule, "A valid rule is required for addition to a category");

    if (not category_Find(self, rule:GetId())) then
        table.insert(self.rules, rule);
    end
end

--[[===========================================================================
    | category_Removes
    |   Removes the provided rule id from this category, if the rule was 
    |   removed then true is returned otherwise false is returned
    =======================================================================--]]
local function category_Remove(self, ruleId)
    assert(type(id) == "string" and string.len(id) ~= 0, "An invalid ruleId was provided")

    for i, rule in ipairs(self.rules) do
        if (rule:CheckMatch(ruleId)) then
            table.remove(self.rules, i)
            return true
        end
    end

    return false
end

--[[===========================================================================
    | category_Reset
    |   This clears all of the rules within this category
    =======================================================================--]]
local function category_Reset(self)
    self.rules = {};
end

--[[===========================================================================
    | category_EvaluateOne
    |   Execute a single rule and return the result
    =======================================================================--]]
local function category_EvaluateOne(self, engine, ruleOrId, log, environment)
    if (type(ruleOrId) == "string") then
        ruleOrId = self:category_Find(self, ruleOrId)
    end

    if (type(ruleOrId) == "table") and ruleOrId:IsHealthy() then
        log:Write("Evaluating rule '%s' (weight: %d)", ruleOrId:GetId(), 0);
        local status, result, message = ruleOrId:Execute(environment)
        if (not status) then
            log:Write("Rule '%s' failed to execute: %s", ruleOrId:GetId(), message or "<unknown error>");
            engine.OnRuleStatusChange("UNHEALTHY", self.id, ruleOrId:GetId(), ruleOrId:GetError())
            return true, false, true, 0
        end

        return true, result == true, false, ruleOrId:GetWeight()
    end


    log:Write("Unable to determine rule to execute [category=%s, rule=%s]", tostring(self:GetId()), tostring(ruleOrId))
    return false, false, false, 0
end

--[[===========================================================================
    | category_Evaluate
    |   This is called to evaluate the rules in this category.  This will
    |   return the rule which evaluated to true otherwise it returns nil.
    |
    |   This only executes healthy rules, the first rule to return a non
    |   false value breaks the loop stops evaluation
    =======================================================================--]]
local function category_Evaluate(self, engine, log, environment)
    local count = 0
    local base = 2 * (#self.rules + 1)
    for index, rule in ipairs(self.rules) do
        if (rule:IsHealthy()) then
            count = count + 1
            
            -- TODO: this should loop and determine the highest weight rule

            log:Write("Evaluating rule '%s' (weight: %d)", rule:GetId(), rule:GetWeight())
            local _, result, error, weight = category_EvaluateOne(self, engine, rule, log, environment)
            if (not error and result) then
                local weight = rule:GetWeight() or 0
                if (type(weight) == "number" and (weight ~= 0)) then
                    weight = base + weight
                else
                    weight = math.max(0, base - (2 * index))
                end

                log:Write("Evaluated rule '%s' to true (weight: %d)", rule:GetId(), rule:GetWeight())
                return rule, count, nil, (self:GetWeight() + weight)
            end
        else
            -- Skipping rule because it isn't healthy
            log:Write("Skipping rule '%s' (unhealthy)", rule:GetId())
        end
    end

    -- We ran everything and nothing returned a valid result, so we just
    -- want to return the count of rules that we ran.
    return nil, count, nil, 0;
end

--[[===========================================================================
    | category_GetRuleStatus
    |   Queries the health of any rule that matches the arguments and adds
    |   an entry to the table for the health of the rule.
    =======================================================================--]]
local function category_GetRuleStatus(self, status, ...)
    for _, rule in ipairs(self.rules) do
        if (rule:CheckMatch(...)) then
            local health = "HEALTHY";
            if (not rule:IsHealthy()) then
                health = "ERROR";
            end
            table.insert(status, { self.id, rule:GetId(), health, rule:GetExecuteCount(), rule:GetError() });
        end
    end
end

-- Define the category API
local category_API =
{
    Add = category_Add,
    Reset = category_Reset,
    Evaluate = category_Evaluate,
    GetName = function(self) return self.name end,
    GetId = function(self) return self.id end,
    GetWeight = function (self) return self.weight end,
    GetRuleStatus = category_GetRuleStatus,
    Find = category_Find,
    Remove = category_Remove,
};

--[[===========================================================================
    | new_Category
    |   Create a new category with the specified name, the name must be a
    |   non-empty string.
    =======================================================================--]]
local function new_Category(id, name, weight)
    assert(type(name) == "string" and (string.len(name) ~= 0), "The category name must be a valid string");
    assert(id and type(id) == "number", "The category id must be provided and be non-empty");
    assert(not weight or type(weight) == "number", "The weight of a category must be a number")

    local instance =
    {
        name = name,
        id = id,
        rules = {},
        weight = weight or 0
    };

    return Package.CreateObject(CATEGORY_OBJECT_TYPE, instance, category_API);
end

-- Publish the constructor so it's visible to the rest of the package
Package.CreateCategory = new_Category;
