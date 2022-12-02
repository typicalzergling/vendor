local _, Addon = ...
local ItemItem = Mixin({}, Addon.CommonUI.Mixins.Tooltip, Addon.CommonUI.Mixins.Border)
local Colors = Addon.CommonUI.Colors
local UI = Addon.CommonUI.UI

--[[ Called when the model is set ]]
function ItemItem:OnModelChange(itemId)
    self:OnBorderLoaded("tbk", Colors.TRANSPARENT, Colors.TRANSPARENT)
    self:SetItemID(itemId)
    self:ContinueOnItemLoad(function()
        local color = self:GetItemQualityColor() or GRAY_FONT_COLOR
        self.name:SetText(self:GetItemName())
        self.name:SetTextColor(color.r, color.g, color.b, color.a or 1)
        UI.Enable(self.delete, not self:IsItemEmpty())
    end)
end

--[[ Called when the item is selected ]]
function ItemItem:OnSelected()
    if (self.delete) then
        self.delete:Show()
    end

    self:SetBackgroundColor(Colors:Get("SELECTED_BACKGROUND"))
    self:SetBorderColor(Colors:Get("SELECTED_BORDER"))
end

--[[ Handle item de-selection ]]
function ItemItem:OnUnselected()
    if (self.delete) then
        self.delete:Hide()
    end

    self:SetBorderColor(Colors.TRANSPARENT)
    if (self:IsMouseOver()) then
        self:SetBackgroundColor(Colors:Get("HOVER_BACKGROUND"))
    else
        self:SetBackgroundColor(Colors.TRANSPARENT)
    end
end

--[[ Handle the mouse entering ]]
function ItemItem:OnEnter()
    if (not self:IsSelected()) then
        self:SetBackgroundColor(Colors:Get("HOVER_BACKGROUND"))
    end
    self:TooltipEnter()
end

--[[ Hanle the mouse leaving ]]
function ItemItem:OnLeave()
    self:TooltipLeave()
    if (not self:IsSelected()) then
        self:SetBackgroundColor(Colors.TRANSPARENT)
    end
end

--[[ Handle deleting this item ]]
function ItemItem:OnDelete()
    self:Notify("OnDelete", self:GetModel())
end

--[[ Check of we have a tooltop to show ]]
function ItemItem:HasTooltip()
    return not self:IsItemEmpty()
end

--[[ Called to show the tooltip for this item ]]
function ItemItem:OnTooltip(tooltip)
    local link = self:GetItemLink()
    if not link then return end
    tooltip:SetHyperlink(link)
end

--[[ Called when the mouse clicked, if there is item notify the parent ]]
function ItemItem:OnMouseDown(...)
    if (Addon.CommonUI.ItemLink.GetCursorItem()) then
        self:Notify("OnDropItem")
    elseif (not self:IsSelected()) then
        self:Select()
	elseif (not self:IsItemEmpty()) then
		PickupItem(self:GetItemLink());
	end
end

Addon.Features.Lists.ItemItem = ItemItem