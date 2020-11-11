local AddonName, Addon = ...;
local ProfileManager = {};
local PROFILE_KEY = {};
local PMGR_KEY = {};
local activeProfileVariable = Addon.SavedVariable:new("ActiveProfile");
local profilesVariable = Addon.ProfilesVariable;
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
    local profile = self.activeProfile;
    if (profile) then
        return profile;
    end

    local activeId = activeProfileVariable:GetOrCreate("");
    if ((type(activeId) == "string") and (string.len(activeId) ~= 0)) then
        local data = profilesVariable:Get(activeId);
        if (type(data) == "table") then
            Addon:Debug("profile", "Using profile '%s'", activeId);
            profile = CreateProfile(activeId);
        end
    end

    if (not profile) then
        profile = CreateProfile();
        Addon.invoke(Addon, "OnCreateDefaultProfile", profile);
        activeProfileVariable:Replace(profile:GetId());
        Addon:Debug("profile", "Created default profile '%s'", profile:GetId());
    else
        Addon.invoke(Addon, "OnCheckProfileMigration", profile);
    end

    profile:SetActive(true);
    self.activeProfile = profile;
    profile:RegisterCallback("OnChanged", function()
            Addon:Debug("profile", "Broadcasting change '%s'", profile:GetName());
            self:TriggerEvent("OnProfileChanged", profile);
        end, self);
    return profile;
end

--[[===========================================================================
   | Changes the currently active profile the specified profile, then send\
   | the profile changed event so everything can update.
   ==========================================================================]]
function ProfileManager:SetProfile(profile)
    local profileId = getProfileId(profile);
    if (not profileId or (string.len(profileId) == 0)) then
        error("Usage: ProfileManager:SetProfile( profile | profileId )");
    end

    local data = profilesVariable:Get(profileId)
    if (not data) then
        error(string.format("The specified profile '%s' does not exist", profileId));		
    end

    local active = self.activeProfile;
    if (active) then
        active:SetActive(false);
        active:UnregisterCallback("onChanged", self)
    end
    
    local prof = CreateProfile(profileId);
    prof:SetActive();
    self.activeProfile = prof;
    activeProfileVariable:Replace(prof:GetId());
    prof:RegisterCallback("OnChanged", function()
            Addon:Debug("profile", "Broadcasting changes '%s'", prof:GetName())
            self:TriggerEvent("OnProfileChanged", prof)
        end, self)
    self:TriggerEvent("OnProfileChanged", prof)
end

--[[===========================================================================
   | Creates a new profile with the specified name.
   ==========================================================================]]
function ProfileManager:CreateProfile(profileName)
    local profile = CreateProfile();
    profile:SetName(profileName);

    Addon.invoke(Addon, "OnInitializeProfile", profile);
    Addon:Debug("profile", "Created new profile '%s'", profile:GetId());
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
    Addon:Debug("profile", "Copied profile '%s' to '%s'", profileId, data.id);
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
        Addon:Debug("profile", "Deleted profile '%s'", profileId);
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
    local active = self.activeProfile;

    profilesVariable:ForEach(function(profile, id)
            local profile = CreateProfile(id);
            profile:SetActive(id == active:GetId());
            table.insert(results, profile);
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
        local instance = {
            activeProfile = false;
        };

        profileManager = Addon.object("ProfileManager", instance, ProfileManager, {
            "OnProfileChanged", "OnProfileCreated", "OnProfileDeleted"
        });

        rawset(self, PMGR_KEY, profileManager);
    end

    return profileManager;
end

function Addon:GetProfileList()
    local profiles = {};

    for _, profile in Addon:GetProfileManager():EnumerateProfiles() do
        table.insert(profiles, profile);
    end

    table.sort(profiles, 
        function(a, b)
            if (not a) then
                return false;
            elseif (not b) then 
                return true;
            else
                return a:GetName() < b:GetName()
            end
        end)

    return profiles
end

function Addon:GetProfileNames()
    local profiles = Addon:GetProfileList()
    local profilenames = {}
    for _, profile in pairs(profiles) do
        table.insert(profilenames, profile:GetName())
    end
    return profilenames
end

function Addon:FindProfile(profileName)
    if not profileName then return nil end
    for _, profile in Addon:GetProfileManager():EnumerateProfiles() do
        if profile:GetName() == profileName then
            return profile
        end
    end
    return nil
end

function Addon:ProfileExists(profileName)
    if Addon:FindProfile(profileName) then return true else return false end
end

function Addon:SetProfile(profileName)
    local profile = Addon:FindProfile(profileName)
    if not profile then return false end
    Addon:GetProfileManager():SetProfile(profile)
    return true
end

function Addon:DeleteProfile(profileName)
    local profile = Addon:FindProfile(profileName)
    if not profile then return false end
    return Addon:GetProfileManager():DeleteProfile(profile)
end

function Addon:NewProfile(profileName)
    if Addon:ProfileExists(profileName) then return false end
    Addon:GetProfileManager():CreateProfile(profileName)
    return true
end

function Addon:RenameProfile(profileName, newProfileName)
    if not Addon:ProfileExists(profileName) then return false end
    local profile = Addon:FindProfile(profileName)
    profile:SetName(newProfileName)
    return true
end

function Addon:CopyProfile(profileName, newProfileName)
    local profile = Addon:FindProfile(profileName)
    if not profile then return false end
    local newprofile = Addon:FindProfile(newProfileName)
    if newprofile then return false end
    Addon:GetProfileManager():CopyProfile(profile, newProfileName)
    return true
end

function Addon:GetCurrentProfile()
    local profile = Addon:GetProfileManager():GetProfile()
    if profile then return profile:GetName() end
    return ""
end