local _, Addon = ...
local locale = Addon:GetLocale()

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

local COLORS =
{
    Border = { WHITE.r, WHITE.g, WHITE.b, 0.75 },
    Background = { WHITE.r, WHITE.g, WHITE.b, 0.1 },
    Text = { WHITE.r, WHITE.g, WHITE.b, 0.75 },
    Hover = { WHITE.r, WHITE.g, WHITE.b, .25 },
    HoverText = { WHITE.r, WHITE.g, WHITE.b, 1 },
    Disabled = { GRAY.r, GRAY.g, GRAY.b, 0.5 },
    DisabledBackground = { GRAY.r, GRAY.g, GRAY.b, 0.05 },
}

--[[===========================================================================
  |
  | KeyValues:
  |     Label - the string (or localized key) for the button text
  |     Help - The alpha level to apply (opt)
  |     Handler - The color to apply (opt)
  |===========================================================================]]
Addon.CommonUI.CommandButton =
{
    OnLoad = function(button) 
        button.backdropInfo = BACKDROP
        button:OnBackdropLoaded()
        button:SetBackdropColor(unpack(COLORS.Background))
        button:SetBackdropBorderColor(unpack(COLORS.Border))
        button.Text:SetTextColor(unpack(COLORS.Text))

        button:SetLabel(button.Label)
    end,

    SetLabel = function(button, label)
        if (type(label) == "string") then
            local loc = locale[label]
            button.Text:SetText(loc or label)
        else
            button.Text:SetText("")
        end
        button:SetText(button.Text:GetText())
    end,

    SetHelp = function(button, help) 
        button.Help = help
    end,

    OnEnter = function(button)
        button:SetBackdropColor(unpack(COLORS.Hover))
        button:SetBackdropBorderColor(unpack(COLORS.HoverText))
        button.Text:SetTextColor(unpack(COLORS.HoverText))

        -- If we have a tooltop then show it
        if (type(button.Help) == "string") then
            local tooltip = locale[button.Help]
            GameTooltip:SetOwner(button, "ANCHOR_BOTTOM")
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -4)
            GameTooltip:SetText(toltip or button.Help, unpack(COLORS.HoverText))
            GameTooltip:Show()
        end
    end,

    OnLeave = function(button)
        button:SetBackdropColor(unpack(COLORS.Background))
        button:SetBackdropBorderColor(unpack(COLORS.Border))
        button.Text:SetTextColor(unpack(COLORS.Text))

        -- If we are the owner of the tooltip hide it
        if (GameTooltip:GetOwner() == button) then
            GameTooltip:Hide()
        end
    end,

    OnDisable = function(button)
        button:SetBackdropColor(unpack(COLORS.DisabledBackground))
        button:SetBackdropBorderColor(unpack(COLORS.Disabled))
        button.Text:SetTextColor(unpack(COLORS.Disabled))
    end,

    OnEnable = function(button)
        button:SetBackdropColor(unpack(COLORS.Background))
        button:SetBackdropBorderColor(unpack(COLORS.Border))
        button.Text:SetTextColor(unpack(COLORS.Text))
    end,

    OnClick = function(button)
        if (button.Handler) then
            print("handler:", button.Handler)
            Addon.Invoke(button:GetParent(), button.Handler, button)
        end
    end,
}
