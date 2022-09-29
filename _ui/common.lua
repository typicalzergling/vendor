local _, Addon = ...
local locale = Addon:GetLocale()
Addon.CommonUI = { Mixins = {} }

local PLACEHOLDER_COLOR_DEFAULT = WHITE_FONT_COLOR
local PLACEHOLDER_ALPHA_DEFAULT = 0.8
local PLACEHOLDER_INSET = 8

-- Simple helper to determine the color
local function computeColor(frame)
    local color = frame.PlacholderColor or PLACEHOLDER_COLOR_DEFAULT
    local alpha = frame.PlacholderAlpha or PLACEHOLDER_ALPHA_DEFAULT
    return color.r, color.g, color.b, alpah
end

--[[===========================================================================
  | Implements a mixin which provides placehodler support, which is ghosted 
  | text on the background.  
  |
  | The "owner" is responsible for calling ShowPlaceholder to toggle 
  \ visibility when appropriate
  |
  | KeyValues:
  |     Placeholder- the string (or localized key) for the text
  |     PlaceholerAlpha - The alpha level to apply (opt)
  |     PlacholderColor - The color to apply (opt)
  |===========================================================================]]
Addon.CommonUI.Mixins.Placeholder = {
    --[[
        Initialize a placeholder
    ]]
    InitializePlaceholder = function(frame)
        local placeholder = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormalSmall")
        placeholder:SetPoint("TOPLEFT", PLACEHOLDER_INSET, -PLACEHOLDER_INSET)
        placeholder:SetPoint("BOTTOMRIGHT", -PLACEHOLDER_INSET, PLACEHOLDER_INSET)
        placeholder:SetDrawLayer("BACKGROUND", 10)
        placeholder:SetTextColor(computeColor(frame))
        frame.__placeholder = placeholder
        frame:SetPlaceholder(frame.Placeholder)
    end,

    --[[
        Shows/Hides the placeholder depending on the state
    ]]
    ShowPlaceholder = function(frame, state)
        if (state ~= frame.__placeholderState) then
            frame.__placeholderState = state
            if (frame.__placeholder) then
                if (state) then
                    frame.__placeholder:Show()
                else
                    frame.__placeholder:Hide()
                end
            end
        end
    end,

    --[[
        Changes the placeholder text
    ]]
    SetPlaceholder = function(frame, text)
        local loctext = locale[text]
        if (frame.__placeholder) then
            frame.__placeholder:SetText(loctext or text)
        end
    end
}

--[[===========================================================================
  | Shared code for handling moving the scrollbar in various views. This moves
  | the bar into the view rather than next to it to make layout easier.
  |
  \   +----------------+
  |   |CCCCCCCCCCCCC SB|
  |   +----------------+
  |
  \   +----------------+
  |   |CCCCCCCCCCCCCCCC|
  |   +----------------+
  |   
  |===========================================================================]]
Addon.CommonUI.Mixins.ScrollView = {

    --[[
        Handle initializing the scrollbar, creating the background and moving it into
        the control.
    ]]
    InitializeScrollView = function(frame, scroller, offset)
        local scrollbar = scroller.ScrollBar
        print("scrollbar:", scrollbar)
        if (scrollbar) then
            local offset = (offset or 5)
            local up = scrollbar.ScrollUpButton
            local down = scrollbar.ScrollDownButton
            local target = scroller:GetScrollChild()

            up:ClearAllPoints()
            up:SetPoint("TOPRIGHT", scroller, "TOPRIGHT")
            
            down:ClearAllPoints()
            down:SetPoint("BOTTOMRIGHT", scroller, "BOTTOMRIGHT")


            -- Move the scrollbar and it's parts
            scrollbar:ClearAllPoints()
            scrollbar:SetPoint("TOPLEFT", up, "BOTTOMLEFT", 0, -2)
            scrollbar:SetPoint("BOTTOMRIGHT", down, "TOPRIGHT", 0, 2)

            -- Add a background
            local bg = scrollbar:CreateTexture(nil, "BACKGROUND", nil, 1)
            bg:SetColorTexture(0, 0, 0, 0.5)
            bg:SetAllPoints(scrollbar)
            bg:Show()

            target:ClearAllPoints()
            target:SetPoint("TOPLEFT", scroller)

            -- If the scrollbar is being hiddem we can have whole space.
            scrollbar:SetScript("OnHide", function(this)
                    target:SetWidth(scroller:GetWidth() - 1)
                end)

            -- If the scrollbar is showing we need to subtract it's width.
            scrollbar:SetScript("OnShow", function(this)
                    target:SetWidth(scroller:GetWidth() - (1 + offset + scrollbar:GetWidth()))
                end)

            scroller.scrollBarHideable = 1
        end
    end
}
