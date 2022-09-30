local _, Addon = ...
local locale = Addon:GetLocale()

local DIALOG_CAPTION_COLOR = { 1, 1, 1, 1 }
local DIALOG_DIVIDER_COLOR = { 1, 1, 1, 0.5 }
local DIALOG_BUTTON_GAP = 8
local DIALOG_BUTTON_WIDTH = 124
local DIALOG_BUTTON_HEIGHT = 28
local DIALOG_PADDING_X = 14
local DIALOG_PADDING_Y = 14

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
	edgeFile = "Interface\\Glues\\Common\\TextPanel-Border",
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
    local contentWidth = content:GetWidth() + (DIALOG_BUTTON_GAP * 2)
    local contentHeight = content:GetHeight() + (DIALOG_BUTTON_GAP * 2)
    local host = dialog.Host

    content:ClearAllPoints()
    content:SetPoint("TOPLEFT", host, "TOPLEFT", DIALOG_BUTTON_GAP, -DIALOG_BUTTON_GAP)
    content:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -DIALOG_BUTTON_GAP, DIALOG_BUTTON_GAP)
    
    cy = cy + (contentHeight + DIALOG_BUTTON_GAP)
    host:ClearAllPoints()
    host:SetPoint("TOPLEFT", dialog.Titlebar, "BOTTOMLEFT", DIALOG_PADDING_X, -DIALOG_BUTTON_GAP)

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

end

Addon.CommonUI.DialogBox = 
{
    OnLoad = function(dialog)
        dialog.backdropInfo = DIALOG_BACKDROP
        dialog:OnBackdropLoaded()
        dialog.Caption:SetTextColor(unpack(DIALOG_CAPTION_COLOR))
        dialog.Divider:SetColorTexture(unpack(DIALOG_DIVIDER_COLOR))
        dialog:SetBackdropColor(0.4, 0.4, 0.6, 0.8)

        dialog.Host.backdropInfo = DIALOG_CONTENT_BACKDROP
        dialog.Host:OnBackdropLoaded()
        dialog.Host:SetBackdropBorderColor(1, 1, 1, 0.25)
        dialog.Host:SetBackdropColor(0, 0, 0, 0.75)

        local titlebar = dialog.Titlebar
        titlebar.back:SetTexture(DIALOG_BACKDROP.bgFile, true, true)
        titlebar.back:SetVertexColor(0.3, 0.35, 0.3, 1)
    end,

    OnShow = function(dialog)        
        if (dialog.__needsLayout) then 
           layoutDialog(dialog)
        end

        if (dialog.__content) then
            dialog.__content:Show()
        end

        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
    end,

    OnHide = function(dialog)
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);

        if (dialog.__content) then
            dialog.__content:Hide()
        end
    end,

    Toggle = function(dialog)
        if (not dialog:IsShown()) then
            dialog:Show()
        else
            dialog:Hide()
        end
    end,

    SetContent = function(dialog, frame)
        if (frame:GetParent() ~= dialog) then
            frame:SetParent(dialog)
        end

        if (dialog:IsShown()) then
            layoutDialog(dialog)
            frame:Show()
        else
            frame:Hide()
        end

        dialog.__content = frame
        dialog.__needsLayout = true
    end,

    SetCaption = function(dialog, name)
        local addon = locale.ADDON_NAME
        local caption = name
        if (addon) then
            local text = locale[name]
            caption = string.format("%s: %s", addon, text or name)
        else
            local text =locale[name]
            caption = text or name
        end
        dialog.Titlebar.text:SetText(caption)
    end,

    SetButtons = function(dialog, buttons)
        assert(type(buttons) == "table", "expected the buttons to be a table")

        dialog.__buttons = {}
        for key, button in pairs(buttons) do
            print("creating buttons", key, button.label, button.handler)
            local frame = CreateFrame("Button", nil, dialog, "CommandButton")
            frame:SetLabel(button.label)
            if (button.help) then
                frame:SetHelp(button.help)
            end

            if (button.handler) then
                frame:SetScript("OnClick", function(this)
                        if (type(button.handler) == "string") then
                            Addon.Invoke(dialog, button.handler, this)
                        elseif (type(button.handler) == "function") then
                            xpcall(button.handler, CallErrorHandler, this)
                        end
                    end)
            end

            dialog.__buttons[key] = frame
            dialog.__needsLayout = true
        end
    end
}
