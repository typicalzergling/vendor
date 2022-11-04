local _, Addon = ...
local Vendor = Addon.Features.Vendor
local locale = Addon:GetLocale()
local HistoryItem = {}
local ActionType = Addon.ActionType
local Colors = Addon.CommonUI.Colors

function HistoryItem:OnLoad()
    Addon.CommonUI.DialogBox.Colorize(self)
end

function HistoryItem:OnUpdate()
    if (self:IsMouseOver()) then
        self.hilite:Show()
    else
        self.hilite:Hide()
    end
end

function HistoryItem:OnEnter()
    local model = self:GetModel()
    local text = Colors.TEXT
    local secondary = GRAY_FONT_COLOR    

    local actionText = locale.OPTIONS_AUDIT_TT_SOLD
    if (model.Action == ActionType.DESTROY) then
        actionText = locale.OPTIONS_AUDIT_TT_DESTROYED
    end

    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -2)    
    GameTooltip:AddLine(locale["OPTIONS_VENDOR_AUDIT"])
    GameTooltip:AddDoubleLine(actionText, date(locale.OPTIONS_AUDIT_TT_DATESTR, model.TimeStamp),
        text.r, text.g, text.b, secondary.r, secondary.g, secondary.b)

    GameTooltip:AddDoubleLine(locale.OPTIONS_AUDIT_TT_PROFILE, model.ProfileName,
        text.r, text.g, text.b, secondary.r, secondary.g, secondary.b)
    GameTooltip:AddDoubleLine(locale.OPTIONS_AUDIT_TT_RULE, model.RuleName,
        text.r, text.g, text.b, secondary.r, secondary.g, secondary.b)

    --@debug@
    GameTooltip:AddDoubleLine("ProfileId:", model.ProfileName,
        text.r, text.g, text.b, secondary.r, secondary.g, secondary.b)
    GameTooltip:AddDoubleLine("RuleId:", model.RuleId,
        text.r, text.g, text.b, secondary.r, secondary.g, secondary.b)
    --@end-debug@

    GameTooltip:Show()
end

function HistoryItem:OnLeave()
    if (GametoolTip:GetOwner() == self) then
        GametoolTip:Hide()
    end
end

function HistoryItem:OnModelChange(model)
    self.value:SetText(Addon:GetPriceString(model.Value, true))
	self.date:SetText(date("%m/%d %I:%M %p", model.TimeStamp))

    local type = self.type
    if (model.Action == ActionType.SELL) then
        type:SetTextColor(GREEN_FONT_COLOR:GetRGBA())
        type:SetText("S")
    elseif (model.Action == ActionType.DESTROY) then
        type:SetText("D")
        type:SetTextColor(RED_FONT_COLOR:GetRGBA())
    else
        type:SetText(nil)
    end
    print("ACTION ---> ", model.Action, type:GetText())

    self:SetItemID(model.Id)
	self:ContinueOnItemLoad(function()
		local color = self:GetItemQualityColor() or GRAY_FONT_COLOR
		self.item:SetText(self:GetItemName())
		self.item:SetTextColor(color.r, color.g, color.b)
	end)
end

Vendor.HistoryItem = HistoryItem