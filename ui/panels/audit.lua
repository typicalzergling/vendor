local _, Addon = ...
local ActionType = Addon.ActionType
local Audit = {}
local AuditItem = {}
local MATCH_CATEGORY = 1

local FILTER_RULES = 
{
	{
		Id ="sold",
		Name = "Sold",
		Script = function() return Action == ACTION_SELL end
	},
	{
		Id = "destroy",
		Name = "Destroyed",
		Script = function() return Action == ACTION_DESTROY end
	},
	{
		Id = "lessthencommon",
		Name = "Common-",
		Script = function() return Quality <= COMMON end
	},
	{
		Id = "epic",
		Name = "Epic",
		Script = function() return Quality == EPIC end
	},
	{
		Id = "uncommon",
		Name = "Uncommon",
		Script = function() return Quality == UNCOMMON end
	},
	{
		Id = "rare",
		Name = "Rare",
		Script = function() return Quality == RARE end
	},
	{
		Id = "legandandbetter",
		Name = "Legendary+",
		Script = function() return Quality >= LEGANDARY end
	},	
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

function Audit:GetItems()
	if (self.items) then
		return self.items
	end

	local items = {}

	local search = self.Search:GetText();
	if (string.len(string.trim(search)) == 0) then
		search = nil
	else
		search = string.lower(search)
	end

	for _, item in ipairs(Addon:GetCharacterHistory()) do
		item.Quality = C_Item.GetItemQualityByID(item.Id) or 0
		item.SearchKey = string.lower(C_Item.GetItemNameByID(item.Id) or "")
		if (self.filterEngine:Evaluate(item)) then
			if (not search or item.SearchKey:find(search)) then
				table.insert(items, item)
			end
		end
	end

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
			Checked = (rule.Id == "sold"),
			Rule = rule
		})
	end

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
		self.Filters:SetText("<none>")
	end
end

function Audit:SetFilters()
	local engine = self.filterEngine
	engine:ClearRules()
	for _, filter in pairs(self.filterItems) do
		if (filter.Checked) then 
			engine:AddRule(MATCH_CATEGORY, filter.Rule)
		end
	end

	self.items = nil
	self.History:Update()
end

Addon.Panels = Addon.Panels or {}
Addon.Panels.Audit = Audit