-- This is exclusively for the debug options panel and Debug-specific commands that do not appear in a normal build.
-- This entire file is excluded from packaging and it is not localized intentionally.
local AddonName, Addon = ...
local L = Addon:GetLocale()

-- Sets up all the console commands for debug functions in this file.
function Addon:SetupDebugConsoleCommands()
    self:AddConsoleCommand("debug", "Toggle Debug. No args prints channels. Specify channel to toggle.",
        function(channel)
            if not channel then 
                Addon:PrintDebugChannels()
            else
                Addon:ToggleDebug(channel)
            end
        end)
    self:AddConsoleCommand("disabledebug", "Turn off all debug channels.", "DisableAllDebugChannels")
    self:AddConsoleCommand("link", "Dump hyperlink information", "DumpLink_Cmd")
    self:AddConsoleCommand("simulate", "Simulates deleting and selling items, without actually doing it.", "ToggleSimulate_Cmd")
    self:AddConsoleCommand("cache", "Clears all caches.", "ClearCache_Cmd")
    self:AddConsoleCommand("profile", "Profile management.", "Profile_Cmd")

    -- Register debug channels for the addon. Register must be done after addon loaded.
    Addon:RegisterDebugChannel("autosell")
    Addon:RegisterDebugChannel("blocklists")
    Addon:RegisterDebugChannel("config")
    Addon:RegisterDebugChannel("destroy")
    Addon:RegisterDebugChannel("events")
    Addon:RegisterDebugChannel("extensions")
    Addon:RegisterDebugChannel("itemerrors")
    Addon:RegisterDebugChannel("items")
    Addon:RegisterDebugChannel("itemproperties")
    Addon:RegisterDebugChannel("profile")
    Addon:RegisterDebugChannel("rules")
    Addon:RegisterDebugChannel("rulesdialog")
    Addon:RegisterDebugChannel("rulesengine")
    Addon:RegisterDebugChannel("test")
    Addon:RegisterDebugChannel("threads")
    Addon:RegisterDebugChannel("tooltip")
    Addon:RegisterDebugChannel("tooltiperrors")
end

-- Debug Commands
function Addon:DumpLink_Cmd(arg)
    self:Print("Link: "..tostring(arg))
    self:Print("Raw: "..gsub(arg, "\124", "\124\124"))
    self:Print("ItemString: "..tostring(self:GetLinkFromString(arg)))
    local props = self:GetLinkPropertiesFromString(arg)
    for i, v in pairs(props) do
        self:Print("["..tostring(i).."] "..tostring(v))
    end
    self:Print("ItemInfo:")
    local itemInfo = {GetItemInfo(tostring(arg))}
    for i, v in pairs(itemInfo) do
        self:Print("["..tostring(i).."] "..tostring(v))
    end
end

function Addon:ToggleSimulate_Cmd()
    Addon:SetDebugSetting("simulate", not Addon:GetDebugSetting("simulate"))
    Addon:Print("Simulate set to %s", tostring(Addon:GetDebugSetting("simulate")))
end

function Addon:ClearCache_Cmd()
    Addon:ClearItemCache()
    Addon:ClearResultCache()
    Addon:Print("Item cache and result cache cleared.")
end

function Addon:Profile_Cmd(cmd, arg1, arg2)
    if cmd then
        cmd = string.lower(cmd)
    end
    if not cmd then
        local profiles = Addon:GetProfileList()
        local active = Addon:GetProfile()
        Addon:Print("All available profiles:")
        for _, profile in pairs(profiles) do
            Addon:Print("  %s [%s]", tostring(profile:GetName()), tostring(profile:GetId()))
        end
        Addon:Print("Active profile: %s", tostring(active:GetName()))

    elseif cmd == "get" then
        local active = Addon:GetProfile()
        Addon:Print("Active profile: %s", tostring(active:GetName()))

    elseif cmd == "set" and type(arg1) == "string" then
        if not Addon:ProfileExists(arg1) then
            Addon:Print("Profile '%s' does not exist.", arg1)
            return
        end
        if Addon:SetProfile(arg1) then
            Addon:Print("Active profile set to '%s'", arg1)
        else
            Addon:Print("Failed setting active profile.")
        end

    elseif cmd == "copy" and type(arg1) == "string" and type(arg2) == "string" then
        if not Addon:ProfileExists(arg1) then
            Addon:Print("Profile '%s' does not exist.", arg1)
            return
        end
        if Addon:ProfileExists(arg2) then
            Addon:Print("Profile '%s' already exists.", arg2)
            return 
        end
        if Addon:CopyProfile(arg1, arg2) then
            Addon:Print("Profile '%s' copied as profile '%s'", arg1, arg2)
        else
            Addon:Print("Failed copying the profile.")
        end

    elseif cmd == "delete" and type(arg1) == "string" then
        if not Addon:ProfileExists(arg1) then
            Addon:Print("Profile '%s' does not exist.", arg1)
            return
        end
        if Addon:DeleteProfile(arg1) then
            Addon:Print("Profile '%s' has been deleted.", arg1)
        else
            Addon:Print("Failed deleting the profile.")
        end

    elseif cmd == "create" and type(arg1) == "string" then
        if Addon:ProfileExists(arg1) then
            Addon:Print("Profile '%s' already exists.", arg1)
            return
        end
        if Addon:NewProfile(arg1) then
            Addon:Print("Profile '%s' has been created and set to the active profile.", arg1)
        else
            Addon:Print("Failed creating the profile.")
        end

    elseif cmd == "rename" and type(arg1) == "string" and type(arg2) == "string" then
        if not Addon:ProfileExists(arg1) then
            Addon:Print("Profile '%s' does not exist.", arg1)
            return
        end
        if Addon:RenameProfile(arg1, arg2) then
            Addon:Print("Profile '%s' has been renamed to '%s'.", arg1, arg2)
        else
            Addon:Print("Failed renaming the profile.")
        end
    else
        Addon:Print("profile usage: <none> | get | set | create | copy | delete | rename")
    end
end



-- Beyond this point are debug related functions that are not packaged.
function Addon:DumpTooltipItemProperties()
    local props = self:GetItemProperties(GameTooltip)
    self:Print("Properties for "..props["Link"])

    -- Print non-derived properties first.
    for i, v in Addon.orderedPairs(props) do
        if not string.find(i, "^Is") then
            local val = v
            if type(v) == "table" then
                val = "{"..table.concat(v, ", ").."}"
            end
            self:Print("    [%s] %s", tostring(i), tostring(val))
        end
    end

    -- Print all the derived properties ("Is*") together.
    for i, v in Addon.orderedPairs(props) do
        if string.find(i, "^Is") then
            self:Print("    ["..tostring(i).."] "..tostring(v))
        end
    end
end

function Addon:DumpItemPropertiesFromTooltip()
    Addon:DumpTooltipItemProperties()
end

Addon:MakePublic(
    "DumpItemPropertiesFromTooltip",
    function () Addon:DumpItemPropertiesFromTooltip() end,
    "DumpItemPropertiesFromTooltip",
    "Dumps properties for item over toolip.")

-- Sorted Pairs from Lua-Users.org. We use this for pretty-printing tables for debugging purposes.

function Addon.__genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

function Addon.orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = Addon.__genOrderedIndex( t )
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1,table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function Addon.orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return Addon.orderedNext, t, nil
end