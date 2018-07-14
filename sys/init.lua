-- Init must be first in the TOC
-- Constants must be second in the toc.
-- All localization files come after Constants.
-- After that it doesn't matter.

-- Create addon namespace, named after the addon name.
-- If this already exists we will assert, as that means you either screwed up and didn't load this first,
-- or it means someone else already defined the namespace, and we're in Undefined Behavior land.
local AddonName = select(1,...)
if _G[AddonName] or _G[AddonName.."_GET"] then
	assert(false, "Addon conflict detected. Addon already exists with this name: "..AddonName)
end
_G[AddonName]  = {}

-- Setup our Addon & frame.
local Addon = _G[AddonName]
Addon.AddonFrame = CreateFrame("Frame")

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
Addon.Locales = {}
function Addon:GetLocalizedStrings()
	-- If called before any locales have been defined, just return nil.
	if not self.Locales[self.c_DefaultLocale] then
		return nil
	end
	
    if not self.LocalizedStrings then
        self.LocalizedStrings = {}

        -- Import the Default Locale
        for k, v in pairs(self.Locales[self.c_DefaultLocale]) do
            self.LocalizedStrings[k] = v
        end

        -- Get current locale strings if available and merge.
        local locale = self.Locales[GetLocale()]
        if locale then
            for k, v in pairs(locale) do
                self.LocalizedStrings[k] = v
            end
        end
    end
    return self.LocalizedStrings
end

-- Create initialization function.
-- This is the function that should be caleld by every addon file:
-- Example: local Addon, L = _G[select(1,...).."_GET"]()
local function getAddonInfo()
	return Addon, Addon:GetLocalizedStrings()
end

-- Set the getAddonInfo to the global namespace to be called by our other files to get the addon and its localization table.
_G[AddonName.."_GET"] = getAddonInfo

