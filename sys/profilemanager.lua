local AddonName, Addon = ...;
local ProfileManager = {};
local PROFILE_KEY = {};
local PMGR_KEY = {};
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

    local activeId = self.activeProfileVariable:GetOrCreate("");
    if ((type(activeId) == "string") and (string.len(activeId) ~= 0)) then
        local data = self.profilesVariable:Get(activeId);
        if (type(data) == "table") then
            Addon:Debug("profile", "Using profile '%s'", activeId);
            profile = CreateProfile(activeId);
        end
    end

    -- If this is a new profile, create it and then let addon decide how
    -- to populate it. If the addon returns a profile, use that one as an
    -- override.
    if (not profile) then
        profile = CreateProfile();
        local override = Addon.Invoke(Addon, "OnCreateDefaultProfile", profile);
        if (override and (override:GetId() ~= profile:GetId())) then
            self.profilesVariable:Set(profile:GetId(), nil);
            profile = override;
        end
        self.activeProfileVariable:Replace(profile:GetId());
        Addon:Debug("profile", "Created new default profile '%s'", profile:GetId());
    else
        Addon.Invoke(Addon, "OnCheckProfileMigration", profile);
    end

    profile:SetActive(true);
    self.activeProfile = profile;
    profile:RegisterCallback("OnChanged", function()
            Addon:Debug("profile", "Broadcasting change '%s'", profile:GetName());
            self:TriggerEvent("OnProfileChanged", profile);
            Addon:RaiseEvent("OnProfileChanged", profile);
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

    local data = self.profilesVariable:Get(profileId)
    if (not data) then
        error(string.format("The specified profile '%s' does not exist", profileId));		
    end

    local active = self.activeProfile;
    if (active) then
        active:SetActive(false);
        active:UnregisterCallback("OnChanged", self)
    end
    
    local prof = CreateProfile(profileId);
    prof:SetActive(true);
    self.activeProfile = prof;
    self.activeProfileVariable:Replace(prof:GetId());
    prof:RegisterCallback("OnChanged", function()
            Addon:Debug("profile", "Broadcasting changes '%s'", prof:GetName())
            self:TriggerEvent("OnProfileChanged", prof)            
            Addon:RaiseEvent("OnProfileChanged", profile);
        end, self)
    self:TriggerEvent("OnProfileChanged", prof)
    Addon:RaiseEvent("OnProfileChanged", profile);
end

--[[===========================================================================
   | Creates a new profile with the specified name.
   ==========================================================================]]
function ProfileManager:CreateProfile(profileName)
    local profile = CreateProfile();
    if profileName and profileName ~= "" then
        profile:SetName(profileName);
    else
        profile:SetName(profile:GetId());
    end

    Addon.Invoke(Addon, "OnInitializeProfile", profile);
    Addon:Debug("profile", "Created new profile '%s'", profile:GetId());
    self:TriggerEvent("OnProfileCreated", profile);
    Addon:RaiseEvent("OnProfileCreated", profile);
    return profile;
end

--[[===========================================================================
   | Copies the specifed profile into a new profile (whole-sale) variable
   | copy, returns the new profile.
   ==========================================================================]]
function ProfileManager:CopyProfile(profile, newProfileName)
    local profileId = getProfileId(profile);
    local data = self.profilesVariable:Get(profileId);
    if (not data) then
        error("Unable to locate the profile to copy");
        return nil;
    end

    local profile = CreateProfile();
    data.id = profile:GetId();
    self.profilesVariable:Set(profile:GetId(), data);
    profile:SetName(newProfileName);
    Addon.Invoke(Addon, "OnCopyProfile", profile)
    Addon:Debug("profile", "Copied profile '%s' to '%s'", profileId, data.id);    
    self:TriggerEvent("OnProfileCreated", profile);
    Addon:RaiseEvent("OnProfileCreated", profile)
    return profile;
end

--[[===========================================================================
   | Deletes the specified profile.	
   ==========================================================================]]
function ProfileManager:DeleteProfile(profile)
    local profileId = getProfileId(profile);
    local data = self.profilesVariable:Get(profileId);
    if (data) then
        self.profilesVariable:Set(profileId, nil);
        Addon:Debug("profile", "Deleted profile '%s'", profileId);
        local profile = CreateProfile(Addon.Profile, profileId)
        self:TriggerEvent("OnProfileDeleted", profile)
        Addon:RaiseEvent("OnProfileDeleted", profile)
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

    -- Check for active profile. We may not have one yet.
    -- That's OK, we don't need one to enumerate
    local activeId = ""
    if self.activeProfile then
        activeId = self.activeProfile:GetId()
    end

    local active = self.activeProfile;

    self.profilesVariable:ForEach(function(profile, id)
            local profile = CreateProfile(id);
            profile:SetActive(id == activeId);
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
            activeProfile = false,
            activeProfileVariable = Addon:CreateSavedVariable("ActiveProfile"),
            profilesVariable = Addon:CreateSavedVariable("Profiles")
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
    return profiles
end

function Addon:GetProfiles()
    local profilelist = {}
    for _, profile in Addon:GetProfileManager():EnumerateProfiles() do
        local entry = {}
        entry.Name = profile:GetName()
        entry.Id = profile:GetId()
        entry.Active = profile:IsActive()
        table.insert(profilelist, entry)
    end
    return profilelist
end

function Addon:FindProfile(profileNameOrId)
    if not profileNameOrId then return nil end
    for _, profile in Addon:GetProfileManager():EnumerateProfiles() do
        if profile:GetId() == profileNameOrId or profile:GetName() == profileNameOrId then
            return profile
        end
    end
    return nil
end

function Addon:ProfileExists(profileNameOrId)
    if Addon:FindProfile(profileNameOrId) then return true else return false end
end

function Addon:SetProfile(profileNameOrId)
    local profile = Addon:FindProfile(profileNameOrId)
    if not profile then return false end
    Addon:GetProfileManager():SetProfile(profile)
    return true
end

function Addon:DeleteProfile(profileNameOrId)
    local profile = Addon:FindProfile(profileNameOrId)
    if not profile then return false end
    return Addon:GetProfileManager():DeleteProfile(profile)
end

function Addon:NewProfile(profileName)
    if Addon:ProfileExists(profileName) then return false end
    Addon:GetProfileManager():CreateProfile(profileName)
    return true
end

function Addon:RenameProfile(profileNameOrId, newProfileName)
    if not Addon:ProfileExists(profileNameOrId) then return false end
    local profile = Addon:FindProfile(profileNameOrId)
    profile:SetName(newProfileName)
    return true
end

function Addon:CopyProfile(profileNameOrId, newProfileName)
    local profile = Addon:FindProfile(profileNameOrId)
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

Addon:GenerateEvents({"OnProfileChanged", "OnProfileCreated", "OnProfileDeleted"})