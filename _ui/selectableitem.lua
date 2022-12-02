local _, Addon = ...
local locale = Addon:GetLocale()
local CommonUI = Addon.CommonUI
local Colors = Addon.CommonUI.Colors
local SelectableItem = Mixin({}, Addon.CommonUI.Mixins.Border, Addon.CommonUI.Mixins.Tooltip)

local COLORS = {
    normal = {
        back = Colors.TRANSPARENT,
        text = Colors.TEXT,
        border = Colors.TRANSPARENT,
    },
    selected = {
        back = Colors.SELECTED_BACKGROUND,
        text = Colors.SELECTED_TEXT,
        border = Colors.SELECTED_BORDER
    },
    hover = {
        back = Colors.HOVER_BACKGROUND,
        text = Colors.HOVER_TEXT,
        border = Colors.TRANSPARENT
    },
    disabled = {
        back = Colors.TRANSPARENT,
        text = Colors.BUTTON_DISABLED_TEXT,
        border = Colors.TRANSPARENT
    }
}

--[[ Handles the loading of a CategoryItem ]]
function SelectableItem:OnLoad()
    self:OnBorderLoaded("tbk")
    self:SetColors("normal")
end

--[[ Enter the selectable item ]]
function SelectableItem:OnEnter()
    self.hover = true
    if (self:IsEnabled()) then
        if not self:IsSelected() then
            self:SetColors("hover")
        end
        self:TooltipEnter()
    end
end

--[[ Leave the selectable item ]]
function SelectableItem:OnLeave()
    self.hover = false
    if (self:IsEnabled()) then
        if not self:IsSelected() then
            self:SetColors("normal")
        end
        self:TooltipLeave()
    end
end

--[[ Handle selection ]]
function SelectableItem:OnSelected()
    self:SetColors("selected")
end

--[[ Handle un-selection ]]
function SelectableItem:OnUnselected()
    if (self.hover) then
        self:SetColors("hover")
    else
        self:SetColors("normal")
    end
end

--[[ Toggles us to disabled ]]
function SelectableItem:OnDisable()
    self:SetColors("disabled")
end

--[[ Toggles us out of disabled state ]]
function SelectableItem:OnEnable()
    if (self.hover == true) then
        self:SetColors("hover")
    else
        self:SetColors("normal")
    end
end

--[[ Handle click ]]
function SelectableItem:OnClick()
    if (not self:IsSelected()) then
        self:Select()
    end
end

--[[ Sets the colors ]]
function SelectableItem:SetColors(which)
    local colors = COLORS[which]
    if (colors) then
        self:SetBackgroundColor(colors.back)
        self:SetBorderColor(colors.border)
        if (self.text and type(self.text.SetTextColor) == "function") then
            self.text:SetTextColor(colors.text:GetRGBA())
        end
    end
end

Addon.CommonUI.SelectableItem = SelectableItem
