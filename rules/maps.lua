
Vendor = Vendor or {}
Vendor.Maps = {}
local L = Vendor:GetLocalizedStrings()

--*****************************************************************************
-- Mapping of numeric representation to possible names (strings) which would identify 
-- the quality of an item, for example, 4, epic, purple are all the same.
--*****************************************************************************
Vendor.Maps.Quality = {
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
    ["token"] = LE_ITEM_QUALITY_HEIRLOOM,
}

--*****************************************************************************
-- Mapping of the numeric item type to non-locasized strings which represent 
-- the type of the item.
--*****************************************************************************
Vendor.Maps.ItemType = 
{
    ["weapon"] = 2,
    ["armor"] = 4,
}

--*****************************************************************************
-- Mapping of the numeric expansion id to non-localized and friendly name
-- for the given expansion.
--*****************************************************************************
Vendor.Maps.Expansion =
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
    ["bfa"] = LE_EXPANSION_8_0, 
    ["bofa"] = LE_EXPANSION_8_0,
}
