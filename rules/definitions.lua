
Vendor = Vendor or {}
Vendor.VendorRuleFunctions = {}
local L = Vendor:GetLocalizedStrings()

Vendor.SystemRules = 
{
	--*****************************************************************************
	-- 
	-- 
	--*****************************************************************************
	Sell = 
	{
		junk = 
		{
			Name = L["SYSRULE_SELL_JUNK"],
			Description = L["SYSRULE_SELL_JUNK_DESC"],
			Script = "Quality() == 0",
		},

		alwayssell = 
		{
			Name = L["SYSRULE_SELL_ALWAYSSELL"],
			Description = L["SYSRULE_SELL_ALWAYSSELL_DESC"],
			Script = "IsAlwaysSellItem()",
		},

		artifactpower =
		{
			Name = L["SYSRULE_SELL_ARTIFACTPOWER"],
			Description = L["SYSRULE_SELL_ARTIFACTPOWER_DESC"],
			Script = "IsArtifactPower() and IsFromExpansion(6) and (PlayerLevel() >= 110)",
		},		

		knownapperance =
		{
			Name = L["SYSRULE_SELL_KNOWNAPPERANCE"],
			Description = L["SYSRULE_SELL_KNOWNAPPERANCE_DESC"],
			Script = "not IsUnknownAppearance() and Level() < {itemlevel}",	
			InsetsNeeded = { "itemlevel" },
		},
				
		uncommon =
		{
			Name = L["SYSRULE_SELL_UNCOMMON_ITEMS"],
			Description = L["SYSRULE_SELL_UNCOMMON_ITEMS_DESC"],
			Script = "IsSoulbound() and ItemType(2, 4) and Quality() == 2 and Level() < {itemlevel}",
			InsetsNeeded = { "itemlevel" },
		},
		
		rare =
		{
			Name = L["SYSRULE_SELL_RARE_ITEMS"],
			Description = L["SYSRULE_SELL_RARE_ITEMS_DESC"],
			Script = "IsSoulbound() and ItemType(2, 4) and Quality() == 3 and Level() < {itemlevel}",
			InsetsNeeded = { "itemlevel" },
		},

		epic =
		{
			Name = L["SYSRULE_SELL_EPIC_ITEMS"],
			Description = L["SYSRULE_SELL_EPIC_ITEMS_DESC"],
			Script = "IsSoulbound() and ItemType(2, 4) and Quality() == 4 and Level() < {itemlevel}",
			InsetsNeeded = { "itemlevel" },
		},
	},

	--*****************************************************************************
	-- 
	-- 
	--*****************************************************************************
	Keep =
	{
		neversell =
		{
			Name = "Never sell item",
			Description = "Matches the item ID against the never sell list",
			Script = "IsNeverSellItem()"
		},	

		common =
		{
			Name = "Common (white) items",
			Description = "Matches any common (white) item",
			Script = "Quality() == 1",
		},

		uncommon =
		{
			Name = "Uncommon (green) items",
			Description = "Matches any uncommon (green) item",
			Script = "Quality() == 2",
		},

		rare =
		{
			Name = "Rare (blue) items",
			Description = "Matches any rare (blue) item",
			Script = "Quality() == 3",
		},

		epic =
		{
			Name = "Epic (purple) items",
			Description = "Matches any epic (purple) item",
			Script = "Quality() == 4",
		},

		legendary =
		{
			Name = "Legendary items",
			Description = "Matches any legenedary item",
			Script = "Quality() == 5",
		},

		artifact =
		{
			Name = "Artifact items",
			Description = "Matches any artifact item",
			Script = "Quality() == 6",
		},

		heirloom =
		{
			Name = "Heirloom items",
			Description = "Matches any heirloom item",
			Script = "Quality() == 7",
		},

		unknownapperence =
		{
			Name = "Unknown apperance",
			Description = "Matches any item which is non-soulbound which is appearence which is unknown to you",
			Script = "not IsSoulbound() and IsUnknownAppearance()",	
		},
	}
}

--*****************************************************************************
-- Subsitutes every instance of "{inset}" with the value specified by 
-- insetValue as a string.
--*****************************************************************************
local function replaceInset(source, inset, insetValue)
	local searchTerm = string.format("{%s}", string.lower(inset))
	local replaceValue = tostring(insetValue)
	return string.gsub(source, searchTerm, replaceValue)
end

--*****************************************************************************
-- Executes a subsitution on all the values within the "insets" table, this table
-- can be null or empty.
--*****************************************************************************
local function replaceInsets(source, insets)
	if (Vendor:TableSize(insets) ~= 0) then
		for inset, value in pairs(insets) do
			source = replaceInset(source, inset, value)
		end
	end
	return source
end

--*****************************************************************************
-- Creates a new id using the rule type and id which is uniuqe for the 
-- given set of insets.  
--
-- Example: makeRuleId("Sell", "Epic", { itemlevel=700 })
--           creates the following "sell.epic(itemlevel:700)"
--*****************************************************************************
local function makeRuleId(ruleType, ruleId, insets)
	local id = string.format("%s.%s", string.lower(ruleType), string.lower(ruleId))
	if (Vendor:TableSize(insets) ~= 0) then
		for inset, value in pairs(insets) do
			if (string.lower(ruleId) ~= string.lower(value)) then
				id  = (id .. string.format("(%s:%s)", string.lower(inset), tostring(value)))
			end
		end
	end
	return id
end

--*****************************************************************************
-- Gets the definition of the specified rule checking the tables of rules 
-- returns the id and the script of the rule. this will format the item level
-- into the rule of needed.
--
-- insets is an optional parameter which is a table of items which shuold
-- be formated into both the ruleId and script.
--*****************************************************************************
function Vendor:GetSystemRuleDefinition(ruleType, ruleId, insets)
	local typeTable = Vendor.SystemRules[ruleType]
	if (typeTable ~= nil) then
		local ruleDef = typeTable[string.lower(ruleId)]
		if (ruleDef ~= nil) then
			return {
						Id = makeRuleId(ruleType, ruleId, insets),
						Name =  replaceInsets(ruleDef.Name, insets),
						Description = replaceInsets(ruleDef.Description, insets),
						Script = replaceInsets(ruleDef.Script, insets),
						InsetsNeeded = ruleDef.InsetsNeeded
					}
		end
	end
	return nil
end

--*****************************************************************************
-- Mapping of numeric representation to possible names (strings) which would identify 
-- the quality of an item, for example, 4, epic, purple are all the same.
--*****************************************************************************
Vendor.VendorRuleFunctions.QualityMap = {
	[0] = { "poor", "junk", "gray" },
	[1] = { "common", "white" },
	[2] = { "uncommon", "green" },
	[3] = { "rare", "blue" },
	[4] = { "epic", "purple" },
	[5] = { "legendary", "orange" },
	[6] = { "artifact" },
	[7] = { "heirloom" },
}

--*****************************************************************************
-- Mapping of the numeric item type to non-locasized strings which represent 
-- the type of the item.
--*****************************************************************************
Vendor.VendorRuleFunctions.TypeMap = 
{
	[2] = { "weapon" },
	[4] = { "armor" },
}

--*****************************************************************************
-- Mapping of the numeric expansion id to non-localized and friendly name
-- for the given expansion.
--*****************************************************************************
Vendor.VendorRuleFunctions.ExpansionMap =
{
	[1] = { "tbc", "burningcrusade" },
	[2] = { "wrath", "lich king" },
	[3] = { "cata" },
	[4] = { "panda", "mists" },
	[5] = { "wod", "dreanor" },
	[6] = { "legion" },
}

--*****************************************************************************
-- Simple helper function which searches for the presence of the given string
-- in the provided list.
--*****************************************************************************
local function isStringInList(list, key)
	key = string.lower(key)
	if (list ~= nil) then
		for _, value in pairs(list) do
			if (key == string.lower(value)) then return true end
		end
	end
end

--*****************************************************************************
-- Matches the item quality (or item qualities) this accepts multiple arguments
-- which can be either strings or numbers.
--*****************************************************************************
function Vendor.VendorRuleFunctions.ItemQuality(...)
	local itemQuality = Quality()
	assert(itemQuality >= 0 and itemQuality <= 7, "Item quality is out of range")
	
	for _, test in ipairs({...}) do		
		if (type(test) == "string") then
			-- Check our table of qualities for the index and see if it matches
			-- one the strings for this quality level.
			if (isStringInList(Vendor.VendorRuleFunctions.QualityMap[itemQuality], test)) then 
				return true 
			end
		elseif (type(test) == "number") then
			-- numeric compare
			if (test == itemQuality) then
				return true
			end
		end	
	end
end

--*****************************************************************************
-- Rule function which match the item type against the list of arguments
-- which can either be numeric or strings which are mapped with the table
-- above.
--*****************************************************************************
function Vendor.VendorRuleFunctions.ItemType(...)
	local itemType = TypeId()

	for _, test in ipairs({...}) do
		if (type(test) == "number") then
			-- numeric compare
			if (test == itemType) then
				return true
			end
		elseif (type(test) == "string") then
			-- check if it is in the list of strings
			if (isStringInList(Vendor.TypeMap[itemType], test)) then
				return true
			end
		end
	end
end

--*****************************************************************************
-- Rule function which matches of the item is from a particular expansion
-- these can either be numeric or you can use a value from the table above
--*****************************************************************************
function Vendor.VendorRuleFunctions.IsFromExpansion(...)
	local expansionId = ExpansionPackId()
	if (expansionId ~= 0) then
		for _, test in ipairs({...}) do
			if (type(test) == "number") then
				-- numeric compare
				if test == expansionId then 
					return true 
				end
			elseif (type(test) == "string") then
				-- list check
				if isStringInList(Vendor.VendorRuleFunctions.ExpansionMap[expansionId], test) then
					return true
				end
			end
		end
	end		
end

--*****************************************************************************
-- Rule function which checks if the specified item is present in the 
-- list of items which should never be sold.
--*****************************************************************************
function Vendor.VendorRuleFunctions.IsNeverSellItem()
	if Vendor:IsItemIdInNeverSellList(Id()) then
		return true
	end
end	

--*****************************************************************************
-- Rule function which chceks if the item is in the list of items which 
-- should always be sold.
--*****************************************************************************
function Vendor.VendorRuleFunctions.IsAlwaysSellItem()
	if Vendor:IsItemIdInAlwaysSellList(Id()) then
		return true
	end
end

--*****************************************************************************
-- Rule function which returns the level of the player.
--*****************************************************************************
function Vendor.VendorRuleFunctions.PlayerLevel()
	return tonumber(UnitLevel("player"))
end
