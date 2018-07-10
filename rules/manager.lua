
Vendor = Vendor or {}
Vendor.RuleManager = {}

--*****************************************************************************
-- Create a new rule object which handles keeping track of the rule it
-- has two properties an ID and compiled chunk of script.
--*****************************************************************************
Vendor.RuleManager.Rule = {}
function Vendor.RuleManager.Rule:Create(ruleId, ruleScript)
	assert(ruleId ~= nil and string.len(ruleId) ~= 0, "all rules must have a valid identifier")
	assert(ruleScript ~= nil and string.len(ruleId) ~= 0, "all rules must have a valid script")

	instance = {

		Id = string.lower(ruleId),
		Script = nil,
	}
	
	-- We also need to wrap the rule script text in return.	
	local script, _,  msg = loadstring(string.format("return (%s)", ruleScript))
	if (not script) then
		Vendor:DebugRules("Failed to create script for '%s'  {%s} :: ", ruleId, ruleScript, msg)
	else
		instance.Script = script
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
		print("running rule: ", self.Id)
		setfenv(self.Script, environment)
		local status, result = pcall(self.Script)
		if status and result then
			return true
		elseif not status then
			Vendor:DebugRules("Failed to invoke rule '%s' : %s%s%s", self.Id, RED_FONT_COLOR_CODE, result, FONT_COLOR_CODE_CLOSE)
			return false
		end
	end
end

--*****************************************************************************
-- Checks if this rule matches the specified ruleId, which can be a valid 
-- string or it can be nil.
--*****************************************************************************
function Vendor.RuleManager.Rule:Matches(ruleId)
	if not ruleId or (string.len(ruleId) == 0) then
		return true
	end

	if (self.Id == string.lower(ruleId)) then
		return true
	end
end

--*****************************************************************************
-- Create a new RuleManager which is a container to manage rules and the 
-- environment they run in.
--*****************************************************************************
function Vendor.RuleManager:Create(functions)
	instance = {
		rules = {},
		environment = {},
		globals = {},
	}

	-- If the caller gave us functions which should be available then
	-- important them into our environment along with certain globals
	Vendor.RuleManager.importGlobals(instance, "string", "math", "tonumber", "tostring")
	if (functions and (type(functions) == "table")) then
		for name, value in pairs(functions) do
			if (type(value) == "function") then
				Vendor:DebugRules("Adding rule function '%s'", name)
				Vendor.RuleManager.AddFunction(instance, name, value)
			end
		end
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
-- Adds a rule with the specified id and the script. 
--*****************************************************************************
function Vendor.RuleManager:AddRule(ruleId,  ruleScript)
	assert(type(ruleId) == "string", "rule name must be a string")
	assert(type(ruleScript) == "string", "rule script must be a string")
	self.rules[ruleId] = self.Rule:Create(ruleId, ruleScript)
	Vendor:Debug("[Rules] added rule '%s'", ruleId)
end

--*****************************************************************************
-- Adds a function to environment which is presented to the rule scripts. 
--*****************************************************************************
function Vendor.RuleManager:AddFunction(functionName, targetFunction)
	assert(type(functionName) == "string", "function name must be a string")
	assert(type(targetFunction) == "function", "type of targetFunction must be a function")
	self.environment[functionName] = targetFunction
	Vendor:Debug("[Rules] added rule function '%s'", functionName)
end

--*****************************************************************************
--  Evaluates all of then rules (or a specific rule) and returns true of 
--  and the name of the that matches it.
--
-- ruleName is optional, if provided it will only run that rule.
--*****************************************************************************
function Vendor.RuleManager:Run(targetObject, ruleName)
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

	-- Evaluate either the specific rule or all of the rules until we find a match	
	for _, rule	in pairs(self.rules) do
		if rule:Matches(ruleName) and rule:Run(ruleEnv) then
			return true, rule.Id
		end
	end	
	
	return false, nil
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
