local AddonName, Addon = ...
local L = Addon:GetLocale()

-- Before Profile Constants
local SELL_LIST = Addon.c_Config_SellAlways;
local KEEP_LIST = Addon.c_Config_SellNever;
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
local CURRENT_VERSION = 1;
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
   | Handle creating a new default profile (either by migration or new)
   ==========================================================================]]
function Addon:OnCreateDefaultProfile(profile)
	if (not Vendor_Settings and not Vendor_RulesConfig) then
		local defaultProfile = Addon:FindDefaultProfile();
        if (defaultProfile) then
            Addon:Debug("profile", "Using existing Vendor Default Profile");
			return defaultProfile;
		else
			Addon:Debug("profile", "Initialized new default vendor profile");
			self:OnInitializeProfile(profile);
			profile:SetName(L.DEFAULT_PROFILE_NAME);
			profile:SetValue("profile:default", true);
		end
	else
		-- Migrate settings variable.
		if (Vendor_Settings) then
			for setting, value in pairs(Vendor_Settings) do
				if ((setting ~= "version") and (setting ~= "interfaceversion")) then
					if (table.hasKey(Addon.DefaultConfig.Settings, setting)) then
						profile:SetValue(setting, value);
					end
				end
			end

			profile:SetValue(PROFILE_KEEP_LIST, Vendor_Settings[KEEP_LIST] or {});
			profile:SetValue(PROFILE_SELL_LIST, Vendor_Settings[SELL_LIST] or {});
			profile:SetValue(PROFILE_DESTROY_LIST, {});
		end

		-- Migrate rule configuation varible.
		if (Vendor_RulesConfig) then
			profile:SetValue(PROFILE_KEEP_RULES, Vendor_RulesConfig.keep or {});
			profile:SetValue(PROFILE_SELL_RULES, Vendor_RulesConfig.sell or {});
			profile:SetValue(PROFILE_DESTROY_RULES, {});
		else
			profile:SetValue(PROFILE_KEEP_RULES, Addon.DefaultConfig.Rules.keep or {});
			profile:SetValue(PROFILE_SELL_RULES, Addon.DefaultConfig.Rules.sell or {});
			profile:SetValue(PROFILE_DESTROY_RULES, Addon.DefaultConfig.Rules.destroy or {});
		end

		Addon:Debug("profile", "Migrated existing vendor settings");
    end

    profile:SetValue(PROFILE_INTERFACEVERSION, INTERFACE_VERSION);
	profile:SetValue(PROFILE_VERSION, CURRENT_VERSION);
end

--[[===========================================================================
   | Handle initializing a new profile, populating it with the default config.
   ==========================================================================]]
function Addon:OnInitializeProfile(profile)

    profile:SetName(string.format("%s - %s", UnitFullName("player")));

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
	-- Current a no-op
end

Addon.Profile = Profile;