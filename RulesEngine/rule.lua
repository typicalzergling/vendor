local PackageName, Package = ...;
local RULE_OBJECT_NAME = (PackageName .. "::Rule");
local RULE_PARAMS_KEY = "RULE_PARAMS";

--[[===========================================================================
    | rule_Execute
    |    Called to exceute a rule against the specified environment, this
    |    a success or failure, followed by the result or message depending on
    |    on what happend.
    ========================================================================--]]
local function rule_Execute(self, environment)
    if (not self.script) then
        self.healthy = false;
    elseif (self.healthy) then
        self.executed = (self.executed + 1);
        -- Adjust the environment to for the rule
        rawset(environment, RULE_PARAMS_KEY, self.params);

        if (type(self.params) == "table") then
            for key, value in pairs(self.params) do
                rawset(environment, key, value)
            end
        end

        setfenv(self.script, environment)
        local status, result = pcall(self.script)        
        rawset(environment, RULE_PARAMS_KEY, nil);

        if (type(self.params) == "table") then
            for key, value in pairs(self.params) do
                rawset(environment, string.upper(key), nil)
            end
        end

        if status then
            self.healthy = true;
            if (type(result) == "number") then
                result = result ~= 0
            elseif (type(result) == "string") then
                result = false
            elseif (type(result) == "function") then
                result = false
            elseif (type(result) ~= "boolean") then
                result = false
            end

            return true, result, nil;
        else
            self.healthy = false;
            self.error = result;
            return false, false, result;
        end
    end

    return false, nil, nil
end

--[[===========================================================================
    | rule_Execute
    |    Called to exceute a rule against the specified environment, this
    |    a success or failure, followed by the result or message depending on
    |    on what happend.
    ========================================================================--]]
local function rule_CheckMatch(self, ...)
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

local rule_API =
{
    CheckMatch = rule_CheckMatch,
    Execute = rule_Execute,
    GetId = function(self) return self.id end,
    IsHealthy = function(self) return self.healthy end,
    GetName = function(self) return self.name end,
    GetWeight = function(self) return self.weight or 0 end,
    GetExecuteCount = function(self) return self.executed end,
    GetError = function(self) return self.error end,
};

--[[===========================================================================
    | rule_new
    |    Creates a new rule with the specified parameters. The return value
    |    is the newly initialized rule object or nil and the error message
    |    which indicates why we couldn't parse it.
    ========================================================================--]]
local function rule_new(id, name, script, params, weight)
    assert(id ~= nil and string.len(id) ~= 0, "The rule id is an invalid string, it must be valid and non-empty.")
    assert(name ~= nil and string.len(name) ~= 0, "The name of the rule must be non-empty and valid.");
    assert(script ~= nil and (type(script) == "function" or type(script) == "string"), "All rules must be provide a valid script function or text.")

    local instance =
    {
        id = string.lower(id),
        name = name,
        healthy = true,
        executed = 0,
        weight = weight or 0
    };

    -- We also need to wrap the rule script text in return.
    if (type(script) == "function") then
        instance.script = script;
    else
        local script, msg = loadstring(string.format("return (%s)", script))
        if (not script) then
            return nil, msg:gsub("%[string.*:%d+:%s*", "");
        else
            instance.script = script
        end
    end

    -- If this rule has parameters then create a copy of them so that
    -- we can setup our environment when we need to execute the rule.
    if ((params ~= nil) and (type(params) == "table")) then
        instance.params = {};
        for name, value in pairs(params) do
            rawset(instance.params, string.upper(name), value);
        end
    end

    -- Initialize the objects metatable
    return Package.CreateObject(RULE_OBJECT_NAME, instance, rule_API), nil;
end

-- Exposed API
Package.CreateRule = rule_new;
