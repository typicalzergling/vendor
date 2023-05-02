local AddonName, Addon = ...
local locale = Addon:GetLocale()
local debugp = function (...) Addon:Debug("chat", ...) end

local ChatFeature = { 
    NAME = "Chat Output", 
    VERSION = 1, 
    DEPENDENCIES = { "Rules" },
    BETA = true,
    DESCRIPTION = [[Controls where the output from vendor goes, allows you to select which messages got to each chat frame]]
}

ChatFeature.MessageType = {
    Destroy =  0x1,
    Merchant = 0x2,
    Repair = 0x4,
    List = 0x8,
    Other = 0x10,
    All = 0xff
}

function ChatFeature:OnInitialize()
    debugp("ChatFeature.OnInitialize()")
end

function ChatFeature:OnTerminate()
    debugp("ChatFeature.OnTerminate()")
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

--[[ Checks if the frame is visible/enabled ]]
local function isFrameActive(chatFrame)
    local tab = _G[chatFrame:GetName() .. "Tab"]
    if (tab) then
        return tab:IsShown()
    end
    return false
end


--[[ Get the current options from the profile ]]
local function getChatOptions()
    local profile = Addon:GetProfile()
    local options = profile:GetValue("chatFeature")
    if (not options) then
        options = {}
        options[getChatName(DEFAULT_CHAT_FRAME)] = ChatFeature.MessageType.All
    end

    return options
end

local CHAT_PREFIX = string.format("%s[%s%s%s]%s%s%s", HIGHLIGHT_FONT_COLOR_CODE, ORANGE_FONT_COLOR_CODE, AddonName, HIGHLIGHT_FONT_COLOR_CODE, FONT_COLOR_CODE_CLOSE, FONT_COLOR_CODE_CLOSE, " ")

--[[ Sends a chat message to the chat frames ]]
function ChatFeature:Output(type, message, ...)
    local args = {}
    for _, arg in ipairs({...}) do
        table.insert(args, tostring(arg))
    end

    message = string.format(locale:GetString(message) or message, unpack(args))
    local options = getChatOptions()
    
    ChatFrameUtil.ForEachChatFrame(
        function(frame)
            if (isFrameActive(frame)) then
                local name = getChatName(frame)
                local bits = options[name] or 0

                if (bit.band(bits, type) == type) then
                    debugp("Sending chat message to '%s' (%s)", name, type)
                    frame:AddMessage(CHAT_PREFIX .. message)
                end
            end
        end)
end

Addon.Features.Chat = ChatFeature