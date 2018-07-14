
local Addon, L = _G[select(1,...).."_GET"]()

Addon.Config = {}
Addon.DefaultConfig = {}

-- Table deep copy, as seen on StackOverflow
-- https://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value
local function deep_copy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[deep_copy(k, s)] = deep_copy(v, s) end
    return res
end


-- NOTE: This can't use Addon:Debug(...) need to figure out a new plan

--*****************************************************************************
-- The default settings for Addon.
--*****************************************************************************
Addon.DefaultConfig.Settings =
{
    -- Current version of the settings config
    version = 1,

    -- Default values of our settings
    throttle_time = 0.15,
    autosell = true,
    autorepair = true,
    guildrepair = true,
    sell_throttle = 1,
    sell_never = {},
    sell_always = {},
}

--*****************************************************************************
-- The default rule configuration
--*****************************************************************************
Addon.DefaultConfig.Rules =
{
    -- Current version of the rules config
    version = 2,

    -- The default rules to enable which cause items to be kept
    keep = {
        "neversell",
        "unsellable",
        "soulboundgear",
        "unknownappearance",
        "legendaryandup",
    },

    -- The default rules to enable which cause items to be sold.
    sell =
    {
        "artifactpower",
        "poor",
        "knowntoys",
        "oldfood",
        { rule = "uncommongear", itemlevel = 190 }, -- green gear < ilvl
        { rule = "raregear", itemlevel = 190 }, -- blue gear < ilvl
    },

    -- Custom rules provied by the user
    custom = {},
    customDefinitions = {},

}

-- NOTE: Per character isn't fully implemented

local NEVER_SELL = Addon.c_ConfigSellNever
local ALWAYS_SELL = Addon.c_ConfigSellAlways

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
                        --@debug@
                        if (not status) then
                            print("Addon.Config: Changed callback failed: \"%s%s%s\"", RED_FONT_COLOR_CODE, result, FONT_COLOR_CODE_CLOSE)
                        end
                        --@end-debug@
                    end
                    self.changes = false
                end
            end,
    }

    if (not Vendor_Settings) then
        Vendor_Settings = deep_copy(Addon.DefaultConfig.Settings)
    elseif (Vendor_Settings and (Vendor_Settings.version ~= Addon.DefaultConfig.Settings.version)) then
        local oldSettings = Vendor_Settings
        local newSettings = deep_copy(Addon.DefaultConfig.Settings)
        self:migrateSettings(oldSettings, newSettings)
        Vendor_Settings = newSettings
        Vendor_SettingsPerCharacter = nil
    end

    if (not Vendor_RulesConfig) then
        Vendor_RulesConfig = deep_copy(Addon.DefaultConfig.Rules)
    elseif (Vendor_RulesConfig and (Vendor_RulesConfig.version ~= Addon.DefaultConfig.Rules.version)) then
        local oldRuleConfig = Vendor_RulesConfig
        local newRuleConfig = deep_copy(Addon.DefaultConfig.Rules)
        self:migrateRulesConfig(oldRuleConfig, newRuleConfig)
        Vendor_RulesConfig = newRuleConfig
    end

    setmetatable(instance, self)
    self.__index = self
    return instance
end

--*****************************************************************************
-- When a batch of chagnes are being made to our settings you can send out
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
        return deep_copy(Addon.DefaultConfig.Rules)
    else
        local value = rawget(Addon.DefaultConfig.Rules, string.lower(ruleType))
        if (value) then
            return deep_copy(value)
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
    if (not ruleType) then
        return Vendor_RulesConfig or deep_copy(Addon.DefaultConfig.Rules)
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
    --Addon:Debug("[Config]: +Begin migrating settings from v=%d to v=%d", oldSettings.version, newSettings.version)
    -- Migrate the sell_never to the new version
   if (rawget(oldSettings, NEVER_SELL)) then
        --Addon:Debug("[Config]: |         Copying never sell list with %d items", #rawget(oldSettings, NEVER_SELL))
        rawset(newSettings, NEVER_SELL, rawget(oldSettings, NEVER_SELL))
    end

    if (rawget(oldSettings, ALWAYS_SELL)) then
        --Addon:Debug("[Config]: |         Copying the always sell list %d items", #rawget(oldSettings, ALWAYS_SELL))
        rawset(newSettings, ALWAYS_SELL, rawget(oldSettings, ALWAYS_SELL))
    end
    --Addon:Debug("[Config] +Setting migration complete")
end

--*****************************************************************************
-- The sets a configuration value, if the value is the ssame as currently
-- set value then we don't mark it has having changed.
--*****************************************************************************
function Addon.Config:migrateRulesConfig(oldSettings, newSettings)
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

-- prototype/
function Addon:GetConfigV2()
    if (not self.configV2) then
        local cfg = self:GetConfig()
        self.configV2 =  {}
        setmetatable(self.configV2,
            {
                __index = function(self, key)
                    return cfg:GetValue(key)
                end,
                __newindex = function(self, key,value)
                    cfg:SetValue(key, value)
                end,
            })
    end
    return self.configV2
end
