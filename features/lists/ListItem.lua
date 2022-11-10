local _, Addon = ...
local ListItem = Mixin({}, Addon.CommonUI.Mixins.Tooltip, Addon.CommonUI.Mixins.Border)
local UI = Addon.CommonUI.UI
local Colors = Addon.CommonUI.Colors
local ListType = Addon.Systems.Lists.ListType
local locale = Addon:GetLocale()

--[[ Handle loading ]]
function ListItem:OnLoad()
    self:OnBorderLoaded("tbk", Colors.TRANSPARENT, Colors.TRANSPARENT)
    UI.SetColor(self.text, "TEXT")
end

--[[ Called to set the model ]]
function ListItem:OnModelChange(list)
    self:OnBorderLoaded("tbk", Colors.TRANSPARENT, Colors.TRANSPARENT)
    UI.SetText(self.text, list:GetName())

    if (list:GetType() == ListType.CUSTOM) then
        UI.SetColor(self.text, "CUSTOMLIST_TEXT")
    else
        UI.SetColor(self.text, "TEXT")
    end
end

--[[ Called when the item is clicked ]]
function ListItem:OnClick()
    if (not self:IsSelected()) then
        self:Select()
    end
end

function ListItem:OnEnter()
    if (not self:IsSelected()) then
        self:SetBorderColor(Colors.TRANSPARENT)
        self:SetBackgroundColor(Colors:Get("HOVER_BACKGROUND"))

        if (self:GetModel():GetType() == ListType.CUSTOM) then
            UI.SetColor(self.text, "CUSTOMLIST_HOVER_TEXT")
        else
            UI.SetColor(self.text, "HOVER_TEXT")
        end    
    end

    self:TooltipEnter()
end

function ListItem:OnLeave()
    if (not self:IsSelected()) then
        self:SetBorderColor(Colors.TRANSPARENT)
        self:SetBackgroundColor(Colors.TRANSPARENT)

        if (self:GetModel():GetType() == ListType.CUSTOM) then
            UI.SetColor(self.text, "CUSTOMLIST_TEXT")
        else
            UI.SetColor(self.text, "TEXT")
        end
    end

    self:TooltipLeave()
end

function ListItem:HasTooltip()
    return true
end

function ListItem:OnTooltip(tooltip)
    local model = self:GetModel()
    local help = model:GetDescription()
    local nameColor = Colors:Get("SELECTED_PRIMARY_TEXT")
    local textColor = Colors:Get("SECONDARY_TEXT")

    tooltip:SetText(self.text:GetText(), nameColor:GetRGB())
    if (self:GetModel():GetType() == ListType.CUSTOM) then
        tooltip:AddLine(locale["TOOLTIP_CUSTOMLIST"])
    else
        tooltip:AddLine(locale["TOOLTIP_SYTEMLIST"])
    end

    if (type(help) == "string" and string.len(help) ~= 0) then
        tooltip:AddLine(" ")
        tooltip:AddLine(locale:GetString(help) or help, textColor.r, textColor.g, textColor.b, true)
    end
end


--[[ Called when the item is selected ]]
function ListItem:OnSelected()
    self:SetBorderColor(Colors:Get("SELECTED_BORDER"))
    self:SetBackgroundColor(Colors:Get("SELECTED_BACKGROUND"))

    if (self:GetModel():GetType() == ListType.CUSTOM) then
        UI.SetColor(self.text, "CUSTOMLIST_SELECTED_TEXT")
    else
        UI.SetColor(self.text, "SELECTED_TEXT")
    end
end

--[[ Called when the item is unselected ]]
function ListItem:OnUnselected()
    local mouseOver = self:IsMouseOver()
    local textColor = "TEXT"

    if (self:GetModel():GetType() == ListType.CUSTOM) then
        if (mouseOver) then
            textColor = "CUSTOMLIST_HOVER_TEXT"
        else
            textColor = "CUSTOMLIST_TEXT"
        end
    else
        if (mouseOver) then
            textColor = "HOVER_TEXT"
        else
            textColor = "TEXT"
        end
    end

    if(not mouseOver) then
        self:SetBorderColor(Colors.TRANSPARENT)
        self:SetBackgroundColor(Colors.TRANSPARENT)
    else
        self:SetBorderColor(Colors.TRANSPARENT)
        self:SetBackgroundColor(Colors:Get("HOVER_BACKGROUND"))
    end
    UI.SetColor(self.text, textColor)
end

Addon.Features.Lists.ListItem = ListItem