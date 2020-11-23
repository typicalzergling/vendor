local AddonName, Addon = ...
local L = Addon:GetLocale()
local ListsPanel = {}
local ListsItem = {}
local ListType = Addon.ListType
local SystemListId = Addon.SystemListId

--[[===========================================================================
    | Defines the entries for the system lists
    ========================================================================--]]
local SYSTEM_LISTS = {
    {
        id = SystemListId.NEVER,
        name  = L.NEVER_SELL_LIST_NAME,
        empty = L.RULES_DIALOG_EMPTY_LIST,
        tooltip = L.NEVER_SELL_LIST_TOOLTIP,
    },
    {
        id = SystemListId.ALWAYS,
        name  = L.ALWAYS_SELL_LIST_NAME,
        empty = L.RULES_DIALOG_EMPTY_LIST,
        tooltip = L.ALWAYS_SELL_LIST_TOOLTIP,
    },
    {
        id = SystemListId.DESTROY,
        name  = L.ALWAYS_DESTROY_LIST_NAME,
        empty = L.RULES_DIALOG_EMPTY_LIST,
        tooltip = L.ALWAYS_DESTROY_LIST_TOOLTIP,
    }
}

--[[===========================================================================
    |  Called when the lsite item is created
    ========================================================================--]]
function ListsItem:OnCreated()
    self:SetScript("OnClick", self.OnClick)
    self:SetScript("OnEnter", self.OnEnter)
    self:SetScript("OnLeave", self.OnLeave)
end

--[[===========================================================================
    | Called when the list item has it's model changed
    ========================================================================--]]
function ListsItem:OnModelChanged(model)
    self.Name:SetText(model.name);
end

--[[===========================================================================
    | Handle updating the list item
    ========================================================================--]]
function ListsItem:OnUpdate()
    if (self:IsMouseOver()) then
        self.Hover:Show();
    else
        self.Hover:Hide();
    end
end

--[[===========================================================================
    | Called when the list items selection state changes
    ========================================================================--]]
function ListsItem:OnSelected(selected)
    if (selected) then
        self.Selected:Show();
        self.Name:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
    else
        self.Selected:Hide();
        self.Name:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
    end
end

--[[===========================================================================
    | Handle a click on the list item
    ========================================================================--]]
function ListsItem:OnClick()
    self:GetList():Select(self:GetModel());
end

--[[===========================================================================
    | Handle showing a tooltip for this list item (if there is one)
    ========================================================================--]]
function ListsItem:OnEnter()
    local model = assert(self:GetModel(), "Item should have a valid model")
    if ((type(model.tooltip) == "string") and (string.len(model.tooltip) ~= 0)) then
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:AddLine(model.name, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        GameTooltip:AddLine(model.tooltip, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
        GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -2)
        GameTooltip:Show()
    end
end

--[[===========================================================================
    | Handle hiding the tooltip if we displayed one
    ========================================================================--]]
function ListsItem:OnLeave()
    if (GameTooltip:GetOwner() == self) then
        GameTooltip:Hide()
    end
end

--[[===========================================================================
    |  Called to handle the load of the lists panel
    ========================================================================--]]
function ListsPanel:OnLoad()
    self.Lists.ItemHeight = 20;
    self.Lists.ItemTemplate = "Vendor_ItemLists_ListItem";
    self.Lists.ItemClass = ListsItem;
    self.Items.isReadOnly = false;

    self.Lists.GetItems = function()
        return SYSTEM_LISTS;
    end

    self.Lists.OnSelection = function() 
        self:OnSelectionChanged();
    end

    self.Items.OnAddItem = function(list, item)
        self:OnAddItem(item);
    end

    self.Items.OnDeleteItem=  function(list, item)
        self:OnDeleteItem(item);
    end

    self:SetScript("OnShow", self.OnShow);
    self:SetScript("OnHide", self.OnHide);
end

--[[===========================================================================
    | Called when the lists panel is show, force selection if we don't have 
    | on at the oment.
    ========================================================================--]]
function ListsPanel:OnShow()
    self.Lists:Update();
    Addon:GetProfileManager():RegisterCallback("OnProfileChanged", self.OnSelectionChanged, self);
    if (not self.Lists:GetSelected()) then
        self.Lists:Select(1);
    end
end

--[[===========================================================================
    | Called when the panel is hidden, unregisters our callback
    ========================================================================--]]
function ListsPanel:OnHide()
    Addon:GetProfileManager():UnregisterCallback("OnProfileChanged", self.OnSelectionChanged, self);
end

--[[===========================================================================
    | Called to delete an item from the current lists item.
    ========================================================================--]]
function ListsPanel:OnDeleteItem(item)
    local list = assert(self:GetSelectedList());
    if (list) then
        list:Remove(Addon.ItemList.GetItemId(item));
    end
end

--[[===========================================================================
    |  Called when an item is added to the list.
    ========================================================================--]]
function ListsPanel:OnAddItem(item)
    local list = assert(self:GetSelectedList());
    if (list) then
        local itemid = Addon.ItemList.GetItemId(item)

        -- Check for condition that this item is unsellable and we are attempting
        -- to add it to the system Sell list.
        if itemid and list.listType == Addon.ListType.SELL then
            if select(11, GetItemInfo(itemid)) == 0 then   -- itemprice is 0 means unsellable
                Addon:Print(L.ITEMLIST_UNSELLABLE, select(2, GetItemInfo(itemid)) or itemid)
                list = Addon:GetList(ListType.DESTROY)
            end
        end

        list:Add(itemid);
    end
end

--[[===========================================================================
    | Retrieves the currently selected list, returns the list, or nil to 
    | indicate there was no selection. Also returns the empty text to show
    | for the specified list.
    ========================================================================--]]
function ListsPanel:GetSelectedList()
    local selection = self.Lists:GetSelected();
    if (selection) then
        local id = selection.id;        
        if (id == SystemListId.NEVER) then
            return Addon:GetList(ListType.KEEP), selection.empty;
        elseif (id == SystemListId.ALWAYS) then
            return Addon:GetList(ListType.SELL), selection.empty;
        elseif (id == SystemListId.DESTROY) then
            return Addon:GetList(ListType.DESTROY), selection.empty;
        end
    end

    return nil;
end

--[[===========================================================================
    | Called to handle selction changed, this simply populates the contents of
    | the list with the items from the currently selected list.
    ========================================================================--]]
function ListsPanel:OnSelectionChanged()
    local list, empty = self:GetSelectedList();
    self.Items:SetEmptyText(empty);

    if (not list) then
        -- List is empty
        self.Items:SetContents();
        self.ItemCount:SetFormattedText("(%d)", 0);
    else
        local contents = list:GetItems();
        local count = table.getn(contents);
        
        self.Items:SetContents(contents);
        self.ItemCount:SetFormattedText("(%d)", count);
    end
end

Addon.Panels = Addon.Panels or {}
Addon.Panels.Lists = ListsPanel