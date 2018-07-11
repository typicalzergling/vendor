Vendor = Vendor or {}
Vendor.RulesUI = {}
local L = Vendor:GetLocalizedStrings()

local function toggleRuleWithItemLevel(frame)
	if (frame.ItemLevel) then
		if (frame.Enabled:GetChecked()) then
			frame.ItemLevel:Enable()
		else
			frame.ItemLevel:Disable()
		end
	end
end

--*****************************************************************************
-- Determines if the specified rule is enabled based on the provied rule
-- list by looking for a match on the ID.
--*****************************************************************************
local function updateRuleEnabledState(ruleFrame, ruleConfig)
	ruleFrame.Enabled:SetChecked(false)
	if (ruleFrame.ItemLevel) then
		ruleFrame.ItemLevel:SetNumber(0)
		ruleFrame.ItemLevel:Disable()
	end
	
	for _, entry in pairs(ruleConfig) do
		if (type(entry) == "string") then
			if (entry == ruleFrame.RuleId) then
				ruleFrame.Enabled:SetChecked(true)

				if (ruleFrame.ItemLevel) then
					ruleFrame.ItemLevel:SetNumber(0)
					ruleFrame.Enabled:SetChecked(false)
					ruleFrame.ItemLevel:Disable()
				end
			end
		elseif (type(entry) == "table") then
			local ruleId = entry["rule"]
			if (ruleId and (ruleId == ruleFrame.RuleId)) then
				ruleFrame.Enabled:SetChecked(true)
				
				if (ruleFrame.ItemLevel) then
					if (type(entry["itemlevel"]) == "number") then
						ruleFrame.ItemLevel:SetNumber(entry["itemlevel"])
					else
						ruleFrame.ItemLevel:SetNumber(0)
						ruleFrame.Enabled:SetChecked(false)
						ruleFrame.ItemLevel:Disable()
					end
				end				
			end
		end
	end	
	
	toggleRuleWithItemLevel(ruleFrame)
end

local function ruleNeeds(rule, inset)
	print("ruleNeeds:", rule, inset)
	inset = string.lower(inset)
	if (rule.InsetsNeeded) then
		for _, needed in ipairs(rule.InsetsNeeded) do
			print("needed", needed)
			if (string.lower(needed) == inset) then
				return true
			end
		end
	end
end

--*****************************************************************************
-- Create a new frame for a rule item in the provided list. This will setup
-- the item for all of the proeprties of the rule 
--
-- TODO: handle insets here.
--*****************************************************************************
local function createRuleItem(parent, ruleId, rule)
	local template = "VendorSimpleRuleTemplate"
	if ruleNeeds(rule, "itemlevel") then
		print("rule", ruleId, "need item level")
		template = "VendorRuleTemplateWithItemLevel"
	end

	local frame = CreateFrame("Frame", ("$parent" .. ruleId), parent, template)
	frame.Rule = rule
	frame.RuleId = ruleId
	frame.RuleName:SetText(rule.Name)
	frame.RuleDescription:SetText(rule.Description)

	if (parent.Rules and ((#parent.Rules % 2) ~= 0)) then
		frame.OddBackground:Show()
	end

	if (frame.ItemLevel) then
		frame.ItemLevel.Label:SetText(L["RULEUI_LABEL_ITEMLEVEL"])
		frame.ToggleRuleState = toggleRuleWithItemLevel
	end

	updateRuleEnabledState(frame, parent.RuleConfig)
	return frame
end

--*****************************************************************************
-- Builds a list of rules which shoudl be enalbed based on the state of
-- rules within the list.
--*****************************************************************************
local function getRuleConfigFromList(frame)
	local config = {}
	if (frame.Rules) then
		for _, ruleItem in ipairs(frame.Rules) do
			if (ruleItem.Enabled:GetChecked()) then
				local entry = { rule = ruleItem.RuleId }

				if (ruleItem.ItemLevel) then
					local ilvl = ruleItem.ItemLevel:GetNumber()
					if (ilvl ~= 0) then
						entry.itemlevel = ilvl
					else
						entry = nil
					end
				end

				if (entry) then
					table.insert(config, entry)
				end
			end
		end
	end
	return config
end

--*****************************************************************************
-- Updates the state of the list based on the config passed in
--*****************************************************************************
local function setRuleConfigFromList(frame, config)
	frame.RuleConfig = config or {}
	if (frame.Rules) then
		for _, ruleFrame in ipairs(frame.Rules) do
			updateRuleEnabledState(ruleFrame, config)
		end
	end
end

--*****************************************************************************
-- Called when a rules list is loaded in order to populate the list of 
-- frames which represent the rules contained in the list.
--*****************************************************************************
function Vendor.RulesUI.InitRuleList(frame, ruleType, ruleList, ruleConfig)
	frame.RuleFrameSize = 0
	frame.NumVisible = 0
	frame.GetRuleConfig = getRuleConfigFromList
	frame.SetRuleConfig = setRuleConfigFromList
	frame.RuleConfig = ruleConfig or {}
	frame.RuleList = ruleList
	frame.RuleType = ruleType

	assert(frame.RuleList, "Rule List frame needs to have the rule list set")
	assert(frame.RuleType, "Rule List frame needs to have the rule type set")
	
	-- Create the frame for each of our rules.
	for id, rule in pairs(frame.RuleList) do
		if (not rule.Locked) then
			local rule = createRuleItem(frame, id, rule)
			frame.RuleFrameSize = math.max(frame.RuleFrameSize, rule:GetHeight())
		end
	end

	-- Give an initial update of the view
	frame.NumVisible = math.floor(frame.View:GetHeight() / frame.RuleFrameSize)
	Vendor.RulesUI.UpdateRuleList(frame)
end

--*****************************************************************************
-- Called when the list is scrolled/created and will iterate through our list
-- of frames an then show/hide and position the frames which should be 
-- currently visibile.
--*****************************************************************************
function Vendor.RulesUI.UpdateRuleList(frame)
	if (frame.Rules) then
		local offset = FauxScrollFrame_GetOffset(frame.View)
		local ruleHeight = frame.RuleFrameSize
		local previousFrame = nil
		local totalItems = #frame.Rules
		local startIndex = (1 + offset)
		local endIndex = math.min(totalItems, offset + frame.NumVisible)

		FauxScrollFrame_Update(frame.View, totalItems, frame.NumVisible, frame.RuleFrameSize, nil, nil, nil, nil, nil, nil, true)
		for ruleIndex=1,#frame.Rules do
			local ruleFrame = frame.Rules[ruleIndex]
			if ((ruleIndex < startIndex) or (ruleIndex > endIndex)) then
				ruleFrame:Hide()
			else
				if (previousFrame) then
					ruleFrame:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, 0)
					ruleFrame:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT", 0, 0)
				else
					ruleFrame:SetPoint("TOPLEFT", frame.View, "TOPLEFT", 0, 0)
					ruleFrame:SetPoint("TOPRIGHT", frame.View, "TOPRIGHT", 0, 0)
				end
				ruleFrame:Show()
				previousFrame = ruleFrame
			end
		end
	end
end

function Vendor.RulesUI.ApplySystemRuleConfig(frame)
	Vendor:DebugRules("Applying config for rule type '%s'", frame.RuleType)
	Vendor.db.profile.rules[string.lower(frame.RuleType)] = getRuleConfigFromList(frame)
	Vendor:OnRuleConfigUpdated()
end

function Vendor:ShowSystemRuleSellDialog()
	VendorSellSystemRulesRulesDialog.SellList:SetRuleConfig(self.db.profile.rules.sell)
	VendorSellSystemRulesRulesDialog:Show()
end
function Vendor:ShowSystemRuleKeepDialog()
	VendorKeepSystemRulesRulesDialog.KeepList:SetRuleConfig(self.db.profile.rules.keep)
	VendorKeepSystemRulesRulesDialog:Show()
end

