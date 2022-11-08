local _, Addon = ...
local locale = Addon:GetLocale()
local DialogBox = Mixin({}, Addon.CommonUI.Mixins.Border)
local Colors = Addon.CommonUI.Colors
local AddonColors = Addon.Colors or  {}
local UI = Addon.CommonUI.UI

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
    self:OnBorderLoaded()

    -- Setup our host
    local host = self.Host
    Mixin(host, Addon.CommonUI.Mixins.Border)
    host:OnBorderLoaded()

    -- Setup te title bar
    UI.Attach(self.Titlebar.close, Addon.CommonUI.CloseButton)
    UI.Prepare(self.Titlebar)

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
    self:SetScript("OnKeyUp", function(_, key)
            if (key == "ESCAPE") then
                self:Hide()
                self:SetPropagateKeyboardInput(false)
                return
            end
            
            self:SetPropagateKeyboardInput(true)
        end)
end

function DialogBox:OnHide()
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
    self:SetScript("OnKeyUp", nil)

    if (self.__content) then
        self.__content:Hide()
    end
end

--[[ Handle drag start ]]
function DialogBox:OnDragStart()
    self:StartMoving()
end

--[[ Handle drag stop ]]
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

    self.Colorize(frame)

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
    local caption = locale:GetString(name) or name

    if (addon and addon ~= caption) then
        caption = string.format("%s: %s", addon, caption)
    end
    
    self.Titlebar.text:SetText(caption)
end

function DialogBox:SetButtons(buttons)
    assert(type(buttons) == "table", "expected the buttons to be a table")

    self.__buttons = {}
    for key, button in pairs(buttons) do
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

--[[ Handle processing a particular item for loc + colors ]]
local function _process(item, getColor, getLocText)
    local color = item.Color
    if (type(color) == "string") then
        color = getColor(color)
        if (type(item.SetTextColor) == "function") then
            item:SetTextColor(color:GetRGBA())
        end

        if (type(item.SetColorTexture) == "function") then
            item:SetColorTexture(color:GetRGBA())
        end
    end

    local loc = item.LocKey or item.LocText
    if (type(loc) == "string") then
        loc = getLocText(loc)
        if (type(item.SetText) == "function") then
            item:SetText(loc)
        end
    end
end

local function _visit(frame, getColor, getLocText)
    for _, child in pairs({ frame:GetChildren() }) do
        _process(child, getColor, getLocText)
        _visit(child, getColor, getLocText)
    end

    -- Handle regions
    for _, region in ipairs({ frame:GetRegions() }) do
        _process(region, getColor, getLocText)
    end
end

local function _getLocalizedString(key)
    local text = locale:GetString(key)
    return text or ("[|cffff0000ERRR:" .. string.upper(key) .. "|r]")
end

--[[ Handle looking up a color ]]
local function _getColor(name)
    name = string.upper(name)

    -- Addon can override common colors
    local clr = AddonColors[name]
    if (type(clr) == "table") then
        return clr
    end

    clr = Colors[name]
    if (type(clr) == "table") then
        return clr
    end

    return RED_FONT_COLOR
end

--[[
    Given a frame this will traverse all of the frames and apply text/vertex
    color to each region

    This uses CommonUI.Colors and  Addon.Colors
]]
function DialogBox.Colorize(frame)
    _visit(frame, _getColor, _getLocalizedString)
end

Addon.CommonUI.DialogBox = DialogBox