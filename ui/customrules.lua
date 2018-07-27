local Addon, L = _G[select(1,...).."_GET"]()
Addon.CustomRuleList = {};
local CustomRuleList=Addon.CustomRuleList;
local Rules=Addon.Rules;
local VENDOR_STATICPOPUP_CONFIRM_DELETE="VENDOR_CONFIRM_DELETE_CUSTOM_RULE";
local ITEM_HEIGHT = 64; -- If you change the height of the template change this as well
local ITEM_TEMPLATE = "Vendor_CustomRule_Template";

--[[===========================================================================
    | SetShareButton:
    |   Updates the share button, text/tooltip
    ========================================================================--]]
function CustomRuleList.SetShareButton(self)
    self.tooltip = L["CONFIG_DIALOG_SHARE_TOOLTIP"];
    self:Disable();
end

--[[===========================================================================
    | sortItems (local)
    |   Sort the items in the custom rule list, we sort them alphabetically
    ========================================================================--]]
local function sortItems(self)
    if (self.items) then
        table.sort(self.items,
            function(ruleA, ruleB) 
                return (ruleA.name:GetText() < ruleB.name:GetText());
            end);
    end            
end

--[[===========================================================================
    | findItem (local)
    |   Finds an item with the specified ruleId.
    ========================================================================--]]
local function findItem(self, ruleId)
    if (self.items) then
        for _, item in ipairs(self.items) do
            if (item.ruleId == ruleId) then
                return item;
            end               
        end
    end
end

--[[===========================================================================
    | findId (local)
    |   Checks for the presence of the given Id in the specified list
    ========================================================================--]]
local function findId(ids, id)
    for _,i in ipairs(ids) do
        if (string.lower(i) == id) then
            return true;
        end
    end
end

--[[===========================================================================
    | ensureItems (local)
    |   Create/Deletes items to match the supplied rule definitions.
    ========================================================================--]]
local function ensureItems(self, ruleDefinitions)
    local ids = {};

    -- Make sure we've got items for each definition
    for _, ruleDef in pairs(ruleDefinitions) do
        local item = findItem(self, ruleDef.Id);
        table.insert(ids, ruleDef.Id);

        if (not item) then
            item = CreateFrame("Button", nil, self, ITEM_TEMPLATE);
            item.ruleId = ruleDef.Id;
            item.ruleDef = ruleDef;
            item.name:SetText(ruleDef.Name);
            item.text:SetText(ruleDef.Description);
            if (item.author) then
                item.author:SetText(ruleDef.EditedBy);
            end
        end
    end

    -- Make sure we don't have any extra items.
    local index = 1;
    if (self.items) then
        while (index <= #self.items) do
            local item = self.items[index];
            if (not findId(ids, string.lower(item.ruleId))) then
                table.remove(self.items, index);
                item:Hide();
                item:SetParent(nil);
            else
                index = (index + 1);
            end            
        end
    end

    sortItems(self);
end

--[[===========================================================================
    | AdjustScrollbar
    |   Moves the scrollbar around, sync's the background and buttons in order
    |   to be better looking state.
    ========================================================================--]]
function CustomRuleList.AdjustScrollbar(self)
 -- Adjust our scrollbar by giving it a background and moving it 
    -- to be right next to us.
    -- TODO move to shared funciton
    local scrollbar = self.ScrollBar;
    if (scrollbar) then
        local buttonHeight = scrollbar.ScrollUpButton:GetHeight();
        local background = self.scrollbarBackground;
        if (background) then
            background:ClearAllPoints();
            background:SetPoint("TOPLEFT", scrollbar.ScrollUpButton, "BOTTOMLEFT", 0, buttonHeight / 2);
            background:SetPoint("BOTTOMRIGHT", scrollbar.ScrollDownButton, "TOPRIGHT", 0, -buttonHeight / 2);
        end
        scrollbar:ClearAllPoints();
        scrollbar:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -buttonHeight);
        scrollbar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, buttonHeight);
    end
end

--[[===========================================================================
    | OnLoad
    |   Called when the panel is loaded, we adjust the scrollbar, and sub
    |   subscribe for changes that would affect the list.
    ========================================================================--]]
function CustomRuleList.OnLoad(self)
    -- Adjust scrollbar
    CustomRuleList.AdjustScrollbar(self);

    -- Subscribe for changes (We need update when our definitions change)
    Rules.OnDefinitionsChanged:Add(function(...) if (self:IsShown()) then CustomRuleList.OnShow(self) end end);
end

--[[===========================================================================
    | OnShow
    |   When the list is shown, we need to adjust the state and sync to the
    |   rule definitions, we use this in other cases as well.
    ========================================================================--]]
function CustomRuleList.OnShow(self)
    ensureItems(self, Rules.GetCustomDefinitions());
    CustomRuleList.Update(self);
end

--[[===========================================================================
    | Update
    |   Syncs the state of the view shows hide the help text and shows/hides
    |   and adjusts the anchors of our items.
    ========================================================================--]]
function CustomRuleList.Update(self)
    local items = self.items or {};

    -- Show/Hide the empty text
    if (#items == 0) then
        self.emptyText:Show();
    else
        self.emptyText:Hide();
    end        

    -- Update the visible custom rules
    local offset = FauxScrollFrame_GetOffset(self);
    local visible = math.floor(self:GetHeight() / ITEM_HEIGHT);
    local anchor = nil;
    local first = (1 + offset);
    local last = (first + visible);
    local width = (self:GetWidth() - self.ScrollBar:GetWidth() - 1);

    FauxScrollFrame_Update(self, #items, visible, ITEM_HEIGHT, nil, nil, nil, nil, nil, nil, true);
    for index,item in ipairs(items) do
        item:ClearAllPoints();
        if ((index >= first) and (index <= last)) then
            item:Show();
            item:SetWidth(width);

            if (not anchor) then
                item:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
            else
                item:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, 0);
            end

            if (index == last) then
                item.divider:Hide();
            else
                item.divider:Show();
            end                

            anchor = item
        else
            item:Hide();
        end
    end
end

--[[===========================================================================
    | EditRule
    |   Called to handle editing the rule associated with the specified item
    ========================================================================--]]
function CustomRuleList.EditRule(item)
    if (item.ruleDef) then
        VendorEditRuleDialog:EditRule(item.ruleDef);
    end
end

--[[===========================================================================
    | ShareRule
    |   TBD
    ========================================================================--]]
function CustomRuleList.ShareRule(item)
end

--[[===========================================================================
    | DeleteRule
    |   Prompts to delete the rule for the provided item.
    ========================================================================--]]
function CustomRuleList.DeleteRule(item)
    local popup = StaticPopup_Show(VENDOR_STATICPOPUP_CONFIRM_DELETE, item.name:GetText());
    if (popup) then
        popup.data = item.ruleId;
    else
        UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
    end
end

-- Add a static popup so we can show it.
StaticPopupDialogs[VENDOR_STATICPOPUP_CONFIRM_DELETE] = 
{
	text = L["CONFIG_DIALOG_CONFIRM_DELETE_FMT1"];
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) 
            Rules.DeleteDefinition(self.data);
        end,
	OnCancel = function (self) end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
};
