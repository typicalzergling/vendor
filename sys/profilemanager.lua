local AddonName, Addon = ...;
local ProfileManager = {};
local PROFILE_KEY = {};
local PMGR_KEY = {};
local activeProfileVariable = Addon.SavedVariable:new("ActiveProfile");
local profilesVariable = Addon.ProfilesVariable;
local function debug(...) Addon:Debug("profile", ...); end
local CreateProfile = Addon.CreateProfile;

-- Local helper function to determine the identifer from the argument
local function getProfileId(profile)
	local t = type(profile);
	if (t == "string") then
		return profile;
	elseif (t == "table") then
		return profile:GetId()
	end

	error("Unable to determine profile identifier from: " .. tostring(profile));
end	

--[[===========================================================================
   | Retrieve the currently active profile. This may create a new profile, 
   | or may cause migration.
   ==========================================================================]]
function ProfileManager:GetProfile()
	local profile = rawget(self, PROFILE_KEY);
	if (profile) then
		return profile;
	end

	local activeId = activeProfileVariable:GetOrCreate("");
	if ((type(activeId) == "string") and (string.len(activeId) ~= 0)) then
		local data = profilesVariable:Get(activeId);
		if (type(data) == "table") then
			debug("Using profile '%s'", activeId);
			profile = CreateProfile(activeId);
		end
	end

	if (not profile) then
		profile = CreateProfile();
		Addon.invoke(Addon, "OnCreateDefaultProfile", profile);
		activeProfileVariable:Replace(profile:GetId());
		debug("Created default profile '%s'", profile:GetId());
		self.OnProfileCreated:Raise(profile);
	else
		Addon.invoke(Addon, "OnCheckProfileMigration", profile);
	end

	profile:SetActive(true);
	rawset(self, PROFILE_KEY, profile);
	self.OnProfileChanged:Raise(profile);
	profile:RegisterCallback("OnChanged", function()
			debug("Broadcasting change '%s'", profile:GetName());
			self:TriggerEvent("OnProfileChanged", profile);
		end, self);
	return profile;
end

--[[===========================================================================
   |	
   ==========================================================================]]
function ProfileManager:SetProfile(profile)
	error("not yet implemented");
end

--[[===========================================================================
   | Creates a new profile with the specified name.
   ==========================================================================]]
function ProfileManager:CreateProfile(profileName)
	local profile = CreateProfile();
	profile:SetName(profileName);

	Addon.invoke(Addon, "OnInitializeProfile", profile);	
	debug("Created new profile '%s'", profile:GetId());
	self.OnProfileCreated:Raise(profile);
	self:TriggerEvent("OnProfileCreated", profile);
	return profile;
end

--[[===========================================================================
   | Copies the specifed profile into a new profile (whole-sale) variable
   | copy, returns the new profile.
   ==========================================================================]]
function ProfileManager:CopyProfile(profile, newProfileName)
	local profileId = getProfileId(profile);
	local data = profilesVariable:Get(profileId);
	if (not data) then
		error("Unable to locate the profile to copy");
		return nil;
	end

	local profile = CreateProfile();
	data.id = profile:GetId();
	profilesVariable:Set(profile:GetId(), data);
	profile:SetName(newProfileName);
	debug("Copied profile '%s' to '%s'", profileId, data.id);
	self.OnProfileCreated:Raise(profile);
	self:TriggerEvent("OnProfileCreated", profile);
	return profile;
end

--[[===========================================================================
   | Deletes the specified profile.	
   ==========================================================================]]
function ProfileManager:DeleteProfile(profile)
	local profileId = getProfileId(profile);
	local data = profilesVariable:Get(profileId);
	if (data) then
		profilesVariable:Set(profileId, nil);
		debug("Deleted profile '%s'", profileId);
		self:TriggerEvent("OnProfileDeleted", CreateProfile(Addon.Profile, profileId));
		return true;
	end

	return false;	
end

--[[===========================================================================
   | Retrieves an enumerate which traveses the available profiles.
   ==========================================================================]]
function ProfileManager:EnumerateProfiles()
	-- Create an array of the profiles
	local results = {};
	profilesVariable:ForEach(function(profile, id)
			table.insert(results, CreateProfile(id));
		end);

	-- Return an iterator of the profiles.
	local iter = 0;
	return function()
		iter = iter + 1;
		if (not results[iter]) then
			return nil, nil;
		end

		return results[iter]:GetId(), results[iter];
	end
end

--[[===========================================================================
   | Retrieves the current profile manager (abstraction) even though the
   | manager is static, this allows options in the future.
   | 
   | Profile Handlers:
   |	Addon.OnCreateDefaultProfile: Called when we do not have an active 
   |		profile and we need a new one, this will recieve a profile.
   |	
   |	Addon.OnCheckProfileMigration: Called when a profile is first loaded, 
   |		Allowing the addon to migrate (or not) the profie.				
   |
   |	Addon.OnInitializeProfile: Called when a new profile is created
   |		and it needs to have the default values set.
   ==========================================================================]]
function Addon:GetProfileManager()
	local profileManager = rawget(self, PMGR_KEY);
	if (not profileManager) then
		profileManager = Mixin(ProfileManager, CallbackRegistryMixin);
		CallbackRegistryMixin.OnLoad(profileManager);
		CallbackRegistryMixin.GenerateCallbackEvents(profileManager, { "OnProfileChanged", "OnProfileCreated", "OnProfileDeleted" });
		profileManager.OnProfileCreated = Addon.CreateEvent("ProfileMaanger.Created");
		profileManager.OnProfileDeleted = Addon.CreateEvent("ProfileManagee.Deleted");
		profileManager.OnProfileChanged = Addon.CreateEvent("ProfileManager.Changed");		
		rawset(self, PMGR_KEY, profileManager);
	end

	return profileManager;
end