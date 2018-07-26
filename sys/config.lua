
local Addon, L = _G[select(1,...).."_GET"]()

Addon.Config = {}
Addon.DefaultConfig = {}

-- BFA specific migration check. 
-- If we existed before BFA, and are currently on or above BFA
local function IsMigrationToBFA()
    if tonumber(Vendor_RulesConfig.interfaceversion) < 80000 
        and tonumber(select(4, GetBuildInfo())) >= 80000 then   -- This condition can be removed once BFA lands
        Addon:Print(L["DATA_MIGRATION_BFA_NOTICE"])
        return true
    end
    return false
end

--*****************************************************************************
-- The default settings for Addon.
--*****************************************************************************
Addon.DefaultConfig.Settings =
{
    -- Current version of the settings config
    version = 2,

    -- Default values of our settings
    [Addon.c_Config_ThrottleTime] = 0.15,
    [Addon.c_Config_AutoSell] = true,
    [Addon.c_Config_AutoRepair] = true,
    [Addon.c_Config_GuildRepair] = true,
    [Addon.c_Config_SellThrottle] = 1,
    [Addon.c_Config_SellNever] = {},
    [Addon.c_Config_SellAlways] = {},
    [Addon.c_Config_Tooltip] = true,
    [Addon.c_Config_SellLimit] = false,
    [Addon.c_Config_MaxSellItems] = Addon.c_BuybackLimit,
}

--*****************************************************************************
-- The default rule configuration
--*****************************************************************************
Addon.DefaultConfig.Rules =
{
    -- Current version of the rules config
    version = 5,
    
    -- Current interface version of the client
    interfaceversion = select(4, GetBuildInfo()),

    -- The default rules to enable which cause items to be kept
    keep = {
        "keep.legendaryandup",
        "keep.equipmentset",
        "keep.soulboundgear",
        "keep.unknownappearance",
    },

    -- The default rules to enable which cause items to be sold.
    sell =
    {
        "sell.poor",
        "sell.oldfood",
        "sell.artifactpower",
        "sell.knowntoys",
    },
}

-- NOTE: Per character isn't fully implemented

local NEVER_SELL = Addon.c_Config_SellNever
local ALWAYS_SELL = Addon.c_Config_SellAlways
local KEEP_RULES = "keep";
local SELL_RULES = "sell";

--*****************************************************************************
-- Create a new config object which provides access to our configuration
--*****************************************************************************
function Addon.Config:Create()
    local instance =
    {
        handlers = {},
        suspend = 0,
        changes = false,
        usingPerUserConfig =
            function(self)
                if (Vendor_Settings) then return Vendor_Settings.savepercharacter end
            end,
            
        notifyChanges =
            function(self)
                if ((self.suspend == 0) and self.changes) then
                    for _, callback in ipairs(self.handlers) do
                        local status, result = pcall(callback, self)
                        if (not status) then
                            Addon:Debug("Config: Changed callback failed: \"%s%s%s\"", RED_FONT_COLOR_CODE, result, FONT_COLOR_CODE_CLOSE)
                        end
                    end
                    self.changes = false
                end
            end,

        ensure = function(self)
            if (not self.ensured) then

                if (not Vendor_Settings) then
                    Vendor_Settings = Addon.DeepTableCopy(Addon.DefaultConfig.Settings)
                    Addon:Debug("Settings have been set from defaults.")
                elseif (Vendor_Settings and (Vendor_Settings.version ~= Addon.DefaultConfig.Settings.version)) then
                    local oldSettings = Vendor_Settings
                    local newSettings = Addon.DeepTableCopy(Addon.DefaultConfig.Settings)
                    self:migrateSettings(oldSettings, newSettings)
                    Vendor_Settings = newSettings
                    Vendor_SettingsPerCharacter = nil
                    Addon:Debug("Settings have been migrated.")
                end

                -- If rules config doesn't exist, initialize it with the defaults.
                if (not Vendor_RulesConfig) then
                    Vendor_RulesConfig = Addon.DeepTableCopy(Addon.DefaultConfig.Rules)
                    Addon:Debug("Rules config has been set from defaults.")

                -- If it does exist, check the version and the interface version to see if we need to do any migration.
                -- For BFA specifically, there is an ilvl squish which necessitates a rule config reset.
                elseif (Vendor_RulesConfig and 
                        ((Vendor_RulesConfig.version ~= Addon.DefaultConfig.Rules.version)
                         or IsMigrationToBFA())
                       ) then
                    local oldRuleConfig = Vendor_RulesConfig
                    local newRuleConfig = Addon.DeepTableCopy(Addon.DefaultConfig.Rules)
                    self:migrateRulesConfig(oldRuleConfig, newRuleConfig)
                    Vendor_RulesConfig = newRuleConfig
                    Addon:Debug("Rules config has been migrated.")
                end

                self.ensured = true;
            end
        end,
    }

    --Addon:RegisterEvent("PLAYER_LOGIN", function() self:ensure() end)
    setmetatable(instance, self)
    self.__index = self
    return instance
end

--*****************************************************************************
-- When a batch of changes are being made to our settings you can send out
-- a single notifcation by doing:
--   config:BeginBatch()
--   config:SetValue("a", 1)
--   config:SetValue("b", 2)
--   config:EndBatch()
--*****************************************************************************
function Addon.Config:BeginBatch()
    self.suspend = (self.suspend + 1)
end

--*****************************************************************************
-- Enad a batch of changes, sends notificaitons if we had any changes
--*****************************************************************************
function Addon.Config:EndBatch()
    self.suspend = math.max(0, self.suspend - 1)
    self:notifyChanges()
end

--*****************************************************************************
-- Adds a handler to be called when the configuration has changed, passes
-- the configuration object as the first parameter.
--*****************************************************************************
function Addon.Config:AddOnChanged(onchange)
    if (type(onchange) == "function") then
        table.insert(self.handlers, onchange)
    end
end

--*****************************************************************************
-- Adds a handler to be called when the configuration has changed, passes
-- the configuration object as the first parameter.
--*****************************************************************************
function Addon.Config:SetPerCharacter(usePerCharacter)
    if (usePerCharacter) then
    else
    end
end

--*****************************************************************************
-- Retrieve the default rule configuration of the given type, or everything
-- NOTE: This always returns a valid table, but it can be empty
--*****************************************************************************
function Addon.Config:GetDefaultRulesConfig(ruleType)
    if (not ruleType) then
        return Addon.DeepTableCopy(Addon.DefaultConfig.Rules)
    else
        local value = rawget(Addon.DefaultConfig.Rules, string.lower(ruleType))
        if (value) then
            return Addon.DeepTableCopy(value)
        end
    end
    return {}
end

--*****************************************************************************
-- Retrieves the current rule configuration for the user, this will gather
-- the data from the default table if we don't have user specific changes
-- NOTE: This always returns a valid table, but it can be empty
--*****************************************************************************
function Addon.Config:GetRulesConfig(ruleType)
    self:ensure()
    if (not ruleType) then
        return Vendor_RulesConfig or Addon.DeepTableCopy(Addon.DefaultConfig.Rules)
    else
        local key = string.lower(ruleType)

        local value = rawget(Vendor_RulesConfig, key)
        if (value ~= nil) then
            return value
        end

        local value = self:GetDefaultRulesConfig(ruleType)
        if (value ~= nil) then
            return value
        end
    end
    return {}
end

--*****************************************************************************
-- This sets the the rule configuration for the specified type, since it
-- it not effecient, and don't change much this doesn't attempt to do a diff
-- of the configuration
--*****************************************************************************
function Addon.Config:SetRulesConfig(ruleType, rules)
    local key = string.lower(ruleType)
    rawset(Vendor_RulesConfig, key, rules)
    self.changes = true
    self:notifyChanges()
end


--*****************************************************************************
-- Returns the configuration value with the specified name, if we cannot find
-- the specified value then 'nil' is returned
--
-- The order is :
--    1 - Per Character (if applicable)
--    2 - Global setttings
--    3 - Default settings
--*****************************************************************************
function Addon.Config:GetValue(name)
    assert(type(name) == "string", "The name of a config value must be a string")
    self:ensure()

    local key = string.lower(name)
    --if (self:usingPerUserConfig() and Vendor_SettingsPerCharacter) then
    --    local value = rawget(Vendor_SettingsPerCharacter, key)
    --    if (value ~= nil) then
    --        return value
    --    end
    --end

    local value = rawget(Vendor_Settings, key)
    if (value ~= nil) then
        return value
    end

    local value = rawget(Addon.DefaultConfig.Settings, key)
    if (value ~= nil) then
        return value
    end

    return value
end

--*****************************************************************************
-- The sets a configuration value, if the value is the same as currently
-- set value then we don't mark it has having changed.
--*****************************************************************************
function Addon.Config:SetValue(name, value)
    assert(type(name) == "string", "The name of a config value must be a string")
   
    local key = string.lower(name)
    --if (self:usingPerUserConfig()) then
    --    Vendor_SettingsPerCharacter = Vendor_SettingsPerCharacter or {}
    --    local currentValue = rawget(Vendor_SettingsPerCharacter, key)
    --    if (currentValue ~= value) then
    --        self.changes = true
    --    end
    --    rawset(Vendor_SettingsPerCharacter, key, value)
    --else
        local currentValue = rawget(Vendor_Settings, key, value)
        if (currentValue ~= value) then
            self.changes = true
        end
        rawset(Vendor_Settings, key, value)
    --end
    self:notifyChanges()
end

--*****************************************************************************
-- This is called when we need to migrate the settings from one version to
-- another, both of the tables will be non-nil so you can access them directly.
--*****************************************************************************
function Addon.Config:migrateSettings(oldSettings, newSettings)
    Addon:Debug("[Config]: +Begin migrating settings from v=%d to v=%d", oldSettings.version, newSettings.version)
    -- Migrate the sell_never to the new version
    if (rawget(oldSettings, NEVER_SELL)) then
        Addon:Debug("[Config]: |         Copying never sell list with %d items", #rawget(oldSettings, NEVER_SELL))
        rawset(newSettings, NEVER_SELL, rawget(oldSettings, NEVER_SELL))
    end

    if (rawget(oldSettings, ALWAYS_SELL)) then
        Addon:Debug("[Config]: |         Copying the always sell list %d items", #rawget(oldSettings, ALWAYS_SELL))
        rawset(newSettings, ALWAYS_SELL, rawget(oldSettings, ALWAYS_SELL))
    end
    Addon:Debug("[Config] +Setting migration complete")
end

--*****************************************************************************
-- The sets a configuration value, if the value is the same as currently
-- set value then we don't mark it has having changed.
--*****************************************************************************
function Addon.Config:migrateRulesConfig(oldSettings, newSettings)
    Addon:Debug("[Config]: +Begin migrating rules from v=%d to v=%d", oldSettings.version, newSettings.version)

    if (oldSettings.version == 3) and (newSettings.version == 4) then
        if (rawget(oldSettings, KEEP_RULES)) then
            Addon:Debug("[Config]: |         Copying keep rules with with %d items", #rawget(oldSettings, KEEP_RULES))
            rawset(newSettings, KEEP_RULES, rawget(oldSettings, KEEP_RULES))
            Addon:Debug("[Config]: |         adding equipmentset keep rule");
            table.insert(rawget(newSettings, KEEP_RULES), "equipmentset");
        end

        if (rawget(oldSettings, SELL_RULES)) then
            Addon:Debug("[Config]: |         Copying sell rules with with %d items", #rawget(oldSettings, SELL_RULES))
            rawset(newSettings, SELL_RULES, rawget(oldSettings, SELL_RULES))
        end
    end

    if (oldSettings.version < 5) then
        Addon:Debug("[Config]: |         Need to migrate rule ids")

        local function migrateIds(prefix, list)
            local l = {};
            for _, entry in ipairs(list) do
                if (type(entry) == "string") then
                    table.insert(l, prefix .. entry);
                elseif (type(entry) == "table") then
                    entry.rule = (prefix .. entry.rule);
                    table.insert(l, entry);
                end
            end
            return l;            
        end;

        rawset(newSettings, SELL_RULES, migrateIds("sell.", rawget(oldSettings, SELL_RULES)));
        rawset(newSettings, KEEP_RULES, migrateIds("keep.", rawget(oldSettings, KEEP_RULES)));
    end

    Addon:Debug("[Config] +Rules migration complete");
end

--*****************************************************************************
-- Determines if the config has been loaded yet.
--*****************************************************************************
function Addon:IsConfigInitialized()
    return self.config and self.config.ensured
end

--*****************************************************************************
-- Creates and returns the configuration object
--*****************************************************************************
function Addon:GetConfig()
    if (not self.config) then
        self.config = Addon.Config:Create()
        self.config:AddOnChanged(function() self:ClearTooltipResultCache() end)
    end
    return self.config
end
