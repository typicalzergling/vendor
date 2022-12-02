local _, Addon = ...;
local RuleConfigObject = {}

-- Helper for debugging
local function debugp(...) Addon:Debug("ruleconfig", ...) end

-- Validates if the rule type is valid
local function IsValidRuleType(ruleType)
	if (type(ruleType) ~= "string") then
		return false;
	end

	local valid = false;
	for _, value in pairs(Addon.RuleType)  do
		if (value == ruleType) then
			valid = true;
			break;
		end
	end
	return valid;
end

local function ValidateRuleConfig(config)
	local t = type(config);
	if (t == "string") then	
		local def = Addon.Rules.GetDefinition(config);
		if (not def) then
			Addon:Debug("ruleconfig", "Failed validation because there was no rule '%s'", config);
			return false;
		end

		return true;
	elseif (t == "table") then
		local def = Addon.Rules.GetDefinition(config.rule);
		if (not def) then
			Addon:Debug("ruleconfig", "Failed validation because there was no rule '%s'", config.rule);
			return false;
		end

		return true;
	end
	
	Addon:Debug("ruleconfig", "Unknown type of a rule config '%s'", t);
	return false;
end

-- Determines if the "rule" matches the specified object.
local function IsRule(rule, ruleId) 
	local t = type(rule);
	if (t == "string") then
		return (rule == ruleId);
	elseif (t == "table") then
		return ((type(rule.rule) == "string") and (rule.rule == ruleId));
	end
	return false;
end

-- Returns the index (if any) of the rule in the list.
local function GetIndexOf(rules, ruleId)
	assert(type(rules) == "table");
	ruleId = string.lower(ruleId);
	for index, rule in ipairs(rules) do 
		if (IsRule(rule, ruleId)) then
			return index;
		end
	end
end

-- Loads / Populates this object with the contentes of the saved variable.
function RuleConfigObject:Load(saved)
	debugp("Loading rule configuration");
	self.rules = Addon.DeepTableCopy(saved or {});
end

-- Saves our current configuration
function RuleConfigObject:Save()
	debugp("Saving rule configuration");
	return Addon.DeepTableCopy(self.rules or  {});
end

local function CreateConfig(rule)
	local t = type(rule);
	if (t == "string") then
		return t;
	elseif (t == "table") then
		return Addon.DeepTableCopy(rule);
	end

	error("Unknown rule configuration option");
end

-- Adds or updates the configuration for the specified rule.
function RuleConfigObject:Set(ruleId, parameters)
	local rule = ruleId; 
	if (type(parameters) == "table") then
		rule = Addon.DeepTableCopy(parameters);
		rule.rule = ruleId;
	end

	assert(ValidateRuleConfig(rule), "The rule configuration appears to be invalid");
	local index = GetIndexOf(self.rules, ruleId);
	if (not index) then
		debugp("Adding new rule '%s' to the config", tostring(ruleId));
		table.insert(self.rules, rule);
		index = table.getn(self.rules);
	else
		debugp("Updated rule '%s' in the configration", tostring(ruleId));
		self.rules[index] = rule;
	end

	self:TriggerEvent("OnChanged", self);
	return CreateConfig(self.rules[index]);
end

-- Remove the specified rule from this configuration
function RuleConfigObject:Remove(ruleId)
	local index = GetIndexOf(self.rules, ruleId);
	if (index) then
		debugp("Removed rule '%s'", ruleId);
		table.remove(self.rules, index);
		self:TriggerEvent("OnChanged", self);
		return true
	end
end

-- Returns the config for the specified rule, or nil if there is not rule 
-- in the config with the specified name.
function RuleConfigObject:Get(ruleId)
	local index = GetIndexOf(self.rules, ruleId);
	if (index and (index >= 1)) then
		return CreateConfig(self.rules[index]);
	end
	return nil;
end

function RuleConfigObject:Contains(ruleId)
	local index = GetIndexOf(self.rules, ruleId);
	if (index and (index >= 1)) then
		return true;
	end
	return false;
end

function RuleConfigObject:Commit()
	local profile = assert(Addon:GetProfileManager():GetProfile(), "Expected a valid active profile");
	profile:SetRules(self.type, self.rules);
	debugp("Commited rules '%s' to the profile", tostring(self.type))
	Addon:RaiseEvent(Addon.Systems.Rules.RuleEvents.CONFIG_CHANGED, self.type, self)
end

function RuleConfigObject:GetType()
	return self.type
end

Addon.RuleConfig = {
	-- Create a new empty instance of the rules config object.
	Create = function(self)
		local instance = {
			type = "",
			rules = {},
			profile = falsae,
		};

		return Addon.object("RuleConfig", instance, RuleConfigObject, { "OnChanged" })
	end,

	-- Create instance of the rules config object from the sepcified 
	-- cofiguration variable.
	LoadFrom = function(self, saved)
		assert(not saved or (type(saved) == "table"), "The saved rule configuration must be a table");
		local obj = Addon.RuleConfig.Create();
		RuleConfigObject.Load(obj, saved or {});
		return obj;
	end,
}

function Addon.RuleConfig:Get(ruleType)
	if (not IsValidRuleType(ruleType)) then
		error(string.format("The specified rule type '%s' is invalid", ruleType or ""), 2);
	end

	local profile = Addon:GetProfileManager():GetProfile()
	local instance = {
		type = ruleType,
		profile = profile,
		rules = profile:GetRules(ruleType),
	}

	return Addon.object("RuleConfig", instance, RuleConfigObject, { "OnChanged" })
end