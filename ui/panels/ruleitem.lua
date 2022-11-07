local AddonName, Addon = ...
local L = Addon:GetLocale()
local RuleItem = {}
local EMPTY = {}

local MENU_DIVIDER = {
    hasArrow = false;
    dist = 0,
    isTitle = true;
    isUninteractable = true,
    notCheckable = true,
    iconOnly = true,
    icon = "Interface\\Common\\UI-TooltipDivider-Transparent",
    tCoordLeft = 0,
    tCoordRight = 1,
    tCoordTop = 0,
    tCoordBottom = 1,
    tSizeX = 0,
    tSizeY = 8,
    tFitDropDownSizeX = true,
    text = " ",
    iconInfo = {
        tCoordLeft = 0,
        tCoordRight = 1,
        tCoordTop = 0,
        tCoordBottom = 1,
        tSizeX = 0,
        tSizeY = 8,
        tFitDropDownSizeX = true,
    },
}
    
--[[============================================================================
    |
    ==========================================================================]]
function RuleItem:HasParameters()
    local model = self:GetModel()
    if (model and model.Rule.Params and (table.getn(model.Rule.Params) ~= 0)) then
        return true
    end
    return false
end

--[[============================================================================
    |
    ==========================================================================]]
function RuleItem:ShowParameters(show)
    if (self.ParamArea) then
        local params = self.ParamArea

        if (self:HasParameters()) then
            if (show) then
                params:Show()
                self:LayoutParameters()
                self:SetHeight(self._height + params:GetHeight())
            elseif (not show) then
                self:SetHeight(self._height)
                params:Hide()
            end
        else
            self:SetHeight(self._height)
            params:Hide()
        end
    end
end

--[[============================================================================
    |
    ==========================================================================]]
function RuleItem:LayoutParameters()
    local params = assert(self.ParamArea)
    local height = 0

    for _, frame in pairs(self.ruleParameters) do

        if (frame:IsShown()) then
            frame:ClearAllPoints();
            frame:SetPoint("TOPLEFT", params, "TOPLEFT", 0, -height);
            frame:SetPoint("TOPRIGHT", params, "TOPRIGHT", 0, -height);
            height = height + frame:GetHeight();
        end
    end

    params:SetHeight(height + 2);		
end

--[[============================================================================
    | Creates frames for each of the rules parameters, if there are none
    | this is a no-op and won't do anything.
    ==========================================================================]]
function RuleItem:CreateParameters(model)
    self.ruleParameters = self.ruleParameters  or {}	
    for _, frame in pairs(self.ruleParameters) do
        frame:Hide()
        frame:ClearAllPoints()
    end

    local params = self.ParamArea
    if (not params) then 
        return
    end

    -- If we have parameters then we want to create them
    if (model.Rule.Params and (table.getn(model.Rule.Params) ~= 0)) then
        local height = 0

        for _, param in ipairs(model.Rule.Params) do
            local frame = self.ruleParameters[param.Key]

            if (string.upper(param.Type) == "NUMERIC") then
                if (not frame) then
                    frame = Mixin(CreateFrame("Frame", nil, params, "Vendor_RuleParam_Numeric"), Addon.Panels.NumericParameter)
                    self.ruleParameters[param.Key] = frame;
                    frame:AddListener(self.OnParameterChanged, self)
                end

                frame:SetParameter(param)
                frame:Show()
            else 
                Addon:Debug("rules", "The parameter type '%s' is not valid, skipping parameter '%s'", param.Type, param.Name);
            end 
        end 
    end

    params:Hide()
    self.expanded = false
end

--[[============================================================================
    | Called to change the state of this rule, this will update the model
    | to reflect our current state.
    ==========================================================================]]
function RuleItem:SetActive(active)
    local model = self:GetModel();
    if (active ~= model.Enabled) then
        model.Enabled = active;
        if (model.Enabled) then
            model.Hidden = false
        end
        self:ShowParameters(model.Enabled)
        self:Update(model)

        model.Params = nil;
        if (self:HasParameters()) then
            local params = {}			
            for key, param in pairs(self.ruleParameters or EMPTY) do
                params[key] = param:GetValue()
            end
            model.Params = params
        end

        Addon.Invoke(self:GetList(), "OnModelChanged", model)
    end
end

--[[============================================================================
    | Update the state of our visuals to match the state of the provided model
    ==========================================================================]]
function RuleItem:Update(model)
    self.Unhealthy:Hide()
    self.Migrate:Hide()

    if (not model) then
        model = assert(self:GetModel())
    end

    -- Adjust the background/text colors if the item is enabled.
    if (model.Enabled) then
        self.Enabled:Show()
        self.Selected:Show()
        if (not model.Unhealthy and not model.NeedsMigration) then
            self.Name:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())
        else
            self.Name:SetTextColor(self:GetNameColor(model):GetRGB())
        end
    else
        self.Enabled:Hide()
        self.Selected:Hide()
        self.Name:SetTextColor(self:GetNameColor(model):GetRGB())
    end

    -- If the rule is out of date, or unhealthy that trumps 
    -- the enabled icon.
    if (model.Unhealthy) then
        self.Enabled:Hide()
        self.Unhealthy:Show()
    elseif (model.NeedsMigration) then
        self.Enabled:Hide()
        self.Migrate:Show()
    end

    -- If we have parameters then push them into the parameter views
    self:ShowParameters(model.Enabled);
end

--[[============================================================================
    | Called when the parameters for this item have changed
    ==========================================================================]]
function RuleItem:OnParameterChanged()
    local model = assert(self:GetModel(), "The rule item should have a valid model")
    if (model.Enabled and self:HasParameters()) then
        local params = {}
        for key, param in pairs(self.ruleParameters or EMPTY) do
            params[key] = param:GetValue()
        end

        model.Params = params;
        Addon.Invoke(self:GetList(), "OnModelChanged", model)
    end
end

--[[============================================================================
    | Invoked when the rule item is created
    ==========================================================================]]
function RuleItem:OnCreated()
    self:SetScript("OnEnter", self.OnEnter);
    self:SetScript("OnLeave", self.OnLeave);
    self:SetScript("OnClick", self.OnClick);
    self:SetScript("OnShow", function()
        self:LayoutParameters(self:GetModel().Enabled)
        self:Update(self:GetModel())
    end)
    self:RegisterForClicks("LeftButtonDown", "RightButtonDown");
    self._height = self:GetHeight()
end

--[[============================================================================
    | Called when the model (data) for this item has changed, this should
    | sync all of the states.
    ==========================================================================]]
function RuleItem:OnModelChanged(model)
    self:CreateParameters(model)
    self.Name:SetText(model.Rule.Name)	

    if (self:HasParameters()) then
        local params = model.Params or EMPTY
        for key, param in pairs(self.ruleParameters or EMPTY) do
            param:SetValue(params[key]);
        end
    end

    self.needsUpdate = true;
end

--[[============================================================================
    |
    ==========================================================================]]
function RuleItem:OnUpdate()
    if (self.needsUpdate) then
        self:Update()
        self.needsUpdate = true
    end

    if (self:IsMouseOver()) then
        self.Hover:Show()
    else
        self.Hover:Hide()
    end
end

--[[============================================================================
    |
    ==========================================================================]]
function RuleItem:GetNameColor(model)
    if (model.Hidden) then
        return LIGHTGRAY_FONT_COLOR
    elseif (model.NeedsMigration) then
        return ORANGE_FONT_COLOR
    elseif (model.Unhealthy) then
        return RED_FONT_COLOR
    end
    return NORMAL_FONT_COLOR
end

--[[============================================================================
    |
    ==========================================================================]]
function RuleItem:OnClick(button)
    if (button == "LeftButton") then
        self:SetActive(not self:GetModel().Enabled);
    elseif (button == "RightButton") then
        if (GameTooltip:GetOwner() == self) then
            GameTooltip:Hide()
        end
        self:OnContextMenu()
    end
end

--[[============================================================================
    |
    ==========================================================================]]
function RuleItem:OnEnter()
    local model = self:GetModel();
    if (not model or not model.Rule) then
        return
    end

    local rule = model.Rule
    GameTooltip:SetOwner(self, "ANCHOR_NONE");
    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 2, -2)

    GameTooltip:AddLine(rule.Name, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

    if (model.Hidden) then
        GameTooltip:AddLine(L.RULE_TOOLTIP_HIDDEN, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
    end

    if (model.NeedsMigration) then
        GameTooltip:AddLine(L.RULEITEM_MIGRATE_WARNING, ORANGE_FONT_COLOR.r, ORANGE_FONT_COLOR.g, ORANGE_FONT_COLOR.b, true);
    elseif (model.Unhealthy) then
        GameTooltip:AddLine(L.RULEITEM_UNHEALTHY_WARNING, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
    elseif (rule.Description) then
        GameTooltip:AddLine(rule.Description, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
    end

    GameTooltip:AddLine(" ");
    if (rule.Extension) then
        GameTooltip:AddLine(string.format(L.RULE_TOOLTIP_SOURCE, Addon.HEIRLOOM_BLUE_COLOR:WrapTextInColorCode(rule.Extension.Name)));
    elseif (not rule.Custom) then
        GameTooltip:AddLine(string.format(L.RULE_TOOLTIP_SOURCE, Addon.ARTIFACT_GOLD_COLOR:WrapTextInColorCode(L.RULE_TOOLTIP_SYSTEM_RULE)));
    else
        GameTooltip:AddLine(string.format(L.RULE_TOOLTIP_SOURCE, Addon.RARE_BLUE_COLOR:WrapTextInColorCode(L.RULE_TOOLTIP_CUSTOM_RULE)));
    end

    --@debug@--
    GameTooltip:AddLine("Id: " .. Addon.EPIC_PURPLE_COLOR:WrapTextInColorCode(rule.Id));
    --@end-debug@

    GameTooltip:Show();
end

--[[============================================================================
    |
    ==========================================================================]]
function RuleItem:OnLeave()
    if (GameTooltip:GetOwner() == self) then
        GameTooltip:Hide()
    end
end

--[[============================================================================
    | Called when the context menu needs to be shown for this item.
    ==========================================================================]]
function RuleItem:OnContextMenu()
    local model = assert(self:GetModel(), "A valid model is expected for a visible item")
    local menu = {}

    table.insert(menu, {
        isTitle = true,
        notCheckable = true,
        isNotRadio = true,
        text = model.Rule.Name,
    })

    if (not model.Rule.Custom) then
        table.insert(menu, {
            isNotRadio = true,
            notCheckable = true,
            text = L.RULE_CMENU_VIEW,
            func = function()
                local editRule = Addon:GetFeature("Dialogs")
                editRule:ShowEditRule(self:GetModel().Rule.Id)
            end
        })		
    else
        table.insert(menu, {
            isNotRadio = true,
            notCheckable = true,
            text = L.RULE_CMENU_EDIT,
            func = function()
                local editRule = Addon:GetFeature("Dialogs")
                print("=== editRule:", editRule)
                Addon.TableForEach(ediRule, print)
                editRule:ShowEditRule(self:GetModel().Rule.Id)
            end
        })		
    end

    table.insert(menu, Addon.DeepTableCopy(MENU_DIVIDER))

    if (not model.Enabled) then
        table.insert(menu, {
            isNotRadio = true,
            notCheckable = true,
            text = L.RULE_CMENU_ENABLE,
            func = function()
                self:SetActive(true)
            end
        })
    else
        table.insert(menu, {
            isNotRadio = true,
            notCheckable = true,
            text = L.RULE_CMENU_DISABLE,
            func = function()
                self:SetActive(false)
            end
        })		
    end

    if (not model.Hidden) then
        table.insert(menu, {
            isNotRadio = true,
            notCheckable = true,
            text = L.RULE_CMENU_HIDE,
            func = function()
                Addon.Invoke(self:GetList(), "ChangeHiddenState", self:GetModel().Rule.Id, true)
            end
        })
    else
        table.insert(menu, {
            isNotRadio = true,
            notCheckable = true,
            text = L.RULE_CMENU_SHOW,
            func = function()
                Addon.Invoke(self:GetList(), "ChangeHiddenState", self:GetModel().Rule.Id, false)
            end
        })		
    end

    if (model.Rule.Custom) then    
        table.insert(menu, Addon.DeepTableCopy(MENU_DIVIDER))
        
        table.insert(menu, {
            isNotRadio = true,
            notCheckable = true,
            text = L.RULE_CMENU_DELETE,
            func = function()
                local rule = self:GetModel().Rule
                local dialog = StaticPopup_Show("VENDOR_CONFIRM_DELETE_RULE", rule.Name);
                dialog.data = rule.Id;		
            end
        })		
    end

    table.insert(menu, Addon.DeepTableCopy(MENU_DIVIDER))
    table.insert(menu, {
        isNotRadio = true,
        notCheckable = true,
        text = L.RULE_CMENU_CLOSE,
        func = function() end
    })		

    Addon.Invoke(self:GetList(), "ShowContextMenu", self, menu)
end
        
Addon.Panels = Addon.Panels or {}
Addon.Panels.RuleItem = RuleItem