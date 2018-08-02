local PackageName, Package = ...;
local ENGINE_OBEJCT_TYPE = (PackageName .. "::Engine");
local g_engineId = 0;

--[[===========================================================================
    | insertCategory (local)
    |   Given a category this attempts to find where to put the category
    |   in order, we sort them by category ID, smallest to biggest.
    =======================================================================--]]
local function insertCategory(self, category)
    local index = 1;
    local categories = self.categories;

    while (categories[index] and categories[index]:GetId() < category:GetId()) do
        index = (index + 1);
    end
    table.insert(categories, index, category);
    return index;
end

--[[===========================================================================
    | findCategory (local)
    |   Locate a category by ID, if not found nil is returned.
    =======================================================================--]]
local function findCategory(self, categoryId)
    for _, category in ipairs(self.categories) do
        if (category:GetId() == categoryId) then
            return category;
        end
    end
end

-- Given a table of possible functions this assigns the given environment to each function.
local function assignFunctionEnv(functions, env)
    for _, v in pairs(functions) do
        if (type(v) == "function") then
            setfenv(v, env);
        end;
    end
end

--[[===========================================================================
    | engine_CreateCategory
    |   Creates a new category in the engine with the specified ID, if the
    |   category alreay exists this raises an error.
    =======================================================================--]]
local function engine_CreateCategory(self, categoryId, categoryName)
    assert(type(categoryName) == "string" and string.len(categoryName) ~= 0, "A category name must be a valid string");
    assert(tonumber(categoryId), "Category IDs must be numeric");
    assert(not findCategory(self, categoryId), "A category with id='" .. tostring(categoryId) .. "' already exists");

    local category = Package.CreateCategory(categoryId, categoryName);
    insertCategory(self, category);
    self.log:Write("Created category(%d, %s)", categoryId, categoryName);
end

--[[===========================================================================
    | engine_ImportGlobals
    |   This imports globals which should be exposed to the rule scripts, this
    |   is addative and can be called more than once, but a good selection is
    |   already handles in the constructor.
    =======================================================================--]]
local function engine_ImportGlobals(self, ...)
    self.log:StartBlock("Start ImportGlobals");
    for _, globalName in ipairs({...}) do
        local global = _G[globalName]
        if (global ~= nil) then
            self.log:Write("Importing: %s", globalName);
            rawset(self.globals, globalName, global);
        end
    end
    self.log:EndBlock();
end

--[[===========================================================================
    | engine_AddFunction
    |   Adds a function to environment which is presented to the rule scripts.
    =======================================================================--]]
local function engine_AddFunction(self, functionName, targetFunction)
    assert(type(functionName) == "string", "function name must be a string")
    assert(type(targetFunction) == "function", "type of targetFunction must be a function")

    self.log:Write("Adding function '%s'", functionName);
    rawset(self.environment, functionName, targetFunction);
end

--[[===========================================================================
    | engine_AddFunctions
    |   Adds a table of functions to the environment used by the rules
    =======================================================================--]]
local function engine_AddFunctions(self, functions)
    assert(type(functions) == "table", "A table of functions must be provided")

    self.log:StartBlock("Start AddFunctions");
    for name, func in pairs(functions) do
        if (type(func) == "function") then
            engine_AddFunction(self, name, func);
        end
    end
    self.log:EndBlock();
end

--[[===========================================================================
    | engine_AddConstant
    |   Adds a constant to the enviornment which is present the rule functions
    =======================================================================--]]
local function engine_AddConstant(self, constantName, constantValue)
    assert(type(constantName) == "string", "constant name must be a string")
    assert(constantValue, "The constant must have a value")
    assert(type(constantValue) ~= "function" and type(constantValue) ~= "table", "the constant must be a simple type");

    self.log:Write("Adding constant '%s'", constantName);
    rawset(self.environment, constantName, constantValue);
end

--[[===========================================================================
    | engine_AddConstants
    |   Adds a table of constants to the rule enviornment
    =======================================================================--]]
local function engine_AddConstants(self, constants)
    assert(type(constants) == "table", "A table of constants must be provided")

    self.log:StartBlock("Begin AddConstants");
    for name, value in pairs(constants) do
        if (type(value) ~= "function") and (type(value) ~= "table") then
            engine_AddConstant(self, name, value)
        end
    end
    self.log:EndBlock();
end

--[[===========================================================================
    | validate_Rule (local)
    |   Given a table which represents a rule definition tis applies all of
    |   constraints to make sure it adheres to what we need.
    =======================================================================--]]
local function validateRule(rule)
    -- Valid the ID
    local id = rule.Id;
    if (not id or (type(id) ~= "string") or (string.len(id) == 0)) then
        error("The rule identifier is invalid", 3);
    end

    -- Valid the name
    local name = rule.Name;
    if (not name or (type(name) ~= "string") or (string.len(name) == 0)) then
        error("The rule name must be a valid string", 3);
    end

    -- Validate the script.
    local script = rule.Script;
    if (not script) then
        error("The rule script must be valid.", 2);
    end

    if (type(script) == "string") and (string.len(script) == 0) then
        error("The rule cannot have an empty script", 3);
    elseif (type(script) ~= "function" and type(script) ~= "string") then
        error("The rule script is an unsupported type: " .. type(script), 3);
    end

    return true;
end

--[[===========================================================================
    | engine_AddRule
    |   Adds creates and adds a rule with the specified definition to the
    |   given category.  The definition must have at least the following
    |   properties:
    |       Id - The unique rule ID for the sepcified rule.
    |       Name - The name of the rule (used for debuging/returns
    |       Script - A string of lua, or function which represents the rule
    |
    |   In addtion, you can pass a table of parameters available to the
    |   rule when it's evaluated.
    =======================================================================--]]
function engine_AddRule(self, categoryId, ruleDef, params)
    assert(type(categoryId) == "number", "The category id must be numeric identifier");
    validateRule(ruleDef);
    if (params and type(params) ~= "table") then
        error("The rule parameters must be a table, providing the parameters as key-value pairs", 2);
    end

    local category = assert(findCategory(self, categoryId), "The specified categoryId (" .. tostring(categoryId) .. ") is invalid, remember to call AddCategory first");
    local rule, message = Package.CreateRule(ruleDef.Id, ruleDef.Name, ruleDef.Script, params);
    if (not rule) then
        self.log:Write("Failed to add '%s' to category=%d due to error: %s", ruleDef.Id, categoryId, message);
        return false, message;
    end

    category:Add(rule);
    self.log:Write("Added '%s' [%d]", ruleDef.Id, categoryId);
    return true, nil;
end

--[[===========================================================================
    | evaluateRules (local)
    |   Helper which handles evaluating all of our rules, this will return
    |   true/false if we found a match, the rule and category along with
    |   the number of rules we ran.
    =======================================================================--]]
local function evaluateRules(self, log, categories, ruleEnv, ...)
    local rulesRun = 0;
    local result = false;
    local rule;
    local category;

    for _, cat in ipairs(categories) do

        log:StartBlock("Category(%d, '%s')", cat:GetId(), cat:GetName());
        local r, ran, message = cat:Evaluate(self, log, ruleEnv, ...);
        rulesRun = (rulesRun + ran);
        log:EndBlock(" End [ran=%d]", ran);

        if (r) then
            rule = r;
            category = cat;
            result = true;
            break;
        end
    end

    return result, rule, category, rulesRun;
end

--[[===========================================================================
    | createAccessors (local)
    |   Given an object, this push all of the non-table and non-function
    |   key/values into a table, for exmaple: object.Id -> Id.
    =======================================================================--]]
local function createAccessors(object)
    local accessors = {};
    if (object) then
        for name, value in pairs(object) do
            if (type(name) == "string") then
                local valueType = type(value);
                if ((valueType ~= "table") and (valueType ~= "function")) then
                    rawset(accessors, name, value);
                end
            end
        end
    end
    return accessors;
end

--[[===========================================================================
    | createRestrictedEnvironment (local)
    |    Builds a table which handles combining the contents of the N tables,
    |   for example, overriding a global function, the are searched in the
    |   order they are specified to this function.
    =======================================================================--]]
local function createRestrictedEnvironment(readOnly, ...)
    local envs = { ... };
    return setmetatable({},
        {
            __newindex =
                function(self, key, value)
                    if (readOnly) then
                        error("The environment is read-only and cannot be changed", 3);
                    end
                    rawset(self, key, value);
                end,
            __index =
                function(self, key)
                    local v = rawget(self, key);
                    if (v ~= nil) then
                        return v;
                    end
                    for _, env in ipairs(envs) do
                        local v = rawget(env, key);
                        if (v ~= nil) then
                            return v;
                        end
                    end

                    if (readOnly) then
                        error(string.format("No function or variable named \"%s\" was not found", key), 3);
                    end
                end
        })

end


--[[===========================================================================
    | engine_Evaluate
    |   Evaluates all of then rules (or a specific rule) and returns true of
    |   and the name of the that matches it.
    |
    |   ... is optional, if provided it will only run that rule.
    |   returns:
    |   result (true or false)
    |   exceuted - the number of rules that executed during evaluate
    |   categoryId - the category the match belongs to
    |   id - the identifier of the matched rule
    |   name - the name of the matched rule
    |   categoryName - the name of the category which contained the matched rule
    =======================================================================--]]
local function engine_Evaluate(self, object, ...)
    -- Create a table of functions that allow you to access the the provided object
    local accessors = createAccessors(object);

    -- Create the environment we want to run the rules against.  Then update the environment of
    -- all the functions we've got in our local environment
    --   Rules - Can see in this order, Our environment, the object accessors, and imported globals.
    --   Function -- Can see in this order, the object accessors and the globals
    local ruleEnv = createRestrictedEnvironment(true, accessors, self.environment, self.globals);
    assignFunctionEnv(self.environment, createRestrictedEnvironment(false, accessors, { OBJECT = object },  _G));

    -- Iterate over all of our lists and determine what the action is based of the
    -- the value of the rules.  The first rule which returns something other than no-action
    -- stops the execution of the rules.
    local matchedRuleId = "<none>";
    local matchedRuleName = nil;
    local matchedCategory = "<none>";
    local categoryId = nil;

    self.log:StartBlock("Evaluating \"%s\"", object.Name or "<unknown>")
    local result, rule, category, rulesRun = evaluateRules(self, self.log, self.categories, ruleEnv, ...)
    if (result and rule and category) then
        matchedRuleId = rule:GetId();
        matchedRuleName = rule:GetName();
        matchedCategory = category:GetName();
        categoryId = category:GetId();
    end

    self.log:EndBlock("result=%d, id=%s [%s], ran=%d", result, matchedRuleId, matchedCategory, rulesRun)
    return result, rulesRun, categoryId, matchedRuleId, matchedRuleName, matchedCategory
end

--[[===========================================================================
    | engine_CreateRuleId
    |   Generates a new unique custom rule id, this rule encodes the player, realm
    |   and time so it should be very unique.
    =======================================================================--]]
local function engine_CreateRuleId(self, categoryId, uniqueName)
    assert(type(categoryId) == "number", "Invalid category ID");
    assert(type(uniqueName) == "string" and string.len(uniqueName) ~= 0, "The unique portion of the ruleId must be valid");

    local category = assert(findCategory(self, categoryId), "The categoryID '" .. tostring(categoryId) .. "' is invalid");
    return string.format("%d.%s", tostring(categoryId), uniqueName);
end

--[[===========================================================================
    | engine_GetRuleStatus
    |   Returns the status of any rule which matches the specified arguments
    |   and returns the results in a table.
    =======================================================================--]]
local function engine_GetRuleStatus(self, ...)
    local status = {}
    for _, category in ipairs(self.categories) do
        category:GetRuleStatus(status, ...);
    end
    return status;
end

--[[===========================================================================
    | engine_CLearRules
    |   Removes all rules from the engine, preserves the environment and
    |   the status.
    =======================================================================--]]
local function engine_ClearRules(self)
    for _, category in ipairs(self.categories) do
        category:Reset();
    end
end

--[[===========================================================================
    | engine_CreateRuleId
    |   Toggles the verbosity of the engine.
    =======================================================================--]]
local function engine_SetVerbose(self, verbose)
    self.log = Package.CreateLog(self.id, verbose);
end

--[[===========================================================================
    | engine_ValidateScript:
    |   Given script text and an object this will validate the script against
    |   the current environment.
    |
    |   Step 1:
    |       Make a rule from the specified script/parameters.
    |
    |   Step 2:
    |       Evaluate the rule against the sample object.
    |
    |   Returns true if validation succeeds, or false and an error message
    |   we are unable to validate the script.
    =======================================================================--]]
local function engine_ValidateScript(self, object, script, params)
    assert(object and (type(object) == "table"), "A valid object must be provided to evaluate against.");
    assert(script and (type(script) == "string") and (string.len(script) ~= 0), "A valid script must be provided to validate.");

    -- Step 1 - Create the rule
    local id =  string.format("vr_%s", time());
    local rule, message = Package.CreateRule(id, id, script, params);
    if (not rule) then
        return false, message;
    end

    -- Step 2 - Evaluate it against the test object
    local accessors = createAccessors(object);
    local renv = createRestrictedEnvironment(true, accessors, self.environment, self.globals);
    assignFunctionEnv(self.environment, createRestrictedEnvironment(false, accessors, { OBJECT = object }, _G));
    local status, _, message = rule:Execute(renv);

    if (not status) then
        return false, message;
    end

    return true;
end

-- Define the API we expose
local engine_API =
{
    CreateRuleId = engine_CreateRuleId,
    Evaluate = engine_Evaluate,
    AddRule = engine_AddRule,
    ImportGlobals = engine_ImportGlobals,
    AddFunctions = engine_AddFunctions,
    AddConstants = engine_AddConstants,
    CreateCategory = engine_CreateCategory,
    GetId = function(self) return self.id end,
    GetRuleStatus = engine_GetRuleStatus,
    ClearRules = engine_ClearRules,
    SetVerbose = engine_SetVerbose,
    ValidateScript = engine_ValidateScript,
};

--[[===========================================================================
    | new_Engine
    |   Creates and initializes a new rule engine object, Optionally a
    |   table of functions and constants can be passed.
    =======================================================================--]]
local function new_Engine(environment, verbose)
    g_engineId = (g_engineId + 1);

    local instance =
    {
        id = g_engineId,
        categories = {},
        environment = {},
        globals = {},
        log = Package.CreateLog(g_engineId, verbose);
        OnRuleStatusChange = Package.CreateEvent("OnRuleStatusChange"),
    }

    instance.log:StartBlock("Start create [%04d]", instance.id);
    -- If the caller gave us functions which should be available then
    -- important them into our environment along with certain globals
    engine_ImportGlobals(instance, "string", "math", "table", "tonumber", "tostring")
    if (environment and (type(environment) == "table")) then
        for name, value in pairs(environment) do
            if (type(value) == "function") then
                engine_AddFunction(instance, name, value);
            elseif (type(value) ~= "table") then
                engine_AddConstant(instance, name, value);
            end
        end
    end
    instance.log:EndBlock();

    return Package.CreateObject(ENGINE_OBEJCT_TYPE, instance, engine_API);
end

-- Expose our create function to the world, this is the only entry point
-- into this instance module/package/addon
_G["CreateRulesEngine"] = new_Engine;
