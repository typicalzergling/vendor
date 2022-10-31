local _, Addon = ...
local locale = Addon:GetLocale()
local CommonUI = Addon.CommonUI
local Colors = Addon.CommonUI.Colors
local CategoryItem = Mixin({}, Addon.CommonUI.Mixins.Border)

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
end

--[[ Called when the model is changed ]]
function CategoryItem:OnModelChange(model)
    print("--> changed categrory model", model)
    local loc = locale:GetString(model.Text)
    self.text:SetText(loc or model.Text)
end

function CategoryItem:OnEnter()
    if not self:IsSelected() then
        self:SetColors("hover")
    end
    
    local model = self:GetModel()
    if (type(model.Help) == "string") then
        local label = locale:GetString(model.Text) or model.Text
        local help = locale:GetString(model.Help) or model.Help

        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -4)
        GameTooltip:SetText(label, Colors.SELECTED_PRIMARY_TEXT:GetRGBA())
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(help, Colors.TEXT:GetRGBA())
        GameTooltip:Show()
    end
end

function CategoryItem:OnLeave()
    if not self:IsSelected() then
        self:SetColors("normal")
    end

    if GameTooltip:GetOwner() == self then
        GameTooltip:Hide()
    end
end

function CategoryItem:OnSelected()
    print("--> on selected")
    self:SetColors("selected")
end

function CategoryItem:OnUnselected()
    self:SetColors("normal")
end

function CategoryItem:OnClick()
    if not self:IsSelected() then
        self:GetList():Select(self:GetModel())
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
