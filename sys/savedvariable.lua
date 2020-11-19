local AddonName, Addon = ...;
Addon.SavedVariable = {
	--[[static]] new = function(self, name)
		local instance = {
			savedVar = (AddonName .. "_" .. name),
			loaded = false,
		}

		setmetatable(instance, self);
		self.__index = self;
		Addon:AddInitializeAction(self.onVariablesLoaded, instance);

		return instance;
	end,

	onVariablesLoaded = function(self)
		self.loaded = true;
	end,

	GetOrCreate = function(self, defaultValue)
		assert(self.loaded, string.format("Attempt to access saved variable '%s' before the variables are loaded", tostring(self.savedVar)));
		local var = _G[self.savedVar];
		if (not var) then
			if (defaultValue ~= nil) then
				if (type(defaultValue) == "table") then
					var = table.copy(defaultValue);
				else 
					var = defaultValue;
				end
			else
				var = {};
			end 
			_G[self.savedVar] = var;
		end
		return var;
	end,

	Replace = function(self, value)
		if (type(value) == "table") then
			_G[self.savedVar] = table.copy(value);
		else
			_G[self.savedVar] = value;
		end
	end,

	Get = function(self, key)
		local var = self:GetOrCreate();
		local value = var[key];
		if (type(value) == "table") then
			return table.copy(value);
		end
		return value;
	end,

	Set = function(self, key, value)
		local var = self:GetOrCreate();
		if (type(value) == "table") then
			var[key] = table.copy(value);
		else
			var[key] = value;
		end
	end,

	ForEach = function(self, callback, ...)
		local var = self:GetOrCreate();
		assert(type(callback) == "function");
		for key, value in pairs(var) do
			xpcall(callback, CallErrorHandler, value, key, ...);
		end
	end
};
