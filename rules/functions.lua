local Addon, L = _G[select(1,...).."_GET"]()
Addon.RuleFunctions = {}
Addon.RuleFunctions.CURRENT_EXPANSION = LE_EXPANSION_BATTLE_FOR_AZEROTH;
Addon.RuleFunctions.BATTLE_FOR_AZEROTH = LE_EXPANSION_BATTLE_FOR_AZEROTH;
Addon.RuleFunctions.POOR = LE_ITEM_QUALITY_POOR;
Addon.RuleFunctions.COMMON = LE_ITEM_QUALITY_COMMON;
Addon.RuleFunctions.UNCOMMON = LE_ITEM_QUALITY_UNCOMMON;
Addon.RuleFunctions.RARE = LE_ITEM_QUALITY_RARE;
Addon.RuleFunctions.EPIC = LE_ITEM_QUALITY_EPIC;
Addon.RuleFunctions.LEGENDARY = LE_ITEM_QUALITY_LEGENDARY;
Addon.RuleFunctions.ARTIFACT = LE_ITEM_QUALITY_ARTIFACT;
Addon.RuleFunctions.HEIRLOOM = LE_ITEM_QUALITY_HEIRLOOM;
Addon.RuleFunctions.TOKEN = LE_ITEM_QUALITY_TOKEN;

--*****************************************************************************
-- Given a set of values this searches for them in the map to see if they map
-- the expected value which is passed in.
--*****************************************************************************
local function checkMap(map, expectedValue, values)
    for i=1,table.getn(values) do
        local value = values[i]
        if (type(value) == "number") then
            if (value == expectedValue) then
                return true
            end
        elseif (type(value) == "string") then
            local mapVal = map[string.lower(value)]
            if (mapVal and (type(mapVal)  == "number") and (mapVal == expectedValue)) then
                return true
            end
        end
    end
    return false
end

--*****************************************************************************
-- Matches the item quality (or item qualities) this accepts multiple arguments
-- which can be either strings or numbers.
--*****************************************************************************
function Addon.RuleFunctions.ItemQuality(...)
    return checkMap(Addon.Maps.Quality, Quality, {...})
end

--*****************************************************************************
-- Rule function which match the item type against the list of arguments
-- which can either be numeric or strings which are mapped with the table
-- above.
--*****************************************************************************
function Addon.RuleFunctions.ItemType(...)
    return checkMap(Addon.Maps.ItemType, TypeId, {...})
end

--*****************************************************************************
-- Rule function which matches of the item is from a particular expansion
-- these can either be numeric or you can use a value from the table above
-- NOTE: If the expansion pack id is zero, it can belong to any or none,
--       this will always evaluate to false.
--*****************************************************************************
function Addon.RuleFunctions.IsFromExpansion(...)
    local xpackId = ExpansionPackId;
    if (xpackId ~= 0) then
        return checkMap(Addon.Maps.Expansion, xpackId, {...})
    end
end

--*****************************************************************************
-- Rule function which checks if the specified item is present in the
-- list of items which should never be sold.
--*****************************************************************************
function Addon.RuleFunctions.IsNeverSellItem()
    if Addon:IsItemIdInNeverSellList(Id) then
        return true
    end
end

--*****************************************************************************
-- Rule function which chceks if the item is in the list of items which
-- should always be sold.
--*****************************************************************************
function Addon.RuleFunctions.IsAlwaysSellItem()
    if Addon:IsItemIdInAlwaysSellList(Id) then
        return true
    end
end

--*****************************************************************************
-- Rule function which returns the level of the player.
--*****************************************************************************
function Addon.RuleFunctions.PlayerLevel()
    return tonumber(UnitLevel("player"))
end

--*****************************************************************************
-- Rule function which returns the localized class of the player.
--*****************************************************************************
function Addon.RuleFunctions.PlayerClass()
    local localizedClassName = UnitClass("player")
    return localizedClassName --This is intentional to avoid passing back extra args
end

--[[============================================================================
    | Rule function which returns the average item level of the players 
	| equipped gear, in classic this just sums all your equipped items and 
	| divides it by the number of item of equipped.
    ==========================================================================]]
function Addon.RuleFunctions.PlayerItemLevel()
	if (not Addon.IsClassic) then
		local _, itemLevel, _ = GetAvergeItemLevel();
		return itemLevel;
	end

	-- What should we do here?
	return 400;
end

--*****************************************************************************
-- This function checks if the specified item is a member of an item set.
--*****************************************************************************
function Addon.RuleFunctions.IsInEquipmentSet(...)
    -- Checks the item set for the specified item
    local function check(itemId, setId)
        itemIds = C_EquipmentSet.GetItemIDs(setId);
        for _, setItemId in pairs(itemIds) do
            if ((setItemId ~= -1) and (setItemId == itemId)) then
                return true
            end
        end
    end

    local sets = { ... };
    local itemId = Id;
    if (#sets == 0) then
        -- No sets provied, so enumerate and check all of the characters item sets
        local itemSets = C_EquipmentSet.GetEquipmentSetIDs();
        for _, setId in pairs(itemSets) do
            if (check(itemId, setId)) then
                return true;
            end
        end
    else
        -- Check against the specific item set/sets provided.
        for _, set in ipairs(sets) do
            local setId = C_EquipmentSet.GetEquipmentSetID(set)
            if (setId and check(itemId, setId)) then
                return true
            end
        end
    end
end

--*****************************************************************************
-- This function allows testing the tooltip text for string values
--*****************************************************************************
function Addon.RuleFunctions.TooltipContains(...)
    local str, side, line = ...
    assert(str and type(str) == "string", "Text must be specified.")
    assert(not side or (side == "left" or side == "right"), "Side must be 'left' or 'right' if present.")
    assert(not line or type(line) == "number", "Line must be a number if present.")

    local function checkSide(textSide, textTable)
        if not side or side == textSide then
            for lineNumber, text in ipairs(textTable) do
                if not line or line == lineNumber then
                    if text and string.find(text, str) then
                        return true
                    end
                end
            end
        end
    end

    return checkSide("left", OBJECT.TooltipLeft) or checkSide("right", OBJECT.TooltipRight)
end

Addon.ScriptReference = Addon.ScriptReference or {}
Addon.ScriptReference.Functions =
{
    PlayerLevel = "Returns the current level of the player",
	PlayerItemLevel = "Returns the average equipped item level for the player, this is not implemented in classic",
    IsAlwaysSellItem = "Returns the state of the item in the always sell list.  A return value of tue indicates it belongs to the list while false indicates it does not.",
    IsNeverSellItem = "Retruns the state of the item in the never sell list.  A return value of true indicates it belongs to the list false indicates it does not.",

    ItemQuality =
    {
        Args = "qual [, qual1..qualN]",
        Map = Addon.Maps.ItemQuality,
        Text = "Determines the item quality",
    },

    IsFromExpansion =
    {
        Args = "xpack0 [, xpack1 .. xpackN]",
        Text = "For items which are marked with and expansion this will compare it against the argeuments, they can either be the numeric identifier or one of the strings shown below.",
        Map = Addon.Maps.Expansion,
    },

    ItemType =
    {
        Args = "type0 [, type2...typeN]",
        Text = "Checks the item type against the string/number passed in which represents the item type",
        Map = Addon.Maps.Quality,
    },

    IsInEquipmentSet =
    {
        Args = "[setName0 .. setNameN]",
        Html = "<p>Checks if the item is a memmber of a Blizzard equipment set and returns true if found." ..
               "If no arguments are provied then all of the chracters equipment sets are check, otherwise" ..
               "this checks only the specified sets.<br/><br/>" ..
               "Examples:<br/>" ..
               "Any: " .. GREEN_FONT_COLOR_CODE .. "IsInEquipmentSet()<br/>" .. FONT_COLOR_CODE_CLOSE ..
               "Specific: " .. GREEN_FONT_COLOR_CODE .. "IsInEquipmentSet(\"Tank\")</p>" .. FONT_COLOR_CODE_CLOSE,
    },

    TooltipContains =
    {
        Args = "text [, side, line]",
        Html = "<p>Checks if specified text is in the item's tooltip." ..
               "Which side of the tooltip (left or right), and a specific line to check are optional." ..
               "If no line or side is specified, the entire tooltip will be checked.<br/><br/>" ..
               "Examples:<br/>" ..
               "Anywhere: " .. GREEN_FONT_COLOR_CODE .. "TooltipContains(\"Rogue\")<br/>" .. FONT_COLOR_CODE_CLOSE ..
               "Check left side line 1: " .. GREEN_FONT_COLOR_CODE .. "TooltipContains(\"Vanq\", \"left\", 1)</p>" .. FONT_COLOR_CODE_CLOSE,
    },
}
