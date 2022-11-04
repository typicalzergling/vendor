local _, Addon = ...
local locale = Addon:GetLocale()
local Colors = Addon.CommonUI.Colors
local CommandButton = Mixin({}, Addon.CommonUI.Mixins.Border)

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

--][[========================================================================]]

local Chip = Mixin({}, Addon.CommonUI.Mixins.Border)

--[[ Sets the color of the chop ]]
local function _setChipColors(chip, state)
    local text = chip.text

    if (not chip:IsEnabled()) then    
        chip:SetBackgroundColor(Colors.BUTTON_DISABLED_BACK)
        chip:SetBorderColor(Colors.BUTTON_DISABLED_BORDER)
        text:SetTextColor(Colors.BUTTON_DISABLED_TEXT:GetRGBA())
    elseif (chip:GetChecked() or state == "checked") then
        chip:SetBackgroundColor(Colors.BUTTON_CHECKED_BACK)
        chip:SetBorderColor(Colors.BUTTON_CHECKED_BORDER)
        text:SetTextColor(Colors.BUTTON_CHECKED_TEXT:GetRGBA())
    elseif (chip:IsMouseOver()) then
        chip:SetBorderColor(Colors.BUTTON_HOVER_BORDER)
        chip:SetBackgroundColor(Colors.BUTTON_HOVER_BACK)
        text:SetTextColor(Colors.BUTTON_HOVER_TEXT:GetRGBA())        
    else
        chip:SetBackgroundColor(Colors.BUTTON_BACK)
        chip:SetBorderColor(Colors.BUTTON_BORDER)
        text:SetTextColor(Colors.BUTTON_TEXT:GetRGBA())
    end
end


--[[ Sets the text of the chip ]]
local function _setChipText(chip, text)
    local text = locale:GetString(text) or text or "<error>"
    chip:SetText(text)

    chip.text:SetText(text)
    chip.text:SetWidth(0)
    chip:SetWidth(16 + chip.text:GetWidth())
    print("--> chip", chip:GetWidth(), text)
end

--[[ Load the chip ]]
function Chip:OnLoad()
    self:OnBorderLoaded()
    _setChipColors(self, "normal")

    if (type(self.Label) == "string") then
        _setChipText(self, self.Label)
    end

    if (type(self.Tooltip) == "string") then
        self:SetHelp(help)
    end

    self:SetScript("OnEnable", _setChipColors)
    self:SetScript("OnDisable", _setChipColors)
    self:SetScript("OnShow", _setChipColors)
    self:SetChecked(false)
end

--[[ Sets the label for this chip ]]
function Chip:SetLabel(label)
    _setChipText(self, label)
end

--[[ Set the tooltip for the chip ]]
function Chip:SetHelp(help)
    if (help) then
        self.help = locale:GetString(help) or help
    else
        self.help = nil
    end
end

--[[ Mouse over the chip ]]
function Chip:OnEnter()
    _setChipColors(self)

    if (type(self.help) == "string") then
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 2, -2)
        GameTooltip:SetText(self.help, Colors.BUTTON_TEXT:GetRGBA())
        GameTooltip:Show()
    end    
end

--[[ Mouse off the chip ]]
function Chip:OnLeave()
    _setChipColors(self)

    if (GameTooltip:GetOwner() == self) then
        GameTooltip:Hide()
    end
end

--[[ Called when the button is clicked (toggle the check state) ]]
function Chip:OnClick()
    _setChipColors(self)

    if type(self.Handler) == "function" then
        pcall(self.Handler)
    end
end

Addon.CommonUI.Chip = Chip

--[[=========================================================================]]

local Layouts = {}

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

local ChipList = {}

function ChipList:OnLoad()
    self.chips = {}
end

--[[ Adds a new chip to the list and setups a re-layout ]]
function ChipList:AddChip(id, text, help, checked)
    local chip = CreateFrame("CheckButton", nil, self, "CommonUI_Chip")
    chip:SetLabel(text)
    chip:SetHelp(help)
    chip:SetChecked(checked == true)
    chip:SetScript("OnSizeChanged", function()
            if self:IsVisible() then
                self.reflow = true
            end
        end)
    chip.Handler = function()
            print("chip state changed")
            print("handler -> ", self.Handler)
            if (self.Handler) then
                Addon.Invoke(self:GetParent(), self.Handler, self)
            end
        end

    self.chips[id] = chip
    self.reflow = true
end

--[[ Called during update, will handle doing a layout if needed ]]
function ChipList:OnUpdate()
    if (self.reflow and self:IsVisible()) then
        self.reflow = false
        Layouts.Flow(self, 8, 8)
    end
end

--[[ Called when our size changes ]]
function ChipList:OnSizeChanged()
    self.reflow = true
end

--[[ Get a list of the chips that are selected ]]
function ChipList:GetSelected()
    local checked = {}

    for id, chip in pairs(self.chips) do
        checked[id] = chip:GetChecked()
    end

    return checked
end

--[[ Updates the list state to match the specified state ]]
function ChipList:SetSelected(chips)
    for _, chip in pairs(self.chips) do
        chip:SetChecked(false)
        _setChipColors(chip)
    end

    for id, state in pairs(chips) do
        local chip = self.chips[id]
        if (chip) then
            chip:SetChecked(state == true)
            _setChipColors(chip)
        end
    end
end

Addon.CommonUI.ChipList = ChipList