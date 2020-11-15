--[[===========================================================================
    | Copyright (c) 2018
    |
    | RulesList:
    |
    ========================================================================--]]

local AddonName, Addon = ...
local L = Addon:GetLocale()

Addon.RulesList = {}
Addon.Rules = Addon.Rules or {};
local Rules = Addon.Rules;
local Package = select(2, ...);
local RulesList = Addon.RulesList;

local function findRuleConfig(ruleId, rulesConfig)
    local id = string.lower(ruleId or "");
    for index, entry in ipairs(rulesConfig) do
        if ((type(entry) == "string") and (string.lower(entry) == id)) then
            return index, entry;
        elseif ((type(entry) == "table") and entry.rule) then
            if (string.lower(entry.rule) == id) then
                return index, entry
            end
        end
    end
end

function RulesList:SetConfigState(configState)
    if (self.ruleType) then
        local profile = Addon:GetProfile();
        local ruleConfig = configState or profile:GetRules(self.ruleType);
        self:ForEach(
            function(item)
                local index, config = findRuleConfig(item:GetRuleId(), ruleConfig);
                if (index and config) then
                    --item:SetConfig(config, index);
                else
                    --item:SetConfig();
                end
            end);
    end
end

function RulesList:SetDefaultConfig()
    if (self.ruleType) then
        self:SetConfigState(Config:GetDefaultRulesConfig(self.ruleType));
    end
end

function RulesList:UpdateConfig()
    if (self.ruleType) then
        local config = {};
        self:ForEach(
            function(item)
                local entry = item:GetConfig();
                if (entry) then
                    table.insert(config, entry);
                end
            end)
            
        Addon:GetProfile():SetRules(self.ruleType, config);
    end
end

function RulesList:CreateItem(ruleDef, _, self)
    local item = Addon.RuleItem:new(self, self.ruleConfig, ruleDef);
    return frame;
end

function RulesList:CompareItems(itemA, itemB)
    local selA = itemA:GetSelected();
    local selB = itemB:GetSelected(); -- todo make this isselected

    -- Push selected items to the front of the list
    if (selA and not selB) then
        return true;
    elseif (not selA and selB) then
        return false;
    elseif (not selA) then
        -- Both aren't selected, use the definiton index.
        return itemA:GetModelIndex() < itemB:GetModelIndex();
    end

    -- Both are selected, use the config index
    return itemA:GetConfigIndex() < itemB:GetConfigIndex();
end

function RulesList.OnLoad(self)
    Mixin(self, Addon.Controls.AutoScrollbarMixin);
    self:OnBackdropLoaded();
    self:AdjustScrollBar(self.List, false);
    self.cache = {};

    -- Set our empty text
    local emptyText = self.EmptyTextKey;
    if (not emptyText) then
        emptyText = self:GetParent().EmptyTextKey;
    end
    if (emptyText) then
        self.EmptyText:SetText(L[emptyText]);
    else
        self.EmptyText:SetText("");
    end

    -- Determine our rule type
    if (not self.ruleType) then
        self.ruleType = self:GetParent().ruleType;
    end

    self.callback = function(action, ruleId)
        if (self.cache[ruleId] or (action == "CREATE")) then
            self:Populate();
            self.needsLayout = true;
        end
    end;

    self.layoutCallback = function()
            self.needsLayout = true;
        end;

    self:SetScript("OnShow", self.OnShow);
    self:SetScript("OnHide", self.OnHide);
    self:SetScript("OnUpdate", self.OnUpdate);
end

--[[===========================================================================
  | Compare two items in the list, our sort order is as follows:
  |  - Enabled state
  |  - Alphabetically by name
  ===========================================================================]]
function ItemCompare(itemA, itemB)
    if (not itemA or not itemB) then
        return nil;
    end 

    local a = itemA:IsEnabled();
    local b = itemB:IsEnabled();

    if (a == b) then
        local ra = itemA:GetRule();
        local rb = itemB:GetRule();
        return ra.Name < rb.Name;
    elseif (b and not a) then
        return false;
    elseif (not b and a) then
        return true;
    end
end

function RulesList:OnShow()
    self.ruleConfig = Addon.RuleConfig:LoadFrom(Addon:GetProfile():GetRules(self.ruleType));
    self:Populate();    
    table.sort(self.items, ItemCompare);

    self:Layout();
    self.ruleConfig:RegisterCallback("OnChanged", 
        function()
            self.needsSave = true;
        end, self);    

    Addon.Rules.OnDefinitionsChanged:Add(self.callback);
end

function RulesList:OnHide()
    if (self.ruleConfig) then
        self.ruleConfig:UnregisterCallback("OnChanged", self);
    end 
    Addon.Rules.OnDefinitionsChanged:Remove(self.callback); 
end

function RulesList:OnUpdate()
    if (self:IsShown()) then
        if (self.needsLayout) then
            self.needsLayout = false;
            self:Layout();
        end
        if (self.items) then
            for _, item in ipairs(self.items) do
                item:OnUpdate();
            end
        end
        if (self.needsSave) then
            self.needsSave = false;
            self:Save();
        end
    end
end

function RulesList:Save()
    if (self.ruleType and self.ruleConfig) then
        local profile = Addon:GetProfile();
        profile:SetRules(self.ruleType, self.ruleConfig:Save());
    end
end

local StackLayoutMixin = {
    Layout = function(cotrol, width, items)
    end
};

function RulesList:Layout()
    local prev = nil;
    local height = 0;
    local width = self.List:GetWidth();
    local parent = self.List:GetScrollChild();
    local viewHeight = self.List:GetHeight();

    if (table.getn(self.items) == 0) then
        self.EmptyText:Show();
    else    
        self.EmptyText:Hide();
    end

    for _, frame in ipairs(self.items) do 
        frame:ClearAllPoints();
        frame:SetWidth(width);
        frame:SetPoint("TOPLEFT", 0, -height);
        frame:Show();

        height = height + frame:GetHeight();
        prev = frame;
    end 

    parent:SetHeight(height);
    parent:SetWidth(width);
end

function RulesList:Populate()
    -- Make sure anything which may already be showing disappears.
    if (self.items) then
        for _, item in ipairs(self.items) do 
            item:ClearAllPoints();
            item:Hide();
            item:SetScript("OnSizeChanged", nil);
        end
    end

    -- Layout the new, or empty item
    self.items = {};
    local defs = Rules.GetDefinitions(self.ruleType);
    local parent = self.List:GetScrollChild();

    for _, ruleDef in ipairs(defs) do 
        local item = self.cache[ruleDef.Id];
        if (not item) then
            item = Addon.RuleItem:new(parent, self.ruleConfig, ruleDef);
            self.cache[ruleDef.Id] = item;
        else 
            item:SetConfig(self.ruleConfig);
        end

        item:SetScript("OnSizeChanged", self.layoutCallback);    
        table.insert(self.items, item);
    end
end

-- Export to Public
Addon.Public.Rules = Addon.Rules
Addon.Public.RulesList = Addon.RulesList