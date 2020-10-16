--[[===========================================================================
    | core.lua
    |
    | This file is the core of the Addon Skeleton framework. It sets up core
    | addon functionality used by the rest of the framework. It is also the
    | only truly essential part of the Skeleton framework.
    | Core does the following for the addon:
    |   1) Sets up the global namespace for the addon to Addon.Public
    |   2) Creates a prefixed Print method for addon use.
    |   3) Sets up lifetime events for Initialize and Terminate of the
    |      addon. Several other skeleton framework files require this file,
    |      and it should always be included in a project.
    |
    | Methods:
    |   Print
    |   AddInitializeAction
    |   AddTerminateAction
    |
    =======================================================================--]]
local AddonName, Addon = ...

--[[===========================================================================
    | Secure namespace and create rudimentary public API.
    | Anything added to Addon.Public will be globally visible.
    | Everything else is by default private to the addon.
    =======================================================================--]]
if _G[AddonName] then
    error("Addon conflict detected. Addon already exists with this name: "..AddonName)
end
Addon.Public = {}
_G[AddonName] = Addon.Public


--[[===========================================================================
    | Print
    | Most basic output to the user, used by most modules for user feedback.
    | Constants can define the color. Prints to DEFAULT_CHAT_FRAME.
    =======================================================================--]]
local color = Addon.c_PrintColorCode or ORANGE_FONT_COLOR_CODE
assert(type(color) == "string", "Addon print color code must be a string.")
local printPrefix = string.format("%s[%s%s%s]%s%s%s", HIGHLIGHT_FONT_COLOR_CODE, color, AddonName, HIGHLIGHT_FONT_COLOR_CODE, FONT_COLOR_CODE_CLOSE, FONT_COLOR_CODE_CLOSE, " ")
function Addon:Print(msg, ...)
    DEFAULT_CHAT_FRAME:AddMessage(printPrefix .. string.format(msg, ...))
end


--[[===========================================================================
    | Create lifetime management events and event handling.
    |
    | Core does lifetime management of Addon load (PLAYER_LOGIN) and unload
    | (PLAYER_LOGOUT). It allows other modules and parts of the addon to
    | plug in and execute on initialization and terminate.
    |
    | All initialize and terminate handlers use pcall. This is especially
    | important for PLAYER_LOGOUT events, where we are likely saving data, so
    | it is important not to fail the addon if there is a problem with one of
    | the handlers. Events in "event.lua" do not use pcall by design.
    |
    | After all initialize handlers execute, we execute a default OnInitialize
    | method for the main addon to do its one-time setup work. Constants can
    | change the name of this function, and it is optional.
    =======================================================================--]]
local addonLifetimeFrame = CreateFrame("Frame")
local onInitializeActions = {}
local onTerminateActions = {}

local function lifetimeEventHandler(frame, event, ...)
    -- On player login, the addon is completely loaded and all saved variables are expected to be present.
    -- This is the ideal time to do initialization.
    if event == "PLAYER_LOGIN" then

        -- Safe call all initialization functions.
        for i, h in ipairs(onInitializeActions) do
            local status, err = pcall(h, ...)
            if not status then
                Addon:Print("Error executing initialize function: %s", tostring(err))
            end
        end

        -- Call the default OnInitialize function, if defined.
        -- If it is defined it must be a function or this is a programmer error.
        if Addon.c_InitializeName then
            assert(type(Addon[Addon.c_InitializeName]) == "function", "Initialize function expected but not found.")
            Addon[Addon.c_InitializeName](Addon, ...)
        elseif Addon.OnInitialize then
            assert(type(Addon.OnInitialize) == "function", "OnInitialize must be a function.")
            Addon:OnInitialize(...)
        end

        -- Clean up event handling and make sure we only process this once.
        addonLifetimeFrame:UnregisterEvent("PLAYER_LOGIN")

    -- On player logout we get an opportunity to do cleanup and save variables.
    -- This happens on client exit, disconnect, and logout.
    elseif event == "PLAYER_LOGOUT" then
        for i, h in ipairs(onTerminateActions) do
            pcall(h, ...)
            -- We don't bother printing errors becuase nobody is here to see them.
            -- We could try to add them to saved vars, perhaps, but who will bother looking there?
        end
        addonLifetimeFrame:UnregisterEvent("PLAYER_LOGOUT")
    else
        -- We should never have any other events here. See "event.lua" for that.
        error("Failure in lifetime event handler. Unexpected event: "..tostring(event))
    end
end

addonLifetimeFrame:SetScript("OnEvent", lifetimeEventHandler)
addonLifetimeFrame:RegisterEvent("PLAYER_LOGIN")
addonLifetimeFrame:RegisterEvent("PLAYER_LOGOUT")

--[[===========================================================================
    | AddInitializeAction
    | AddTerminateAction
    |
    | These add the specified functions to be run on Initialize and Terminate
    | of the addon. Generally, you don't want to use these, and should instead
    | use "event.lua" to handle events for the addon, and use the OnInitialize
    | function for addon setup. These are intended for Skeleton framework use.
    =======================================================================--]]
function Addon:AddInitializeAction(action)
    assert(type(action) == "function", "Initialize Action must be a function.")
    table.insert(onInitializeActions, action)
end

function Addon:AddTerminateAction(action)
    assert(type(action) == "function", "Terminate Action must be a function.")
    table.insert(onTerminateActions, action)
end

-- No-Op debug messages. This will be overridden if debug.lua is included,
-- but still exist if it doesn't, so calls to Debug wont' fail.
Addon.Debug = function () end
