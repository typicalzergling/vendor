local AddonName, Addon = ...;
local VARIABLES_LOADED = {}
local SavedVariable = {}

local Object = {}
function Object.ReadOnly(name, instance, api)
	return setmetatable({}, {
		__metatable = name,
		__index = function(self, key)
			return instance[key] or api[key]
		end,
		__newindex = function(self, key, value)
			error(string.format("Attempted to set '%s' on read-only object '%s'", key, name))
		end
	})
end

--[[ Create a new saved variable ]]
--[[static]] function SavedVariable.new(name)
	assert(type(name) == "string", "The name of a saved variable must be a string")

	local instance = {
		savedVar = (AddonName .. "_" .. name),
		}

	return Object.ReadOnly(string.format("SavedVariable[%s]", name), instance, SavedVariable)
end

--[[ Ensures the saved variable exists, if does not the assign the value provided ]]
function SavedVariable:GetOrCreate(defaultValue)
	--@debug@
	assert(rawget(Addon, VARIABLES_LOADED), string.format("Attempt to access saved variable '%s' before the variables are loaded", self.savedVar))
	--@end-debug@
	
	local var = _G[self.savedVar];
	if (not var) then
		if (defaultValue ~= nil) then
			if (type(defaultValue) == "table") then
				var = Addon.DeepTableCopy(defaultValue)
			else 
				var = defaultValue
			end
		else
			var = {}
		end 
		_G[self.savedVar] = var
	end

	return var
end

--[[ Repleace the entire saved variable ]]
function SavedVariable:Replace(value)
	if (type(value) == "table") then
		_G[self.savedVar] = Addon.DeepTableCopy(value);
	else
		_G[self.savedVar] = value;
	end
end

--[[ Gets teh value from the variable with the specified key ]]
function SavedVariable:Get(key)
	local var = self:GetOrCreate();

	--@debug@
	assert(type(var) == "table")
	--@end-debug@

	local value = var[key];
	if (type(value) == "table") then
		return Addon.DeepTableCopy(value);
	end

	return value;
end

--[[ Set a key in the saved varaible to the provide value ]]
function SavedVariable:Set(key, value)
	local var = self:GetOrCreate();

	--@debug@
	assert(type(var) == "table")
	--@end-debug@

	if (type(value) == "table") then
		var[key] = Addon.DeepTableCopy(value);
	else
		var[key] = value;
	end
end

--[[ Iterate over all of the keys in the variable ]]
function SavedVariable:ForEach(callback, ...)
	local var = self:GetOrCreate();

	--@debug@
	assert(type(callback) == "function", "Attempt to call a non-function");
	assert(type(var) == "table", "Attempting to iterate a non-table")
	--@end-debug@

	for key, value in pairs(var) do
		local success = xpcall(callback, CallErrorHandler, value, key, ...);
		if (not success) then
			return
		end
	end
end

--[[=== System: SavedVariables ==============================================]]

local SavedVariablesSystem = {}

--[[ Initialize hthe saved variable system ]]
function SavedVariablesSystem:Startup(register)
	rawset(Addon, VARIABLES_LOADED, 1)

	self.variables = {}
	register({ "CreateSavedVariable" })
end

--[[ Called to get the dependencies of this system ]]
function SavedVariablesSystem:GetDependencies()
	return { "event:VARIABLES_LOADED" };
end

--[[ Create a new saved variable ]]
function SavedVariablesSystem:CreateSavedVariable(name)
	assert(rawget(Addon, VARIABLES_LOADED) == 1, "Expected variables to be loaded")

	if (not self.variables[name]) then
		self.variables[name] = SavedVariable.new(name)
	end

	return self.variables[name]
end

Addon.Systems.SavedVariables = SavedVariablesSystem