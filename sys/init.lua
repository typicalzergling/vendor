-- Init must be first in the TOC
-- Constants must be second in the toc.
-- All localization files come after Constants.
-- After that it doesn't matter.

-- Create addon namespace, named after the addon name.
-- If this already exists we will assert, as that means you either screwed up and didn't load this first,
-- or it means someone else already defined the namespace, and we're in Undefined Behavior land.
local AddonName = select(1,...)

if _G[AddonName] or _G[AddonName.."_GET"] or _G[AddonName.."_LOC"] then
    assert(false, "Addon conflict detected. Addon already exists with this name: "..AddonName)
end
_G[AddonName]  = {}

-- Setup our Addon & frame.
local Addon = _G[AddonName]
Addon.AddonFrame = CreateFrame("Frame")
Addon.IsClassic = (WOW_PROJECT_ID  == WOW_PROJECT_CLASSIC);

-- Event Handling
local events = {}

local function dispatchEvent(handler, ...)
    if type(handler) == "function" then
        handler(...)
    else
        if Addon[handler] then
            -- Assume self parameter must be passed
            Addon[handler](Addon, ...)
        else
            assert(false, "Function named "..handler.." not found in "..AddonName)
        end
    end
end 

-- We support multiple handlers for the same event.
local function eventDispatcher(frame, event, ...)
    handler = events[event]

    if not handler then
        assert(false, "Event was registered and did not appear in the events list. Event="..tostring(event))
    end
    
    if type(handler) == "table" then
        -- Execute all handlers for this event.
        for k, v in ipairs(handler) do
            dispatchEvent(v, ...)
        end
    else
        dispatchEvent(handler, ...)
    end
end 

local function registerEvent(event, handler)
    -- If the event handler doesn't already exist
    if not events[event] then
        events[event] = handler
    else 
        -- Check if we need to convert it to table    
        if type(events[event] ~= "table") then
            local firstHandler = events[event]
            events[event] = {}
            table.insert(events[event], firstHandler)
        end
        
        -- Add to the table
        table.insert(events[event], handler)
    end
end

-- Define Register Event
function Addon:RegisterEvent(event, handler)
    assert(event and type(event) == "string", "Invalid arguments to RegisterEvent - Must specify a string")
    assert(handler and (type(handler) == "function" or type(handler) == "string"), "Invalid arguments to RegisterEvent - Handler must be string or function")

    -- If this is a new event, we need to register for it with the frame.
    if not events[event] then
        Addon.AddonFrame:RegisterEvent(event)
    end
    
    -- Register the handler with the event.
    registerEvent(event, handler)
end

-- Set the script to use the event Dispatcher.
Addon.AddonFrame:SetScript("OnEvent", eventDispatcher)

-- Define a default event, PLAYER_LOGIN, which is when we should initialize our addon.
Addon:RegisterEvent("PLAYER_LOGIN", "OnInitialize")

function Addon:DumpEvents()
    for k, v in pairs(events) do
        if type(v) == "table" then
            for i, e in pairs(v) do
                print("Event: "..tostring(k).."  Handler: "..tostring(e))
            end
        else
            print("Event: "..tostring(k).."  Handler: "..tostring(v))
        end
    end
end

-- Setup Localization
-- After I
-- It is a huge memory waste when we have more than one locale.
-- TODO: Make this late bound so we evaluate the strings then flush
local locales = {}
local localizedStrings = nil
local function getLocalizedStrings()
    -- If called before the default locale has been defined or loaded, return nil
    -- A mitigation is to make sure the default locale loads LAST.
    if not Addon.c_DefaultLocale or (locales and not locales[Addon.c_DefaultLocale]) then
        return nil
    end

    if not localizedStrings then
        localizedStrings = {}

        -- Import the Default Locale
        for k, v in pairs(locales[Addon.c_DefaultLocale]) do
            localizedStrings[k] = v
        end

        -- Get current locale strings if available and merge.
        local locale = locales[GetLocale()]
        if locale then
            for k, v in pairs(locale) do
                localizedStrings[k] = v
            end
        end
        
        -- Delete the now unnecessary locales
        -- If the load order is wrong or loc files arent' loaded first, 
        -- this will cause the addon to fail to load.
        -- And it will clean up unused locale strings for us.
        locales = nil
    end
    return localizedStrings
end

-- Create the global Addon LOC method
-- This is used by the loc files to gain access to addon locales
local function getLocales()
    return locales
end
_G[AddonName.."_LOC"] = getLocales

-- Create the global Addon GET method. 
-- This is the function that should be called by every addon file
-- to get the Addon data and to get the Localized Strings.
-- Example: local Addon, L = _G[select(1,...).."_GET"]()
-- This should only be called either before the default locale constant has
-- been defined, or after all locales have been loaded.
local function getAddonInfo()
    if (not Addon.Config) then
        return Addon, getLocalizedStrings()
    else
        return Addon, getLocalizedStrings(), Addon:GetConfig()
    end
end

_G[AddonName.."_GET"] = getAddonInfo

