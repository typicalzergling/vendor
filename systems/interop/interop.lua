--[[
    This is for broad interoperability for functions that change their purpose in classic vs retail
    or later. Rather than have each system create their own interoperability for a given function
    we do it all here, once so it does not require being done repeatedly.
]]

local _, Addon = ...
local L = Addon:GetLocale()
local function debugp(...) Addon:Debug("interop", ...) end

local Interop = {}

function Interop:GetDependencies()
    -- Interop requires being able to know the build information.
    return {"info"}
end

local Info = Addon.Systems.Info


--[[
    Blizzard has been moving global functions into C_ class families. This map
    Identifies how those methods have been moved around so simple refactorings
    can be easily mapped and used interchangeably based on their presence.
]]
local interopMap = {
    -- [OldName]                    = {"NewClassName",      "NewMethodName"}

    -- C_Container remaps from 10.0
    ["GetContainerItemInfo"]        = {"C_Container",       "GetContainerItemInfo"},
    ["GetContainerNumSlots"]        = {"C_Container",       "GetContainerNumSlots"},
    ["UseContainerItem"]            = {"C_Container",       "UseContainerItem"},
    ["PickupContainerItem"]         = {"C_Container",       "PickupContainerItem"},
    ["GetContainerFreeSlots"]       = {"C_Container",       "GetContainerFreeSlots"},

    -- C_AddOn remaps from 11.0
    ["GetAddOnInfo"]                = {"C_AddOns",          "GetAddOnInfo"},
    ["IsAddOnLoaded"]               = {"C_AddOns",          "IsAddOnLoaded"},
    ["GetAddOnMetadata"]            = {"C_AddOns",          "GetAddOnMetadata"},
    ["GetNumAddOns"]                = {"C_AddOns",          "GetNumAddOns"},

    -- C_Item remaps from 11.0
    ["GetItemInfo"]                 = {"C_Item",            "GetItemInfo"},
    ["GetItemInfoInstant"]          = {"C_Item",            "GetItemInfoInstant"},
    ["GetDetailedItemLevelInfo"]    = {"C_Item",            "GetDetailedItemLevelInfo"},
    ["IsEquippableItem"]            = {"C_Item",            "IsEquippableItem"},
    ["IsUsableItem"]                = {"C_Item",            "IsUsableItem"},

    -- C_Item remaps from 11.1
    ["GetItemStats"]                = {"C_Item",            "GetItemStats"},
}

local function registerInteropMap(register)
    for oldMethod, newMap in pairs(interopMap) do
        assert(newMap[1] and newMap[2], "Must have valid map")
        local class = newMap[1]
        local method = newMap[2]
        if _G[class] and _G[class][method] then
            assert(type(_G[class][method]) == "function", "Expected function for "..class.."."..method..", got "..type(_G[class][method]))
            Interop[oldMethod] = function(_, ...) return _G[class][method](...) end
        else
            assert(_G[oldMethod], "Expected to find "..method.." but it does not exist.");
            Interop[oldMethod] = function(_, ...) return _G[oldMethod](...) end
        end

        register(method)
    end
end

--[[ NUM_TOTAL_EQUIPPED_BAG_SLOTS - Changed in 10.0 ]]
local getNumTotalEquippedBagSlots = nil
local function setupGetNumTotalEquippedBagSlots()
    if NUM_TOTAL_EQUIPPED_BAG_SLOTS then
        getNumTotalEquippedBagSlots = function() return NUM_TOTAL_EQUIPPED_BAG_SLOTS end
    else
        getNumTotalEquippedBagSlots = function() return NUM_BAG_SLOTS end
    end
end
function Interop:GetNumTotalEquippedBagSlots()
    return getNumTotalEquippedBagSlots()
end

--[[ IsLocationValid - IsValid was added in BFA ]]
local isLocationValid = nil
local function setupIsLocationValid()
    isLocationValid = function(location) return C_Item.DoesItemExist(location) end
end
function Interop:IsLocationValid(location)
    return isLocationValid(location)
end

function Interop:Startup(register)
    -- Set up non-trivial maps or one-offs
    setupGetNumTotalEquippedBagSlots()
    setupIsLocationValid()
    
    register({
        "GetNumTotalEquippedBagSlots",
    })

    -- Set up all the simple remaps
    registerInteropMap(register)
end

function Interop:Shutdown()
end

Addon.Systems.Interop = Interop