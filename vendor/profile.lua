local AddonName, Addon = ...;
local DEFAULT_PROFILE = "-[DEFUALT]-";
local SELL_LIST = Addon.c_Config_SellAlways;
local KEEP_LIST = Addon.c_Config_SellNever;
local KEEP_RULE = Addon.c_RuleType_Keep;
local SELL_RULE = Addon.c_RuleType_Sell;
local SCRAP_RULE = Addon.c_RuleType_Scrap;
local KEEP_RULES = "keep";
local SELL_RULES = "sell";
local SCRAP_RULES ="scrap";
local PROFILE_VERSION = 1;
local INTERFACE_VERSION = select(4, GetBuildInfo());
local table_copy = Addon.DeepTableCopy;

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
local profileObserversLow = {};

Vendor_Profiles = Vendor_Profiles or {};
Vendor_ActiveProfile = Vendor_ActiveProfile or nil;

--[[ Static Methods ]]--

-- Create a new instance of a profile object.
function Profile:Create(_profileName)
	if (Profile:HasProfile(_profileName)) then
		error(string.format("Cannot create a profile with an already existing name: %s", _profileName));
	end

	local savedVariable={
		name=_profileName,
		id=_profileName,
		version=PROFILE_VERSION,
		interfaceversion=INTERFACE_VERSION,
		settings={},
		rules={},
		lists={
			[SELL_LIST] = {},
			[KEEP_LIST] = {},
		},
	};

	Addon:DebugChannel("profile", "Created new profile '%s'", _profileName);
	table.insert(Vendor_Profiles, savedVariable);
    local instance = {
		profile = savedVariable,
    };

   setmetatable(instance, self);
   self.__index = self;
   return instance;
end

-- Checks if a profile with the specified name exists, if the profile does 
-- not exist then it will return false.
function Profile:HasProfile(profileName)
	for _, profile in ipairs(Vendor_Profiles) do 
		if (profile.name == profileName) then
			return true;
		end
	end
	return false;
end

-- Checks for the existence of a profile with the specified name, if the name 
-- isn't found this return nil, otherwise it returns a profile object.
function Profile:GetProfile(profileName)
	for _, _profile in ipairs(Vendor_Profiles) do 
		if (_profile.name == profileName) then
			local instance = {
				profile = _profile,
			};

			setmetatable(instance, self)
			self.__index = self
			return instance
		end
	end

	return nil;
end

function Profile:DeleteProfile(profileName)
	local index = -1;

	for i, profile in ipairs(Vendor_Profiles) do 
		if (profile.name == profileName) then
			index = i;
		end
	end

	if (index > 0) then
		Addon:DebugChannel("profile", "Deleting profile '%s' (index=%d)", profileName, index);
		table.remove(Vendor_Profiles, index);
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
	profile.profile.settings = Addon.DeepTableCopy(Addon.DefaultConfig.Settings);
	profile.profile.rules = Addon.DeepTableCopy(Addon.DefaultConfig.Rules);
	profile.profile.settings[SELL_LIST] = nil;
	profile.profile.settings[KEEP_LIST] = nil;
	Addon:DebugChannel("profile", "Created default profile");
	return profile;
end

-- Create the default profile from the old-style config variables (<4)
function Profile:CreateDefaultFromOldConfig()	
	Profile:DeleteProfile(DEFAULT_PROFILE);
	local profile = Profile:Create(DEFAULT_PROFILE);

	-- Migrate settings variable.
	if (Vendor_Settings) then
		profile.profile.settings = table_copy(Vendor_Settings);
		profile.profile.settings[SELL_LIST] = nil;
		profile.profile.settings[KEEP_LIST] = nil;
		profile.profile.settings["debugrules"] = nil;
		profile.profile.settings["debug"] = nil;
		profile.profile.settings.version = nil;
		profile.profile.settings.interfaceversion = nil;
		profile.profile.lists[KEEP_LIST] = table_copy(Vendor_Settings[KEEP_LIST]);
		profile.profile.lists[SELL_LIST] = table_copy(Vendor_Settings[SELL_LIST]);
	end

	-- Migrate rule configuation varible.
	if (Vendor_RulesConfig) then
		profile.profile.rules = table_copy(Vendor_RulesConfig);
		profile.profile.rules.version = nil;
		profile.profile.rules.interfaceversion = nil;
	end

	-- Clear the existing saved variables.
	--Vendor_RulesConfig = nil;
	--Vendor_Settings = nil;

	Addon:DebugChannel("profile", "Create default profile from existing settings");
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
			Addon:DebugChannel("profile", "%s|    |  |r%d) [%d] Error: %s%s|r", GREEN_FONT_COLOR_CODE, index, rank, RED_FONT_COLOR_CODE, msg);
		else
			Addon:DebugChannel("profile", "%s|    |  |r%d) [%s] %sSuccess|r", GREEN_FONT_COLOR_CODE, index, rank,  GREEN_FONT_COLOR_CODE);
		end
	end
end


local function sendChangeEvents(self)
	Addon:DebugChannel("profile", "%s+  |rStarting change notifications [%d handlers]", GREEN_FONT_COLOR_CODE, table.getn(profileObservers));

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
	Addon:DebugChannel("profile", "%s+  |rCompleted change notifications", GREEN_FONT_COLOR_CODE)
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
	return self.profile.name;
end

-- Changes the name of this profile.
function Profile:SetName(profileName)
	if (type(profileName) ~= "string") then
		error("The profile name must be a string");
	end

	if (Profile:HasProfile(profileName)) then
		error(string.format("A profile with the specified name '%s' already exists.", profileName));
	end

	self.profile.name = profileName;
	self:notifyChanges();
end

-- Retrieve a setting from the profile, if the profile does not have 
---setting defined, this will read the value from the default config.
-- In debug we verify the setting name is valid.
function Profile:GetValue(settingName)
	--@debug@
	if (not key_exists(self.profile.settings, settingName) or
		(settingName == KEEP_LIST) or
		(settignName == SELL_LIST)) then
		error(string.format("There is no setting '%s'", settingName));
	end
	--@end-debug@

	local val = self.profile.settings[settingName];
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
	if (not key_exists(Addon.DefaultConfig.Settings, settingName) or
		(settingName == KEEP_LIST) or
		(settignName == SELL_LIST)) then
		error(string.format("There is no setting '%s'", settingName));
	end
	--@end-debug@--

	if (self.profile.settings[settingName] ~= value) then
		self.profile.settings[settingName] = value;
		Addon:DebugChannel("profile", "Profile '%s' has changed setting '%s'", self.profile.name, settingName);
		self:NotifyChanges();
	end
end

-- Retreive the list of enabled rules (and their parameters) for
-- this profile.
function Profile:GetRules(rulesType)
	if (rulesType == SELL_RULE) then
		return table_copy(self.profile.rules[SELL_RULES] or {});
	elseif (rulesType == KEEP_RULE) then
		return table_copy(self.profile.rules[KEEP_RULES] or {});
	elseif (rulesType == SCRAP_RULE) then
		return table_copy(self.profile.rules[SCRAP_RULES] or {});
	end

	--@debug@
	error(string.format("There is not rule type '%s'", rulesType));
	--@end-debug@
end

-- Called to change the value of a rules list.
function Profile:SetRules(rulesType, config)
	if (type(config) ~= "table") then
		error("The rule config must be a table");
	end

	if (rulesType == SELL_RULE) then
		self.profile.rules[SELL_RULES] = table_copy(config);
		Addon:DebugChannel("profile", "Profile '%s', %s rule changed", self:GetName(), SELL_RULE);
		self:NotifyChanges();
		return;
	elseif (rulesType == KEEP_RULE) then
		self.profile.rules[KEEP_RULES] = table_copy(config);
		Addon:DebugChannel("profile", "Profile '%s', %s rule changed", self:GetName(), KEEP_RULE);
		self:NotifyChanges();
		return;
	elseif (rulesType == SCRAP_RULE) then 
		self.profile.rules[SCRAP_RULES] = table_copy(config);
		Addon:DebugChannel("profile", "Profile '%s', %s rule changed", self:GetName(), SCRAP_RULES);
		self:NotifyChanges();
		return;
	end

	--@debug@
	error(string.format("There is not a rule type '%s'", rulesType))
	--@end--debug@
end

-- Retrieves the specified block list from the profile.
function Profile:GetList(listType)
	if (listType == Addon.c_AlwaysSellList) then
		return table_copy(self.profile.lists[SELL_LIST] or {});
	elseif (listType == Addon.c_NeverSellList) then
		return table_copy(self.profile.lists[KEEP_LIST] or {});
	end

	error(string.format("There is no '%s' list", listType));
end

-- Sets the specified list
function Profile:SetList(listType, list)
	if (listType == Addon.c_AlwaysSellList) then
		self.profile.lists[SELL_LIST] = table_copy(list);
		self:NotifyChanges();
		return;
	elseif (listType == Addon.c_NeverSellList) then
		self.profile.lists[KEEP_LIST] = table_copy(list);
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

	return self:GetName() == other:GetName();
end

-- Retrieves the currently active profile
function Addon:GetProfile()
	local profile = nil;

	-- If we have not yet migrated the profiles, 
	-- then we need to migrate teh default profile.
	if ((Vendor_ActiveProfile == nil) or 
		(table.getn(Vendor_Profiles) == 0)) then
		profile = Profile:CreateDefaultFromOldConfig();
	else
		-- Load the named profile which is active.
		profile = Profile:GetProfile(Vendor_ActiveProfile);
	end

	-- If we don't have a profile then assign it to
	-- the default profile.
	if (not profile) then
		profile = Profile:GetDefaultProfile();
	end

	-- Cache the profile
	if (not self.profile) then
		self.profile = profile;
	end

	-- Update our saved variable
	if (Vendor_ActiveProfile ~= profile:GetName()) then
		Vendor_ActiveProfile = profile:GetName();
	end

	-- Return the prfile.
	return self.profile;
end

function Addon:SetProfile(profileName)
	error("not-yet-implemented");
end

Addon.Profile = Profile;