local _, Addon = ...
local locale = Addon:GetLocale()
local Vendor = Addon.Features.Vendor
local RuleType = Addon.RuleType
local RulesTab = {}

function RulesTab:OnLoad()
	self.ruleFeature = Addon:GetFeature("Rules")
	self.ruleItems = {}
end

--[[ Retreive the categories for the rules ]]
function RulesTab:GetCategories()
	print("--> get categories")
	return {
		{
			Type = Addon.RuleType.KEEP,
			Text = "RULE_TYPE_KEEP_NAME",
			Help = "RULE_TYPE_KEEP_DESCR",
		},
		{
			Type = Addon.RuleType.SELL,
			Text = "RULE_TYPE_SELL_NAME",
			Help = "RULE_TYPE_SELL_DESCR",
		},
		{
			Type = Addon.RuleType.DESTROY,
			Text = "RULE_TYPE_DELETE_NAME",
			Help = "RULE_TYPE_DELETE_DESCR",
		}
	}
end

function RulesTab:OnActivate()
	if (not self.ruleType:GetSelected()) then
		self.ruleType:Select(1)
	end
	self:ShowRules()
end

function RulesTab:GetRules()
	return self.ruleFeature:GetRules()
end

--[[ Create an item for the specified rule ]]
function RulesTab:CreateRuleItem(model)
	local frame = self.ruleItems[model.Id]
	if (not frame) then
		frame = CreateFrame("CheckButton", nil, self, "RuleItem")
		Addon.AttachImplementation(frame, Vendor.RuleItem, true)
		Addon.CommonUI.DialogBox.Colorize(frame)
		self.ruleItems[model.Id] = frame
	end
	return frame
end

function RulesTab:ShowRules()
	local selected = self.ruleType:GetSelected()
	if (selected) then
		self.activeConfig = self.ruleFeature:GetConfig(selected.Type)
		self.rules:Filter(self:CreateFilter(selected.Type, true))
	end
end

function RulesTab:UpdateConfig(view)
	if (self.activeConfig) then
		local config = self.activeConfig
		for _, model in ipairs(view) do
			local item = self:CreateRuleItem(model)
			item:SetActive(config:Contains(model.Id))
			if (type(model.Params) == "table") then
				item:SetParameters(config:Get(model.Id))
			end
		end
	end
end

--[[ Creates a filter based on the parameters ]]
function RulesTab:CreateFilter(type, includeHidden)
	return function(rule)
			if (rule.Type == type) then
				return true
			end

			if (includeHidden and rule.Type == RuleType.HIDDEN) then
				return true
			end

			return false
		end
end

Vendor.MainDialog.RulesTab = RulesTab