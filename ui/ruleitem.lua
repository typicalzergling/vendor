--[[===========================================================================
    | Copyright (c) 2018
    |
    | RuleItem:
    |
    ========================================================================--]]

local Addon, L, Config = _G[select(1,...).."_GET"]()
local Package = select(2, ...);
local RuleItem = {};

function RuleItem:ShowMoveButtons(show)
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
end

function RuleItem:SetRule(ruleDef)
    self.ruleId = ruleDef.Id;
    self.selected = false;

    self.name:SetText(ruleDef.Name);
    self.text:SetText(ruleDef.Description);

    self.moveUp.tooltip = L["CONFIG_DIALOG_MOVEUP_TOOLTIP"];
    self.moveDown.tooltip = L["CONFIG_DIALOG_MOVEDOWN_TOOLTIP"];
    self:ShowMoveButtons(false);
    self.check:Hide();
    self.check:SetVertexColor(0, 1, 0, 1);

    -- Disable item level by default
    local itemLevel = self.itemLevel;
    if (itemLevel) then
        itemLevel.label:SetText(L["RULEUI_LABEL_ITEMLEVEL"])
        itemLevel:Disable();
        itemLevel:SetText(0);
    end
end

function RuleItem:GetRuleId()
    return self.ruleId;
end

function RuleItem:SetConfig(config, index)
    self.configIndex = index;
    self:SetSelected(config ~= nil);

    if (self.itemLevel) then
        self.itemLevel:SetNumber(0);
    end        

    if (config and (type(config) == "table")) then
        for paramName, paramValue in pairs(config) do
            if (string.upper(paramName) == "ITEMLEVEL") then
                if (self.itemLevel) then
                    local value = tonumber(paramValue) or 0;
                    self.itemLevel:SetNumber(value);
                end                    
            end
        end            
    end
end

function RuleItem:GetConfig()
    if (not self.selected) then
        return nil;
    end

    if (not self.itemLevel) then
        return string.lower(self:GetRuleId());
    end

    local config = { rule = self:GetRuleId() };
    if (self.itemLevel) then
        config.ITEMLEVEL = self.itemLevel:GetNumber();
    end

    return config;
end

function RuleItem:GetConfigIndex()
    return self.configIndex;
end

function RuleItem:SetSelected(selected)
    self.selected = selected;
    if (selected) then
        self.check:Show();
        self.selectedBackground:Show();
        self:ShowMoveButtons(true);

        if (self.itemLevel) then
            self.itemLevel:Enable();
        end            
    else
        self.check:Hide();
        self.selectedBackground:Hide();
        self:ShowMoveButtons(false);

        if (self.itemLevel) then
            self.itemLevel:Disable();
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
        -- You can view "definition" of system rules.       
        local ruleDef = self:GetModel();
        if (ruleDef) then
            VendorEditRuleDialog:EditRule(ruleDef, not ruleDef.Custom);
        end            
    end
end

Package.RuleItem = RuleItem;
