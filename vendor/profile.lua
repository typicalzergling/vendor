local AddonName, Addon = ...;
local DEFAULT_PROFILE = "-[DEFAULT]-";

local SELL_LIST = Addon.c_Config_SellAlways;
local KEEP_LIST = Addon.c_Config_SellNever;
local KEEP_RULES = "keep";
local SELL_RULES = "sell";
local DELETE_RULES ="delete";
local PROFILE_VERSION = 1;
local INTERFACE_VERSION = select(4, GetBuildInfo());

local RuleType = Addon.RuleType;

--@debug@
local function key_exists(t, c)
	if (type(t) == "table") then
		for k, _ in pairs(t) do
			if (k == c) then
				return true;
			end
		end
	end
	return false;
end
--@end-debug@

local Profile = {}
local profileObservers = {};
local profileSavedVariable = Addon.SavedVariable:new("Profiles");
local activeProfileVariable = Addon.SavedVariable:new("ActiveProfile");

--[[ Static Methods ]]--

-- Create a new instance of a profile object.
function Profile:Create(_profileName)
	if (Profile:HasProfile(_profileName)) then
		error(string.format("Cannot create a profile with an already existing name: '%s'", _profileName));
	end

	local savedVar={
		name=_profileName,
		id=string.lower(_profileName),
		version=PROFILE_VERSION,
		interfaceversion=INTERFACE_VERSION,
		settings={},
		rules={
			sell = {},
			delete = {},
			keep = {},
		},
		lists={
			[SELL_LIST] = {},
			[KEEP_LIST] = {},
		},
	};

	Addon:Debug("profile", "Created new profile '%s'", _profileName);
	profileSavedVariable:Set(savedVar.id, savedVar);
    local instance = {
		key = savedVar.id,
		cache = savedVar,
    };

   setmetatable(instance, self);
   self.__index = self;
   return instance;
end

-- Checks if a profile with the specified name exists, if the profile does 
-- not exist then it will return false.
function Profile:HasProfile(profileId)
	local profile = profileSavedVariable:Get(string.lower(profileId));
	return (type(profile) == "table");
end

-- Checks for the existence of a profile with the specified name, if the name 
-- isn't found this return nil, otherwise it returns a profile object.
function Profile:GetProfile(profileId)
	local profile = profileSavedVariable:Get(string.lower(profileId));
	if (type(profile) == "table") then
		local instance = {
			key = profile.id,
			cache = profile
		};

		setmetatable(instance, self)
		self.__index = self
		return instance
	end

	return nil;
end

function Profile:DeleteProfile(profileId)
	local profile = profileSavedVariable:Get(string.lower(profileId));
	if (type(profile) == "table") then
		Addon:Debug("profile", "Deleting profile '%s'", profile.name);
		profileSavedVariable:Set(profile.id, nil);
	end
end

-- Retrieves the default profile, if the defult profile doesn't already exist 
-- then a new profile is created using the default config
function Profile:GetDefaultProfile()
	local profile = Profile:GetProfile(DEFAULT_PROFILE);
	if (profile) then
		return profile;
	end

	local profile = Profile:Create(DEFAULT_PROFILE);
	profile.cache.settings = Addon.DeepTableCopy(Addon.DefaultConfig.Settings);
	profile.cache.rules = table.copy(Addon.DefaultConfig.Rules);
	profile.cache.settings[SELL_LIST] = nil;
	profile.cache.settings[KEEP_LIST] = nil;

	profileSavedVariable:Set(profile.key, profile.cache);
	Addon:Debug("profile", "Created default profile (%s)", profile.key);
	return profile;
end

-- Create the default profile from the old-style config variables (<4)
function Profile:CreateDefaultFromOldConfig()	
	Profile:DeleteProfile(DEFAULT_PROFILE);
	local profile = Profile:Create(DEFAULT_PROFILE);

	-- Migrate settings variable.
	if (Vendor_Settings) then
		profile.cache.settings = table.copy(Vendor_Settings);
		profile.cache.settings[SELL_LIST] = nil;
		profile.cache.settings[KEEP_LIST] = nil;
		profile.cache.settings["debugrules"] = nil;
		profile.cache.settings["debug"] = nil;
		profile.cache.settings.version = nil;
		profile.cache.settings.interfaceversion = nil;
		profile.cache.lists[KEEP_LIST] = table.copy(Vendor_Settings[KEEP_LIST]);
		profile.cache.lists[SELL_LIST] = table.copy(Vendor_Settings[SELL_LIST]);
	end

	-- Migrate rule configuation varible.
	if (Vendor_RulesConfig) then
		profile.cache.rules = table.copy(Vendor_RulesConfig);
		profile.cache.rules.version = nil;
		profile.cache.rules.interfaceversion = nil;
	end

	-- Clear the existing saved variables.
	--Vendor_RulesConfig = nil;
	--Vendor_Settings = nil;

	Addon:Debug("profile", "Created default profile from existing settings");
	profileSavedVariable:Set(profile.key, profile.cache);
	return profile;
end

function Profile:RegisterForChanges(_callback, _rank)
	if (type(_callback) ~= "function") then
		error("Expect the callback argument of RegisterForChanges to be a function");
	end
	if (_rank and (type(_rank) ~= "number")) then
		error("Expected the rank argument of RegisterForChanges to be absent or a number");
	end

	local insert = {
		rank=_rank or 1000,
		callback=_callback,
	};

	table.insert(profileObservers, insert);
	table.sort(profileObservers, 
		function (a, b)
			return (a.rank < b.rank);
		end);
end

--[[ Instance Methods ]]--


local function invoke(self, index, rank, observer)
	assert(type(rank) == "number");
	assert(type(observer) == "function");

	if (type(observer) == "function") then
		local r, msg = xpcall(observer, CallErrorHandler, self);
		if (not r) then
			Addon:Debug("profile", "%s|    |r%d) [%d] Error: %s%s|r", GREEN_FONT_COLOR_CODE, index, rank, RED_FONT_COLOR_CODE, msg);
		else
			Addon:Debug("profile", "%s|    |r%d) [%s] %sSuccess|r", GREEN_FONT_COLOR_CODE, index, rank,  GREEN_FONT_COLOR_CODE);
		end
	end
end


local function sendChangeEvents(self)
	Addon:Debug("profile", "%s+  |rStarting change notifications [%d handlers]", GREEN_FONT_COLOR_CODE, table.getn(profileObservers));

	if (self.timer) then
		self.timer:Cancel();
		self.timer = nil;
	end
	-- If thes the currently active profile, then we want to invoke the callbacks
	local active = Addon:GetProfile();
	if (active and self:IsEqual(active)) then
		for i, observer in ipairs(profileObservers) do
			invoke(self, i, observer.rank, observer.callback)
		end
	end
	Addon:Debug("profile", "%s+  |rCompleted change notifications", GREEN_FONT_COLOR_CODE)
end	


-- Called to notify any listeners of changes to this profile, notifications 
-- are only sent if this is currently active profile.
function Profile:NotifyChanges() 
	if (self.timer) then
		self.timer:Cancel();
		self.timer = nil;
	end
	self.timer = C_Timer.NewTimer(0.25, function() sendChangeEvents(self) end);
end


-- Gets the name of this profile.
function Profile:GetName()
	return self.cache.name;
end

function Profile:GetId()
	return self.key;
end

-- Changes the name of this profile.
function Profile:SetName(profileName)
	if (type(profileName) ~= "string") then
		error("The profile name must be a string");
	end

	self.cache.name = profileName;
	profileSavedVariable:Set(self.key, self.cache);
	self:notifyChanges();
end

-- Retrieve a setting from the profile, if the profile does not have 
---setting defined, this will read the value from the default config.
-- In debug we verify the setting name is valid.
function Profile:GetValue(settingName)
	--@debug@
	if (not table.hasKey(Addon.DefaultConfig.Settings, settingName) or
		(settingName == KEEP_LIST) or
		(settignName == SELL_LIST)) then
		error(string.format("There is no setting '%s'", settingName));
	end
	--@end-debug@

	local val = self.cache.settings[settingName];
	if (val == nil) then
		val = Addon.DefaultConfig.Settings[settingName];
	end

	return val;
end

-- Modify a setting, this will create an entry for the settign within
-- the profile. 
-- In debug we verify the setting name is valid.
function Profile:SetValue(settingName, value)
	--@debug@--
	if (not table.hasKey(Addon.DefaultConfig.Settings, settingName) or
		(settingName == KEEP_LIST) or
		(settignName == SELL_LIST)) then
		error(string.format("There is no setting '%s'", settingName));
	end
	--@end-debug@--

	if (self.cache.settings[settingName] ~= value) then
		self.cache.settings[settingName] = value;
		Addon:Debug("profile", "Profile '%s' has changed setting '%s'", self.cache.name, settingName);
		profileSavedVariable:Set(self.key, self.cache);
		self:NotifyChanges();
	end
end

-- Maps the external rule type to our internal rule key name
local function RuleTypeToRuleKey(ruleType)
	if (ruleType == RuleType.SELL) then
		return SELL_RULES;
	elseif (ruleType == RuleType.KEEP) then
		return KEEP_RULES;
	elseif (ruleType == RuleType.DELETE) then
		return DELETE_RULES;
	end 

	return nil;
end

-- Retreive the list of enabled rules (and their parameters) for
-- this profile.
function Profile:GetRules(ruleType)
	local key = RuleTypeToRuleKey(ruleType);
	if (key) then
		return table.copy(self.cache.rules[key] or {});
	end

	--@debug@
	error(string.format("Unable to retrive rules '%s' as it is invalid.", ruleType));
	--@end-debug@
	return {};
end

-- Called to change the value of a rules list.
function Profile:SetRules(ruleType, config)
	if (type(config) ~= "table") then
		error("The rule config must be a table");
	end

	local key = RuleTypeToRuleKey(ruleType);
	if (key) then
		self.cache.rules[key] = table.copy(config);
		Addon:Debug("profile", "Profile '%s', %s rule changed", self:GetName(), ruleType);
		profileSavedVariable:Set(self.key, self.cache);
		self:NotifyChanges();
		return;
	end

	--@debug@
	error(string.format("There is not a rule type '%s'", ruleType));
	--@end-debug@
end 

local function ListTypeToKey(listType)
	if (listType == Addon.c_AlwaysSellList) then
		return SELL_LIST;
	elseif (listType == Addon.c_NeverSellList) then
		return KEEP_LIST;
	end 
	return nil;
end

-- Retrieves the specified block list from the profile.
function Profile:GetList(listType)
	local key = ListTypeToKey(listType);
	if (key) then
		return table.copy(self.cache.lists[key] or {});
	end
	error(string.format("There is no '%s' list", listType));
end

-- Sets the specified list
function Profile:SetList(listType, list)
	local key = ListTypeToKey(listType);
	if (key) then
		self.cache.lists[key] = table.copy(list);
		profileSavedVariable:Set(self.key, self.cache);
		self:NotifyChanges();
		return;
	end

	error(string.format("There is no '%s' list", listType));
end

-- Creates a completely independent version of the profile
function Profile:Clone()
end

-- Checks if the two profile are equal
function Profile:IsEqual(other)
	if (not other) then
		return false;
	elseif (self == other) then
		return true;
	end

	return self:GetId() == other:GetId();
end

-- Retrieves the currently active profile
function Addon:GetProfile()
	if (self.activeProfile) then
		return self.activeProfile;
	end

	local profile = nil;
	local active = activeProfileVariable:GetOrCreate("");

	-- If we have not yet migrated the profiles, 
	-- then we need to migrate teh default profile.
	if ((active ~= nil) and (string.len(active) ~= 0)) then
		profile = Profile:GetProfile(active);
	end

	if (not profile and Vendor_Settings) then
		profile = Profile:CreateDefaultFromOldConfig();
		activeProfileVariable:Replace(profile:GetId());
	end

	-- If we don't have a profile then assign it to
	-- the default profile.
	if (not profile) then
		profile = Profile:GetDefaultProfile();
		activeProfileVariable:Replace(profile:GetId());
	end

	self.activeProfile = profile;
	Addon:Debug("profile", "Setting active profile to '%s'", profile:GetName());
	return self.activeProfile;
end

function Addon:SetProfile(profileName)
	error("not-yet-implemented");
end

Addon.Profile = Profile;