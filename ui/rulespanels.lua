local AddonName, Addon = ...
local L = Addon:GetLocale();
local RulesPanel = {};
Addon.RulesPanels = Addon.RulesPanel or {};

local SCROLL_PADDING_X = 4;
local SCROLL_PADDING_Y = 17;
local SCROLL_BUTTON_PADDING = 4;

local function setLocalizedText(frame, control, keyname)
    if (target[control]) then
        local key = frame[keyname];
        if (type(key) == "string") then
            local text = L[key] or string.upper(key);
            frame[control]:SetText(text);
        end
    end
end

-- Loads in initializes a new rules panel (called from the XML's onload)
function RulesPanel.onInit(self)
    -- Mixin the implementation of the panel.
    local subclass = self.Implementation;
    if ((type(subclass) == "string") and Addon.RulesPanels) then
        local obj = Addon.RulesPanels[subclass];
        if (type(Addon.RulesPanels[subclass]) == "table") then
            Mixin(self, obj);
        end
    else
        Addon:Debug("rulesdialog", "Expected an implementation for RulesPanel");
    end

    -- If a help text key was provied set the help text in the panel.
    if (self.HelpText) then
        local helpTextKey = self.HelpTextKey;
        if (type(helpTextKey) == "string") then
            local text = L[helpTextKey];
            if (type(text) == "string") then
                self.HelpText:SetText(text);
            end
        else
            self.HelpText:SetText("");
        end
    end

    -- Load the panel and attach an onevent in case the subclass registers.
    self:SetScript("OnEvent", function(...) Addon.invoke(self, "OnEvent", ...) end);
    self:SetScript("OnShow", function(...) Addon.invoke(self, "OnShow", ...) end);
    self:SetScript("OnHide", function(...) Addon.invoke(self, "OnHide", ...) end);
    invoke(self, "OnLoad");
end



--[[ Lists Panel ]]

local ListType = Addon.ListType;
local ListsItem = {};

function ListsItem:OnCreated()
    self:SetScript("OnClick", self.OnClick)
    self:SetScript("OnEnter", self.OnEnter)
    self:SetScript("OnLeave", self.OnLeave)
end

function ListsItem:OnModelChanged(model)
    self.Name:SetText(model.name);
end

function ListsItem:OnUpdate()
    if (self:IsMouseOver()) then
        self.Hover:Show();
    else
        self.Hover:Hide();
    end
end

function ListsItem:OnSelected(selected)
    if (selected) then
        self.Selected:Show();
        self.Name:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
    else
        self.Selected:Hide();
        self.Name:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
    end
end

function ListsItem:OnClick()
    self:GetParent():Select(self:GetModel());
end

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

function ListsItem:OnLeave()
    if (GameTooltip:GetOwner() == self) then
        GameTooltip:Hide()
    end
end

local SystemListId = 
{
    NEVER = "system:never-sell",
    ALWAYS = "system:always-sell",
    DESTROY = "system:always-destroy",
};

local SYSTEM_LISTS = 
{
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
};

local ListsPanel = 
{
    OnLoad = function(self)
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
    end,

    OnShow = function(self)
        self.Lists:Update();
        Addon:GetProfileManager():RegisterCallback("OnProfileChanged", self.OnSelectionChanged, self);
        if (not self.Lists:GetSelected()) then
            self.Lists:Select(1);
        end
    end,

    OnHide = function(self)
        Addon:GetProfileManager():UnregisterCallback("OnProfileChanged", self.OnSelectionChanged, self);
    end,
};

function ListsPanel:OnDeleteItem(item)
    local list = assert(self:GetSelectedList());
    if (list) then
        list:Remove(Addon.ItemList.GetItemId(item));
    end
end

function ListsPanel:OnAddItem(item)
    local list = assert(self:GetSelectedList());
    if (list) then
        list:Add(Addon.ItemList.GetItemId(item));
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
        self.ItemCount:Hide();
    else
        local contents = list:GetItems();
        local count = table.getn(contents);
        
        self.Items:SetContents(contents);
        if  (count ~= 0) then
            self.ItemCount:SetFormattedText("(%d)", count);
            self.ItemCount:Show();
        else
            self.ItemCount:Hide();
        end
    end
end

Addon.RulesPanels.HelpPanel = HelpPanel;
Addon.RulesPanels.ListsPanel = ListsPanel;
Addon.Public.RulesPanel = RulesPanel;