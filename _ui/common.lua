local _, Addon = ...
local locale = Addon:GetLocale()
local Colors = Addon.CommonUI.Colors

local PLACEHOLDER_ALPHA_DEFAULT = 0.8
local PLACEHOLDER_INSET = 8

-- Simple helper to determine the color
local function computeColor(frame)
    local color = frame.PlacholderColor or PLACEHOLDER_COLOR_DEFAULT
    local alpha = frame.PlacholderAlpha or PLACEHOLDER_ALPHA_DEFAULT
    return color.r, color.g, color.b, alpha
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
        placeholder:SetTextColor(Colors.PLACEHOLDER_COLOR:GetRGBA())
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
        local loctext = locale:GetString(text)
        if (frame.__placeholder) then
            frame.__placeholder:SetText(loctext or text or "")
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

local Border = {}

--[[ Get a color defined in the XML ]]
local function borderGetColor(border, key, default)
    if (type(border[key]) == "string") then
        return Colors:Get(border[key])
    end

    return Colors:Get(default)
end

-- todo only create the parts we are using
function Border:OnBorderLoaded(parts, borderColor, backColor)
    self.borders = {}

    local border = self:CreateTexture(nil, "BORDER")
    border:SetPoint("TOPLEFT")
    border:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -1)
    border:SetHeight(1)
    self.borderTop = border

    border = self:CreateTexture(nil, "BORDER")
    border:SetPoint("BOTTOMLEFT")
    border:SetPoint("BOTTOMRIGHT")
    border:SetHeight(1)
    self.borderBottom = border

    border = self:CreateTexture(nil, "BORDER")
    border:SetPoint("TOPLEFT")
    border:SetPoint("BOTTOMLEFT")
    border:SetWidth(1)
    self.borderLeft = border

    border = self:CreateTexture(nil, "BORDER")
    border:SetPoint("TOPRIGHT", 0, -1)
    border:SetPoint("BOTTOMRIGHT", 0, 1)
    border:SetWidth(1)
    self.borderRight = border

    border = self:CreateTexture(nil, "BACKGROUND")
    self.background = border

    self:SetBorderParts(parts or "lrtbk")

    -- Set the background color 
    if (not backColor) then
        backColor = borderGetColor(self, "BackgroundColor", "DEFAULT_BACKGROUND")
    end
    self:SetBackgroundColor(backColor)

    -- Set the border
    if (not borderColor) then
        borderColor = borderGetColor(self, "BorderColor", "DEFAULT_BORDER")
    end
    self:SetBorderColor(borderColor)
end

function Border:CreateBorderTexture(horiz)
    local tex = self:CreateTexture(nil, "BORDER")
    if (horiz) then
        tex:SetHeight(1)
    else
        text:SetWidth(1)
    end

    table.insert(self.borders, tex)
end

function Border:SetBorderParts(parts)
    parts = parts or ""
    local background = self.background

    -- top
    if (string.find(parts, "t")) then
        self.borderTop:Show()
        background:SetPoint("TOP", self.borderTop, "BOTTOM")
    else
        self.borderTop:Hide()
        background:SetPoint("TOP")
    end

    -- bottom 
    if (string.find(parts, "b")) then
        self.borderBottom:Show()
        self.background:SetPoint("BOTTOM", self.borderBottom, "TOP")
    else
        self.borderBottom:Hide()
        self.background:SetPoint("BOTTOM")
    end

    -- left
    if (string.find(parts, "l")) then
        self.background:SetPoint("LEFT", self.borderLeft, "RIGHT")
        self.borderLeft:Show()
    else
        self.borderLeft:Hide()
        self.background:SetPoint("LEFT")
    end

    -- right
    if string.find(parts, "r") then
        self.background:SetPoint("RIGHT", self.borderRight, "LEFT")
        self.borderRight:Show()
    else
        self.borderRight:Hide()
        self.background:SetPoint("RIGHT")
    end

    -- background
    if string.find(parts, "k") then
        self.background:Show()
    else
        self.background:Hide()
    end
end

function Border:SetBorderColor(r, g, b, a)
    if (type(r) == "table") then
        g = r.g
        b = r.b
        a = r.a or 1
        r = r.r
    elseif (type(r) == "string") then
        local clr = Colors:Get(r)
        r = clr.r
        b = clr.b
        g = clr.g
        a = clr.a or 1
    end

    self.borderLeft:SetColorTexture(r, g, b, a)
    self.borderRight:SetColorTexture(r, g, b, a)
    self.borderTop:SetColorTexture(r, g, b, a)
    self.borderBottom:SetColorTexture(r, g, b, a)
end

function Border:SetBackgroundColor(r, g, b, a)
    if (type(r) == "table") then
        b = r.b
        g = r.g
        a = r.a or 1
        r = r.r
    elseif (type(r) == "string") then
        local clr = Colors:Get(r)
        r = clr.r
        b = clr.b
        g = clr.g
        a = clr.a or 1
    end

    self.background:SetColorTexture(r, g, b, a)
end


Addon.CommonUI.Mixins.Border = Border;

Addon.CommonUI.Mixins.Debounce = 
{
    --[[
        Adds a function which will be invoked after the specified time has elased, 
        calling it again extends the timer, calling with a nil hanlder or a zero
        time will cancel the timer.
    ]]
    Debounce = function(debounce, time, handler, ...)
        if (debounce.__dtimer) then
            debounce.__dtimer:Cancel()
            debounce.__dtimer = nil
        end

        if (time ~= 0) and handler then
            local args = { ... }
            debounce.__dtimer = C_Timer.After(time, function()
                debounce.__dtimer = nil
                xpcall(handler, CallErrorHandler, debounce, unpack(args))
            end)
        end
    end
}

Addon.CommonUI.Mixins.Tooltip =
{
    InitTooltip = function(self)
        self:SetScript("OnEnter",
            function(frame)
                if (type(frame.OnEnter) == "function") then
                    frame:OnEnter()
                end            
                frame:TooltipEnter()
            end)

        self:SetScript("OnLeave",
            function(frame)
                frame:TooltipLeave()
                if (type(frame.OnLeave) == "function") then
                    frame:OnLeave()
                end
            end)
    end,

    --[[ Called to see if we should show a tooltip ]]
    TooltipEnter = function(self)
        -- Should we show a tooltip?
        local func = self.HasTooltip
        if (type(func) == "function") then
            local success, show = xpcall(self.HasTooltip, CallErrorHandler, self)
            if (not success or not show) then
                return
            end
        end

        local offsetX = 2
        local offsetY = -2

        if (type(self.TooltipOffsetX) == "number") then
            offsetX = self.TooltipOffsetX
        end

        if (type(self.TooltipOffsetY) == "number") then
            offsetY = self.TooltipOffsetY
        end

        -- Invoke the tooltip
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", offsetX, -offsetY)

        func = self.OnTooltip
        if (type(func) == "function") then
            xpcall(self.OnTooltip, CallErrorHandler, self, GameTooltip)
        end

        GameTooltip:Show()
    end,

    --[[ Called to hide the tooltip if we are showing it ]]
    TooltipLeave = function(self)
        if (GameTooltip:GetOwner() == self) then
            GameTooltip:Hide()
        end
    end
}

local HIGHLIGHT_KEY = {}

Addon.CommonUI.Mixins.Highlight =
{
    --[[ Called to initialize the highlight ]]
    InitHighlight = function(self, color)
        if (not color) then
            if (type(self.HighlightColor) == "string") then
                color = Colors:Get(self.HighlightColor, Colors.HOVER_BACKGROUND)
            else
                color = Colors.HOVER_BACKGROUND
            end
        end

        local highlight = self:CreateTexture("BACKGROUND")
        highlight:SetAllPoints(self)
        highlight:SetColorTexture(color:GetRGBA())
        highlight:Hide()
        rawset(self, HIGHLIGHT_KEY, highlight)
    end,

    --[[ Called to update the state of the highlight ]]
    OnUpdate = function(self, ...)
        if (self:IsVisible()) then
            local highlight = rawget(self, HIGHLIGHT_KEY)
            if (self:IsMouseOver()) then
                highlight:Show()
            elseif (highlight:IsVisible()) then
                highlight:Hide()
            end
        end

        if (type(self._OnUpdate) == "function") then
            self:_OnUpdate(...)
        end
    end
}