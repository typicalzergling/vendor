local _, Addon = ...
local locale = Addon:GetLocale()

local DIALOG_CAPTION_COLOR = { 1, 1, 1, 1 }
local DIALOG_DIVIDER_COLOR = { 1, 1, 1, 0.5 }
local DIALOG_BUTTON_GAP = 10
local DIALOG_BUTTON_WIDTH = 124
local DIALOG_BUTTON_HEIGHT = 28

Addon.CommonUI.DialogBox = 
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
        frame:SetPoint("BOTTOM", 0, 2 * paddingBottom + (dialog.ButtonHeight or DIALOG_BUTTON_HEIGHT))

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
    end,

    SetButtons = function(dialog, buttons)
        print("settings buttons", buttons)
        assert(type(buttons) == "table", "expected the buttons to be a table")

        local last = nil
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

            frame:SetWidth(dialog.ButtonWidth or DIALOG_BUTTON_WIDTH)
            if (not last) then
                frame:SetPoint("BOTTOM", dialog, "BOTTOM", 0, dialog.paddingBottom or 0)
                frame:SetPoint("RIGHT", dialog.Caption)
                frame:SetHeight(dialog.ButtonHeight or DIALOG_BUTTON_HEIGHT)
            else
                frame:SetPoint("TOPRIGHT", last, "TOPLEFT", -DIALOG_BUTTON_GAP, 0)
                frame:SetPoint("BOTTOMRIGHT", last, "BOTTOMLEFT", -DIALOG_BUTTON_GAP, 0)
            end

            last = frame
            dialog["button_" .. key] = frame
        end
    end
}
