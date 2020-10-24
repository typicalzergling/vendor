-- This is a file exclusively for debug channels and functions. On a release build, debug statements are no-op and ignored.
-- This file will exist on a release build so Debug related code in the other files is defined.
local AddonName, Addon = ...
local DEBUG_VARIABLE = (AddonName .. "_debug");

Addon.IsDebug = true

-- Ensure the debugging variable.
local function debugEnsureVariable()
    _G[DEBUG_VARIABLE] = _G[DEBUG_VARIABLE] or {
        channel={}, 
        settings={},
    };
end

-- Explicity sets the state of a debug channel
function Addon:SetDebugChannel(channel, enabled) 
    debugEnsureVariable()
    local name = string.lower(channel);
    if (not enabled) then
        _G[DEBUG_VARIABLE].channel[name] = nil;
    else 
        _G[DEBUG_VARIABLE].channel[name] = true;
    end
end

-- Toggles the debug channel (changing it to on it was off, or on it was off)
function Addon:ToggleDebug(channel)
    local name = string.lower(channel);
    local enabled = self:IsDebugChannelEnabled(channel);

    if enabled then
        _G[DEBUG_VARIABLE].channel[name] = nil;
        self:Print("Debug channel %s disabled.", name)
    else
        _G[DEBUG_VARIABLE].channel[name] = true;
        self:Print("Debug channel %s enabled.", name)
    end
end

-- Get a named debug setting value (key must be a string)
function Addon:GetDebugSetting(key)
    debugEnsureVariable()
    if (type(key) ~= "string") then
        Addon:Print("ERROR: the key for SetDebugSetting must be a string");
        return;
    end

    return _G[DEBUG_VARIABLE].settings[string.lower(key)];
end

-- Saves a named debug setting key must be a string.
function Addon:SetDebugSetting(key, value)
    debugEnsureVariable()
    if (type(key) ~= "string") then
        Addon:Print("ERROR: the key for SetDebugSetting must be a string");
        return;
    end

    _G[DEBUG_VARIABLE].settings[string.lower(key)] = value
end

-- Checks if a channel enabled
function Addon:IsDebugChannelEnabled(channel)
    debugEnsureVariable()
    local name = string.lower(channel);
    return (_G[DEBUG_VARIABLE].channel[name]) == true;
end

-- Writes a debug message for a specific channmel to the defualt chat frame
function Addon:Debug(channel, msg, ...)
    local name = string.upper(channel);
    if (Addon:IsDebugChannelEnabled(name)) then
        self:Print(" %s[%s]%s " .. msg, ACHIEVEMENT_COLOR_CODE, name, FONT_COLOR_CODE_CLOSE, ...)
    end
end