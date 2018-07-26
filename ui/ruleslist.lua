local Addon, L = _G[select(1,...).."_GET"]()
Addon.RulesUI = {}
Addon.Rules = Addon.Rules or {};
local Rules = Addon.Rules;

function table.swap(T, i, j)
    local tmp = rawget(T, i)
    rawset(T, i, rawget(T, j))
    rawset(T, j, tmp)
end

Addon.RulesList =
{
    HideMoveButtons = function(rule)
        rule.MoveUp:Hide()
        rule.MoveDown:Hide()
    end,

    --*****************************************************************************
    -- Updates the state of the up/down arrows for the specified rule item
    --*****************************************************************************
    UpdateMoveButtons = function(rule)
        if (rule.first and rule.last) then
            rule.MoveUp:Hide();
            rule.MoveDown:Hide();
        elseif (rule.first) then
            rule.MoveUp:Hide()
            rule.MoveDown:Show()
        elseif (rule.last) then
            rule.MoveUp:Show()
            rule.MoveDown:Hide()
        else
            rule.MoveUp:Show()
            rule.MoveDown:Show()
        end
    end,

    --*****************************************************************************
    -- Move the rule within the list on spot in the given direction
    --*****************************************************************************
    MoveRule = function(ruleList, rule, direction)
        local newIndex = (rule.index + direction)
        if ((newIndex >= 1) and (newIndex <= #ruleList.Rules)) then
            table.swap(ruleList.Rules, rule.index, newIndex)
            Addon.RulesUI.UpdateRuleList(ruleList)
        end
    end,

    --*****************************************************************************
    -- Searches the given table for the frame represented by the specified rule
    -- config, and if it's found then it returns the index where the item is
    --*****************************************************************************
    findRuleById = function(rules, ruleConfig)
        local ruleId = ruleConfig
        if (type(ruleId) == "table") then
            ruleId = ruleId.rule
        end
        if (rules) then
            for i,rule in ipairs(rules) do
                if (ruleId == rule.RuleId) then
                    return i
                end
            end
        end
        return -1
    end,
}

local function toggleRuleWithItemLevel(frame)
    if (frame.ItemLevel) then
        if (frame.Enabled:GetChecked()) then
            frame.ItemLevel:Enable()
        else
            frame.ItemLevel:Disable()
        end
    end
end

--*****************************************************************************
-- Determines if the specified rule is enabled based on the provied rule
-- list by looking for a match on the ID.
--*****************************************************************************
local function updateRuleEnabledState(ruleFrame, ruleConfig)
    ruleFrame.Enabled:SetChecked(false)
    if (ruleFrame.ItemLevel) then
        ruleFrame.ItemLevel:SetNumber(0)
        ruleFrame.ItemLevel:Disable()
    end

    for _, entry in pairs(ruleConfig) do
        if (type(entry) == "string") then
            if (entry == ruleFrame.RuleId) then
                ruleFrame.Enabled:SetChecked(true)

                if (ruleFrame.ItemLevel) then
                    ruleFrame.ItemLevel:SetNumber(0)
                    ruleFrame.Enabled:SetChecked(false)
                    ruleFrame.ItemLevel:Disable()
                end
            end
        elseif (type(entry) == "table") then
            local ruleId = entry["rule"]
            if (ruleId and (ruleId == ruleFrame.RuleId)) then
                ruleFrame.Enabled:SetChecked(true)

                if (ruleFrame.ItemLevel) then
                    if (type(entry["itemlevel"]) == "number") then
                        ruleFrame.ItemLevel:SetNumber(entry["itemlevel"])
                    else
                        ruleFrame.ItemLevel:SetNumber(0)
                        ruleFrame.Enabled:SetChecked(false)
                        ruleFrame.ItemLevel:Disable()
                    end
                end
            end
        end
    end

    toggleRuleWithItemLevel(ruleFrame)
end

local function ruleNeeds(rule, inset)
    inset = string.lower(inset)
    if (rule.InsetsNeeded) then
        for _, needed in ipairs(rule.InsetsNeeded) do
            if (string.lower(needed) == inset) then
                return true
            end
        end
    end
end

--*****************************************************************************
-- Helper function which sets up the rule item, this can be called multiple
-- times for custom rules.
--*****************************************************************************
local function setRuleItem(frame, rule)
    frame.Rule = rule
    frame.RuleName:SetText(rule.Name)
    frame.RuleDescription:SetText(rule.Description)
end

--*****************************************************************************
-- Create a new frame for a rule item in the provided list. This will setup
-- the item for all of the proeprties of the rule
--
--*****************************************************************************

--*****************************************************************************
-- Builds a list of rules which shoudl be enalbed based on the state of
-- rules within the list.
--*****************************************************************************
local function getRuleConfigFromList(frame)
    local config = {}
    if (frame.Rules) then
        for _, ruleItem in ipairs(frame.Rules) do
            if (ruleItem.Enabled:GetChecked()) then
                local entry = { rule = ruleItem.RuleId }

                if (ruleItem.ItemLevel) then
                    local ilvl = ruleItem.ItemLevel:GetNumber()
                    if (ilvl ~= 0) then
                        entry.itemlevel = ilvl
                    else
                        entry = nil
                    end
                end

                if (entry) then
                    table.insert(config, entry)
                end
            end
        end
    end
    return config
end

--*****************************************************************************
-- Updates the state of the list based on the config passed in
--*****************************************************************************
local function setRuleConfigFromList(frame, config)
    frame.RuleConfig = config or {}
    if (frame.Rules) then
        local rules = frame.Rules

        -- First update each item in the list
        for _, ruleFrame in ipairs(rules) do
            updateRuleEnabledState(ruleFrame, config)
            ruleFrame.index = -1
        end

        -- Second re-order the list to reflect the order of the rules
        for i, ruleConfig in ipairs(config) do
            local ruleIndex = Addon.RulesList.findRuleById(rules, ruleConfig)
            if (ruleIndex ~= -1) then
                if (ruleIndex ~= i) then
                    table.swap(rules, ruleIndex, i)
                    rules[i].index = 0
                else
                    rules[i].index = 0
                end
            end
        end

        -- Third the remaining rules should be sorted by the order
        -- of execution (items without an order are pushed to the end)
        if (#config ~= #rules) then
            local start = #config
            local part = { select(start + 1, unpack(rules)) }

            table.sort(part,
                function (ruleA, ruleB)
                    return ((ruleA.Rule.Order or 0) < (ruleB.Rule.Order or 0))
                end)

            for i=1,#part do
                rules[start + i] = part[i]
            end
        end
    end
    Addon.RulesUI.UpdateRuleList(frame)
end

--*****************************************************************************
-- Helper function which looks for the frame which corresponds to the 
-- particular rule ID.
--*****************************************************************************
local function findRuleFrameByRuleId(frame, ruleId)
    if (frame.Rules) then
        for _, ruleFrame in ipairs(frame.Rules) do
            if (ruleFrame.RuleId == ruleId) then
                return ruleFrame
            end
        end
    end        
    return nil;
end

--*****************************************************************************
-- Called when a rules list is loaded in order to populate the list of
-- frames which represent the rules contained in the list.
--*****************************************************************************
function Addon.RulesUI.InitRuleList(frame, ruleType, ruleList, ruleConfig)
    frame.RuleFrameSize = 0
    frame.NumVisible = 0
    frame.GetRuleConfig = getRuleConfigFromList
    frame.SetRuleConfig = setRuleConfigFromList
    frame.RuleConfig = ruleConfig or {}
    frame.RuleList = ruleList
    frame.RuleType = ruleType

    assert(frame.RuleList, "Rule List frame needs to have the rule list set")
    assert(frame.RuleType, "Rule List frame needs to have the rule type set")

    -- Create the frame for each of our rules.
    for id, rule in pairs(ruleList) do
        if (not rule.Locked) then
            -- See if we already have a frame for this rule, if we do
            -- then we can just reuse it.
            local ruleFrame = findRuleFrameByRuleId(frame, id);
            if (not ruleFrame) then
                ruleFrame = createRuleItem(frame, id, rule)
            else
                setRuleItem(ruleFrame, rule);
            end
            
            frame.RuleFrameSize = math.max(frame.RuleFrameSize, ruleFrame:GetHeight())
        end
    end

    -- Give an initial update of the view
    Addon.RulesUI.UpdateRuleList(frame)
end

--*****************************************************************************
-- Called when the list is scrolled/created and will iterate through our list
-- of frames an then show/hide and position the frames which should be
-- currently visibile.
--*****************************************************************************
function Addon.RulesUI.UpdateRuleList(frame)
    if (frame.Rules) then
        local offset = FauxScrollFrame_GetOffset(frame.View)
        local ruleHeight = frame.RuleFrameSize
        local previousFrame = nil
        local totalItems = #frame.Rules
        local numVisible = math.floor(frame.View:GetHeight() / frame.RuleFrameSize)
        local startIndex = (1 + offset)
        local endIndex = math.min(totalItems, offset + numVisible)

        FauxScrollFrame_Update(frame.View, totalItems, numVisible, frame.RuleFrameSize, nil, nil, nil, nil, nil, nil, true)
        for ruleIndex=1,#frame.Rules do
            local ruleFrame = frame.Rules[ruleIndex]
            ruleFrame.index = ruleIndex
            ruleFrame.first = (ruleIndex == 1)
            ruleFrame.last = (ruleIndex == totalItems)
            if ((ruleIndex < startIndex) or (ruleIndex > endIndex)) then
                ruleFrame:Hide()
            else
                if (previousFrame) then
                    ruleFrame:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, 0)
                    ruleFrame:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT", 0, 0)
                else
                    ruleFrame:SetPoint("TOPLEFT", frame.View, "TOPLEFT", 0, 0)
                    ruleFrame:SetPoint("TOPRIGHT", frame.View, "TOPRIGHT", 0, 0)
                end
                if (not ruleFrame:IsShown()) then
                    ruleFrame:Show()
                end

                if (not ruleFrame.last) then
                    ruleFrame.Divider:Show()
                else
                    ruleFrame.Divider:Hide()
                end

                if (ruleFrame:IsMouseOver()) then
                    Addon.RulesList.UpdateMoveButtons(ruleFrame)
                else
                    Addon.RulesList.HideMoveButtons(ruleFrame)
                end

                previousFrame = ruleFrame
            end
        end
    end
end

local RulesList = Addon.RulesList;

local function createItem(self, ruleDef)
    local template = "Vendor_Rule_Template"
    if (ruleDef.NeedsParams and ruleDef.NeedsParams.ITEMLEVEL) then
        template = "Vendor_Rule_Template_ItemLevel"
    end

    local item = CreateFrame("Button", nil, self, template)
    item.ruleId = ruleDef.Id;
    item.enabled = false;

    item.name:SetText(ruleDef.Name);
    item.text:SetText(ruleDef.Description);

    if (item.ItemLevel) then
        item.ItemLevel.Label:SetText(L["RULEUI_LABEL_ITEMLEVEL"])
        --item.ToggleRuleState = toggleRuleWithItemLevel
    end

    --updateRuleEnabledState(frame, parent.RuleConfig)
    return item;
end

local function findItem(self, ruleId)
    if (self.items) then
        local id = string.lower(ruleId);
        for _, item in ipairs(self.items) do
            if (string.lower(item.ruleId) == id) then
                return item;
            end
        end
    end
end

local function ensureItems(self, ruleDefs)
    local ids = {}
    for i, ruleDef in ipairs(ruleDefs) do
        print("--- rule:", ruleDef.Id);
        table.insert(ids, string.lower(ruleDef.Id));

        local item = findItem(self, ruleDef.Id);
        if (not item) then
            item = createItem(self, ruleDef);
            item.order = i;
        end
    end

    table.sort(self.items, 
        function(itemA, itemB)
            if (itemA.enabled and not itemB.enabled) then
                return true;
            elseif (not itemA.enabled and itemB.enabled) then
                return false;
            end        
            return (itemA.order < itemB.order);
        end);
end

function RulesList.OnLoad(self)
    print("ruleList: onLoad");
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

function RulesList.OnShow(self)
    print("ruleList: onShow(", self.ruleType, ")");
    if (self.ruleType) then
        ensureItems(self, Rules.GetDefinitions(self.ruleType));
        RulesList.Update(self);
    end
end

function RulesList.Update(self)
    print("ruleList: update");
    local items = self.items or {};

    -- Show/Hide the empty text
    if (#items == 0) then
        self.emptyText:Show();
    else
        self.emptyText:Hide();
    end        

    -- Update the visible custom rules
    local offset = FauxScrollFrame_GetOffset(self);
    local visible = math.floor(self:GetHeight() / 64);
    local anchor = nil;
    local first = (1 + offset);
    local last = (first + visible);
    local width = (self:GetWidth() - self.ScrollBar:GetWidth() - 1);

    FauxScrollFrame_Update(self, #items, visible, 64, nil, nil, nil, nil, nil, nil, true);
    for index,item in ipairs(items) do
        item:ClearAllPoints();
        if ((index >= first) and (index < last)) then
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

function RulesList.OnRuleItemMouseUp(ruleItem, mouseButton)
    local ruleType = ruleItem:GetParent().RuleType;
    if (ruleType ~= Addon.c_RuleType_Custom) then
        -- System rules can be displayed (read-only) by shift-right click
        if ((mouseButton == "RightButton") and IsShiftKeyDown()) then
            VendorEditRuleDialog:EditRule(ruleItem.Rule, true)
        end
    elseif ((ruleType == Addon.c_RuleType_Custom) and (mouseButton == "LeftButton")) then
        -- Custom rules are edited by double clicking.  So in order to handle that
        -- we need to set a timer and when it expires clear the double click logic. When
        -- the timer expires (it's a single shot) we clear the time which means we don't
        -- have a click pending, otherwise it's valid and we've got a click pending so
        --- this has become a double click.
        if (not ruleItem.timer) then
            ruleItem.timer = C_Timer.NewTicker(0.500, function() ruleItem.timer = nil; end);
        else
            ruleItem.timer:Cancel();
            ruleItem.timer = nil;
            VendorEditRuleDialog:EditRule(ruleItem.Rule, false);
        end
    end
end

function Addon.RulesUI.ApplySystemRuleConfig(frame)
    Addon:DebugRules("Applying config for rule type '%s'", frame.RuleType)
    Addon:GetConfig():SetRulesConfig(frame.RuleType, getRuleConfigFromList(frame))
end
