local AddonName, Addon = ...
local locale = Addon:GetLocale()

--[[
    Chat System

    This populates information and properties for all systems to use or make available to other
    systems. 
]]

local ChatSystem = { 
    ready = false,

    MessageType = {
        Destroy     =  0x1,
        Merchant    = 0x2,
        Repair      = 0x4,
        List        = 0x8,
        Other       = 0x10,
        Debug       = 0x10000,

        Console     = 0x20000,
        All         = 0xfffff
    }
}

function ChatSystem:Startup(register)
    self.ready = true;
    self.chat = false;

    register({ "Output" })
end

function ChatSystem:OnFeatureEnabled(name, feature)
    if (string.lower(name) == "chat") then
        self.chat = feature
    end
end

function ChatSystem:OnFeatureDisabled(name)
    if (string.lower(name) == "chat") then
        self.chat = nil;
    end
end

function ChatSystem:Shutdown()
    self.ready = false
end

--[[ Sends a chat message to the chat frames ]]
function ChatSystem:Output(mtype, message, ...)
    --!!!! Danger: You cannot have debug prints in this method !!! --

    local args = {...}
    for i, arg in ipairs(args) do
        if type(arg) ~= "string" then
            args[i] = tostring(arg)
        end
    end

    message = tostring(message)
    message = locale:GetString(message) or message

    local success, output = pcall(string.format, message, unpack(args))
    if (not success) then
        --@debug@
        DEFAULT_CHAT_FRAME:AddMessage(RED_FONT_COLOR_CODE .. "Failed to format string:|r \"" .. message .. "\"|r")
        --@end-debug@
        --Addon:LogError(....)
    else
        if (self.ready and (type(self.chat)  == "table")) then
            self.chat:Output(mtype, output)
        else
            self:Print(output)
        end
    end
end

local color = Addon.c_PrintColorCode or ORANGE_FONT_COLOR_CODE
assert(type(color) == "string", "Addon print color code must be a string.")
local printPrefix = string.format("%s[%s%s%s]%s%s%s", HIGHLIGHT_FONT_COLOR_CODE, color, AddonName, HIGHLIGHT_FONT_COLOR_CODE, FONT_COLOR_CODE_CLOSE, FONT_COLOR_CODE_CLOSE, " ")

--[[===========================================================================
    | Print
    | Most basic output to the user, used by most modules for user feedback.
    | Constants can define the color. Prints to DEFAULT_CHAT_FRAME.
    =======================================================================--]]
function ChatSystem:Print(msg)
    if (self.ready) then
        DEFAULT_CHAT_FRAME:AddMessage(printPrefix .. msg)
    end
end
    
Addon.Systems.Chat = ChatSystem