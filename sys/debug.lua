-- This is a file exclusively for debug channels and functions. On a release build, debug statements are no-op and ignored.
-- This file will exist on a release build so Debug related code in the other files is defined.
local AddonName, Addon = ...
local DEBUG_VARIABLE = (AddonName .. "_debug");

-- Ensure the debugging variable.
function Addon:DebugEnsureVariable()
    _G[DEBUG_VARIABLE] = _G[DEBUG_VARIABLE] or {
        channel={}, 
        settings={},
    };
end

-- Toggles the debug channel (changing it to on it was off, or on it was off)
function Addon:ToggleDebug(channel)
    local name = string.upper(channel);
    local enabled = self:IsDebugChannelEnabled(channel);

    if enabled then
        _G[DEBUG_VARIABLE].channel[name] = nil;
        self:Print("Debug channel %s disabled.", name)
    else
        _G[DEBUG_VARIABLE].channel[name] = true;
        self:Print("Debug channel %s enabled.", name)
    end
end

-- Explicity sets the state of a debug channel
function Addon:SetDebugChannel(channel, enabled) 
    self:DebugEnsureVariable();
    local name = string.upper(channel);
    if (not enabled) then
        _G[DEBUG_VARIABLE].channel[name] = nil;
    else 
        _G[DEBUG_VARIABLE].channel[name] = true;
    end
end

-- Checks if a channel enabled
function Addon:IsDebugChannelEnabled(channel)
    self:DebugEnsureVariable();
    local name = string.upper(channel);
    return (_G[DEBUG_VARIABLE].channel[name]) == true;
end

-- Get a named debug setting value (key must be a string)
function Addon:GetDebugSetting(key)
    self:DebugEnsureVariable();
    if (type(key) ~= "string") then
        Addon:Print("ERROR: the key for SetDebugSetting must be a string");
        return;
    end

    return _G[DEBUG_VARIABLE].settings[string.upper(key)];
end

-- Saves a named debug setting key must be a string.
function Addon:SetDebugSetting(key, value)
    self:DebugEnsureVariable();
    if (type(key) ~= "string") then
        Addon:Print("ERROR: the key for SetDebugSetting must be a string");
        return;
    end

    _G[DEBUG_VARIABLE].settings[string.upper(key)] = value
end