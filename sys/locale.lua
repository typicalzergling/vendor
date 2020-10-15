-- locale.lua

local _, Addon = ...

local locales = {}
local localizedStrings = nil
local localizedStringsProxy = nil

-- This will implicitly late-bind the Locale if it hasn't been defined.
-- Once this is called, you cannot Add new locales.
function Addon:GetLocale()
    if not localizedStrings then
        Addon:SetLocale()
    end
    -- Always return the proxy, which is set up at the same time localizedStrings is.
    return localizedStringsProxy
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
    assert(locales, "You cannot add a locale after calling GetLocale() or SetLocale(). Move up the '"..locale.."' definition in the TOC load order to fix this.")
    table.insert(locales, { locale=locale, strings=strings })
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
function Addon:SetLocale()
    -- Do nothing if we already have strings set.
    if localizedStrings then return end

    -- Use the override if it is provided.
    local targetLocale = nil
    if self.c_TargetLocale then
        targetLocale = findLocale(self.c_TargetLocale)
    end

    -- Fallback to the Locale matching the game client.
    if not targetLocale then
        targetLocale = findLocale(GetLocale())
    end

    -- If no override and we don’t’ match the client, choose a default.
    -- The default will be the default locale if provided, then the first one in the list, 
    -- and if not one then we will create a new empty locale and use that.
    if not targetLocale and self.c_DefaultLocale then
        targetLocale = findLocale(self.c_DefaultLocale)
    end

    if not targetLocale then
        if not locales[1] then
            self:AddLocale("", {})
        end
        targetLocale = locales[1]
    end

    -- Target locale identified, now build the string table.
    -- Determine default locale. This will be the constant if defined, or the first locale discovered.
    local defaultLocale
    if self.c_DefaultLocale and locales[self.c_DefaultLocale] then
        defaultLocale = locales[self.c_DefaultLocale]
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
    localizedStringsProxy = {}
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
        -- Such an event is certainly a programmer error.
        __newindex =
            function(t, k)
                error("Attempting to create or modify localized string with identifier: "..tostring(k))
            end,
    }
    setmetatable(localizedStringsProxy, proxyMetatable)

    -- Free up memory for all the unused strings.
    locales = nil
end


