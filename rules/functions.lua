local Addon, L = _G[select(1,...).."_GET"]()

Addon.RuleFunctions = {}
Addon.RuleFunctions.NO_ACTION = 1
Addon.RuleFunctions.KEEP = 2
Addon.RuleFunctions.SELL = 3
Addon.RuleFunctions.SELL_WITH_PROMPT = 4

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
    assert((Quality() >= LE_ITEM_QUALITY_POOR) and (Quality() <= LE_ITEM_QUALITY_WOW_TOKEN), "Item quality is out of range")
    return checkMap(Addon.Maps.Quality, Quality(), {...})
end

--*****************************************************************************
-- Rule function which match the item type against the list of arguments
-- which can either be numeric or strings which are mapped with the table
-- above.
--*****************************************************************************
function Addon.RuleFunctions.ItemType(...)
    return checkMap(Addon.Maps.ItemType, TypeId(), {...})
end

--*****************************************************************************
-- Rule function which matches of the item is from a particular expansion
-- these can either be numeric or you can use a value from the table above
--*****************************************************************************
function Addon.RuleFunctions.IsFromExpansion(...)
    return checkMap(Addon.Maps.Expansion, ExpansionPackId(), {...})
end

--*****************************************************************************
-- Rule function which checks if the specified item is present in the 
-- list of items which should never be sold.
--*****************************************************************************
function Addon.RuleFunctions.IsNeverSellItem()
    if Addon:IsItemIdInNeverSellList(Id()) then
        return true
    end
end 

--*****************************************************************************
-- Rule function which chceks if the item is in the list of items which 
-- should always be sold.
--*****************************************************************************
function Addon.RuleFunctions.IsAlwaysSellItem()
    if Addon:IsItemIdInAlwaysSellList(Id()) then
        return true
    end
end

--*****************************************************************************
-- Rule function which returns the level of the player.
--*****************************************************************************
function Addon.RuleFunctions.PlayerLevel()
    return tonumber(UnitLevel("player"))
end
