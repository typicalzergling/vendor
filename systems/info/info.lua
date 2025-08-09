--[[
    Info System

    This populates information and properties for all systems to use or make available to other
    systems. 
]]

local _, Addon = ...
local L = Addon:GetLocale()
local function debugp(...) Addon:Debug("info", ...) end

-- Actual version and then assumed "next" version is the next minor version bump.
local RETAIL_VERSION = 110200           -- 11.2 Live
local RETAIL_VERSION_NEXT = 110200      -- 11.2 PTR (presently unused)
local CLASSIC_VERSION = 11507           -- Classic SOD
local CLASSIC_VERSION_NEXT = 50500      -- Classic MoP
local tocVersion = {
    RetailNext = RETAIL_VERSION_NEXT,
    Retail = RETAIL_VERSION,
    ClassicNext = CLASSIC_VERSION_NEXT,
    Classic = CLASSIC_VERSION,
}

local releaseOrder = { "RetailNext", "Retail", "ClassicNext", "Classic" }

local DELAY_LOAD_TIME = 10

-- System Def
local Info = {}

-- Type Enum
-- These are sorted by interface version
-- So can do, for example: if releaseType < ReleaseType.Retail
Info.ReleaseType = {
    Classic = 1,
    ClassicNext = 2,
    Retail = 3,
    RetailNext = 4,
}

function Info:GetDependencies()
    return {}
end

local prof1Id = nil
local prof2Id = nil

local function updateProfessionIds()
    local prof1, prof2 = GetProfessions()
    local changed = false

    -- First prof may not be learned
    if prof1 then
        profInfo1 = {GetProfessionInfo(prof1)}

        -- in most cases it will be the same profession.
        if prof1Id ~= profInfo1[7] then
            prof1Id = profInfo1[7]
            changed = true
        end
    else
        -- Check if we unlearned the prof
        if prof1Id then
            prof1Id = nil
            changed = true
        end
    end

    -- Second prof may not be learned
    if prof2 then
        profInfo2 = {GetProfessionInfo(prof2)}
        if prof2Id ~= profInfo2[7] then
            prof2Id = profInfo2[7]
            changed = true
        end
    else
        -- Check if we unlearned the prof
        if prof2Id then
            prof2Id = nil
            changed = true
        end
    end

    if changed then
        -- If changed rebuild the item result cache since any profession rules need re-evaluation.
        -- During first load the result cache may not be available yet.
        debugp("Professions changed")
        if (Addon.ClearItemResultCache) then
            debugp("Professions changed, clearing the cache.")
            Addon:ClearItemResultCache("Professions Changed")
        end
    end
end

-- These may be nil if the character hasn't learned a profession yet or dropped one.
function Info:GetProfessionIds()
    return prof1Id, prof2Id
end

local equipmentSetGUIDs = nil
function Info:GetEquipmentSetsForGUID(itemGUID)
    return equipmentSetGUIDs[itemGUID]
end

-- Get all item guids and to which equipment set they belong.
-- TODO: add bank check, this hsould be safe to update more frequently, as long as it isn't constant.
-- if soemthing goes into inventory from bank, we need to update this list
function updateEquipmentSetGUIDs()
    debugp("Updating EquipmentSet GUIDs")
    local itemSets = C_EquipmentSet.GetEquipmentSetIDs();
    equipmentSetGUIDs = {}
    for _, setId in pairs(itemSets) do
        local locations = C_EquipmentSet.GetItemLocations(setId) or {}
        for _, eLocation in pairs(locations) do
            if eLocation > 1 then
                local player, bank, bags, void, slot, bag = EquipmentManager_UnpackLocation(eLocation)

                if (Addon.Systems.Info.IsClassicNext) then
                    -- On Classic Mists this there is no "void" return value.
                    -- Must shift over the arguments by 1
                    bag = slot
                    slot = void
                end

                itemLocation = nil
                if player and bags then
                    -- In a bag
                    itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
                elseif player and slot then
                    -- Equipped
                    itemLocation = ItemLocation:CreateFromEquipmentSlot(slot)
                end

                if itemLocation then
                    local guid = C_Item.GetItemGUID(itemLocation)
                    if not equipmentSetGUIDs[guid] then
                        equipmentSetGUIDs[guid] = {}
                    end
                    table.insert(equipmentSetGUIDs[guid], setId)
                end
            end
        end
    end

    if Addon.IsDebug then
        for k, v in pairs(equipmentSetGUIDs) do
            debugp("GUID = "..tostring(k).."  in "..tostring(#v).." sets")
        end
    end

    if (Addon.ClearItemResultCache) then
        debugp("Equipment set changed, clearing cache")
        Addon:ClearItemResultCache()
    end
end

-- For some reason blizzard does not immediately have equipmentset info loaded, so delay load it.
local function delayLoadEquipmentSetInfo(delay)
    C_Timer.After(delay, function() updateEquipmentSetGUIDs() end)
end

local function populateBuildInfo()
    Info.Build = {}
    Info.Build.Version, Info.Build.BuildNumber, Info.Build.BuildDate, Info.Build.InterfaceVersion = GetBuildInfo() 

    -- Go through TOC versions highest to lowest to find match
    for _, release in ipairs(releaseOrder) do
        if Info.Build.InterfaceVersion >= tocVersion[release] then
            Info.Release = Info.ReleaseType[release]
            Info.ReleaseName = release
            Info.IsExactTOCMatch = Info.Build.InterfaceVersion == tocVersion[release]
            debugp("Release identified as: %s - %s, exact = %s", release, tostring(Info.Build.InterfaceVersion), tostring(Info.IsExactTOCMatch))
            break
        end
    end

    Info.IsClassic = Info.Release == Info.ReleaseType.Classic
    Info.IsClassicNext = Info.Release == Info.ReleaseType.ClassicNext
    Info.IsRetail = Info.Release == Info.ReleaseType.Retail
    Info.IsRetailNext = Info.Release == Info.ReleaseType.RetailNext
    Info.IsRetailEra = Info.Release >= Info.ReleaseType.Retail
    Info.IsClassicEra = Info.Release < Info.ReleaseType.Retail
    debugp("IsClassic = %s", tostring(Info.IsClassic))
    debugp("IsClassicNext = %s", tostring(Info.IsClassicNext))
    debugp("IsRetail = %s", tostring(Info.IsRetail))
    debugp("IsRetailNext = %s", tostring(Info.IsRetailNext))
end

-- Convert price to a pretty string
-- To reduce spam we don't show copper unless it is the only unit of measurement (i.e. < 1 silver)
-- Gold:    FFFFFF00
-- Silver:  FFFFFFFF
-- Copper:  FFAE6938
function Info:GetPriceString(price, all)
    if not price then
        return "<missing>"
    end

    local copper, silver, gold, str
    copper = price % 100
    price = math.floor(price / 100)
    silver = price % 100
    gold = math.floor(price / 100)

    str = {}
    if gold > 0 or all then
        table.insert(str, "|cFFFFD100")
        table.insert(str, gold)
        table.insert(str, "|r|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:4:0|t  ")

        table.insert(str, "|cFFE6E6E6")
        table.insert(str, string.format("%02d", silver))
        table.insert(str, "|r|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:4:0|t  ")

        if (all) then
            table.insert(str, "|cFFC8602C")
            table.insert(str, copper)
            table.insert(str, "|r|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:4:0|t")
        end

    elseif silver > 0 then
        table.insert(str, "|cFFE6E6E6")
        table.insert(str, silver)
        table.insert(str, "|r|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:4:0|t  ")

    else
        -- Show copper if that is the only unit of measurement.
        table.insert(str, "|cFFC8602C")
        table.insert(str, copper)
        table.insert(str, "|r|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:4:0|t")
    end

    -- Return the concatenated string using the efficient function for it
    return table.concat(str)
end

--[[ Validate the release is acceptable for this client ]]
function Info:CheckReleaseForClient(release)
    if (release == Info.ReleaseType.RetailNext or release == Info.ReleaseType.Retail) then
        return self.IsRetailEra
    elseif (release == Info.ReleaseType.Classic or release == Info.ReleaseType.ClassicNext) then
        return self.IsClassicEra
    end
    return false
end

function Info:Startup(register)
    populateBuildInfo()

    -- There is no event for when you respec and gain a profession
    -- However, anytime you learn a new profession, you get a new recipe
    Addon:RegisterEvent("NEW_RECIPE_LEARNED", updateProfessionIds)
    Addon:RegisterEvent("PLAYER_TALENT_UPDATE", updateProfessionIds)
    updateProfessionIds()

    -- Equipment sets do not exist on classic.
    if not Info.IsClassic then
        -- We only need to get equipment set data whenever a set changes.
        Addon:RegisterEvent("EQUIPMENT_SETS_CHANGED", updateEquipmentSetGUIDs)

        -- Equipment set items may be in the bank, so anytime we close the
        -- bank we need to regenerate the equipment set mappings.
        Addon:RegisterEvent("BANKFRAME_CLOSED", updateEquipmentSetGUIDs)

        -- Try to load quickly in case player goes to a merchant straight away.
        delayLoadEquipmentSetInfo(DELAY_LOAD_TIME)

        -- Fallback in case there's a lot of addons this might take longer to get the data.
        delayLoadEquipmentSetInfo(DELAY_LOAD_TIME*3)
    end

    register({
        "GetPriceString",
        "CheckReleaseForClient",
        "GetProfessionIds",
        "GetEquipmentSetsForGUID",
    })
end

function Info:Shutdown()
end

Addon.Systems.Info = Info