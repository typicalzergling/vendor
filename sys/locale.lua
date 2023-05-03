--[[===========================================================================
    | locale.lua
    |
    | This file enables easy localization within the addon. The intent is that
    | this module is entirely optional, and can be omitted if you do not wish
    | to localize. Alternately, if you do wish to localize, but later, you can
    | include it with only one locale and that will be the one used. All
    | localization is handled via fallback logic. The default locale specified
    | is assumed to be the primary locale, and then the actual locale will be
    | detected and then merge the locale into the default to create the final
    | stringtable. To use, you simply do 'local L = Addon:GetLocale()' and then
    | index the strings. If you index a string that does not exist, the addon
    | will not error; instead the key you used will be the string returned.
    | This can help you find undefined strings in your addon without causing
    | errors. You can even ignore localization initially and not define any,
    | then call GetLocale() for the stringtable, and use the keys to the
    | table as your strings.
    |
    | Methods:
    |   AddLocale
    |   GetLocale
    |
    =======================================================================--]]

local _, Addon = ...

local locales = {}
local localizedStrings = nil
local localizedStringsProxy = nil
local LocaleObject = {}
local currentLocale = nil

function LocaleObject:__construct()
    assert(type(self.locale) == "string", "Expected locate property to be defined")
    self.strings = localizedStrings
end

function LocaleObject:GetName()
    return self.locale
end

function LocaleObject:Add(strings)
    assert(type(strings) == "table", "Expected the argument to be a table")

    for id, string in pairs(strings) do
        self.strings[id] = string
    end
end

function LocaleObject:Remove(strings)
    assert(type(strings) == "table", "Expected the argument to be a table")
    
    for id, _ in pairs(strings) do
        self.strings[id] = nil
    end
end

function LocaleObject:Get(id)
    assert(type(id) == "string", "Expected the ID to be a string")
    return self.strings[id] or nil
end

function LocaleObject:Format(id, ...)
    local string = self:Get(id)
    if (type(string) == "string") then
        return string.format(string, ...)
    end
    return nil
end
    

-- This will add a locale definition to the addon.
-- All locale definitions must be added before calling SetLocale or GetLocale.
-- This is because we want to be efficient and not keep around a bunch of stringtables in memory when 
-- the user only needs one of those tables. So we will enforce early definition of all stringtables,
-- and then choose one early on and discard the rest.
-- This means that Locales will be among the very first things you load in your TOC.
-- You should load Constants -> Init -> Locale -> Locale Definitions before anything else.
function Addon:AddLocale(locale, strings)
    assert(type(locale) == "string", "Invalid parameter to AddLocale: locale must be a string.")
    assert(type(strings) == "table", "Invalid parameter to AddLocale: strings must be a string table.")
    assert(locales, "You cannot add a locale after calling GetLocale(). Move up the '"..locale.."' definition in the TOC load order to fix this.")
    table.insert(locales, { locale=locale, strings=strings })
end

--[[ Finds the locale object for the specified locale, returns nil if the locale doens't exist ]]
function Addon:FindLocale(locale)
    if (string.lower(locale) ~= string.lower(currentLocale)) then
        return nil
    end

    return Addon.object("LocaleObject", { locale = locale }, LocaleObject)
end

local function findLocale(locale)
    assert(locales and type(locales) == "table")   -- If this hits it is a programming error in this file.
    locale = locale
    for _, v in ipairs(locales) do
        if v.locale == locale then
            return v
        end
    end
    return nil
end

-- Fallback logic
-- 1) Use TargetLocale as an override if it is specified.
--      This is an optional constant so it can globally apply to the entire addon
-- 2) Use the game client Locale if present.
-- 3) Use the default locale, if one is specified.
-- 4) Use the *first* locale in the list
-- 5) Make an empty locale and use that.
local function setLocale()
    -- Do nothing if we already have strings set.
    if localizedStrings then return end

    -- Use the override if it is provided.
    local targetLocale = nil
    if Addon.c_TargetLocale then
        targetLocale = findLocale(Addon.c_TargetLocale)
    end

    -- Fallback to the Locale matching the game client.
    if not targetLocale then
        targetLocale = findLocale(GetLocale())
    end

    -- If no override and we don’t’ match the client, choose a default.
    -- The default will be the default locale if provided, then the first one in the list, 
    -- and if not one then we will create a new empty locale and use that.
    if not targetLocale and Addon.c_DefaultLocale then
        targetLocale = findLocale(Addon.c_DefaultLocale)
    end

    if not targetLocale then
        if not locales[1] then
            Addon:AddLocale("", {})
        end
        targetLocale = locales[1]
    end

    -- Target locale identified, now build the string table.
    -- Determine default locale. This will be the constant if defined, or the first locale discovered.
    local defaultLocale
    if Addon.c_DefaultLocale and locales[Addon.c_DefaultLocale] then
        defaultLocale = locales[Addon.c_DefaultLocale]
    else
        defaultLocale = locales[1]
    end
    
    -- Use default as a base.
    localizedStrings = {}
    for k, v in pairs(defaultLocale.strings) do
        localizedStrings[k] = v
    end
    
    -- If target isn't the default, merge that one in.
    if targetLocale and targetLocale.locale ~= defaultLocale then
        for k, v in pairs(targetLocale.strings) do
            localizedStrings[k] = v
        end
    end

    -- Set up proxy for the localized strings
    -- This table is empty, so adds or edits at this point will always be errors.
    localizedStringsProxy = {
        
        -- Retrieves the string if exists, otherwise it returns nil
        GetString  = function(t, k)
            return localizedStrings[k]
        end,

        -- Retrieves a formatted string (converting the arguments to strings)
        FormatString = function(t, k, ...)
            local fmt = localizedStrings[k]
            assert(fmt, "Expected a valid string to format :: " .. tostring(k))

            local args = {}
            for _, arg in ipairs({...}) do
                table.insert(args, tostring(arg))
            end

            return string.format(fmt, unpack(args))
        end
    }

    local proxyMetatable = {
        __metatable = {},

        -- If we try to index a string that doesn't exist, use the key instead.
        -- This is better for the player than throwing Lua errors and failing.
        __index = 
            function(t, k)
                local str = localizedStrings[k]
                if not str then
                    return tostring(k)
                end
                return str
            end,

        -- If a string is attempted to be added, fail the add and
        -- throw an error. It is a mistake to be assigning a localized
        -- string or adding a new one after we have already set the locale.
        -- Such an event is a programmer error.
        __newindex =
            function(t, k)
                error("Attempting to create or modify localized string with identifier: "..tostring(k))
            end,
    }

    setmetatable(localizedStringsProxy, proxyMetatable)

    -- Free up memory for all the unused strings.
    currentLocale = targetLocale.locale
    locales = nil
end

-- This will implicitly late-bind the Locale if it hasn't been defined.
-- Once this is called once, you cannot Add new locales.
function Addon:GetLocale()
    if not localizedStrings then
        setLocale()
    end
    -- Always return the proxy, which is set up at the same time localizedStrings is.
    return localizedStringsProxy
end


Addon.Public.SetLocalizedString = function(self, control, key)
    if (key and (type(key) == "string")) then
        local locale = Addon:GetLocale();
        control:SetText(locale[key] or string.upper(key));
    end
end
