local _, Addon = ...;
local L = Addon:GetLocale();
local RulesConfig = {};
local RuleTypeItem = {};
local RuleType = Addon.RuleType;
local EMPTY = {}

local RULE_TYPES = 
{
	{
		Type = RuleType.KEEP,
		Name = L.RULE_TYPE_KEEP_NAME,
		Description = L.RULE_TYPE_KEEP_DESCR,
		Empty = L.RULE_LIST_EMPTY,
	},
	{
		Type = RuleType.SELL,
		Name = L.RULE_TYPE_SELL_NAME,
		Description = L.RULE_TYPE_SELL_DESCR,
		Empty = L.RULE_LIST_EMPTY,
	},
	{
		Type = RuleType.DESTROY,
		Name = L.RULE_TYPE_DELETE_NAME,
		Description = L.RULE_TYPE_DELETE_DESCR,
		Empty = L.RULE_LIST_EMPTY,
	}
}

function RuleTypeItem:OnCreated()
	self:SetScript("OnClick", self.OnClick);
	self:SetScript("OnEnter", self.OnEnter);
	self:SetScript("OnLeave", self.OnLeave);
end

function RuleTypeItem:OnModelChanged(model)
	self.Name:SetText(model.Name);
end

function RuleTypeItem:OnSelected(selected)
	if (selected) then
		self.Selected:Show()
		self.Name:SetTextColor(WHITE_FONT_COLOR:GetRGB())
	else
		self.Selected:Hide()
		self.Name:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
	end
end

function RuleTypeItem:OnUpdate()
	if (self:IsMouseOver()) then
		self.Hover:Show();
	else
		self.Hover:Hide();
	end
end

function RuleTypeItem:OnClick()
	self:GetParent():Select(self:GetModel());
end

function RuleTypeItem:OnEnter()
	local model = self:GetModel();

	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:AddLine(model.Name, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true);
	GameTooltip:AddLine(model.Description, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 4, -4);
	GameTooltip:Show();
end

function RuleTypeItem:OnLeave()
	if (GameTooltip:GetOwner() == self) then
		GameTooltip:Hide();
	end
end

--[[===========================================================================
   | Retrieves the currently selected model
   ==========================================================================]]
 function RulesConfig:GetRuleType()
	local selection = self.Types:GetSelected()
	if (not selection) then
		return RULE_TYPES[1]
	end
	return selection
end

local function compareRules(a, b)
	if (not a and b) then
		return true
	elseif (a and not b) then
		return false
	else
		if (a.Enabled and not b.Enabled) then
			return true
		elseif (not a.Enabled and b.Enabled) then
			return false
		else
			local rA = a.Rule;
			local rB = b.Rule;

			if (rA.Order and not rB.Order) then
				return true
			elseif (not rA.Order and rB.Order) then
				return false
			elseif (rA.Order and rB.Order) then
				return rA.Order < rB.Order
			else
				return rA.Name < rB.Name
			end
		end
	end
end

--[[===========================================================================
   | Refresh the rules view.
   ==========================================================================]]
function RulesConfig:Refresh()
	local model = self:GetRuleType()
	local hidden = Addon.RuleConfig:Get(RuleType.HIDDEN)
	local rules = Addon.RuleConfig:Get(model.Type)
	local ruleManager = Addon:GetRuleManager()

	-- Create the list items from the definitions, merged with the 
	-- config. Track the counts while we are building (hidden/enabled/total)
	local numHidden = 0
	local numEnabled = 0
	local total = 0
	local items = {}
	local showHidden = self.ShowHidden:GetChecked()

	for _, ruleDef in ipairs(Addon.Rules.GetDefinitions(model.Type)) do
		total = total + 1
		local hidden = hidden:Contains(ruleDef.Id)

		if (hidden) then 
			numHidden = numHidden + 1
		end

		if (not hidden or showHidden) then
			local state = rules:Get(ruleDef.Id)

			local params = EMPTY
			if (type(state) == "table") then
				params = state
			end

			table.insert(items, {
				Rule = ruleDef,
				Params = params,
				Enabled = (state ~= nil),
				Hidden = hidden,
				NeedsMigration = ruleDef.needsMigration == true,
				Unhealthy = ruleManager:CheckRuleHealth(ruleDef.Id) ~= true,
			})

			if (state) then
				numEnabled = numEnabled + 1
			end
		end
	end

	table.sort(items, compareRules)
	self.rules = items;

	if (numHidden ~= 0) then
		self.Counts:SetFormattedText("(%d/%d/%d)", numEnabled, numHidden, total)
		
		local suffix
		if (numHidden == 1) then
			suffix = L.OPTIONS_RULES_ONE_HIDDEN
		else
			suffix = string.format(L.OPTIONS_RULES_N_HIDDEN, numHidden)
		end
		self.ShowHidden.label:SetText(L.OPTIONS_RULES_SHOW_HIDDEN .. suffix)
	else
		self.Counts:SetFormattedText("(%d/%d)", numEnabled, total)
		self.ShowHidden.label:SetText(L.OPTIONS_RULES_SHOW_HIDDEN)
	end

	self:UpdateCounts(numEnabled, numHidden, total)
	self.Rules:SetEmptyText(model.Empty)
	self.Rules:Update()
end

function RulesConfig:UpdateCounts(numEnabled, numHidden, total)
	if (numEnabled == nil) then
		local model = self:GetRuleType()
		local hidden = Addon.RuleConfig:Get(RuleType.HIDDEN)
		local rules = Addon.RuleConfig:Get(model.Type)

		total = 0
		numHidden = 0
		numEnabled = 0
	
		for _, ruleDef in ipairs(Addon.Rules.GetDefinitions(model.Type)) do
			total = total + 1

			if (hidden:Contains(ruleDef.Id)) then
				numHidden = numHidden + 1
			end
			
			if (rules:Contains(ruleDef.Id)) then
				numEnabled = numEnabled + 1
			end	
		end
	end

	if (numHidden ~= 0) then
		self.Counts:SetFormattedText("(%d/%d/%d)", numEnabled, numHidden, total)
		
		local suffix
		if (numHidden == 1) then
			suffix = L.OPTIONS_RULES_ONE_HIDDEN
		else
			suffix = string.format(L.OPTIONS_RULES_N_HIDDEN, numHidden)
		end
		self.ShowHidden.label:SetText(L.OPTIONS_RULES_SHOW_HIDDEN .. suffix)
	else
		self.Counts:SetFormattedText("(%d/%d)", numEnabled, total)
		self.ShowHidden.label:SetText(L.OPTIONS_RULES_SHOW_HIDDEN)
	end
end

--[[===========================================================================
   | Called to load the profiles config page, setup the various one time
   | items on our page.
   ==========================================================================]]
function RulesConfig:OnLoad()
	Addon.LocalizeFrame(self);
	self:SetScript("OnShow", self.OnShow);
	self:SetScript("OnHide", self.OnHide);
	self.Types.ItemClass = RuleTypeItem;
	self.Rules.ItemClass = Addon.Panels.RuleItem;

	self.Types.GetItems = function()
		return RULE_TYPES;
	end

	self.Types.OnSelection = function()
		self:Refresh();
	end

	self.Rules.GetItems = function()
		return self.rules or EMPTY
	end

	self.Rules.OnModelChanged = function(list, model)
		self:OnModelChanged(model)
	end

	self.Rules.ShowContextMenu = function(list, item, menu)
		self:ShowContextMenu(item, menu)
	end

	self.Rules.ChangeHiddenState = function(list, ruleId, hidden)
		self:ChangeHiddenState(ruleId, hidden)
	end

	self.ShowHidden.SetValue = function(check, show)
		self:Refresh()
	end

	Addon.Rules.OnDefinitionsChanged:Add(function()
		if (self:IsVisible()) then
			self:Refresh()
		end
	end)
end


--[[===========================================================================
   | Called when the view is displayed, hookup our callbacks.
   ==========================================================================]]
function RulesConfig:OnShow()
	self.Types:Update();
	self.Types:EnsureSelection()
	self:Refresh();
end

--[[===========================================================================
   | Called when the view is hidden, we don't need callback/notifications
   | when the view is not visible.
   ==========================================================================]]
function RulesConfig:OnHide()
end

function RulesConfig:OnModelChanged(model)
	local typeModel = assert(self:GetRuleType(), "We should have a valid 'RuleType' model")
	local rules = Addon.RuleConfig:Get(typeModel.Type)
	local hidden = Addon.RuleConfig:Get(RuleType.HIDDEN)
		
	if (model.Enabled) then
		local count = 0
		for key in pairs(model.Params or EMPTY) do
			if (key ~= "rule") then
				count = count + 1
			end
		end

		Addon:Debug("config", "Enabling rule '%s' in '%s' list with %s parameter(s)", model.Rule.Name, typeModel.Name, count)
		rules:Set(model.Rule.Id, model.Params)
		rules:Commit()
		if (hidden:Remove(model.Rule.Id)) then
			hidden:Commit()
		end
	else
		Addon:Debug("config", "Remving rule '%s' in '%s' list", model.Rule.Name, typeModel.Name)
		if (rules:Remove(model.Rule.Id)) then
			rules:Commit()
		end
	end

	self:UpdateCounts()
end

function RulesConfig:ShowContextMenu(item, menu)
	local contextMenu = self.contextMenu
	if (not contextMenu) then
		self.contextMenu = CreateFrame("Frame", "VendorRulesContextMenu", self, "UIDropDownMenuTemplate")
		contextMenu = self.contextMenu
	end

	EasyMenu(menu, contextMenu, "cursor", 0, 0, "MENU", 60);	
end

function RulesConfig:ChangeHiddenState(ruleId, hidden)
	local rules = Addon.RuleConfig:Get(RuleType.HIDDEN)
	if (hidden)	 then
		local typeModel = assert(self:GetRuleType(), "We should have valid rule type")
		local config = Addon.RuleConfig:Get(typeModel.Type)
		config:Remove(ruleId)
		config:Commit()
		rules:Set(ruleId)
	else
		rules:Remove(ruleId)
	end

	rules:Commit()
	self:Refresh()
end

Addon.RulesConfigPanel = RulesConfig;

