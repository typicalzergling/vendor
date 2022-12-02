-- This is a file exclusively for debug channels and functions. On a release build, debug statements are no-op and ignored.
-- This file will exist on a release build so Debug related code in the other files is defined.
local AddonName, Addon = ...
local DEBUG_VARIABLE = (AddonName .. "_debug");

Addon.IsDebug = true

-- Ensure the debugging variable.
local function debugEnsureVariable()
    _G[DEBUG_VARIABLE] = _G[DEBUG_VARIABLE] or {
        channel={
            default = true,
        }, 
        settings={},
    };
end

function Addon:RegisterDebugChannel(channel)
    debugEnsureVariable()
    local name = string.lower(channel)
    if _G[DEBUG_VARIABLE].channel[name] == nil then
        _G[DEBUG_VARIABLE].channel[name] = false
    end
end

function Addon:PrintDebugChannels()
    debugEnsureVariable()
    self:Print("Debug Channels:")
    local keys = {}
    for key in pairs(_G[DEBUG_VARIABLE].channel) do table.insert(keys, key) end
    table.sort(keys)
    for _, name in ipairs(keys) do
        if _G[DEBUG_VARIABLE].channel[name] then
            self:Print("%s # %s%s", GREEN_FONT_COLOR_CODE, string.lower(name), FONT_COLOR_CODE_CLOSE)
        else
            self:Print("    %s", string.lower(name))
        end
    end
end

--[[ Gets the debug channels ]]
function Addon:GetDebugChannels()
    local keys = {}
    for key in pairs(_G[DEBUG_VARIABLE].channel) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

function Addon:DisableAllDebugChannels()
    debugEnsureVariable()
    for name, enabled in pairs(_G[DEBUG_VARIABLE].channel) do
        _G[DEBUG_VARIABLE].channel[name] = false
    end
    self:Print("All Debug Channels disabled.")
end

-- Explicity sets the state of a debug channel
function Addon:SetDebugChannel(channel, enabled) 
    debugEnsureVariable()
    local name = string.lower(channel);
    if (not enabled) then
        _G[DEBUG_VARIABLE].channel[name] = false;
    else 
        _G[DEBUG_VARIABLE].channel[name] = true;
    end
end

-- Toggles the debug channel (changing it to on it was off, or on it was off)
function Addon:ToggleDebug(channel)
    local name = string.lower(channel);
    local enabled = self:IsDebugChannelEnabled(channel);

    if enabled then
        _G[DEBUG_VARIABLE].channel[name] = false;
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
    if (Addon.IsDebug) then
        debugEnsureVariable()
        local name = string.lower(channel);
        return (_G[DEBUG_VARIABLE].channel[name]) == true;
    end
    return false
end

-- Writes a debug message for a specific channmel to the defualt chat frame
function Addon:Debug(channel, msg, ...)
    local name = string.upper(channel or "default");
    if (Addon:IsDebugChannelEnabled(name)) then
        local success = pcall(self.Print, self, "%s[%s]%s " .. msg, ACHIEVEMENT_COLOR_CODE, name, FONT_COLOR_CODE_CLOSE, ...)
        if (not success) then
            print(RED_FONT_COLOR_CODE .. "Debug Failed|r :: ", channel, msg, ...)
        end
    end
end

-- Outputs the contents of a table in debug
function Addon:DebugForEach(channel, t, ...)
    if Addon.IsDebug then
        local c = channel or "default"
        local msg = ""
        local args = { ... }

        Addon:Debug(c, "+ Start ForEach: %s", tostring(t))
        if (table.getn(args) ~= 0) then
            for _, o in pairs({...}) do
                if (string.len(msg) ~= 0) then
                    msg = msg .. " "
                end
                msg = msg .. tostring(o)
            end
        end

        if (t and (type(t) == "table")) then
            for k, v in pairs(t) do
                Addon:Debug(c, "|    %s = %s %s", tostring(k), tostring(v), msg)
            end
        else
            Addon:Debug(c, "|    " .. DISABLED_FONT_COLOR:WrapTextInColorCode("nil or !table") .. " %s", msg)
        end
        Addon:Debug(c, "+ End ForEach: %s", tostring(t))

    end
end