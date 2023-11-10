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
    ["bfa"] = 8.0, 
    ["bofa"] = 8.0,
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
    ["versatility"] = ITEM_MOD_VERSATILITY, 
};

--*****************************************************************************
-- Mapping of EquipLoc to corresponding SlotIds
--*****************************************************************************
local INVENTORY_SLOT_MAP = {
    INVTYPE_HEAD            = {1},
    INVTYPE_NECK            = {2},
    INVTYPE_SHOULDER        = {3},
    INVTYPE_BODY            = {4},
    INVTYPE_CHEST           = {5},
    INVTYPE_WAIST           = {6},
    INVTYPE_LEGS            = {7},
    INVTYPE_FEET            = {8},
    INVTYPE_WRIST           = {9},
    INVTYPE_HAND            = {10},
    INVTYPE_FINGER          = {11,12},
    INVTYPE_TRINKET         = {13,14},
    INVTYPE_WEAPON          = {16,17}, -- 17 is only if dual wielding
    INVTYPE_SHIELD          = {17},
    INVTYPE_RANGED          = {16},
    INVTYPE_CLOAK           = {15},
    INVTYPE_2HWEAPON        = {16},
    INVTYPE_TABARD          = {19},
    INVTYPE_ROBE            = {5},
    INVTYPE_WEAPONMAINHAND  = {16},
    INVTYPE_WEAPONOFFHAND   = {17},  -- Doc says 16 but that doesn't make sense.
    INVTYPE_HOLDABLE        = {17},
    INVTYPE_THROWN          = {16},
    INVTYPE_RANGEDRIGHT     = {16},
}

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

local function getEnvironmentVariables()
    local RuleEnvironmentVariables = {}
    if Addon.Systems.Info.IsRetailEra then
        RuleEnvironmentVariables.CURRENT_EXPANSION = LE_EXPANSION_DRAGONFLIGHT
    else
        RuleEnvironmentVariables.CURRENT_EXPANSION = LE_EXPANSION_WRATH_OF_THE_LICH_KING
    end
    RuleEnvironmentVariables.CLASSIC = LE_EXPANSION_CLASSIC                                 -- 0
    RuleEnvironmentVariables.BURNING_CRUSADE = LE_EXPANSION_BURNING_CRUSADE                 -- 1
    RuleEnvironmentVariables.WRATH_OF_THE_LICH_KING = LE_EXPANSION_WRATH_OF_THE_LICH_KING   -- 2
    RuleEnvironmentVariables.CATACLYSM = LE_EXPANSION_CATACLYSM                             -- 3
    RuleEnvironmentVariables.MISTS_OF_PANDARIA = LE_EXPANSION_MISTS_OF_PANDARIA             -- 4
    RuleEnvironmentVariables.WARLORDS_OF_DRAENOR = LE_EXPANSION_WARLORDS_OF_DRAENOR         -- 5
    RuleEnvironmentVariables.LEGION = LE_EXPANSION_LEGION                                   -- 6
    RuleEnvironmentVariables.BATTLE_FOR_AZEROTH = LE_EXPANSION_BATTLE_FOR_AZEROTH           -- 7
    RuleEnvironmentVariables.SHADOWLANDS = LE_EXPANSION_SHADOWLANDS                         -- 8
    RuleEnvironmentVariables.DRAGONFLIGHT = LE_EXPANSION_DRAGONFLIGHT                       -- 9
    RuleEnvironmentVariables.POOR = 0
    RuleEnvironmentVariables.COMMON = 1
    RuleEnvironmentVariables.UNCOMMON = 2
    RuleEnvironmentVariables.RARE = 3
    RuleEnvironmentVariables.EPIC = 4
    RuleEnvironmentVariables.LEGENDARY = 5
    RuleEnvironmentVariables.ARTIFACT = 6
    RuleEnvironmentVariables.HEIRLOOM = 7
    RuleEnvironmentVariables.TOKEN = 8
    RuleEnvironmentVariables.KEEP_LIST = Addon.ListType.KEEP
    RuleEnvironmentVariables.SELL_LIST = Addon.ListType.SELL
    RuleEnvironmentVariables.DESTROY_LIST = Addon.ListType.DESTROY

    RuleEnvironmentVariables.PlayerName,
    RuleEnvironmentVariables.PlayerRealm = UnitFullName("player");

    return RuleEnvironmentVariables
end

function Addon.Systems.Rules:GetRuleEnvironmentVariables()
    return getEnvironmentVariables()
end


local RuleFunctions = {
{
    Name = "PlayerLevel",
    Documentation = locale["HELP_PLAYERLEVEL"],
    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
    Function = function()
        return tonumber(UnitLevel("player"))
    end,
},

{
    Name = "PlayerClass",
    Documentation = locale["HELP_PLAYERCLASS"],
    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
    Function = function()
        local localizedClassName, englishClass = UnitClass("player")
        return englishClass --This is intentional to avoid passing back extra args
    end,
},

{
    Name = "PlayerClassId",
    Documentation = locale["HELP_PLAYERCLASSID"],
    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
    Function = function()
        return select(3, UnitClass("player"))
    end,
},

{
    Name = "PlayerSpecialization",
    Documentation = locale["HELP_PLAYERSPECIALIZATION"],
    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
    Function = function()
        return select(2, GetSpecializationInfo(GetSpecialization()))
    end,
},

{
    Name = "PlayerSpecializationId",
    Documentation = locale["HELP_PLAYERSPECIALIZATIONID"],
    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
    Function = function()
        return select(1, GetSpecializationInfo(GetSpecialization()))
    end,
},

{
    Name = "PlayerItemLevel",
    Documentation = locale["HELP_PLAYERITEMLEVEL"],
    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
    Function = function()
        local itemLevel = GetAverageItemLevel();
	    return floor(itemLevel);
    end,

},

{
    Name = "IsInEquipmentSet",
    Documentation = locale["HELP_ISINEQUIPMENTSET_TEXT"],
    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
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
    end,
},

--@end-do-not-package@

{
    Name = "TooltipContains",
    Documentation = locale["HELP_TOOLTIPCONTAINS_TEXT"],
    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
    Function = function(...)
        local str, side, line = ...
        assert(str and type(str) == "string", "Text must be specified.")
        assert(not side or (side == "left" or side == "right"), "Side must be 'left' or 'right' if present.")
        assert(not line or type(line) == "number", "Line must be a number if present.")
        if Addon.Systems.Info.IsRetailEra then
            if side then
                if side == "left" then
                    return Addon.Systems.ItemProperties:IsStringInTooltipLeftText(OBJECT.TooltipData, str)
                else
                    return Addon.Systems.ItemProperties:IsStringInTooltipRightText(OBJECT.TooltipData, str)
                end
            else
                return Addon.Systems.ItemProperties:IsStringInTooltip(OBJECT.TooltipData, str)
            end
        else
            -- Classic scan used pre-cached tooltip text.
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
    end
},

{
    Name = "HasStat",
    Documentation = locale["HELP_HASSTAT_TEXT"],
    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
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

{
    Name = "TotalItemCount",
    Documentation = locale["HELP_TOTALITEMCOUNT_TEXT"],
    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
    Function = function(...)
        local includeBank, includeUses = ...
        -- Assuming if you care to know about the bank you also want reagent bank.
        return GetItemCount(Link, includeBank, includeUses, includeBank)
    end,
},

{
    Name = "CurrentEquippedLevel",
    Documentation = locale["HELP_CURRENTEQUIPPEDLEVEL_TEXT"],
    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
    Function = function(...)

        -- Return 0 if this is a non-equippable item.
        if not IsEquipment then return 0 end

        -- Get the slot IDs for the current piece of gear
        local slots = {}
        if INVENTORY_SLOT_MAP[EquipLoc] then
            slots = INVENTORY_SLOT_MAP[EquipLoc]
        end
        assert(type(slots) == "table", "Expected InventorySlotIds to be a table, got "..type(slots))
        if #slots == 0 then return 0 end

        -- Check for multiple slots
        -- Multiple slots occurs int he following situations:
        --      One-Handed Weapon in Offhand
        --      Rings
        --      Trinkets
        if #slots == 0 then return 0 end

        if EquipLoc == "INVTYPE_WEAPON" then
            -- Dual wield can check both slots, but non-dual wield cannot, so
            -- if this character cannot dual wield, then remove slot 17 from the
            -- check so we don't compare a weapon with a shield.
            if not CanDualWield() then
                slots = {16}
            end
        end

        -- Warriors can Dual-Wield 2H weapons.
        -- Note there is a chance that a 2h weapon can be compared against a 1h weapon
        -- This is not a perfect rule but intended for keep rules to protect your
        -- best / side-grade gear.
        if EquipLoc == "INVTYPE_2HWEAPON" and (select(3, UnitClass("player"))== 1) then
            -- Only fury warriors have titan grip, but they may not be in fury spec
            -- If they can't dual wield 2h weapons then the slot will be empty anyway
            -- and there is no harm in checking. And not checking means this function
            -- will work on Classic!
            slots = {16,17}
        end

        local lowestlevel = 0
        for _, slot in ipairs(slots) do
            local location = ItemLocation:CreateFromEquipmentSlot(slot)
            if C_Item.DoesItemExist(location) then
                local link = C_Item.GetItemLink(location)
                --local equiploc = select(4, GetItemInfoInstant(link))
                local ilvl = GetDetailedItemLevelInfo(link)
                if ilvl and (lowestlevel == 0 or ilvl < lowestlevel) then
                    lowestlevel = ilvl
                end
            end
        end

        return lowestlevel
    end,
},

}

function Addon.Systems.Rules:RegisterSystemFunctions()
    self:RegisterFunctions(RuleFunctions)
end