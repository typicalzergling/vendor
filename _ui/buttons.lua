local _, Addon = ...
local locale = Addon:GetLocale()
local Colors = Addon.CommonUI.Colors
local CommandButton = Mixin({}, Addon.CommonUI.Mixins.Border)
local UI = Addon.CommonUI.UI

--[[===========================================================================
  |
  | KeyValues:
  |     Label - the string (or localized key) for the button text
  |     Help - The alpha level to apply (opt)
  |     Handler - The color to apply (opt)
  |===========================================================================]]

function CommandButton:OnLoad()
    self:OnBorderLoaded(nil, Colors.BUTTON_BORDER, Colors.BUTTON_BACK)
    self.text:SetTextColor(Colors.BUTTON_TEXT:GetRGBA())
    self:SetLabel(self.Label)
end

function CommandButton:SetLabel(label)
    local loc = locale:GetString(label) or label
    if (type(loc) == "string") then
        self.text:SetText(loc)
        self.text:SetTextColor(Colors.BUTTON_TEXT:GetRGBA())
    else
        -- Debug else case
        self.text:SetText("<error>")
        self.text:SetTextColor(1, 0, 0)
    end

    self:SetText(self.text:GetText())
end

function CommandButton:SetHelp(help)
    self.Help = help
end

function CommandButton:OnEnter()
    self:SetBorderColor(Colors.BUTTON_HOVER_BORDER)
    self:SetBackgroundColor(Colors.BUTTON_HOVER_BACK)
    self.text:SetTextColor(Colors.BUTTON_HOVER_TEXT:GetRGBA())

    -- If we have a tooltop then show it
    if (type(self.Help) == "string") then
        local tooltip = locale[button.Help] or self.Help
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -4)
        GameTooltip:SetText(tooltip, Colors.BUTTON_TEXT:GetRGBA())
        GameTooltip:Show()
    end
end

function CommandButton:OnLeave()
    self:SetBackgroundColor(Colors.BUTTON_BACK)
    self:SetBorderColor(Colors.BUTTON_BORDER)
    self.text:SetTextColor(Colors.BUTTON_TEXT:GetRGBA())

    -- If we are the owner of the tooltip hide it
    if (GameTooltip:GetOwner() == self) then
        GameTooltip:Hide()
    end
end

function CommandButton:OnDisable()
    self:SetBackgroundColor(Colors.BUTTON_DISABLED_BACK)
    self:SetBorderColor(Colors.BUTTON_DISABLED_BORDER)
    self.text:SetTextColor(Colors.BUTTON_DISABLED_TEXT:GetRGBA())
end

function CommandButton:OnEnable()
    self:SetBackgroundColor(Colors.BUTTON_BACK)
    self:SetBorderColor(Colors.BUTTON_BORDER)
    self.text:SetTextColor(Colors.BUTTON_TEXT:GetRGBA())
end

function CommandButton:OnClick()
    if (self.Handler) then
        Addon.Invoke(self:GetParent(), self.Handler, self)
    end
end

Addon.CommonUI.CommandButton = CommandButton

--[[ IconButton =============================================================]]
local IconButton = Mixin({}, Addon.CommonUI.Mixins.Border, Addon.CommonUI.Mixins.Tooltip)

-- Call to load the icon button
function IconButton:OnLoad()
    self:OnBorderLoaded(nil, Colors.TRANSPARENT, Colors.TRANSPARENT)
    if (type(self.Icon) == "string") then
        self.icon:SetTexture(self.Icon)
    end
    self.icon:SetAlpha(.6)
end

function IconButton:OnEnter()
    self:SetBackgroundColor(Colors:Get("BUTTON_HOVER_BACK"))
    self:SetBorderColor(Colors:Get("BUTTON_HOVER_BORDER"))
    self.icon:SetAlpha(1)
    self:TooltipEnter()
end

function IconButton:OnLeave()
    self:TooltipLeave()
    self:SetBackgroundColor(Colors.TRANSPARENT)
    self:SetBorderColor(Colors.TRANSPARENT)
    self.icon:SetAlpha(.6)
end

function IconButton:OnEnable()
    if (not self:IsMouseOver()) then
        self.icon:SetAlpha(.6)
    else
        self.icon:SetAlpha(1)
    end
end

function IconButton:OnDisable()
    self.icon:SetAlpha(.25)
end

function IconButton:OnClick()
    CommandButton.OnClick(self)
end

function IconButton:HasTooltip()
    return type(self.Help) == "string"
end

function IconButton:OnTooltip(tooltip)
    local help = locale:GetString(self.Help) or self.Help
    tooltip:SetText(help)
end

Addon.CommonUI.IconButton = IconButton


--[[=========================================================================]]

local Layouts = {}
Addon.CommonUI.Layouts = Layouts

function Layouts.Flow(frame, marginX, marginY)
    local width = frame:GetWidth()
    marginX = tonumber(marginX) or 0
    marginY = tonumber(marginY) or 0

    local height = 0
    local left = 0
    local top = 0
    local row = 0

    for i, child in ipairs({ frame:GetChildren() }) do
        local cx = child:GetWidth()
        local cy = child:GetHeight()

        if (i ~= 1 and cx > (width - left)) then
            -- new row
            top = top + row + marginY
            row = cy

            child:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -top)
            left = cx + marginX
        else
            child:SetPoint("TOPLEFT", frame, "TOPLEFT", left, -top)

            left = left + cx + marginX
            if (cy > row) then
                row = cy
            end
        end

        if (cx > width and width ~= 0) then
            child:SetWidth(width)
        end
    end

    if (row ~= 0) then
        height = top + row
    end

    frame:SetHeight(height)
end

local function numberOrZero(value)
    if (type(value) == "number") then
        return value
    end
    return 0
end

local function getPadding(padding)
    if (type(padding) == "number") then
        return padding, padding, padding, padding
    elseif (type(padding) == "table") then
        return numberOrZero(padding.left), numberOrZero(padding.top), 
                numberOrZero(padding.right), numberOrZero(padding.bottom)
    end

    return 0, 0, 0, 0
end

function Layouts.Stack(panel, children, padding, spacing, panelWidth)
    local space = 0
    local width = panelWidth or panel:GetWidth()
    children = children or {}

    local paddingLeft, paddingTop, paddingRight, paddingBottom = getPadding(padding)
    if (type(spacing) == "number") then
        space = spacing
    end
    
    local height = paddingTop
    width = width - (paddingLeft + paddingRight)
    local num = table.getn(children)

    Addon:Debug("layouts", "Stack + num=%s, width=%s, spacing=%s, padding=[%s, %s, %s, %s]", num, width, spacing, paddingLeft, paddingTop, paddingRight, paddingBottom)

    for i, child in ipairs(children) do
        if (child:IsShown()) then
            local objectType = child:GetObjectType()
            local ml, mt, mr, mb = getPadding(child.margins or child.Margins)
            Addon:Debug("layouts", "Stack | child margins=[%s, %s, %s, %s]", ml, mt, mr, mb)

            height = height
            if (i ~= 1) then
                height = height + mt
            end

            if (objectType ~= "Line") then
                child:ClearAllPoints()
                if (child.Align == "far") then
                    child:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -(mr + paddingRight), -height)
                elseif (child.Align == "near") then
                    child:SetPoint("TOPLEFT", panel, "TOPLEFT", ml + paddingLeft, -height)
                else
                    child:SetWidth(width - (mr + ml))
                    child:SetPoint("TOPLEFT", panel, "TOPLEFT", ml + paddingLeft, -height)
                end
            else
                child:SetStartPoint("TOPLEFT", panel, "TOPLEFT", 0, -height)
                child:SetEndPoint("TOPRIGHT", panel, "TOPRIGHT", 0, -height)
            end

            if (objectType == "FontString") then
                child:SetHeight(0)
            elseif (objectType ~= "Texture" and objectType ~= "Line") then
                -- If the child has a layout handler then invoke it
                if (type(child.Layout) == "function") then
                    xpcall(child.Layout, CallErrorHandler, child, width - (mr + ml))
                end
            end
            
             height = height + child:GetHeight() + space
             if (i ~= num) then
                height = height + mb
             end

             Addon:Debug("layouts", "Stack | %s = %s x %s [%s]", i, child:GetWidth(), child:GetHeight(), height)
        end
    end

    height = height + paddingBottom
    Addon:Debug("layouts", "Stack + final height=%s", height)
    panel:SetHeight(height)
    return height
end