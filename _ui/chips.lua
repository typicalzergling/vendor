--[[

]]

local _, Addon = ...
local Layouts = Addon.CommonUI.Layouts
local UI = Addon.CommonUI.UI
local Colors = Addon.CommonUI.Colors
local locale = Addon:GetLocale()
local CHIP_PADDING = 10

local Chip = Mixin({}, Addon.CommonUI.Mixins.Border, Addon.CommonUI.Mixins.Tooltip)
local Chips = {}

local CHIP_COLORS = {
    disabled = {
        back = "BUTTON_DISABLED_BACK",
        border = "BUTTON_DISABLED_BORDER",
        text = "BUTTON_DISABLED_BORDER"
    },
    checked = {
        back = "BUTTON_CHECKED_BACK",
        border = "BUTTON_CHECKED_BORDER",
        text = "BUTTON_CHECKED_TEXT"
    },
    hover = {
        border = "BUTTON_HOVER_BORDER",
        back = "BUTTON_HOVER_BACK",
        text = "BUTTON_HOVER_TEXT"
    },
    normal = {
        back = "BUTTON_BACK",
        border = "BUTTON_BORDER",
        text = "BUTTON_TEXT"
    }
}


--[[ Sets the text of the chip ]]
local function _setChipText(chip, text)
    local text = locale:GetString(text) or text or "<error>"
    chip:SetText(text)

    chip.text:SetText(text)
    chip.text:SetWidth(0)
    chip:SetWidth(16 + chip.text:GetWidth())
end

--[[ Load the chip ]]
function Chip:OnLoad()
    self:OnBorderLoaded()
    self:SetColors()

    self:SetScript("OnEnable", self.SetColors)
    self:SetScript("OnDisable",self.SetColors)
    self:SetScript("OnShow", self.SetColors)
    self:SetChecked(false)
end

--[[ Set teh colors for this chip ]]
function Chip:SetColors()
    local colors = CHIP_COLORS.normal
    if (not self:IsEnabled()) then
        colors = CHIP_COLORS.disabled
    elseif (self:GetChecked()) then
        colors = CHIP_COLORS.checked
    elseif (self:IsMouseOver()) then
        colors = CHIP_COLORS.hover
    end

    if (colors) then
        self:SetBorderColor(colors.border)
        self:SetBackgroundColor(colors.back)
        UI.SetColor(self.text, colors.text)
    end
end

--[[ Sets the label for this chip ]]
function Chip:SetLabel(label)
    label = locale:GetString(label) or label
    
    local text = self.text
    text:SetText(label)
    text:SetWidth(0)
    self:SetWidth(self.text:GetWidth() + CHIP_PADDING * 2)
end

--[[ Set the tooltip for the chip ]]
function Chip:SetTooltip(tooltip)
    if (tooltip) then
        self.tooltip = locale:GetString(tooltip) or tooltip
        if (string.len(self.tooltip) == 0) then 
            self.tooltip = nil
        end
    else
        self.tooltip = nil
    end
end

--[[ Mouse over the chip ]]
function Chip:OnEnter()
    self:SetColors()
    self:TooltipEnter()
end

--[[ Check if we have a tooltip ]]
function Chip:HasTooltip()
    return type(self.tooltip) == "string"
end

--[[ Called to populate our tooltip ]]
function Chip:OnTooltip(tooltip)
    local textColor = Colors:Get("TEXT")
    tooltip:AddLine(self.tooltip, textColor.r, textColor.g, textColor.b, 1)
end

--[[ Mouse off the chip ]]
function Chip:OnLeave()
    self:SetColors()
    self:TooltipLeave()
end

--[[ Called when the button is clicked (toggle the check state) ]]
function Chip:OnClick()
    self:SetColors()

    local parent = self:GetParent()
    parent:OnChipStateChanged(self, self:GetChecked())
end

--[[ Chips ==================================================================]]

function Chips:OnLoad()
    self.chips = {}
    self.radio = (self.IsExclusive == true)
    self.onesize = (self.OneSize == true)
end

--[[ Adds a new chip to the list and setups a re-layout ]]
function Chips:AddChip(id, text, help, checked)
    local chip = CreateFrame("CheckButton", nil, self, "CommonUI_Chip")
    UI.Attach(chip, Chip)
    chip:SetLabel(text)
    chip:SetTooltip(help)
    chip:SetChecked(checked == true)
    chip:SetScript("OnSizeChanged", function()
            if self:IsVisible() then
                self.reflow = true
            end
        end)

    rawset(chip, "chipId", id)
    self.chips[id] = chip
    self.reflow = true
end

--[[ Add a list of chips, ordered by the position in the list ]]
function Chips:AddChips(chips)
    assert(type(chips) == "table", "Expected the list of chips to be a table")

    for _, chip in ipairs(chips) do
        self:AddChip(chip.id, chip.text, chip.tooltip, chip.checked)
    end
end

--[[ Called during update, will handle doing a layout if needed ]]
function Chips:OnUpdate()
    if (self.reflow and self:IsVisible()) then
        self.reflow = false
        Layouts.Flow(self, 8, 8)
    end
end

--[[ Called when our size changes ]]
function Chips:OnSizeChanged()
    self.reflow = true
end

function Chip:OnShow()
    self.reflow = true
end

--[[ Get a list of the chips that are selected ]]
function Chips:GetSelected()
    local checked = {}

    for id, chip in pairs(self.chips) do
        checked[id] = chip:GetChecked()
    end

    return checked
end

--[[ Updates the list state to match the specified state ]]
function Chips:SetSelected(chips)
    for id, chip in pairs(self.chips) do
        chip:SetChecked(chips[id] == true)
        chip:SetColors()
    end
end

--[[ Invoked when the state of a chip changes ]]
function Chips:OnChipStateChanged(chip, state)
    local id = rawget(chip, "chipId")

    if (self.radio) then
        -- If we are in radio mode then only one chip can get selected
        -- at a time.
        for chipId, chip in pairs(self.chips) do
            if (id ~= chipId) then
                chip:SetChecked(false)
                chip:SetColors()
            end
        end
    end

    if (type(self.Handler) == "string") then
        local parent = self:GetParent()
        if (type(parent[self.Handler]) == "function") then
            local selected = self:GetSelected()
            parent[self.Handler](parent, selected, self)
        end
    end
end

Addon.CommonUI.ChipList = Chips
Addon.CommonUI.Chips = Chips