local Addon, L = _G[select(1,...).."_GET"]()
Addon.CustomRuleList = {};
local Package=select(2,...);
local CustomRuleList=Addon.CustomRuleList;
local Rules=Addon.Rules;
local CustomRule = {};
local VENDOR_STATICPOPUP_CONFIRM_DELETE="VENDOR_CONFIRM_DELETE_CUSTOM_RULE";

--[[===========================================================================
    | SetShareButton:
    |   Updates the share button, text/tooltip
    ========================================================================--]]
function CustomRule:Init(ruleDef)
    if (self.author) then
        local font, size = self.author:GetFont();
        self.author:SetFont(font, 6.0, "MONOCHROME");
        self.author:SetAlpha(0.25);
        if (ruleDef.EditedBy) then
            self.author:SetText(ruleDef.EditedBy);
        end            
    end

    self.name:SetText(ruleDef.Name);
    self.text:SetText(ruleDef.Description);
    self.shareButton.tooltip = L["CONFIG_DIALOG_SHARE_TOOLTIP"];
    self.shareButton:Disable();
end


--[[===========================================================================
    | EditRule
    |   Called to handle editing the rule associated with the specified item
    ========================================================================--]]
function CustomRule:EditRule()
    VendorEditRuleDialog:EditRule(self:GetModel());
end

--[[===========================================================================
    | ShareRule
    |   TBD
    ========================================================================--]]
function CustomRule:ShareRule()
end

--[[===========================================================================
    | DeleteRule
    |   Prompts to delete the rule for the provided item.
    ========================================================================--]]
function CustomRule:DeleteRule()
    local ruleDef = self:GetModel();
    local popup = StaticPopup_Show(VENDOR_STATICPOPUP_CONFIRM_DELETE, ruleDef.Name);
    if (popup) then
        popup.data = ruleDef.Id;
    else
        UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
    end
end

function CustomRuleList:CreateItem(ruleDef)
    local item = Mixin(CreateFrame("Button", nil, self, "Vendor_CustomRule_Template"), CustomRule);
    item:Init(ruleDef);
    return item;
end

--[[===========================================================================
    | sortItems (local)
    |   Sort the items in the custom rule list, we sort them alphabetically
    ========================================================================--]]
function CustomRuleList:CompareItems(itemA, itemB)
    return (itemA.name:GetText() < itemB.name:GetText());
end

--[[===========================================================================
    | OnLoad
    |   Called when the panel is loaded, we adjust the scrollbar, and sub
    |   subscribe for changes that would affect the list.
    ========================================================================--]]
function CustomRuleList.OnLoad(self)
    Mixin(self, Package.ListBase, CustomRuleList);
    self:AdjustScrollbar(self);

    -- Subscribe for changes (We need update when our definitions change)
    Rules.OnDefinitionsChanged:Add(
        function()
            self:RebuildView(Rules.GetCustomDefinitions());
        end);
end

--[[===========================================================================
    | OnShow
    |   When the list is shown, we need to adjust the state and sync to the
    |   rule definitions, we use this in other cases as well.
    ========================================================================--]]
function CustomRuleList:OnShow()
    self:UpdateView(Rules.GetCustomDefinitions());
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
