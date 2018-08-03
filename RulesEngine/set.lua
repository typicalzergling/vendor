local PackageName, Package = ...;
local RULESET_OBJECT_NAME = (PackageName .. "::Ruleset");
local AND_RULES = 1;
local OR_RULES = 2;

-- Helper which turns "X|Y|Z" into a table of values.
function flagsFromString(str, sep)
    local r = {};
    str = tostring(str or "");
    str:gsub("([^|]+)", function(f)
            print(f);
            f = f:gsub("%s", "");
            table.insert(r, f);
        end);
    return r;
end

--[[===========================================================================
    | set_Execute
    |   Called to execute a rule set.  How this behaves depends on the logic
    |   operation for the set.  If it's an OR then the first rule which
    |   evaluates true causes the set to return true, otherwise if it's an
    |   and the first rule that returns false causes the set to return false.
    ========================================================================--]]
local function set_Execute(self, renv)
    local logicOp = self.logicOp;
    local setStatus = true;
    local setResult = false;
    local count = 0;
    local log = self.engine.log;

    self.executed = (self.executed + 1);
    -- Set the default value of the set result
    if (logicOp == AND_RULES) then
        setResult = true;
    end

    -- Evaluate the rules
    log:StartBlock("Evaluating Set[%s] logicOp=%d", self.id, logicOp);
    for _, rule in ipairs(self.rules) do
        count = (count + 1);
        if (rule:IsHealthy()) then
            log:Write("Executing '%s'", rule:GetId());
            local status, result, message = rule:Execute(renv);
            if (status) then
                if (result and (logicOp == OR_RULES)) then
                    setResult = true;
                    break;
                elseif (not result and (logicOp == AND_RULES)) then
                    setResult = false;
                    break;
                end
            else
                setStatus = false;
                setResult = false;
                setMessage = string.format("Set[%s] failed to execute rule=%d: ", self.id, rule:GetId(), message);
                break;
            end
        else
            setError = true;
            setMessage = string.format("Set[%s] contains unhealthy rule=%s [%s]", self.id, rule:GetId(), rule:GetError());
        end
    end
    log:EndBlock("Result=%s, [ran %d/%d]", tostring(setResult), count, #self.rules);

    return setStatus, setResult, setMessage;
end

--[[===========================================================================
    | set_CheckMatch
    |   Checks if our identifier is contained in the list of ids.  An empty
    |   list matches everything.
    ========================================================================--]]
local function set_CheckMatch(self, ...)
    local names = {...};
    if (#names == 0) then
        return true
    end

    for _, name in ipairs(names) do
        if (string.lower(name) == self.id) then
            return true
        end
    end

    return false
end

--[[===========================================================================
    | set_AddRule:
    |   Adds a new rule from the definition to our rule set.
    =========================================================================]]
local function set_AddRule(self, ruleDef, params)
    Package.validateRuleDefinition(ruleDef, 3);
    assert(ruleDef and type(ruleDef) == "table", "Invalid rule definition was provided");
    if (params and (type(params) ~= "table")) then
        error("The rule parameters must be a table, providing the parameters as key-value pairs", 2);
    end

    local rule, message = Package.CreateRule(ruleDef.Id, ruleDef.Name, ruleDef.Script, params);
    if (not rule) then
        self.engine.log:Write("Failed to add '%s' to set=%s due to error: %s", ruleDef.Id, self.id, message);
        return false, message;
    end

    table.insert(self.rules, rule);
    self.engine.log:Write("Added '%s' to set=%s", ruleDef.Id, self.id);
    return true, nil;
end

--[[===========================================================================
    | set_SetOptions
    |   Sets the options for this rule set, we currently support two
    |   options "RULE_AND" and "RULE_OR" to control the locial operations
    =========================================================================]]
local function set_SetOptions(self, options)
    for  _, option in  ipairs(flagsFromString) do
        if (option == "RULE_AND") then
            self.logicOp = RULE_AND;
        elseif (option == "RULE_OR") then
            self.logicOp = RULE_OR;
        else
            error(string.format("And invalid option \"%s\" was provided to %s.", option, RULESET_OBJECT_NAME), 2);
        end
    end
end

--[[===========================================================================
    | set_SetRules:
    |   This sets all of the rules in the set to be the indexed table passed
    |   into the set, with additionally a set of options passed in.
    |   Note: Parameters are considered to be passed in the .Params key of
    |   rule definition.  These can be null.
    =========================================================================]]
local function set_SetRules(self, rules, options)
    assert(rules and type(rules) == "table", "The rules to set must be a table");
    self.engine.log:StartBlock("Set[%d] settings rules (%s)", self.id, options or "");

    -- Set the rules
    table.setn(self.rules, 0);
    for _, rule in ipairs(rules) do
        Package.validateRuleDefinition(rule, 3);
        local result, message = set_AddRule(self, rule, rule.Params);
        if (not reuslt) then
            self.engine.log:EndBlock();
            return false, message;
        end
    end

    -- Set the options
    if (options) then
        set_setOptions(self, options);
    end

    self.engine.log:EndBlock();
    return true;
end

--[[===========================================================================
    | set_IsHealthy
    |   Checks the health of this rule set, in order for a set to be
    |   healthy all of our rules must be healthy.
    =========================================================================]]
local function set_IsHealthy(self)
    for _, rule in ipairs(self.rules) do
        if (not rule:IsHealthy()) then
            return false;
        end
    end

    return true;
end

--[[===========================================================================
    | set_GetError:
    |   This returns the first rule within our set that has an error or
    |   nil, if none of rules have an error.
    =========================================================================]]
local function set_GetError(self)
    for _, rule in ipairs(self.rules) do
        if (not rule:IsHealthy()) then
           return rule:GetError();
        end
    end
end

local ruleset_API =
{
    CheckMatch = set_CheckMatch,
    Execute = set_Execute,
    GetId = function(self) return self.id end,
    IsHealthy = set_IsHealthy,
    GetName = function(self) return self.name end,
    GetExecuteCount = function(self) return self.executed end,
    GetError = set_GetError,
    AddRule = set_AddRule,
    SetRules = set_SetRules,
    SetOptions = set_SetOptions;
    GetNumRules = function(self) return table.getn(self.rules); end,
};

--[[===========================================================================
    | new_Ruleset
    |    Creates a new rule with the specified parameters. The return value
    |    is the newly initialized rule object or nil and the error message
    |    which indicates why we couldn't parse it.
    ========================================================================--]]
local function new_Ruleset(engine, id, name)
    assert(id ~= nil and string.len(id) ~= 0, "The rule id is an invalid string, it must be valid and non-empty.")
    assert(name ~= nil and string.len(name) ~= 0, "The name of the rule must be non-empty and valid.");

    local instance =
    {
        id = string.lower(id),
        name = name,
        executed = 0,
        rules = {},
        logicOp = AND_RULES,
        engine = engine,
    };

    -- Initialize the objects metatable
    return Package.CreateObject(RULESET_OBJECT_NAME, instance, ruleset_API);
end

-- Exposed API
Package.CreateRuleset = new_Ruleset;
