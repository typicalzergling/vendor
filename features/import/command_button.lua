local _, Addon = ...
local locale = Addon:GetLocale();
Addon.Controls = Addon.Controls or {}
local CommonUI = Addon.CommonUI

local WHITE = WHITE_FONT_COLOR
local GRAY = GRAY_FONT_COLOR

local BACKDROP = 
{
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Glues\\Common\\TextPanel-Border",
    tile = true,
    tileEdge = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },    
}


local DIALOG_CAPTION_COLOR = { 1, 1, 1, 1 }
local DIALOG_DIVIDER_COLOR = { 1, 1, 1, 0.5 }

Addon.Controls.DialogBox = 
{
    OnLoad = function(dialog)
        dialog.backdropInfo = BACKDROP_DIALOG_32_32
        dialog:OnBackdropLoaded()
        dialog.Caption:SetTextColor(unpack(DIALOG_CAPTION_COLOR))
        dialog.Divider:SetColorTexture(unpack(DIALOG_DIVIDER_COLOR))
    end,

    OnShow = function(dialog)
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
        if (dialog.content) then
            dialog.content:Show()
        end
    end,

    OnHide = function(dialog)
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
        if (dialog.content) then
            dialog.content:Hide()
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
        local paddingTop = dialog.paddingTop or 0
        local paddingBottom = dialog.paddingBottom or 0
        local width = frame:GetWidth()
        local height = frame:GetHeight()

        dialog:SetWidth(width + dialog:GetWidth())
        dialog:SetHeight(height + dialog:GetHeight())

        if (frame:GetParent() ~= dialog) then
            frame:SetParent(dialog)
        end

        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", dialog.Caption, "BOTTOMLEFT", 0, -paddingTop)
        frame:SetPoint("TOPRIGHT", dialog.Caption, "BOTTOMRIGHT", 0, -paddingTop)
        frame:SetPoint("BOTTOM", 0, paddingBottom)

        if (dialog:IsShown()) then
            frame:Show()
        else
            frame:Hide()
        end

        dialog.content = frame
    end,

    SetCaption = function(dialog, name)
        local addon = locale.ADDON_NAME
        if (addon) then
            local text = locale[name]
            dialog.Caption:SetFormattedText("%s: %s", addon, text or name)
        else
            local text =locale[name]
            dialog.Caption:SetText(text or name)
        end
    end
}

local TEXTAREA_BORDER = { 1, 1, 1, .5 }
local TEXTAREA_BACK = { 1, 1, 1, .08 }
local TEXTAREA_HOVER = { 1, 1, 1, .75 }

Addon.Controls.TextArea = 
{
    OnLoad = function(textarea) 
        textarea.backdropInfo = BACKDROP
        if (textarea.backdropInfo) then
            textarea:OnBackdropLoaded()
            textarea:SetBackdropBorderColor(unpack(TEXTAREA_BORDER))
            textarea:SetBackdropColor(unpack(TEXTAREA_BACK))
        end

        Mixin(textarea, CommonUI.Mixins.Placeholder, CommonUI.Mixins.ScrollView)
        textarea:InitializePlaceholder()
        textarea:InitializeScrollView(textarea.Scroller)

        local edit = textarea.Scroller:GetScrollChild()
        edit:SetScript("OnEditFocusGained", function()
                textarea:ShowPlaceholder(false)
            end)

        edit:SetScript("OnEditFocusLost", function()
                textarea:ShowPlaceholder(not textarea:HasText())
            end)

        edit:SetScript("OnTextChanged", function()
                ScrollingEdit_OnTextChanged(edit, edit:GetParent())
                if (textarea.__timer) then
                    textarea.__timer:Cancel()
                end

                textarea.__timer = C_Timer.NewTimer(0.25, function() 
                        textarea.__timer = nil
                        if (textarea.Handler) then
                            Addon.Invoke(textarea:GetParent(), textarea.Handler, edit:GetText())
                        end
                    end)
            end)

        ScrollFrame_OnLoad(textarea.Scroller)
    end,

    HasText = function(textarea)
        local text = textarea.Scroller:GetScrollChild():GetText()
        return (type(text) == "string") and (string.len(text) ~= 0)
    end,

    OnMouseDown = function(textarea)
        textarea.Scroller:GetScrollChild():SetFocus()
    end,
}