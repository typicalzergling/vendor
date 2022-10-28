local _, Addon = ...
local locale = Addon:GetLocale()
local Vendor = Addon.Features.Vendor
local RulesTab = {}

--[[ Retreive the categories for the rules ]]
function RulesTab:GetCategories()
	print("--> get categories")
	return {
		{
			Type = Addon.RuleType.KEEP,
			Text = "RULE_TYPE_KEEP_NAME",
			Tooltip = "RULE_TYPE_KEEP_DESCR",
		},
		{
			Type = Addon.RuleType.SELL,
			Text = "RULE_TYPE_SELL_NAME",
			Tooltip = "RULE_TYPE_SELL_DESCR",
		},
		{
			Type = Addon.RuleType.DESTROY,
			Text = "RULE_TYPE_DELETE_NAME",
			Tooltip = "RULE_TYPE_DELETE_DESCR",
		}
	}
end

local CategoryItem = {
	OnModelChange = function(item, model)
		item.text:SetText(locale[model.Text])
	end
}

function RulesTab:CreateCategoryItem(model)
	print("create rule category", model.Text, model.Type)
	return Mixin(CreateFrame("Button", nil, self, "Vendor_CategoryItem"), CategoryItem)
end

Vendor.MainDialog.RulesTab = RulesTab