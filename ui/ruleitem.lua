--[[===========================================================================
    | Copyright (c) 2018
    |
    | RuleItem:
    |
    ========================================================================--]]

local AddonName, Addon = ...
local L = Addon:GetLocale()
local RuleItem = {};

local NUMERIC_PARAM_TEMPLATE = "Vendor_Rule_Numeric_Param";
local PARAM_MARGIN_X = 6;

local RULE_SOURCE_FMT2 = HIGHLIGHT_FONT_COLOR_CODE .. "Source: %s%s|r";
local RULE_ID_FMT1 = HIGHLIGHT_FONT_COLOR_CODE .. "RuleId: " .. NORMAL_FONT_COLOR_CODE .. "\"%s\"|r";
local RULE_SOURCE_TEXT = L.RULEITEM_SOURCE;

local function HandleRuleAction(frame, action, ruleId)
    if (action == "View") then
        local ruleDef = assert(Addon.Rules.GetDefinition(ruleId));
        VendorEditRuleDialog:EditRule(ruleDef, true);
    elseif (action == "Edit") then
        local ruleDef = assert(Addon.Rules.GetDefinition(ruleId));
        VendorEditRuleDialog:EditRule(ruleDef, false);
    end        
end;

local MOVE_UP_ITEM = {
    isNotRadio = true,
    notCheckable = true,
    text = "Move Up",
    tooltipText = "Move this rule up in the priority list",
    arg1 = "MoveUp",
    func = HandleRuleAction,
};

local MOVE_DOWN_ITEM = {
    isNotRadio = true,
    notCheckable = true,
    text = "Move Down",
    tooltipText = "Move this rule downin the priority list",
    arg1 = "MoveDown",
    func = HandleRuleAction,
};

local HIDE_ITEM = {
    isNotRadio = true,
    notCheckable = true,
    text = "Hide",
    tooltipText = "Hides this rule so you will no longer see it in the dialog. [tbd]",
    arg1 = "Hide",
    func = HandleRuleAction,
};

local DELETE_ITEM = {
    isNotRadio = true,
    notCheckable = true,
    text = "Delete",
    tooltipText = "Deletes this rule",
    arg1 = "Delete",
    func = HandleRuleAction,
};

local EDIT_ITEM = {
    isNotRadio = true,
    notCheckable = true,
    text = "Edit",
    tooltipText = "Edit thie rule",
    arg1 = "Edit",
    func = HandleRuleAction,
};

local VIEW_ITEM = {
    isNotRadio = true,
    notCheckable = true,
    text = "View",
    tooltipText = "View this rule",
    arg1 = "View",
    func = HandleRuleAction,
};

local CUSTOM_MENU = {
    EDIT_ITEM,
    MOVE_UP_ITEM,
    MOVE_DOWN_ITEM,
    HIDE_ITEM,
    DELETE_ITEM
}

local EXTENSION_MENU = {
    VIEW_ITEM,
    MOVE_UP_ITEM,
    MOVE_DOWN_ITEM,
    HIDE_ITEM,
};

local BUILTIN_MENU = {
    VIEW_ITEM,
    MOVE_UP_ITEM,
    MOVE_DOWN_ITEM,
    HIDE_ITEM,
};

local NumericParameter = {
    --[[static]]
    Initialize = function(self, control, param)
        Mixin(control, self);
        control.param = param;
        control.key = string.upper(param.Key);
        local edit = control:GetControl();
        edit:SetNumeric(true);
        edit:SetFontObject(GameFontHighlightSmall);
        edit:SetMaxLetters(8);
        control:SetNumber(self.GetDefault(control));
        control.Label:SetText(param.Name or "");
    end,

    GetDefault = function(self)
        local param = self.param;
        local value = nil;

        if (type(param.Default) == "function") then
            success, value = xpcall(param.Default, CallErrorHandler);
        elseif (type(param.Default) == "number") then
            value = param.Default;
        else
            value = 0;
        end 

        return value;
    end,

    Save = function(self, target)
        local value = self:GetNumber();
        if (value == nil or (self:GetText() == "")) then
            value = self:GetDefault();
        end 
        target[self.key] = (value or 0);
    end,

    Load = function(self, target)
        local value = target[self.key] or 0;
        if ((value == nil) or not table.hasKey(target, self.key)) then
            value = self:GetDefault();
        end
        self:SetNumber(value);
    end,

    Default =function(self, target)
        target[self.key] = self:GetDefault();
    end,
}

local RuleItem = {

    --[[staic]]--
    Create = function(parent, ruleDef)
        local instance = CreateFrame("Button", nil, parent, "Vendor_RuleItem_Simple");
        instance:SetRule(ruleDef);
        return instance;
    end,

    OnLoad = function(self)
        Mixin(self, CallbackRegistryMixin);
        CallbackRegistryMixin.OnLoad(self);
        CallbackRegistryMixin.GenerateCallbackEvents(self, { "OnExpanded" });
        self:SetScript("OnEnter", self.OnEnter);
        self:SetScript("OnLeave", self.OnLeave);
        self:SetScript("OnClick", self.OnClick);
        self:SetScript("OnShow", self.OnShow);
        self:SetScript("OnHide", self.OnHide);
        self:RegisterForClicks("LeftButtonDown", "RightButtonDown");

        self.enabled = false;
        self.migrate = false;
        self.unhealthy = false;
    end,
    
    SetRule = function(self, ruleDef)
        self.ruleId = ruleDef.Id;
        self.rule = ruleDef;
        self.Name:SetText(ruleDef.Name);
        self.migrate = ruleDef.needsMigration;
        self:CreateParameters();
    end,

    GetRule = function(self)
        return self.rule;
    end,

    GetRuleId = function(self)
        return self.ruleId;
    end,

    Compare = function(self, other)
    end,

    SetMove = function(self)
    end,

    SetConfig = function(self, config)
        if (config ~= self.config) then
            self.config = config;
            if (self:IsShown()) then
                self:Update(config:Get(self:GetRuleId()));
            end
        end
    end,

    OnUpdate = function(self)
        self:SetHover(self:IsMouseOver());
    end,

    OnEnter = function(self)
        if (self.rule) then
            local rule = self.rule;
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
            GameTooltip:AddLine(rule.Name, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

            if (self.migrate) then
                GameTooltip:AddLine(L["RULEITEM_MIGRATE_WARNING"], ORANGE_FONT_COLOR.r, ORANGE_FONT_COLOR.g, ORANGE_FONT_COLOR.b, true);
            elseif (self.unhealthy) then
                GameTooltip:AddLine(L["RULEITEM_UNHEALTHY_WARNING"], RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
            elseif (rule.Description) then
                GameTooltip:AddLine(rule.Description, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
            end

            GameTooltip:AddLine("");
            if (rule.Extension) then
                GameTooltip:AddLine(RULE_SOURCE_TEXT .. HEIRLOOM_BLUE_COLOR:WrapTextInColorCode(rule.Extension.Name));
            elseif (not rule.Custom) then
                GameTooltip:AddLine(RULE_SOURCE_TEXT .. ARTIFACT_GOLD_COLOR:WrapTextInColorCode("Built-In"));
            else
                GameTooltip:AddLine(RULE_SOURCE_TEXT .. RARE_BLUE_COLOR:WrapTextInColorCode("Custom Rule"));
            end


            --@debug@--
            -- In debug we get a rule id
            GameTooltip:AddLine(HIGHLIGHT_FONT_COLOR_CODE .. "RuleId: " .. EPIC_PURPLE_COLOR:WrapTextInColorCode(rule.Id));
            --@end-debug@

            GameTooltip:Show();
        end
    end,

    OnLeave = function(self)
        GameTooltip:Hide();
    end,

    OnClick = function(self, button)
        if (button == "RightButton") then
            local menu = BUILTIN_MENU;
            if (self.rule.Custom) then
                menu = CUSTOM_MENU;
            elseif (self.rule.Extension) then
                menu = EXTENSION_MENU;
            end

            table.forEach(menu, function(item) item.arg2 = self.ruleId end);

            local menuFrame = CreateFrame("Frame", "VendorRulesContextMenu", UIParent, "UIDropDownMenuTemplate");
            EasyMenu(menu, menuFrame, "cursor", 0, 0, "MENU");
            --menuFrame:SetPoint("CENTER", UIParent, "CENTER");
            --Easty
        elseif (button == "LeftButton") then
            self:Toggle();
        end
    end,
};

function RuleItem:OnShow()
    if (self.config) then
        self:Update(self.config:Get(self:GetRuleId()));
    end
end

function RuleItem:OnHide()
end

function RuleItem:SetNameColor()
    local color = DISABLED_FONT_COLOR;
    if (self.migrate) then
        color = ORANGE_FONT_COLOR;
    elseif (self.unhealthy and (self.enabled or self.hover)) then
        color = RED_FONT_COLOR;
    elseif (self.unhealthy and not self.enabled) then
        color = DULL_RED_FONT_COLOR;
    elseif (self.enabled or self.hover) then
        color = HIGHLIGHT_FONT_COLOR;
    end
    self.Name:SetTextColor(color:GetRGB());
end

function RuleItem:Update(config)
    if (config) then
        self.enabled = true;
        self.Selected:Show();
        self.Check:Show();
        if (self:HasParameters()) then
            self:LoadParameters(config);
            self:SetHeight(self.collpasedHeight + self.Params:GetHeight());
            self.Params:Show();
        end
    else
        self.config:Remove(self.ruleId);
        self.enabled = false;
        self.Selected:Hide();
        self.Check:Hide();
        if (self:HasParameters()) then
            self:SetHeight(self.collpasedHeight);
            self.Params:Hide();
        end
    end
    self:SetNameColor();
end

function RuleItem:IsEnabled()
    return (self.enabled == true);
end

-- True if this item has parametes
function RuleItem:HasParameters()
    return self.rule and 
        self.rule.Params and 
        (table.getn(self.rule.Params) ~= 0);
end 

function RuleItem:SaveParmeters()
    if (not self:HasParameters()) then
        return nil;
    end

    local data = {}
    table.forEach(self.paramTemplates,
        function(param)
            param:Save(data);
        end);

    return data;
end

function RuleItem:LoadParameters(data)
    if (self.paramTemplates)     then
        data = data or {};
        table.forEach(self.paramTemplates, 
            function(param)
                param:Load(data);
            end);
    end
end

function RuleItem:GetDefaults()
    if (not self:HasParameters())  then
        return self:GetRuleId();
    end

    data = {};
    table.forEach(self.paramTemplates,
        function(param)
            param:Default(data);
        end);

    data.rule = self:GetRuleId();
    return data;
end

function RuleItem:Toggle()
    local config = nil;
    if (not self.enabled) then
        config = self.config:Set(self:GetRuleId(), self:SaveParmeters());
    else   
        self.config:Remove(self:GetRuleId());
    end
    self:Update(config);
end

function RuleItem:SetHover(hover)
    if (not self.hover and hover) then
        self.hover = true;
        self.Hover:Show();
        self:SetNameColor();
    elseif (self.hover and not hover) then
        self.hover = false;
        self.Hover:Hide()
        self:SetNameColor();
    end
end

--[[function RuleItem:ShowMoveButtons(show)
    local moveUp = self.moveUp;
    local moveDown = self.moveDown;
    if (show) then
        if (moveUp:IsEnabled()) then
            moveUp:Show();
        else
            moveUp:Hide();
        end

        if (moveDown:IsEnabled()) then
            moveDown:Show();
        else
            moveDown:Hide();
        end
    else
        moveUp:Hide();
        moveDown:Hide();
    end
end

function RuleItem:SetMove(canMoveUp, canMoveDown)
    local moveUp = self.moveUp;
    local moveDown = self.moveDown;

    if (canMoveUp) then
        moveUp:Enable();
    else
        moveUp:Disable();
    end

    if (canMoveDown) then
        moveDown:Enable();
    else
        moveDown:Disable();
    end
    self:ShowMoveButtons(self.selected);
end

function RuleItem:ShowDivider(show)
    if (show) then
         self.divider:Show();
    else
        self.divider:Hide();
    end
end]]

local function updateConfig(self)
    if (self.config) then
        self.config:Set(self:GetRuleId(), self:SaveParmeters());
    end
end

--[[============================================================================
    | Creates frames for each of the rules parameters, if there are none
    | this is a no-op and won't do anything.
    ==========================================================================]]
function RuleItem:CreateParameters()
    local rule = self:GetRule();
    if (not rule or not rule.Params or (select("#", rule.Params) < 1)) then
        return;
    end

    local params = self.Params;
    local height = 0;
    assert(not self.paramTemplates or table.getn(self.paramTemplates) == 0);

    self.paramTemplates = {};
    for _, param in ipairs(rule.Params) do
        local frame = nil;
        if (string.upper(param.Type) == "NUMERIC") then
            frame = CreateFrame("Frame", nil, params, NUMERIC_PARAM_TEMPLATE);
            NumericParameter:Initialize(frame, param);
            frame:RegisterCallback("OnChange", updateConfig, self);
        else 
            Addon:Debug("rules", "The parameter type '%s' is not valid, skipping parameter '%s'", param.Type, param.Name);
        end 

        if (frame) then
            frame:ClearAllPoints();
            frame:SetPoint("TOPRIGHT", params, "TOPRIGHT", 0, -height);
            height = height + frame:GetHeight();
            table.insert(self.paramTemplates, frame);
        end
    end 

    params:SetHeight(height + 2);
    params:Hide();
end 

--[[
============================================================================
    | RuleItem:LayoutParameters:
    |   If we've got parameters then we need to give the layout, we have
    |   "hidden" item in the markup where we anchor them to, but we also
    |   need to move the text so it properly wraps when we've got a parameter
    ==========================================================================
function RuleItem:LayoutParameters()
    if (self.params and table.getn(self.params)) then
        local anchor;
        local width = 0;
        for _, frame in ipairs(self.params) do
            frame:ClearAllPoints();
            if (not anchor) then
                frame:SetPoint("BOTTOMRIGHT", self.paramArea, "BOTTOMRIGHT", 0, 0);
            else
                frame:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMLEFT", -PARAM_MARGIN_X, 0);
            end
            frame:Show();
            anchor = frame;
            width = (width + frame:GetWidth() + PARAM_MARGIN_X);
        end

        self.paramArea:SetWidth(width);
        self.text:SetPoint("BOTTOMRIGHT", self.paramArea, "BOTTOMLEFT", -PARAM_MARGIN_X, 0);
    else
        -- Make sure this is the same as the XML
        self.text:SetPoint("BOTTOMRIGHT", self.paramArea, "BOTTOMLEFT", 0, 0);
    end
end

============================================================================
    | RuleItem:SetParamValue
    |   Given the name of a parameter, and it's value this will handle setting
    |   the value on the frame, the first frame with the name is the one
    |   that gets the value.
    ==========================================================================
function RuleItem:SetParamValue(name, value)
    if (self.params) then
        for _, frame in ipairs(self.params) do
            if (string.upper(name) == frame.paramKey) then
                if (frame.paramType == "NUMERIC") then
                    -- If we numeric then we know the value is an editbox
                    -- in numeric mode,  just call "SetNumber"
                    frame:SetNumber(value);
                end
            else
                Addon:Debug("rules", "The parameter type '%s' is unknown for '%s' - rule %s", frame.paramType, name, tostring(self.ruleId));
            end
        end
    end
end

[============================================================================
    | RuleItem:GetParamValue:
    |   Given a frame this retrieves the value.
    ==========================================================================
function RuleItem:GetParamValue(frame)
    if (frame.paramType == "NUMERIC") then
        return frame:GetNumber();
    else
        Addon:Debug("rules", "The frame has an invalid parameter type '%s'", frame.paramType);
    end
end

function RuleItem:SetRule(ruleDef)
    self.ruleId = ruleDef.Id;
    self.selected = false;

    self.name:SetText(ruleDef.Name);
    self.text:SetText(ruleDef.Description);

    self.moveUp.tooltip = L["CONFIG_DIALOG_MOVEUP_TOOLTIP"];
    self.moveDown.tooltip = L["CONFIG_DIALOG_MOVEDOWN_TOOLTIP"];
    self.migrationText:SetText(L["RULEITEM_MIGRATE_WARNING"])
    self:ShowMoveButtons(false);
    self.check:Hide();
    self.check:SetVertexColor(0, 1, 0, 1);

    local ruleManager = Addon:GetRuleManager();
    if (ruleManager and not ruleManager:CheckRuleHealth(ruleDef.Id)) then
        self.background:Show();
        self.background:SetColorTexture(ORANGE_FONT_COLOR.r, ORANGE_FONT_COLOR.g, ORANGE_FONT_COLOR.b, 0.25);
        self.unhealthy:Show();
        self.migration:Hide();
        self.migrationText:Hide();
        self.text:Show();
    elseif (ruleDef.needsMigration) then
        self.background:Show();
        self.background:SetColorTexture(YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b, 0.05);
        self.unhealthy:Hide();
        self.migration:Show();
        self.migrationText:Show();
        self.text:Hide();
    else
        self.background:Hide();
        self.unhealthy:Hide();
        self.migration:Hide();
        self.migrationText:Hide();
        self.text:Show();
    end

    if (ruleDef.Custom) then
        self.custom:Show();
        self.extension:Hide();
    elseif (Addon.Rules.IsExtension(ruleDef)) then
        self.custom:Hide();
        self.extension:Show();
    else
        self.custom:Hide();
        self.extension:Hide();
    end

    if (ruleDef.Params) then
        self:CreateParameters(ruleDef.Params);
    end
    self:LayoutParameters();
end

function RuleItem:GetRuleId()
    return self.ruleId;
end

============================================================================
    | RuleItem:SetConfig
    |   Set the configuration of this item.
    ==========================================================================
function RuleItem:SetConfig(config, index)
    if (config and (type(config) == "table")) then
        for paramName, paramValue in pairs(config) do
            if (string.lower(paramName) ~= "rule") then
                self:SetParamValue(paramName, paramValue);
            end
        end
    end

    self.configIndex = index;
    self:SetSelected(config ~= nil);

    if (config ~= nil and self.migrationText:IsShown()) then 
        self.background:SetColorTexture(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 0.1);
    end
end

============================================================================
    | RuleItem:GetConfig
    |   Builds and retrieves the config entry for this rule, or return
    |   nil to indicate this rule isn't enabled.
    ==========================================================================
function RuleItem:GetConfig()
    if (not self.selected) then
        return nil;
    end

    -- If we've got no parameters then simply want to return the
    -- rule id, rather building a table.
    if (not self.params or (table.getn(self.params) == 0)) then
        return self:GetRuleId();
    end

    -- We've got parameters, so copy each one out into the
    -- the table we're going to return.
    local config = { rule = self:GetRuleId() };
    for _, frame in ipairs(self.params) do
        rawset(config, frame.paramKey, self:GetParamValue(frame));
    end

    return config;
end

function RuleItem:GetConfigIndex()
    return self.configIndex;
end

============================================================================
    | RuleItem:SetSelected:
    |   Sets the selected  / enabled state of this item and updates all
    |   the UI to reflect that state.
    ==========================================================================
function RuleItem:SetSelected(selected)
    self.selected = selected;
    if (selected) then
        self.check:Show();
        self.selectedBackground:Show();
        self:ShowMoveButtons(true);
    else
        self.check:Hide();
        self.selectedBackground:Hide();
        self:ShowMoveButtons(false);
    end

    if (self.params) then
        for _, frame in ipairs(self.params) do
            if (selected) then
                frame:Enable();
            else
                frame:Disable();
            end
        end
    end

    if (self.migrationText:IsShown()) then 
        if (selected) then
            self.background:SetColorTexture(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 0.1);
        else
            self.background:SetColorTexture(YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b, 0.05);
        end 
    end
end

function RuleItem:GetSelected()
    return self.selected;
end

function RuleItem:OnClick(button)
    if (button == "LeftButton") then
        self:SetSelected(not self.selected);
    elseif (button == "RightButton") then
        -- You can view "definition" of system rules, and extension rules
        -- you can edit custom rules.
        local ruleDef = self:GetModel();
        if (ruleDef) then
            VendorEditRuleDialog:EditRule(ruleDef, ruleDef.ReadOnly or not ruleDef.Custom);
        end
    end
end

============================================================================
    | RuleItem:OnMouseEnter:
    |   Called when the user mouses over the item if our item text is truncated
    |   then we will show a tooltip for the item.
    ==========================================================================
function RuleItem:OnMouseEnter()
    if (self.text:IsTruncated()) then
        local nameColor = { self.name:GetTextColor() };
        local textColor = { self.text:GetTextColor() };
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
        GameTooltip:AddLine(self.name:GetText(), unpack(nameColor));
        GameTooltip:AddLine(self.text:GetText(), unpack(textColor));
        GameTooltip:Show();
    end
end

============================================================================
    | RuleItem:OnMouseLeave:
    |   Called when the user mouses off the item
    ==========================================================================
function RuleItem:OnMouseLeave()
    if (GameTooltip:GetOwner() == self) then
        GameTooltip:Hide();
    end
end
]]

Addon.RuleItem = {
       --[[staic]]--
       new = function(self, parent, config, ruleDef)
        local instance = Mixin(CreateFrame("Button", nil, parent, "Vendor_RuleItem_Simple"), RuleItem);
        RuleItem.OnLoad(instance);
        instance:SetRule(ruleDef);
        instance:SetConfig(config);
        return instance;
    end,
}