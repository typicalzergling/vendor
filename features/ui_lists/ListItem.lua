local _, Addon = ...
local locale = Addon:GetLocale()
local ListItem = Mixin({}, Addon.CommonUI.Mixins.Tooltip, Addon.CommonUI.Mixins.Border)
local UI = Addon.CommonUI.UI
local Colors = Addon.CommonUI.Colors
local ListType = nil
local ChangeType = Addon.Systems.Lists.ChangeType
local ListEvents = Addon.Systems.Lists.ListEvents

--[[ Handle loading ]]
function ListItem:OnLoad()
    ListType = Addon.Systems.Lists.ListType
    self:OnBorderLoaded("tbk", Colors.TRANSPARENT, Colors.TRANSPARENT)
    UI.SetColor(self.text, "TEXT")
    self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
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

function ListItem:OnShow()
    Addon:RegisterCallback(ListEvents.CHANGED, self, self.OnListUpdate)
end

function ListItem:OnHide()
    Addon:UnregisterCallback(ListEvents.CHANGED, self)
end

--[[ When the list name changes update our name ]]
function ListItem:OnListUpdate(list, change, what)
    if (change == ChangeType.OTHER and what == "name") then
        if (list:GetId() == self:GetModel():GetId()) then
            UI.SetText(self.text, list:GetName())
        end
    end
end

--[[ Called when the item is clicked ]]
function ListItem:OnClick(button)
    if (button == "LeftButton") then
        if (not self:IsSelected()) then
            self:Select()
        end
    elseif (button == "RightButton") then
        self:TooltipLeave()
        self:ShowContextMenu()
    end
end

function ListItem:OnEnter()
    self.hover = true
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
    self.hover = false
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
        tooltip:AddDoubleLine(locale["LISTOOLTIP_LISTTYPE"], locale["TOOLTIP_CUSTOMLIST"])
    else
        tooltip:AddDoubleLine(locale["LISTOOLTIP_LISTTYPE"], locale["TOOLTIP_SYTEMLIST"])
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
    local mouseOver = self.hover == true
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

function ListItem:Edit()
    Addon.Features.Lists.ShowEditDialog(self:GetModel())
end

function ListItem:Copy()
    Addon.Features.Lists.ShowEditDialog(self:GetModel(), true)
end

function ListItem:Delete()
    local parent = Addon.CommonUI.Dialog.Find(self)
    local list = self:GetModel()
    UI.MessageBox("DELETE_LIST_CAPTION",
        locale:FormatString("DELETE_LIST_FMT1", list:GetName()), {
            {
                text = "CONFIRM_DELETE_LIST",
                handler = function()
                    Addon:DeleteList(self:GetModel():GetId())
                end,
            },
            "CANCEL_DELETE_LIST"
        }, parent)
end

function ListItem:CreateRule()
end

function ListItem:ShowContextMenu()
    local list = self:GetModel()
    local menu = {}
    local isCustom = list:GetType() == ListType.CUSTOM
    local editor = Addon.Features.Lists.CreateEditor(list)

    table.insert(menu, { text="RULE_CMENU_EDIT", handler=function() self:Edit() end })
    table.insert(menu, { text="RULE_CMENU_COPY", handler=function() self:Copy() end })

    if (isCustom and editor:CanDelete()) then
        table.insert(menu, { text="RULE_CMENU_DELETE", handler=function() self:Delete() end })
    end

    local export = Addon:GetFeature("import")
    if (export ~= nil) then
        if (editor:CanExport()) then
            table.insert(menu, { text="RULE_CMENU_EXPORT", handler=function() 
                export:ShowExportDialog("EXPORT_LIST_CAPTION", editor:GetExportValue())
            end })
        end
    end

    table.insert(menu, "-")
    table.insert(menu, "RULE_CMENU_CLOSE")

    Addon.CommonUI.ShowContextMenu(self, menu)
end

Addon.Features.Lists.ListItem = ListItem