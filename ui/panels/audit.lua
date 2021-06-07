local _, Addon = ...
local ActionType = Addon.ActionType
local L = Addon:GetLocale()
local Audit = {}
local AuditItem = {}
local MATCH_CATEGORY = 1

local FILTER_RULES = 
{
	{
		Id ="sold",
		Name = L.OPTIONS_AUDIT_FILTER_SOLD,
		Script = function() return Action == ACTION_SELL end
	},
	{
		Id = "destroy",
		Name = L.OPTIONS_AUDIT_FILTER_DESTROYED,
		Script = function() return Action == ACTION_DESTROY end
	},
	{
		Id = "lessthencommon",
		Name = L.OPTIONS_AUDIT_FILTER_COMMON,
		Script = function() return Quality <= COMMON end
	},
	{
		Id = "epic",
		Name = L.OPTIONS_AUDIT_FILTER_EPIC,
		Script = function() return Quality == EPIC end
	},
	{
		Id = "uncommon",
		Name = L.OPTIONS_AUDIT_FILTER_UNCOMMON,
		Script = function() return Quality == UNCOMMON end
	},
	{
		Id = "rare",
		Name = L.OPTIONS_AUDIT_FILTER_RARE,
		Script = function() return Quality == RARE end
	},
	{
		Id = "legandandbetter",
		Name = L.OPTIONS_AUDIT_FILTER_LEGENDARY,
		Script = function() return Quality >= LEGANDARY end
	},	
	{
		Id = "extension",
		Name = L.OPTIONS_AUDIT_FILTER_EXTENSION,
		Script = function() return (RuleDefinition and RuleDefinition.Extension) end
	}
}

function AuditItem:OnCreated()
end

function AuditItem:OnModelChanged(model)
	self.Value:SetText(Addon:GetPriceString(model.Value, true))
	self.Date:SetText(date("%m/%d %I:%M %p", model.TimeStamp))
	self:SetItemID(model.Id)
	self:ContinueOnItemLoad(function()
		local color = self:GetItemQualityColor() or ITEM_QUALITY_COLORS[0]
		self.Item:SetText(self:GetItemName())
		self.Item:SetTextColor(color.r, color.g, color.b)
	end)
	if (model.Action == ActionType.SELL) then
		self.ActionSell:Show()
		self.ActionDestroy:Hide()
	else
		self.ActionDestroy:Show()
		self.ActionSell:Hide()
	end

	if (model.Value == 0) then
		self.Value:Hide()
	else
		self.Value:Show()
	end
end

function AuditItem:GetRuleColor(model)
	if (model.RuleDefinition) then
		if (model.RuleDefinition.Extension) then
			return HEIRLOOM_BLUE_COLOR
		elseif (model.RuleDefinition.Custom) then
			return RARE_BLUE_COLOR
		end
		return ARTIFACT_GOLD_COLOR
	end

	-- No longer exists
	return RED_FONT_COLOR
end

function AuditItem:OnEnter()
	if (not self:IsItemEmpty()) then
		local model = self:GetModel()
		local profileId, profile = Addon:GetProfileInfoFromHistoryId(model.Profile)
		local ruleColor = self:GetRuleColor(model)
		local labelColor = NORMAL_FONT_COLOR

		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -2)
		GameTooltip:SetHyperlink(self:GetItemLink())
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L.OPTIONS_VENDOR_AUDIT)
		if (model.Action == ActionType.SELL) then
			GameTooltip:AddDoubleLine("  " .. L.OPTIONS_AUDIT_TT_SOLD, date(L.OPTIONS_AUDIT_TT_DATESTR, model.TimeStamp), 			
			BLUE_FONT_COLOR.r, BLUE_FONT_COLOR.g, BLUE_FONT_COLOR.b,
			HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		elseif (model.Action == ActionType.DESTROY) then
			GameTooltip:AddDoubleLine("  " .. L.OPTIONS_AUDIT_TT_DESTROYED, date(L.OPTIONS_AUDIT_TT_DATESTR, model.TimeStamp),
			ORANGE_FONT_COLOR.r, ORANGE_FONT_COLOR.g, ORANGE_FONT_COLOR.b,
			HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		end
		GameTooltip:AddDoubleLine("  " .. L.OPTIONS_AUDIT_TT_PROFILE, profile, 
			labelColor.r, labelColor.g, labelColor.b,
			HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		--@debug@
		GameTooltip:AddDoubleLine("  ProfileId:", profileId, 
			labelColor.r, labelColor.g, labelColor.b,
			HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
		--@end-debug@
		GameTooltip:AddDoubleLine("  " .. L.OPTIONS_AUDIT_TT_RULE, model.RuleName, 
			labelColor.r, labelColor.g, labelColor.b,
			ruleColor.r, ruleColor.g, ruleColor.b)
		--@debug@
		GameTooltip:AddDoubleLine("  RuleId:", model.RuleId, 
			labelColor.r, labelColor.g, labelColor.b,
			ruleColor.r, ruleColor.g, ruleColor.b)

		--@end-debug@
		GameTooltip:Show()
	end	
end

function AuditItem:OnLeave()
	if (GameTooltip:GetOwner() == self) then
		GameTooltip:Hide()
	end
end

function AuditItem:OnUpdate()
	if (self:IsMouseOver()) then
		self.Hover:Show()
	else
		self.Hover:Hide()
	end
end

function Audit:GetItems()
	if (type(self.items) == "table") then
		return self.items
	end

	local items = {}

	local search = self.Search:GetText();
	if (string.len(string.trim(search)) == 0) then
		search = nil
	else
		search = string.lower(search)
	end

	for _, item in pairs(Addon:GetCharacterHistory()) do
		local ruleId, ruleName = Addon:GetRuleInfoFromHistoryId(item.Rule)
		item.Quality = C_Item.GetItemQualityByID(item.Id) or 0
		item.SearchKey = string.lower(C_Item.GetItemNameByID(item.Id) or "")
		item.RuleDefinition = Addon.Rules.GetDefinition(ruleId, nil, true)
		item.RuleId = ruleId
		item.RuleName = ruleName
		if ((self.enabledFilters == 0) or self.filterEngine:Evaluate(item)) then
			if (not search or item.SearchKey:find(search)) then
				table.insert(items, item)
			end
		end
	end

	table.sort(items, function(a, b)
		return a.TimeStamp > b.TimeStamp
	end)

	self.items = items;
	return items;
end

function Audit:OnLoad()
	self.History.ItemClass = AuditItem
	self.History.GetItems = function()
		return self:GetItems()
	end

	local constants = {}
	for n, v in pairs(ActionType) do
		constants["ACTION_" .. string.upper(n)] = v
	end

	self.filterEngine = CreateRulesEngine()	
	self.filterEngine:CreateCategory(MATCH_CATEGORY, "matched")
	self.filterEngine:AddConstants(Addon.RuleFunctions)
	self.filterEngine:AddConstants(constants)

	local filters = {}
	for _, rule in ipairs(FILTER_RULES) do
		table.insert(filters, {
			Text = rule.Name,
			Checked = false,
			Rule = rule
		})
	end

	filters[1].Checked = true
	filters[2].Checked = true
	self.filterItems = filters;
	self.Filters:SetItems(filters);
	self:SetFilterText()

	self.Filters.noCloseOnSelect = true
	self.Filters.noAutoSelect = true
	self.Filters.OnSelection = function(_, value, checked)
		self.filterItems[value].Checked = checked
		self:SetFilterText()	
		self:SetFilters()
	end

	self:SetScript("OnShow", function()
			Addon.OnHistoryChanged:Add(function()
				self:OnHistoryChanged()
			end)
			self:SetFilterText()
			self:SetFilters()

			self.Search:RegisterCallback("OnChange", function()
				self.items = nil
				self.History:Update()
			end, self)	
	end)

	self:SetScript("OnHide", function()
		self.Search:UnregisterCallback("OnChange", self)
	end)
end

function Audit:SetFilterText()
	local names = {}
	for _, filter in pairs(self.filterItems) do
		if (filter.Checked) then 
			table.insert(names, filter.Text)
		end
	end
	
	if (table.getn(names) ~= 0) then
		self.Filters:SetText(table.concat(names, ", "))
	else
		self.Filters:SetText(L.OPTIONS_AUDIT_FILTER_ALL)
	end
end

function Audit:SetFilters()
	local engine = self.filterEngine
	local enabled = 0
	engine:ClearRules()
	for _, filter in pairs(self.filterItems) do
		if (filter.Checked) then 
			engine:AddRule(MATCH_CATEGORY, filter.Rule)
			enabled = enabled + 1
		end
	end

	self.items = nil
	self.enabledFilters = enabled
	self.History:FlagForUpdate()
end

function Audit:OnHistoryChanged()
	self.items = nil
	self.History:FlagForUpdate()
end

Addon.Panels = Addon.Panels or {}
Addon.Panels.Audit = Audit