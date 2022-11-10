local _, Addon = ...
local locale = Addon:GetLocale()
local CommonUI = Addon.CommonUI
local Colors = Addon.CommonUI.Colors
local CategoryItem = Mixin({}, Addon.CommonUI.Mixins.Border, Addon.CommonUI.Mixins.Tooltip)
local UI = CommonUI.UI

local DEFAULT_COLOR_SCHEME = {
    BACK = Colors.TRANSPARENT,
    TEXT = Colors.TEXT,
    BORDER = Colors.TRANSPARENT,

    SELECTED_TEXT = Colors.SELECTED_PRIMARY_TEXT,
    SELECTED_BACK = Colors.SELECTED_BACKGROUND,
    SELECTED_BORDER = Colors.SELECTED_BORDER,
    SELECTED_PARTS = "tbk",

    HOVER_TEXT = Colors.HOVER_TEXT,
    HOVER_BACK = Colors.HOVER_BACKGROUND,
    HOVER_BORDER = Colors.TRANSPARENT,
}

--[[ Handles the loading of a CategoryItem ]]
function CategoryItem:OnLoad()
    self.colorScheme = DEFAULT_COLOR_SCHEME
    self:OnBorderLoaded("tbk")
    self:SetColors("normal")
    self:InitTooltip()
end

--[[ Called when the model is changed ]]
function CategoryItem:OnModelChange(model)
    if (type(model.GetName) == "function") then
        UI.SetText(self.text, model:GetName())
    elseif (type(model.Name) == "string") then
        UI.SetText(self.text, model.Name)
    elseif (type(model.Text) == "string") then
        UI.SetText(self.text, model.Text)
    else
        self.text:SetText()
    end
end

function CategoryItem:OnEnter()
    if not self:IsSelected() then
        self:SetColors("hover")
    end
    self:TooltipEnter()
end

--[[ Gets the tooltip text ]]
function CategoryItem:GetHelpText()
    local model = self:GetModel()

    if (type(model.GetDescription) == "function") then
        return model:GetDescription()
    elseif (type(model.Help) == "string") then
        return model.Help
    elseif (type(model.Description) == "string") then
        return model.Description
    end

    return nil
end

--[[ Check if we have a tooltop ]]
function CategoryItem:HasTooltip()
    local help = self:GetHelpText()
    return type(help) == "string" and string.len(help) ~= 0
end

--[[ Show a tooltip for this item ]]
function CategoryItem:OnTooltip(tooltip)
    local text = self:GetHelpText()
    local loc = locale:GetString(text)
    local nameColor = Colors:Get("SELECTED_PRIMARY_TEXT")
    local textColor = Colors:Get("SECONDARY_TEXT")

    tooltip:SetText(self.text:GetText(), nameColor:GetRGB())
    tooltip:AddLine(loc or text, textColor.r, textColor.g, textColor.b, true)
end

function CategoryItem:OnLeave()
    if not self:IsSelected() then
        self:SetColors("normal")
    end
    self:TooltipLeave()
end

function CategoryItem:OnSelected()
    self:SetColors("selected")
end

function CategoryItem:OnUnselected()
    self:SetColors("normal")
end

function CategoryItem:OnClick()
    if not self:IsSelected() then
        self:Select()
    end
end

function CategoryItem:SetColors(which)
    local colors = self.colorScheme

    if (which == "normal") then
         self:SetBorderColor(colors.BORDER)
         self:SetBackgroundColor(colors.BACK)
         self.text:SetTextColor(colors.TEXT:GetRGBA())
    elseif (which == "hover") then
        self:SetBorderColor(colors.HOVER_BORDER)
        self:SetBackgroundColor(colors.HOVER_BACK)
        self.text:SetTextColor(colors.HOVER_TEXT:GetRGBA())
   elseif (which == "selected") then
        self:SetBorderColor(colors.SELECTED_BORDER)
        self:SetBackgroundColor(colors.SELECTED_BACK)
        self.text:SetTextColor(colors.SELECTED_TEXT:GetRGBA())
    else
        error("Usage: SetColors(normal | selected | hover) got: " .. tostring(which))
    end
end

Addon.CommonUI.CategoryItem = CategoryItem
