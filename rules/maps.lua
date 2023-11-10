local AddonName, Addon = ...
local L = Addon:GetLocale()

Addon.Maps = {}

--*****************************************************************************
-- Mapping of numeric representation to possible names (strings) which would identify 
-- the quality of an item, for example, 4, epic, purple are all the same.
--*****************************************************************************
Addon.Maps.Quality = {
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
Addon.Maps.ItemType = 
{
    ["weapon"] = 2,
    ["armor"] = 4,
}

--*****************************************************************************
-- Mapping of the numeric expansion id to non-localized and friendly name
-- for the given expansion.
--*****************************************************************************
Addon.Maps.Expansion =
{
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
    ["bfa"] = 8.0,
    ["bofa"] = 8.0,
    ["sl"] = 9.0,
    ["shadowlands"] = 9.0,
    ["dragonflight"] = 10.0,
    ["df"] = 10.0,
}

--*****************************************************************************
-- Mapping of the various stat abbrviates/names to localized version you can 
-- find on the actual item.
--*****************************************************************************
Addon.Maps.Stats = 
{
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
    ["leech"] = ITEM_MOD_CR_LIFESTEAL_SHORT,
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