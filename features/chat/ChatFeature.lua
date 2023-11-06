local AddonName, Addon = ...
local locale = Addon:GetLocale()
local FRAMES_KEY = "feature:chat:frames"
local MessageType = Addon.Systems.Chat.MessageType

--@debug@
local debugp = function (msg, ...) Addon:Debug("chat", "ChatFeature: " .. msg, ...) end
--@debug-end@

local ChatFeature = { 
    NAME = "Chat Output", 
    VERSION = 1, 
    DEPENDENCIES = { "settings" },
    BETA = true,
    DESCRIPTION = [[Controls where the output from vendor goes, allows you to select which messages got to each chat frame]]
}

function ChatFeature:OnInitialize()
    debugp("ChatFeature.OnInitialize()")

    local settings = Addon:GetFeature("Settings")
    settings:RegisterPage(
        "CHAT_SETTING_NAME",
        "CHAT_SETTING_DESCR",
        function(parent)
            local frame = CreateFrame("Frame", nil, parent or UIParent, "Chat_Settings")
            Addon.CommonUI.UI.Attach(frame, Addon.Features.Chat.ChatSettings)
            return frame
        end)
end

function ChatFeature:OnTerminate()
    debugp("ChatFeature.OnTerminate()")

    local settings = Addon:GetFeature("settings")
    settings:UnregisterPage("CHAT_SETTING_NAME")
end

function ChatFeature:GetSettings()
end

--[[ Get thelocalized name of the chat frame ]]
local function getChatName(chatFrame)
    local tab = _G[chatFrame:GetName() .. "Tab"]
    if (tab) then
        return tab:GetText()
    end
    return ""
end

--[[ Get the current options from the profile ]]
function ChatFeature:GetFrameSettings()
    local profile = Addon:GetProfile()
    local options = profile:GetValue(FRAMES_KEY)
    if (not options) then
        options = {}
        options[getChatName(DEFAULT_CHAT_FRAME)] = MessageType.All
        profile:SetValue(FRAMES_KEY, options)
    end

    return options
end

--[[ Update the profile with the new values ]]
function ChatFeature:SetFrameSetting(name, value)
    local profile = Addon:GetProfile()
    local options = self:GetFrameSettings()
    options[name] = value or 0
    profile:SetValue(FRAMES_KEY, options)
end

--[[ Sends a chat message to the chat frames ]]
function ChatFeature:Output(type, message)
    -- Danger - You cannot have debug prints in this method --
    local prefix = string.format(locale.CHAT_MESSAGE_PREFIX_FMT1, AddonName)
    local options = self:GetFrameSettings()

    if (type == MessageType.Console) then
        DEFAULT_CHAT_FRAME:AddMessage(prefix .. message)
        return
    end

    --@debug
    if (type == MessageType.Debug) then
        if (not Addon.IsDebug) then return end;
        prefix = string.format(locale.CHAT_MESSAGEDEBUG_PREFIX_FMT1, AddonName)
    end
    --@end-debug@
    
    ChatFrameUtil.ForEachChatFrame(
        function(frame)
            local name, _, _, _, _, _, shown, _, docked = FCF_GetChatWindowInfo(frame:GetID())
            if (shown or docked) then
                local bits = options[name] or 0
                if (bit.band(bits, type) == type) then
                    frame:AddMessage(prefix .. message)
                end
            end
        end)
end

Addon.Features.Chat = ChatFeature