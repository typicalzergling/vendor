local _, Addon = ...
local locale = Addon:GetLocale()
local Vendor = Addon.Features.Vendor
local RuleType = nil
local RuleEvents = nil
local RulesTab = {}
local ProfileEvents = Addon.Systems.Profile.ProfileEvents

function RulesTab:OnLoad()
	self.ruleFeature = Addon:GetFeature("Rules")
	Addon:RegisterCallback(ProfileEvents.ACTIVE_CHANGED, self, self.OnActiveProfileChange)
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
	Addon:RegisterCallback(ProfileEvents.ACTIVE_CHANGED, self, self.OnActiveProfileChange)
	
	local selected = self.ruleType:GetSelected()
	if (selected) then
		self.activeConfig = self.ruleFeature:GetConfig(selected.Type)
	end

	self:ApplyFilters()
	self.rules:Rebuild()
end

function RulesTab:OnDeactivate()
	Addon:UnregisterCallback(RuleEvents.CONFIG_CHANGED, self)
	Addon:UnregisterCallback(ProfileEvents.ACTIVE_CHANGED, self)
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
	local visible = self.ruleType:GetSelected()

	if (type == RuleType.HIDDEN) then
		self:ApplyFilters()
		self.rules:Rebuild()
	elseif (visible and (visible.Type == type) and self.view) then
		self.activeConfig = config
		self:UpdateConfig(self.view)
	end
end

function RulesTab:OnActiveProfileChange(newProfile, oldProfile)
	Addon:Debug("rulestab", "Profile changed '%s' => '%s'", oldProfile:GetId(), newProfile:GetId())

	local selected = self.ruleType:GetSelected()
	if (selected) then
		self.activeConfig = self.ruleFeature:GetConfig(selected.Type)
	end

	self:ApplyFilters()
	self.rules:Rebuild()
end

function RulesTab:GetRules()
	return self.ruleFeature:GetRules(nil, true)
end

--[[ Apply our filters ]]
function RulesTab:ApplyFilters()
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
	self:ApplyFilters()
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
	self.view = view
	if (self.activeConfig) then
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