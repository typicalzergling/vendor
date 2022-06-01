local AddonName, Addon = ...
local L = Addon:GetLocale()

-- Before Profile Constants
local SELL_LIST = "sell_always"     -- Legacy Sell List key, needed for migration
local KEEP_LIST = "sell_never"      -- Legacy Keep list key, needed for migration
local KEEP_RULES = "keep";
local SELL_RULES = "sell";
local DESTROY_RULES ="destroy";

-- Profile Constants
local PROFILE_KEEP_LIST = "list:keep";
local PROFILE_SELL_LIST = "list:sell";
local PROFILE_DESTROY_LIST = "list:destroy";
local PROFILE_SELL_RULES = "rules:sell";
local PROFILE_KEEP_RULES = "rules:keep";
local PROFILE_DESTROY_RULES = "rules:destroy";
local PROFILE_HIDDEN_RULES = "rules:hidden"
local PROFILE_VERSION = "profile:version";
local CURRENT_VERSION = 2;
local PROFILE_INTERFACEVERSION = "profile:interface";
local INTERFACE_VERSION = select(4, GetBuildInfo());

local RuleType = Addon.RuleType;
local ListType = Addon.ListType;
local Profile = {}

--[[===========================================================================
   | Maps the external rule type to our internal rule key name
   ==========================================================================]]
local function RuleTypeToRuleKey(ruleType)
	if (ruleType == RuleType.SELL) then
		return PROFILE_SELL_RULES;
	elseif (ruleType == RuleType.KEEP) then
		return PROFILE_KEEP_RULES;
	elseif (ruleType == RuleType.DESTROY) then
		return PROFILE_DESTROY_RULES;
	elseif (ruleType == RuleType.HIDDEN) then
		return PROFILE_HIDDEN_RULES
	end

	return nil;
end

--[[===========================================================================
   | Gets the rule configuration for the specified type
   ==========================================================================]]
function Profile:GetRules(ruleType)
	local key = RuleTypeToRuleKey(ruleType)
	if (key) then
		return self:GetValue(key) or {};
	end

	--@debug@
	error(string.format("Unable to retrieve rules '%s' as it is invalid.", ruleType));
	--@end-debug@
	return {};
end

--[[===========================================================================
   |  Update the specified rule configuation
   ==========================================================================]]
function Profile:SetRules(ruleType, config)
	if (type(config) ~= "table") then
		error("The rule config must be a table");
	end

	local key = RuleTypeToRuleKey(ruleType);
	if (key) then
		Addon:Debug("profile", "Profile '%s', %s rule changed", self:GetName(), ruleType);
		self:SetValue(key, config or {});
		return;
	end

	--@debug@
	error(string.format("There is not a rule type '%s'", ruleType));
	--@end-debug@
end 

--[[===========================================================================
   | Helper to map list type to profile key
   ==========================================================================]]
local function ListTypeToKey(listType)
	if (listType == ListType.SELL) then
		return PROFILE_SELL_LIST;
	elseif (listType == ListType.KEEP) then
		return PROFILE_KEEP_LIST;
	elseif (listType == ListType.DESTROY) then
		return PROFILE_DESTROY_LIST;
	end 

	return nil;
end

--[[===========================================================================
   | Retrieves the specified list
   ==========================================================================]]
function Profile:GetList(listType)
	local key = ListTypeToKey(listType);
	if (key) then
		return self:GetValue(key) or {};
	end

	--@debug@
	error(string.format("There is no '%s' list", listType));
	--@end-debug@

	return {};
end

--[[===========================================================================
   |  Updates the specified list
   ==========================================================================]]
function Profile:SetList(listType, list)
	local key = ListTypeToKey(listType);

	if (key) then
		self:SetValue(key, list);
		Addon:Debug("profile", "Profile '%s', %s list changed", self:GetName(), listType);
		return;
	end

	--@debug@
	error(string.format("There is no '%s' list", listType));
	--@end-debug@
end

--[[===========================================================================
   | Retrieves the currently active profile
   ==========================================================================]]
function Addon:GetProfile()
    local profileManager = Addon:GetProfileManager();
    return profileManager:GetProfile();
end

--[[===========================================================================
   | Finds the default profile, if "nil" if there isn't one.
   ==========================================================================]]
function Addon:FindDefaultProfile()
	for _, profile in Addon:GetProfileManager():EnumerateProfiles() do
		if (profile:GetValue("profile:default") == true) then
			return profile;
		end
	end
	return nil;
end

--[[===========================================================================
   | Handle creating a new profile (either by migration or new)
   ==========================================================================]]
function Addon:OnCreateDefaultProfile(profile)

    --[[ Ideally we create the Default Profile one time, and then for each character process the config. However, its possible
        all data gets deleted, and therefore there is no default profile and we need to re-create it and use it for this
        character. Ultimately three outcomes from this call:

        1) Default Profile is Created and used.
        2) Default Profile is found and used.
        3) Default Profile is found, copied and a new profile created and used with user-specific rules overrides.

        Scenarios:
        1) No Default Profile -> Create it
            1a) If no Vendor_Settings exists, use defaults, we're done.
            1b) If Vendor_Settings exists, import when creating the Default Profile.

        2) Default Profile Exists
            2a) No Vendor_RulesConfig data -> Just Use default Profile as-is.
            2b) Vendor_RulesConfig exists (which is per-character) -> Copy Default Profile, then apply RulesConfig overrides.

        Returning a profile from this function tells the caller to override whatever profile they made and use the one
        we return, otherwise we make inline changes to the profile.
    ]]
    -- First see if we already have a Default Profile.
    local defaultProfile = Addon:FindDefaultProfile();

    -- If no default profile, create one.
    if not defaultProfile then
        defaultProfile = Addon:GetProfileManager():CreateProfile(L.DEFAULT_PROFILE_NAME)
        defaultProfile:SetValue("profile:default", true);

        -- Override settings with what the user previously had.
		if (Vendor_Settings) then
			for setting, value in pairs(Vendor_Settings) do
				if ((setting ~= "version") and (setting ~= "interfaceversion")) then
					if (table.hasKey(Addon.DefaultConfig.Settings, setting)) then
						defaultProfile:SetValue(setting, value);
					end
				end
			end

            -- These were global and are now per-profile.
			defaultProfile:SetValue(PROFILE_KEEP_LIST, Vendor_Settings[KEEP_LIST] or {});
			defaultProfile:SetValue(PROFILE_SELL_LIST, Vendor_Settings[SELL_LIST] or {});
            defaultProfile:SetValue(PROFILE_DESTROY_LIST, {});
            
            -- Remove the old now-migrated settings.
            Vendor_Settings = nil
        end
        Addon:Debug("profile", "Created new default profile.");
    end

    -- If no per-user settings then the default profile is all that is needed.
    if not Vendor_RulesConfig then
        Addon:Debug("profile", "Found existing Vendor Default Profile");
        return defaultProfile
    end

    -- Copy the Default Profile, and then override with per-user settings.
    local defaultProfileCopy = Addon:GetProfileManager():CopyProfile(defaultProfile, Addon:GetCharacterFullName())

    -- Now overwrite the rules with this character's old rules:
    defaultProfileCopy:SetValue(PROFILE_KEEP_RULES, Vendor_RulesConfig.keep or {});
    defaultProfileCopy:SetValue(PROFILE_SELL_RULES, Vendor_RulesConfig.sell or {});
    defaultProfileCopy:SetValue(PROFILE_DESTROY_RULES, {});

    -- Give new name to signify this player's profile is specific.
    defaultProfileCopy:SetName(Addon:GetCharacterFullName())

    -- Remove old data now that we've migrated it to a profile.
    Vendor_RulesConfig = nil

    Addon:Debug("profile", "Used default profile settings with per-user rules config");
    return defaultProfileCopy
end

--[[===========================================================================
   | Handle initializing a new profile, populating it with the default config.
   ==========================================================================]]
function Addon:OnInitializeProfile(profile)

	-- Set the version
	profile:SetValue(PROFILE_INTERFACEVERSION, INTERFACE_VERSION);
	profile:SetValue(PROFILE_VERSION, CURRENT_VERSION);

	-- Lists start empty
	profile:SetValue(PROFILE_DESTROY_LIST, {});
	profile:SetValue(PROFILE_KEEP_LIST, {});
	profile:SetValue(PROFILE_SELL_LIST, {});

	-- Copy the default rules from the config
	profile:SetValue(PROFILE_KEEP_RULES, Addon.DefaultConfig.Rules.keep or {});
	profile:SetValue(PROFILE_SELL_RULES, Addon.DefaultConfig.Rules.sell or {});
	profile:SetValue(PROFILE_DESTROY_RULES, Addon.DefaultConfig.Rules.destroy or {});

	-- Copy the default settings into the new profile.
	table.forEach(Addon.DefaultConfig.Settings, 
		function(value, name)
			profile:SetValue(name, value);
		end);
end

--[[===========================================================================
   | Handle copying a profile
   ==========================================================================]]
function Addon:OnCopyProfile(profile)
    -- Just in case we are copying the default profile, it does not become a default profile.
    profile:SetValue("profile:default", false);
end


function Addon:OnCheckProfileMigration(profile)
	Addon:Debug("profile", "In CheckMigration for Profile: " .. profile:GetName());
	local version = profile:GetValue(PROFILE_VERSION)
	Addon:Debug("profile", "Profile Version: " .. tostring(version));

	-- No-op for current version.
	if version == CURRENT_VERSION then
		Addon:Debug("profile", "Profile is current, skipping migration.");
		return
	end

	-- Migrate new cosmetic sys rule to be on by default. 
	if version < 2 then
		Addon:Debug("profile", "Migrating cosmetic sys rule...");
		local keeprules = profile:GetValue(PROFILE_KEEP_RULES)

		-- Remove old cosmetic rule from the rulepack.
		local index = nil
		for k,v in pairs(keeprules) do
			if v == "e[rulepack.cosmetic]" then
				index = k
				break
			end
		end
		table.remove(keeprules, index)

		-- Add new keep rule replacement.
		table.insert(keeprules, "keep.cosmetic")

		-- Update the keeprules.
		profile:SetValue(PROFILE_KEEP_RULES, keeprules)
	end

	-- Profile version is now migrated, update to current.
	profile:SetValue(PROFILE_VERSION, CURRENT_VERSION)
	Addon:Debug("profile", "Profile Migration Complete.");
end

Addon.Profile = Profile;