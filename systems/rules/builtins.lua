local AddonName, Addon = ...
local locale = Addon:GetLocale()

--*****************************************************************************
-- Mapping of numeric representation to possible names (strings) which would identify 
-- the quality of an item, for example, 4, epic, purple are all the same.
--*****************************************************************************
local QUALITY = {
    ["poor"] = LE_ITEM_QUALITY_POOR,
    ["junk"] = LE_ITEM_QUALITY_POOR,
    ["gray"] = LE_ITEM_QUALITY_POOR,
    ["common"] = LE_ITEM_QUALITY_COMMON,
    ["white"] = LE_ITEM_QUALITY_COMMON,
    ["uncommon"] = LE_ITEM_QUALITY_UNCOMMON,
    ["green"] = LE_ITEM_QUALITY_UNCOMMON,
    ["rare"] = LE_ITEM_QUALITY_RARE,
    ["blue"] = LE_ITEM_QUALITY_RARE,
    ["epic"] = LE_ITEM_QUALITY_EPIC,
    ["purple"] = LE_ITEM_QUALITY_EPIC,  
    ["legendary"] = LE_ITEM_QUALITY_LEGENDARY,
    ["artifact"] = LE_ITEM_QUALITY_ARTIFACT,
    ["heirloom"] = LE_ITEM_QUALITY_HEIRLOOM,    
    ["token"] = LE_ITEM_QUALITY_TOKEN,
}

--*****************************************************************************
-- Mapping of the numeric item type to non-locasized strings which represent 
-- the type of the item.
--*****************************************************************************
local ITEM_TYPE =  {
    ["weapon"] = 2,
    ["armor"] = 4,
}

--*****************************************************************************
-- Mapping of the numeric expansion id to non-localized and friendly name
-- for the given expansion.
--*****************************************************************************
local EXPANSION  = {
    ["tbc"] = LE_EXPANSION_BURNING_CRUSADE,
    ["bc"] = LE_EXPANSION_BURNING_CRUSADE,
    ["burning crusade"] = LE_EXPANSION_BURNING_CRUSADE,
    ["wrath"] = LE_EXPANSION_WRATH_OF_THE_LICH_KING,
    ["wotlk"] = LE_EXPANSION_WRATH_OF_THE_LICH_KING,
    ["lich king"] = LE_EXPANSION_WRATH_OF_THE_LICH_KING,
    ["cata"] = LE_EXPANSION_CATACLYSM,
    ["cataclysm"] = LE_EXPANSION_CATACLYSM,
    ["panda"] = LE_EXPANSION_MISTS_OF_PANDARIA,
    ["mop"] = LE_EXPANSION_MISTS_OF_PANDARIA,
    ["mists"] = LE_EXPANSION_MISTS_OF_PANDARIA,
    ["wod"] = LE_EXPANSION_WARLORDS_OF_DRAENOR,
    ["draenor"] = LE_EXPANSION_WARLORDS_OF_DRAENOR,
    ["legion"] = LE_EXPANSION_LEGION,
    ["bfa"] = LE_EXPANSION_8_0, 
    ["bofa"] = LE_EXPANSION_8_0,
    ["sl"] = 9.0,
    ["shadowlands"] = 9.0,
    ["df"] = 10.0,
    ["drgonflight"] = 10.0
}

--*****************************************************************************
-- Mapping of the various stat abbrviates/names to localized version you can 
-- find on the actual item.
--*****************************************************************************
local STATS =  {
    ["agi"] = ITEM_MOD_AGILITY_SHORT,
    ["agility"] = ITEM_MOD_AGILITY_SHORT,
    ["ap"] = ITEM_MOD_ATTACK_POWER_SHORT,
    ["attackpower"] = ITEM_MOD_ATTACK_POWER_SHORT,
    ["attack power"] = ITEM_MOD_ATTACK_POWER_SHORT,
    ["block"] = ITEM_MOD_BLOCK_RATING_SHORT,
    ["corruption"] = ITEM_MOD_CORRUPTION,
    ["crit"] = ITEM_MOD_CRIT_RATING_SHORT,
    ["critical"] = ITEM_MOD_CRIT_RATING_SHORT,
    ["critical strike"] = ITEM_MOD_CRIT_RATING_SHORT,
    ["avoidance"] = ITEM_MOD_CR_AVOIDANCE_SHORT,
    ["leach"] = ITEM_MOD_CR_LIFESTEAL_SHORT,
    ["multistrike"] = ITEM_MOD_CR_MULTISTRIKE_SHORT,
    ["speed"] = ITEM_MOD_CR_SPEED_SHORT,
    ["industructable"] = ITEM_MOD_CR_STURDINESS_SHORT,
    ["defense"] = ITEM_MOD_DEFENSE_SKILL_RATING_SHORT,
    ["dodge"] = ITEM_MOD_DODGE_RATING_SHORT,
    ["armor"] = ITEM_MOD_EXTRA_ARMOR_SHORT,
    ["bonusarmor"] = ITEM_MOD_EXTRA_ARMOR_SHORT,
    ["bonus armor"] = ITEM_MOD_EXTRA_ARMOR_SHORT,
    ["haste"] = ITEM_MOD_HASTE_RATING_SHORT,
    ["health"] = ITEM_MOD_HEALTH_SHORT,
    ["hit"] = ITEM_MOD_HIT_RATING_SHORT,
    ["int"] = ITEM_MOD_INTELLECT_SHORT,
    ["intellect"] = ITEM_MOD_INTELLECT_SHORT,
    ["manaregen"] = ITEM_MOD_MANA_REGENERATION_SHORT,
    ["mana"] = ITEM_MOD_MANA_SHORT,
    ["mastery"] = ITEM_MOD_MASTERY_RATING_SHORT,
    ["parry"] = ITEM_MOD_PARRY_RATING_SHORT,
    ["bonushealing"] = ITEM_MOD_SPELL_HEALING_DONE_SHORT,
    ["spirit"] = ITEM_MOD_SPIRIT_SHORT,
    ["stam"] = ITEM_MOD_STAMINA_SHORT,
    ["stamina"] = ITEM_MOD_STAMINA_SHORT,
    ["str"] = ITEM_MOD_STRENGTH_SHORT,
    ["strength"] = ITEM_MOD_STRENGTH_SHORT,
    ["vers"] = ITEM_MOD_VERSATILITY,
    ["vers"] = ITEM_MOD_VERSATILITY, 
};

--*****************************************************************************
-- Helper function which given a value, will search the map for the value
-- and return  the value contained in the map.
--*****************************************************************************
local function getValueFromMap(map, value)
    if (type(map) ~= "table") then
        return nil;
    end
    
    local mapValue = value;
    if (type(mapValue) == "string") then
            mapValue = string.lower(mapValue);
    end

    return map[mapValue];
end

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

local RuleFunctions = {
{
    Name = "ItemQuality",
    Function = function(...)
        return checkMap(QUALITY, Quality, {...})
    end,
    Documentation = locale["HELP_ITEMQUALITY_TEXT"]
},

{
    Name = "ItemType",
    Function = function(...)
            return checkMap(ITEM_TYPE, TypeId, {...})
        end,
    Documentation = locale["HELP_ITEMTYPE_TEXT"]
},
{
    Name = "IsFromExpansion",
    Function = function(...)
        local xpackId = ExpansionPackId;
        if (xpackId ~= 0) then
            return checkMap(EXPANSION, xpackId, {...})
        end
    end,
    Documentation = locale["HELP_ITEMISFROMEXPANSION_TEXT"]
},
{
    Name = "PlayerLevel",
    Function = function()
        return tonumber(UnitLevel("player"))
    end,
    Documentation = locale["HELP_PLAYERLEVEL"]
},
{
    Name = "PlayerClass",
    Function = function()
        local localizedClassName = UnitClass("player")
        return localizedClassName --This is intentional to avoid passing back extra args
    end,
    Documentation = locale["HELP_PLAYERCLASS"]
},

--@retail@
{
    Name = "PlayerItemLevel",
    Function = function()
        assert(not Addon.IsClassic);
        local itemLevel = GetAverageItemLevel();
	    return floor(itemLevel);
    end,
    Documentation = locale["HELP_PLAYERITEMLEVEL"]
},
--@end-retail@

{
    Name = "IsInEquipmentSet",
    Function = function(...)
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
    end,
    Documentation = locale["HELP_ISINEQUIPMENTSET_TEXT"]
},
--@do-not-package@
{
    Name = "tostring",
    Function = function(...)
        return tostring(...)
    end,
},

{
    Name = "print",
    Function = function(...)
        return Addon:Debug("rules", ...)
    end
},
--@end-do-not-package@

{
    Name = "TooltipContains",
    Documentation = locale["HELP_TOOLTIPCONTAINS_TEXT"],
    Function = function(...)
        local str, side, line = ...
        assert(str and type(str) == "string", "Text must be specified.")
        assert(not side or (side == "left" or side == "right"), "Side must be 'left' or 'right' if present.")
        assert(not line or type(line) == "number", "Line must be a number if present.")
        if side then
            if side == "left" then
                return Addon:IsStringInTooltipLeftText(OBJECT.TooltipData, str)
            else
                return Addon:IsStringInTooltipRightText(OBJECT.TooltipData, str)
            end
        else
            return Addon:IsStringInTooltip(OBJECT.TooltipData, str)
        end
    end
},

{
    Name = "HasStat",
    Documentation = locale["HELP_HASSTAT_TEXT"],
    Function = function(...)
        local stats = {...};
        local itemStats = {};

        -- build a table of the stats this item has
        for st, sv in pairs(GetItemStats(Link)) do
            if (sv ~= 0) then
                itemStats[_G[st]] = true;
            end
        end

        if (not itemStats or not table.getn(itemStats)) then
            return false;
        end
        
        local n = table.getn(stats);
        for _, iStat in ipairs({...}) do
            local stat = getValueFromMap(STATS, iStat)
            if (stat and 
                (type(stat) == "string") and 
                string.len(stat) and 
                itemStats[stat]) then
                return true;
            end
        end

        return false;
    end
},
}

function Addon.Systems.Rules:RegisterSystemFunctions()
    self:RegisterFunctions(RuleFunctions, AddonName)
end