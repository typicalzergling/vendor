-- This is a file exclusively for debug channels and functions. On a release build, debug statements are no-op and ignored.
-- This file will exist on a release build so Debug related code in the other files is defined.
local AddonName, Addon = ...

local debugSettings = _G[AddonName .. "_debug"];
if (not debugSettings or (type(debugSettings) ~= "table")) then
    debugSettings = { 
        channel={}, 
        settings={},
    };
    _G[AddonName .. "_debug"] = debugSettings;
end

-- Toggles the debug channel (changing it to on it was off, or on it was off)
function Addon:ToggleDebug(channel)
    local name = string.upper(channel);
    local enabled = self:IsDebugChannelEnabled(channel);

    
    if enabled then
        debugSettings.channel[name] = nil;
        self:Print("Debug channel %s disabled.", name)
    else
        debugSettings.channel[name] = true;
        self:Print("Debug channel %s enabled.", name)
    end
    _G[AddonName .. "_debug"] = debugSettings;
end

-- Explicity sets the state of a debug channel
function Addon:SetDebugChannel(channel, enabled) 
    local name = string.upper(channel);
    if (not enabled) then
        debugSettings.channel[name] = nil;
    else 
        debugSettings.channel[name] = true;
    end
    _G[AddonName .. "_debug"] = debugSettings;
end

-- Checks if a channel enabled
function Addon:IsDebugChannelEnabled(channel)
    local name = string.upper(channel);
    if (debugSettings and (type(debugSettings) == "table")) then
        if (debugSettings.channel) then
            return (debugSettings.channel[name]) == true;
        end
    end    
    return false;
end

-- Get a named debug setting value (key must be a string)
function Addon:GetDebugSetting(key)
    if (type(key) ~= "string") then
        Addon:Print("ERROR: the key for SetDebugSetting must be a string");
        return;
    end

    if (debugSettings and (type(debugSettings) == "table")) then
        return debugSettings.settings[string.upper(key)];
    end
end

-- Saves a named debug setting key must be a string.
function Addon:SetDebugSetting(key, value)
    if (type(key) ~= "string") then
        Addon:Print("ERROR: the key for SetDebugSetting must be a string");
        return;
    end

    if (debugSettings and (type(debugSetting) == "table")) then
        debugSettings.settings[string.upper(key)] = value;
    end
end