local _, Addon = ...
local locale = Addon:GetLocale()
local DialogBox = {}

local DIALOG_BUTTON_GAP = 8
local DIALOG_BUTTON_WIDTH = 124
local DIALOG_BUTTON_HEIGHT = 28
local DIALOG_PADDING_X = 14
local DIALOG_PADDING_Y = 14
local DIALOG_CONTENT_PADDING_X = 18
local DIALOG_CONTENT_PADDING_Y = 12
local DIALOG_BACK_COLOR = CreateColor(0.4, 0.45, 0.4, 0.8)
local DIALOG_CONTENT_BORDER_COLOR = CreateColor(1, 1, 1, 0.25)
local DIALOG_CAPTION_BACK_COLOR = CreateColor(0.3, 0.35, 0.35, 1)
local DIALOG_CAPTION_COLOR = WHITE_FONT_COLOR

local DIALOG_BACKDROP = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Glues\\Common\\TextPanel-Border",
	tile = true,
	tileEdge = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
};

local DIALOG_CONTENT_BACKDROP = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileEdge = true,
	tileSize = 32,
	edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
};

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
        local buttonsWidth  = 2 * DIALOG_PADDING_X
        for _, button in pairs(dialog.__buttons) do
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

    local coordstart = 0.0625
    local divider = dialog.Titlebar.divider
    local repeatX = max(0, (divider:GetWidth() / 16) * dialog:GetEffectiveScale() - coordstart)
    divider:SetTexCoord(
        0.2578125, repeatX,  0.3671875, repeatX,
        0.2578125, coordstart, 0.3671875, coordstart)
    divider:SetTexture(DIALOG_BACKDROP.edgeFile, true, true)

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
    self.backdropInfo = DIALOG_BACKDROP
    self:OnBackdropLoaded()
    self:SetBackdropColor(DIALOG_BACK_COLOR:GetRGBA())

    local host = self.Host
    host.backdropInfo = DIALOG_CONTENT_BACKDROP
    host:OnBackdropLoaded()
    host:SetBackdropBorderColor(DIALOG_CONTENT_BORDER_COLOR:GetRGBA())

    local titlebar = self.Titlebar
    titlebar.back:SetTexture(DIALOG_BACKDROP.bgFile, true, true)
    titlebar.back:SetVertexColor(DIALOG_CAPTION_BACK_COLOR:GetRGBA())
    titlebar.text:SetTextColor(DIALOG_CAPTION_COLOR:GetRGBA())
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

Addon.CommonUI.DialogBox = DialogBox