
Vendor = Vendor or {}
Vendor.RuleManager = {}

local RULE_TYPE_LOCKED = 1
local RULE_TYPE_KEEP = 2
local RULE_TYPE_SELL = 3
local RULE_TYPE_CUSTOM = 4

Vendor.RULE_ACTION_NONE = 0
Vendor.RULE_ACTION_KEEP = 1
Vendor.RULE_ACTION_SELL = 2
Vendor.RULE_ACTION_PROMPT = 3

Vendor.RuleResult =
{
	NONE = 0,
	KEEP = 1,
	SELL = 2,
	PROMPT = 3,
}

--*****************************************************************************
-- Create a new rule object which handles keeping track of the rule it
-- has two properties an ID and compiled chunk of script.
--*****************************************************************************
Vendor.RuleManager.Rule = {}
function Vendor.RuleManager.Rule:Create(ruleType, ruleId, ruleScript)
	assert(type(ruleType) == "number", "The rule type must be one of our constants")
    assert(ruleId ~= nil and string.len(ruleId) ~= 0, "all rules must have a valid identifier")
    assert(ruleScript ~= nil and string.len(ruleId) ~= 0, "all rules must have a valid script")

    instance = {
		Type = ruleType,
        Id = string.lower(ruleId),
        Script = nil,
        Order = 0,
    }
    
    -- We also need to wrap the rule script text in return. 
    if (type(ruleScript) == "function") then
    	instance.Script = ruleScript
    else    
	    local script, _,  msg = loadstring(string.format("return (%s)", ruleScript))
	    if (not script) then
	        Vendor:DebugRules("Failed to create script for '%s'  {%s} :: ", ruleId, ruleScript, msg)
	    else
	        instance.Script = script
	    end
	end
	
    setmetatable(instance, self)
    self.__index = self 
    return instance
end

--*****************************************************************************
-- Execute this rule against the provided environment, if the execution 
-- fails this returns false.
--*****************************************************************************
function Vendor.RuleManager.Rule:Run(environment)
    if self.Script then
        setfenv(self.Script, environment)
        local status, result = pcall(self.Script)
        
        if status then
			if (type(result) == "number") and (result >= Vendor.RuleResult.NONE) and (result <= Vendor.RuleResult.PROMPT) then
				return result
			elseif (type(result) == "boolean") then
				if (self.Type == RULE_TYPE_SELL) then 
					if (result) then 
						return Vendor.RULE_ACTION_SELL 
					end
				elseif (self.Type == RULE_TYPE_KEEP) then
					if (result) then 
						return Vendor.RULE_ACTION_KEEP 
					end
				end
			end
        elseif not status then
            Vendor:DebugRules("Failed to invoke rule '%s' : %s%s%s", self.Id, RED_FONT_COLOR_CODE, result, FONT_COLOR_CODE_CLOSE)
        end
    end
    -- If we get here something went wrong and we should take no-action
	return Vendor.RULE_ACTION_NONE
end

--*****************************************************************************
-- Determins if this rule mathces the named provided as arguments if no 
-- names are provided then it is assumed that we match
--*****************************************************************************
function Vendor.RuleManager.Rule:Matches(...)
	local names = {...}
	if (#names == 0) then
		return true
	end
	for _, name in ipairs(names) do
		if (string.lower(name) == self.Id) then
			return true
		end
	end
	return false
end

--*****************************************************************************
-- Create a new RuleManager which is a container to manage rules and the 
-- environment they run in.
--*****************************************************************************
function Vendor.RuleManager:Create(functions)
    instance = {
        rules =
        {
        	[RULE_TYPE_LOCKED] = {},
        	[RULE_TYPE_KEEP] = {},
        	[RULE_TYPE_SELL] = {},
        	[RULE_TYPE_CUSTOM] = {},
        },
        environment = {},
        globals = {},
    }

    -- If the caller gave us functions which should be available then
    -- important them into our environment along with certain globals
    Vendor.RuleManager.importGlobals(instance, "string", "math", "tonumber", "tostring")
    Vendor.RuleManager.AddConstants(instance, Vendor.RuleResult)
    if (functions and (type(functions) == "table")) then
    	Vendor.RuleManager.AddFunctions(instance, functions)
    end
    
    setmetatable(instance, self)
    self.__index = self
    return instance
end

--*****************************************************************************
-- This imports globals which should be exposed to the rule scripts, this 
-- is addative and can be called more than once, but a good selection is 
-- already handles in the constructor.
--*****************************************************************************
function Vendor.RuleManager:importGlobals(...)
    for _, globalName in ipairs({...}) do
        local global = _G[globalName]
        if (global ~= nil) then
            self.globals[globalName] = global
        end
    end
end

--*****************************************************************************
-- Adds a function to environment which is presented to the rule scripts. 
--*****************************************************************************
function Vendor.RuleManager:AddFunction(functionName, targetFunction)
    assert(type(functionName) == "string", "function name must be a string")
    assert(type(targetFunction) == "function", "type of targetFunction must be a function")
    Vendor:DebugRules("Adding function '%s' the rule environment", functionName)
    self.environment[functionName] = targetFunction
end

--*****************************************************************************
-- Adds a table of functions to the environment used by the rules
--*****************************************************************************
function Vendor.RuleManager:AddFunctions(functions)
	assert(type(functions) == "table", "A table of functions must be provided")
	for name, func in pairs(functions) do
		if (type(func) == "function") then
			Vendor.RuleManager.AddFunction(self, name, func)
		end
	end
end

--*****************************************************************************
-- Adds a constant to the enviornment which is present the rule functions
--*****************************************************************************
function Vendor.RuleManager:AddConstant(constantName, constantValue)
	assert(type(constantName) == "string", "constant name must be a string")
	assert(constantValue, "The constant must have a value")
	Vendor:DebugRules("Adding constant '%s' with value '%s' to the rule environment", constantName, constantValue)
	self.environment[constantName] = constantValue
end

--*****************************************************************************
-- Adds a table of constants to the rule enviornment
--*****************************************************************************
function Vendor.RuleManager:AddConstants(constants)
	assert(type(constants) == "table", "A table of constants must be provided")
	for name, value in pairs(constants) do
		Vendor.RuleManager.AddConstant(self, name, value)
	end
end

--*****************************************************************************
-- Adds a rule with the specified id and the script. 
--*****************************************************************************
function Vendor.RuleManager:AddRule(ruleId,  ruleScript)
    assert(type(ruleId) == "string", "rule name must be a string")
    assert(type(ruleScript) == "string", "rule script must be a string")
    self.rules[ruleId] = self.Rule:Create(ruleId, ruleScript)
    Vendor:DebugRules("Added rule '%s'", ruleId)
end

--*****************************************************************************
-- This handles evaluating the rules against the specified environment 
--*****************************************************************************
local function evaluateRules(rules, ruleEnv, ...)
	local rulesRun = 0
	for _, ruleList in pairs(rules) do
		for _, rule in ipairs(ruleList)	do
			if rule:Matches(...) then
				rulesRun = (rulesRun + 1)
				local result = rule:Run(ruleEnv)				
				Vendor:DebugRules("|         %s[type=%d, order=%d] %d", rule.Id, rule.Type, rule.Order, result)				
				if (result ~= Vendor.RULE_ACTION_NONE) then
					return result, rule.Id, rulesRun, rule.Name
				end
			end
		end
	end	
	return Vendor.RUN_ACTION_NONE, nil, rulesRun, nil
end

--*****************************************************************************
--  Evaluates all of then rules (or a specific rule) and returns true of 
--  and the name of the that matches it.
--
-- ruleName is optional, if provided it will only run that rule.
--*****************************************************************************
function Vendor.RuleManager:Run(targetObject, ...)
    -- Create a table of functions that allow you to access the the provided object
    local accessors = {}
    if targetObject then
        for name, value in pairs(targetObject) do
            if ((type(value) ~= "function") or (type(value) ~= "table")) then
                accessors[name] = function() return value end
            end
        end
    end 

    -- Create the environment we want to run the rules against.  Then update the environment of 
    -- all the functions we've got in our local environment
    --   Rules - Can see in this order, Our enviornment, the object accessors, and imported globals.
    --   Function -- Can see in this order, the object accessors and the globals
    local ruleEnv = self:CreateRestrictedEnvironment(self.environment, self:CreateRestrictedEnvironment(accessors, self.globals))
    local functionEnv = self:CreateRestrictedEnvironment(accessors, _G) 
    for k,v in pairs(self.environment) do
        if (type(v) == "function") then
            setfenv(v, functionEnv)
        end
    end

	-- Iterate over all of our lists and determine what the action is based of the 
	-- the value of the rules.  The first rule which returns something other than no-action
	-- stops the execution of the rules.
	Vendor:DebugRules("+ Start \"%s\"", targetObject.Name or "<unknown>")
	local result, matchedRuleId, rulesRun, matchedRuleName = evaluateRules(self.rules, ruleEnv, ...)
	Vendor:DebugRules("+ End [result=%d, id=%s, ran=%d", result, (matchedRuleId or "<none>"), rulesRun)
	
    return result, matchedRuleId, rulesRun, matchedRuleName
end

--*****************************************************************************
-- Builds a table which handles combining the contents of the two tables,
-- for example, overriding a global function
--
-- chainTo is optional and can be nil to stop the chain.
--*****************************************************************************
function Vendor.RuleManager:CreateRestrictedEnvironment(environment, chainTo)
    instance = {}
    setmetatable(instance, 
        { 
        __index = function(self, key)
            local value = environment[key]
            if (value == nil) and (chainTo ~= nil) then
                value = chainTo[key]
            end
            return value
        end
        })
        
    return instance
end


--*****************************************************************************
-- This will add a system rule of the specified type to the list of rules
-- we are going to run.  The rule could end up in either type specific 
-- list or the locked list depending on the rule.
--*****************************************************************************
function Vendor.RuleManager:AddSystemRule(ruleType, ruleId, insets, ruleDef)
	assert(type(ruleType) == "string", "The ruleType must be a string")
	assert(type(ruleId) == "string", "the rule id must be a string")

	local systemRuleDef = ruleDef or Vendor.SystemRules.GetDefinition(ruleType, ruleId, insets)
	if (not systemRuleDef) then
		Vendor:DebugRules("Unable to locate system rule '%s' of type '%s'", ruleId, ruleType)
		return
	end

	-- Little helper function to keep the rule tables in order
	local function insertRuleSorted(t, r)
		for i=1,#t do
			if (t[i].Order > r.Order) then
				table.insert(t, i, r)
				return
			end
		end
		table.insert(t, r)
	end

	local ruleTable = nil
	local rule = nil
	if (systemRuleDef.Locked) then
		ruleTable = self.rules[RULE_TYPE_LOCKED]
		if (ruleType == Vendor.c_RuleType_Keep) then
			rule = self.Rule:Create(RULE_TYPE_KEEP, systemRuleDef.Id, systemRuleDef.Script)
		else
			assert(ruleType == Vendor.c_RuleType_Sell, "Locked rules can only be Sell/Keep (" .. ruleType .. ")")
			rule = self.Rule:Create(RULE_TYPE_SELL, systemRuleDef.Id, systemRuleDef.Script)
		end
	elseif (ruleType == Vendor.c_RuleType_Sell) then
		ruleTable = self.rules[RULE_TYPE_SELL] 
		rule = self.Rule:Create(RULE_TYPE_SELL, systemRuleDef.Id, systemRuleDef.Script)
	elseif (ruleType == Vendor.c_RuleType_Keep) then
		ruleTable = self.rules[RULE_TYPE_KEEP] 
		rule = self.Rule:Create(RULE_TYPE_KEEP, systemRuleDef.Id, systemRuleDef.Script)
	end	

	if (rule and ruleTable) then
		if (not rule.Order or rule.Order == 0) then
			if (systemRuleDef.Order) then
				assert(type(systemRuleDef.Order) == "number", "Why does the rule definition have a non-numeric order?")
				rule.Order = systemRuleDef.Order
			else
				rule.Order = #ruleTable
			end
		end
		
		Vendor:DebugRules("Adding system rule '%s'  [type='%d', order=%d]", rule.Id, rule.Type, rule.Order)
		rule.Name = systemRuleDef.Name
		insertRuleSorted(ruleTable, rule)
	end
end

--*****************************************************************************
-- Helper which handles walking through a config block of system rules
-- sell, keep and applies them the config manager.
--*****************************************************************************
local function applySystemRuleConfig(ruleManager, ruleType, configBlock)
	for _, ruleConfig in ipairs(configBlock) do
		if (type(ruleConfig) == "string") then
			ruleManager:AddSystemRule(ruleType, ruleConfig, nil)
		elseif (type(ruleConfig) == "table") then
			assert(ruleConfig.rule and type(ruleConfig.rule) == "string", "rule config should contain the ruleId")
			ruleManager:AddSystemRule(ruleType, ruleConfig.rule, ruleConfig)
		end
	end
end

--*****************************************************************************
-- Given a configuration table this will update the state of this rule
-- manager to reflect the state. This clears all existing rules we might
-- alread have and then adds locked, plus the rules in the table below.
--*****************************************************************************
function Vendor.RuleManager:UpdateConfig(configTable)
	Vendor:DebugRules("Updating rule maanger config")
	
	self.rules =
        {
        	[RULE_TYPE_LOCKED] = {},
        	[RULE_TYPE_KEEP] = {},
        	[RULE_TYPE_SELL] = {},
        	[RULE_TYPE_CUSTOM] = {},
        }

	-- First apply all of the locked rules
	for _, lockedRule in ipairs(Vendor.SystemRules.GetLockedRules()) do
		self:AddSystemRule(lockedRule.Type, lockedRule.Id, nil, lockedRule)
	end

	if (configTable) then
		-- Handle system keep rules
		local keepRules = configTable[string.lower(Vendor.c_RuleType_Keep)]
		if (keepRules) then			
			applySystemRuleConfig(self, Vendor.c_RuleType_Keep, keepRules)
		end

		-- Handle system sell rules
		local sellRules = configTable[string.lower(Vendor.c_RuleType_Sell)]
		if (sellRules) then
			applySystemRuleConfig(self, Vendor.c_RuleType_Sell, sellRules)
		end

		-- Handle custom rules (NYI)
		local customRules = configTable["custom"]
		if (customRules) then
		end
	end
end
