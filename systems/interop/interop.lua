--[[
    This is for broad interoperability for functions that change their purpose in classic vs retail
    or later. Rather than have each system create their own interoperability for a given function
    we do it all here, once so it does not require being done repeatedly.
]]

local _, Addon = ...
local L = Addon:GetLocale()
local debugp = function (...) Addon:Debug("interop", ...) end

local Interop = {}

function Interop:GetDependencies()
    -- Interop requires being able to know the build information.
    return {"info"}
end

local Info = Addon.Systems.Info

--[[ GetContainerItemInfo ]]
local getContainerItemInfo = nil
local function setupGetContainerItemInfo()
    if Info.IsRetailEra then
        getContainerItemInfo = C_Container.GetContainerItemInfo
    else
        getContainerItemInfo = GetContainerItemInfo
    end
end
function Interop:GetContainerItemInfo(...)
    return getContainerItemInfo(...)
end

--[[ GetContainerNumSlots ]]
local getContainerNumSlots = nil
local function setupGetContainerNumSlots()
    if Info.IsRetailEra then
        getContainerNumSlots = C_Container.GetContainerNumSlots
    else
        getContainerNumSlots = GetContainerNumSlots
    end
end
function Interop:GetContainerNumSlots(...)
    return getContainerNumSlots(...)
end

--[[ UseContainerItem ]]
local useContainerItem = nil
local function setupUseContainerItem()
    if Info.IsRetailEra then
        useContainerItem = C_Container.UseContainerItem
    else
        useContainerItem = UseContainerItem
    end
end
function Interop:UseContainerItem(...)
    return useContainerItem(...)
end

--[[ PickupContainerItem ]]
local pickupContainerItem = nil
local function setupPickupContainerItem()
    if Info.IsRetailEra then
        pickupContainerItem = C_Container.PickupContainerItem
    else
        pickupContainerItem = PickupContainerItem
    end
end
function Interop:PickupContainerItem(...)
    return pickupContainerItem(...)
end

--[[ GetContainerFreeSlots ]]
local getContainerFreeSlots = nil
local function setupGetContainerFreeSlots()
    if Info.IsRetailEra then
        getContainerFreeSlots = C_Container.GetContainerFreeSlots
    else
        getContainerFreeSlots = GetContainerFreeSlots
    end
end
function Interop:GetContainerFreeSlots(container)
    return getContainerFreeSlots(container)
end


--[[ NUM_TOTAL_EQUIPPED_BAG_SLOTS]]
local getNumTotalEquippedBagSlots = nil
local function setupGetNumTotalEquippedBagSlots()
    if Info.IsRetailEra then
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
    if Info.IsRetailEra then
        isLocationValid = function(location) return location:IsValid() end
    else
        isLocationValid = function(location) return C_Item.DoesItemExist(location) end
    end
end
function Interop:IsLocationValid(location)
    return isLocationValid(location)
end

function Interop:Startup(onready)
    setupGetContainerItemInfo()
    setupGetContainerNumSlots()
    setupUseContainerItem()
    setupPickupContainerItem()
    setupGetContainerFreeSlots()
    setupGetNumTotalEquippedBagSlots()
    setupIsLocationValid()
    onready({
        "GetContainerItemInfo",
        "GetContainerNumSlots",
        "UseContainerItem",
        "PickupContainerItem",
        "GetContainerFreeSlots",
        "GetNumTotalEquippedBagSlots",
    })
end

function Interop:Shutdown()
end

Addon.Systems.Interop = Interop