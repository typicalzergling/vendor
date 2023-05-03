local _, Addon = ...
local locale = Addon:GetLocale()
local UI = Addon.CommonUI.UI
local Layouts = Addon.CommonUI.Layouts
local PAGE_SPACING = 12

--@debug@
local function debugp(msg, ...) Addon:Debug("chat", msg, ...) end
--@end-debug@

local FrameSetting = {}
local ChatSettings = {}

function FrameSetting:OnLoad()
    for _, toggle in ipairs(self.bits) do
        toggle:RegisterCallback("OnChange",function(_, on)
                local options = Addon.Features.Chat:GetFrameSettings()
                local flags = options[self.name] or 0

                if (on == true) then
                    flags = bit.bor(flags, toggle.bit)
                else
                    flags = bit.band(flags, bit.bnot(toggle.bit))
                end

                Addon.Features.Chat:SetFrameSetting(self.name, flags)
            end, self)
    end
end

function FrameSetting:SetFrame(frame)
    self.name = FCF_GetChatWindowInfo(frame:GetID())
    self.frameName:SetText(locale:FormatString("CHAT_TABNAME_FMT1", self.name))
    self:Update()
end

function FrameSetting:OnShow()
    Addon:RegisterCallback("OnProfileChanged", self, self.Update)
    self:Update()
end

function FrameSetting:OnHide()
    Addon:UnregisterCallback("OnProfileChanged", self, self.Update)
end

function FrameSetting:Update()
    debugp("Update ChageFrame(%s)", self.name)
    local options = Addon.Features.Chat:GetFrameSettings()
    local flags = options[self.name] or 0
    for _, switch in ipairs(self.bits) do
        switch:SetValue(bit.band(flags, switch.bit or 0) == switch.bit)
    end
end

--[[ Load the hidden rule settings page ]]
function ChatSettings:OnLoad()
    self.frames = {}
    self.stack = {}

    self.container = CreateFrame("Frame", nil, self)
    self:SetClipsChildren(true)

    local template = "MinimalScrollBar"
    if ( Addon.Systems.Info.IsClassicEra) then
        template = "WowTrimScrollBar"
    end

    self.markdown = Addon.CommonUI.CreateMarkdownFrames(self.container, locale.CHAT_SETTINGS_HELP)

    self.scrollbar = CreateFrame("EventFrame", nil, self, template)
    self.scrollbar:SetPoint("TOPRIGHT", -2, 0)
    self.scrollbar:SetPoint("BOTTOMRIGHT", -2, 0)
    self.scrollbar:RegisterCallback("OnScroll", function() self:Update() end)
    self:SetScript("OnMouseWheel", function(_, ...) self.scrollbar:OnMouseWheel(...) end)
end

--[[ Called when the page is shown ]]
function ChatSettings:OnShow()
    self.scrollbar:SetScrollPercentage(0)

    for _, frame in pairs(self.frames) do
        frame:Hide()
    end

    self.stack = {}
    ChatFrameUtil.ForEachChatFrame(
        function(chatFrame)
            local frame = self.frames[chatFrame:GetName()]
            if (not frame) then
                frame = CreateFrame("Frame", nil, self.container, "Chat_FrameSetting")
                UI.Attach(frame, FrameSetting)
                self.frames[chatFrame:GetName()] = frame
            end

            local name, _, _, _, _, _, shown, locked, docked, nointer = FCF_GetChatWindowInfo(chatFrame:GetID())

            if (string.len(name) ~= 0 and (shown or docked) and (name ~= COMBAT_LOG)) then
                frame:SetFrame(chatFrame)
                table.insert(self.stack, frame)
                frame:Show()
            end
        end)

    self:OnSizeChanged(self:GetWidth(), self:GetHeight())
end

--[[ Called when the settings are hidden ]]
function ChatSettings:OnHide()
    for _, frame in ipairs(self.stack) do
        frame:Hide()
    end
    
    self.stack = {}
end

function ChatSettings:Update()
    local height = self:GetHeight()
    local percentage = self.scrollbar:GetScrollPercentage()
    local top = ((self.viewHeight or height) - height) * percentage
    self.container:SetPoint("TOPLEFT", 0, top)
end

--[[ Handle our layout ]]
function ChatSettings:OnSizeChanged(width, height)
    local cxScroll = math.max(16, self.scrollbar:GetWidth())
    local viewWidth = width - (cxScroll + 4)

    local panels = {}
    for _, frame in ipairs(self.markdown) do
        table.insert(panels, frame)
    end

    for _, frame in ipairs(self.stack) do
        table.insert(panels, frame)
    end

    local layoutHeight = Layouts.Stack(self.container, panels, 0, PAGE_SPACING, viewWidth)
    debugp("layoutHeight - %s, panelHeight = %s", layoutHeight, height)

    if (layoutHeight > height) then
        self.scrollbar:SetVisibleExtentPercentage(math.max(0, math.min(height / layoutHeight)))
        self.scrollbar:SetScrollAllowed(true)
    else
        self.scrollbar:SetScrollAllowed(false)
    end

    self.viewHeight = layoutHeight
    self.container:SetPoint("TOPLEFT")
    self.container:SetWidth(viewWidth)
end

Addon.Features.Chat.ChatSettings = ChatSettings