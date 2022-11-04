local _, Addon = ...
local locale = Addon:GetLocale()
local Vendor = Addon.Features.Vendor
local RuleType = Addon.RuleType
local RulesTab = {}

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
end

function RulesTab:GetRules()
	local rules = Addon:GetFeature("Rules")
	return rules:GetRules()
end

function RulesTab:CreateRuleItem(model)
	local frame =CreateFrame("CheckButton", nil, self, "RuleItem")
	Addon.AttachImplementation(frame, Vendor.RuleItem, true)
	Addon.CommonUI.DialogBox.Colorize(frame)
	return frame
end

function RulesTab:ShowRules()
	print("--> show rules")
	local selected = self.ruleType:GetSelected()
	if (selected) then
		self.rules:Filter(self:CreateFilter(selected.Type, true))
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