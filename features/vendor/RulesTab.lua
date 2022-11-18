local _, Addon = ...
local locale = Addon:GetLocale()
local Vendor = Addon.Features.Vendor
local RuleType = nil
local RuleEvents = nil
local RulesTab = {}

function RulesTab:OnLoad()
	self.ruleFeature = Addon:GetFeature("Rules")
end

--[[ Retreive the categories for the rules ]]
function RulesTab:GetCategories()
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

	-- This needs an OnLoad or OnInitialize
	RuleType = Addon.RuleType
	RuleEvents = Addon.Systems.Rules.RuleEvents

	self.ruleType:EnsureSelection()
	Addon:RegisterCallback(RuleEvents.CONFIG_CHANGED, self, self.OnConfigChanged)
	self:ApplyFilers()
	self.rules:Rebuild()
end

function RulesTab:OnDeactivate()
	Addon:UnregisterCallback(RuleEvents.CONFIG_CHANGED, self)
end

function RulesTab:CreateRule()
	local editRule = Addon:GetFeature("Dialogs")
	editRule:CreateRule()
end

function RulesTab:OnRuleDefinitionCreated()
	self.rules:Rebuild()
end

function RulesTab:OnRuleDefinitionUpdated()
	self.rules:Rebuild()
end

function RulesTab:OnRuleDefinitionDeleted()
	self.rules:Rebuild()
end

function RulesTab:OnConfigChanged(type, config)
	Addon:Debug("rulestab", "Got rule config change '%s'", type)
	self.rules:Rebuild()
	self:ApplyFilers()
end

function RulesTab:GetRules()
	return self.ruleFeature:GetRules(nil, true)
end

--[[ Apply our filters ]]
function RulesTab:ApplyFilers()
	if (self.activeConfig) then
		self.rules:Filter(self:CreateFilter())
	else
		self.rules:Filter(function() return false end)
	end
end

--[[ Create an item for the specified rule ]]
function RulesTab:CreateRuleItem(model)
	local frame = CreateFrame("CheckButton", nil, self, "RuleItem")
	Addon.AttachImplementation(frame, Vendor.RuleItem, true)
	Addon.CommonUI.DialogBox.Colorize(frame)
	return frame
end

function RulesTab:ShowRules(category)
	self.activeConfig = self.ruleFeature:GetConfig(category.Type)
	self:ApplyFilers()
	self.rules:Sort(function(ruleA, ruleB)

			local hasA = ruleA and self.activeConfig:Contains(ruleA.Id)
			local hasB = ruleB and self.activeConfig:Contains(ruleB.Id)

			if (hasA and not hasB) then
				return true
			elseif (not hasA and hasB) then
				return false
			end

			if (ruleA.Order) then
				if (not ruleB.Order) then
					return true
				elseif (ruleA.Order ~= ruleB.Order) then
					return ruleA.Order  < ruleB.Order
				end
			end

			if (ruleB.Order) then
				if (not ruleA.Order) then
					return true
				elseif (ruleA.Order ~= ruleB.Order) then
					return ruleA.Order  < ruleB.Order
				end
			end

			if ruleA.Name ~= ruleB.Name then
				return ruleA.Name < ruleB.Name
			else
				return ruleA.Id < ruleB.Id
			end
		end)
end

function RulesTab:UpdateConfig(view)
	if (self.activeConfig) then
		local config = self.activeConfig
		local list = self.rules

		for _, model in ipairs(view) do
			local item = list:FindItem(model)
			item:SetConfig(self.activeConfig)
		end
	end
end

--[[ Creates a filter based on the parameters ]]
function RulesTab:CreateFilter()
	local ruleType = self.activeConfig:GetType()
	local  hiddenRules = Addon.RuleConfig:Get(RuleType.HIDDEN)

	return function(rule)
			if (hiddenRules and hiddenRules:Contains(rule.Id)) then
				return false
			end

			if (rule.Type ~= ruleType) then
				return false
			end

			return true
		end
end

Vendor.MainDialog.RulesTab = RulesTab