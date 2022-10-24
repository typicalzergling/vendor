local _, Addon = ...
local locale = Addon:GetLocale()
local DialogBox = Mixin({}, Addon.CommonUI.Mixins.Border)
local Colors = Addon.CommonUI.Colors

local DIALOG_BUTTON_GAP = 8
local DIALOG_BUTTON_WIDTH = 124
local DIALOG_BUTTON_HEIGHT = 28
local DIALOG_PADDING_X = 14
local DIALOG_PADDING_Y = 14
local DIALOG_CONTENT_PADDING_X = 18
local DIALOG_CONTENT_PADDING_Y = 12

local function layoutButtons(dialog)
    -- Position the buttons if needed
    if (dialog.__buttons) then
        local last = nil
        local buttonsWidth  = 0

        for _, button in pairs(dialog.__buttons) do
            if (button:IsShown()) then
                if (buttonsWidth == 0) then
                    buttonsWidth = 2 * DIALOG_PADDING_X
                end

                button:ClearAllPoints()

                button:SetHeight(DIALOG_BUTTON_HEIGHT)
                button:SetWidth(DIALOG_BUTTON_WIDTH)
                if (not last) then
                    button:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", -DIALOG_PADDING_X, DIALOG_PADDING_Y)
                else
                    button:SetPoint("BOTTOMRIGHT", last, "BOTTOMLEFT", -DIALOG_BUTTON_GAP, 0)
                    buttonsWidth = buttonsWidth + DIALOG_BUTTON_GAP
                end

                last = button
                buttonsWidth = buttonsWidth + DIALOG_BUTTON_WIDTH
            end
        end

        return buttonsWidth, last
    end

    return 0
end

local function layoutDialog(dialog)
    local cy = (DIALOG_PADDING_Y * 2) + dialog.Titlebar:GetHeight()
    local cx = (DIALOG_PADDING_X * 2)

    -- Position the main content
    local content = dialog.__content
    local contentWidth = content:GetWidth() + (DIALOG_CONTENT_PADDING_X * 2)
    local contentHeight = content:GetHeight() + (DIALOG_CONTENT_PADDING_Y * 2)
    local host = dialog.Host

    content:ClearAllPoints()
    content:SetPoint("TOPLEFT", host, "TOPLEFT", DIALOG_CONTENT_PADDING_X, -DIALOG_CONTENT_PADDING_Y)
    content:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -DIALOG_CONTENT_PADDING_X, DIALOG_CONTENT_PADDING_Y)
    
    cy = cy + (contentHeight + DIALOG_BUTTON_GAP + 4)
    host:ClearAllPoints()
    host:SetPoint("LEFT", DIALOG_PADDING_X, 0)
    host:SetPoint("TOP", dialog.Titlebar, "BOTTOM", 0, -(DIALOG_BUTTON_GAP + 4))

    -- Position the buttons if needed
    if (dialog.__buttons) then
        local last = nil
        local buttonsWidth, last  = layoutButtons(dialog)

        cy = cy + DIALOG_BUTTON_HEIGHT + DIALOG_PADDING_Y
        host:SetPoint("BOTTOM", last, "TOP", 0, DIALOG_BUTTON_GAP)
        host:SetPoint("RIGHT", dialog, "RIGHT", -DIALOG_PADDING_X, 0)
        if (buttonsWidth > contentWidth) then
            cx = cx + buttonsWidth
        else
            cx = cx + contentWidth
        end
    else
        host:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", -DIALOG_PADDING_X, DIALOG_PADDING_Y)
        cx = cx + contentWidth
    end

    -- Size the dialog
    dialog:SetWidth(cx)
    dialog:SetHeight(cy)

    dialog.__needsLayout = nil
end

local function layout(dialog)
    if (dialog:IsShown()) then
        layoutDialog(dialog)
    else
        dialog.__needsLayout = true
    end
end

function DialogBox:OnLoad()
    self:OnBorderLoaded(nil, Colors.DIALOG_BORDER_COLOR, Colors.DIALOG_BACK_COLOR)

    -- Setup our host
    local host = self.Host
    Mixin(host, Addon.CommonUI.Mixins.Border)
    host:OnBorderLoaded()
    print("--> setting content")
    host:SetBackgroundColor(Colors.DIALOG_CONTENT_BACKGROUND_COLOR)
    host:SetBorderColor(Colors.DIALOG_CONTENT_BORDER_COLOR)

    -- Setup te title bar
    local titlebar = self.Titlebar
    titlebar.back:SetColorTexture(Colors.DIALOG_CAPTION_BACK_COLOR:GetRGBA())
    titlebar.text:SetTextColor(Colors.DIALOG_CAPTION_COLOR:GetRGBA())
    titlebar.divider:SetColorTexture(Colors.DIALOG_BORDER_COLOR:GetRGBA())

    -- Setup our closed button
    local close = titlebar.close
    close.text:SetTextColor(Colors.BUTTON_TEXT:GetRGBA())
    Mixin(close, Addon.CommonUI.Mixins.Border)
    close:OnBorderLoaded(nil, Colors.TRANSPARENT, Colors.TRANSPARENT)
    close:SetScript("OnClick", function(close)
            self:Hide()
        end)
    close:SetScript("OnEnter", function(frame)
            frame.text:SetTextColor(Colors.BUTTON_HOVER_TEXT:GetRGBA())
            frame:SetBackgroundColor(Colors.BUTTON_HOVER_BACK)
            frame:SetBorderColor(Colors.BUTTON_HOVER_BORDER)
        end)
    titlebar.close:SetScript("OnLeave", function(frame)
            frame:SetBackgroundColor(Colors.TRANSPARENT)
            frame:SetBorderColor(Colors.TRANSPARENT)
        end)

    self:SetClampedToScreen(true)
    self:RegisterForDrag("LeftButton")
end

function DialogBox:OnShow()
    if (self.__needsLayout) then 
        layoutDialog(self)
    end

    if (self.__content) then
        self.__content:Show()
    end

    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function DialogBox:OnHide()
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);

    if (self.__content) then
        self.__content:Hide()
    end
end

function DialogBox:OnDragStart()
    self:StartMoving()
end

function DialogBox:OnDragStop()
    self:StopMovingOrSizing()
end

function DialogBox:Toggle()
    if (not self:IsShown()) then
        self:Show()
    else
        self:Hide()
    end
end

function DialogBox:SetContent(frame)
    if (frame:GetParent() ~= self) then
        frame:SetParent(self)
    end

    if (self:IsShown()) then
        frame:Show()
    else
        frame:Hide()
    end

    self.__content = frame
    layout(self)
end

function DialogBox:SetCaption(name)
    local addon = locale.ADDON_NAME
    local caption = name
    if (addon) then
        local text = locale[name]
        caption = string.format("%s: %s", addon, text or name)
    else
        local text =locale[name]
        caption = text or name
    end
    self.Titlebar.text:SetText(caption)
end

function DialogBox:SetButtons(buttons)
    assert(type(buttons) == "table", "expected the buttons to be a table")

    self.__buttons = {}
    for key, button in pairs(buttons) do
        print("creating buttons", key, button.label, button.handler)
        local frame = CreateFrame("Button", nil, self, "CommandButton")
        frame:SetLabel(button.label)
        if (button.help) then
            frame:SetHelp(button.help)
        end

        if (button.handler) then
            frame:SetScript("OnClick", function(this)
                    if (type(button.handler) == "string") then
                        Addon.Invoke(self, button.handler, this)
                    elseif (type(button.handler) == "function") then
                        xpcall(button.handler, CallErrorHandler, this)
                    end
                end)
        end

        self.__buttons[key] = frame
        layout(self)
    end
end

-- Sets the enabled/disabled state of the button
function DialogBox:SetButtonEnabled(id, enabled)
    if (self.__buttons) then
        local button = self.__buttons[id]
        if (button) then
            if (enabled) then
                button:Enable()
            else
                button:Disable()
            end
        end
    end
end

-- Show or hide the dialog button
function DialogBox:SetButtonVisiblity(id, show)
    if (self.__buttons) then
        local button = self.__buttons[id]
        if (button) then
            if (not button:IsShown() and show) then
                button:Show()
                layout(self)
            elseif (button:IsShown() and not show) then
                button:Hide()
                layout(self)
            end
        end
    end
end

--[[
    Set the state of all the buttons at once, if the button is prensent in the 
    array then this will disable/hide the button
]]
function DialogBox:SetButtonState(buttons)
    assert(type(buttons) == "table", "Expected the button state to be a table")
    if self.__buttons then
        for id, button in pairs(self.__buttons) do
            local state = buttons[id]
            if (not state) then
                button:Hide()
                button:Disable()
            elseif (type(state) == "boolean" and state == true) then
                button:Show()
                button:Enable()
            elseif (type(state) == "table") then
                table.forEach(state, print)
                if (state.enabled == true) then
                    button:Enable()
                else
                    button:Disable()
                end

                if (state.show == true) then
                    button:Show()
                else
                    button:Hide()
                end
            end
        end
    end

    layoutButtons(self)
end

Addon.CommonUI.DialogBox = DialogBox