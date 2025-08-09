--[[
    Functions System

    This populates information and properties for all systems to use or make available to other
    systems. 
]]

local _, Addon = ...
local L = Addon:GetLocale()
local DEBUG_CHANNEL = "functions"
local function debugp(...) Addon:Debug(DEBUG_CHANNEL, ...) end

local DELAY_LOAD_TIME = 10

-- Feature Def
local Functions = {}

function Functions:GetDependencies()
    return { "status" }
end

-- Profession functions

local PROFESSION_MAP = {
    ALCHEMY = 171,
    BLACKSMITHING = 164,
    ENCHANTING = 333,
    ENGINEERING = 202,
    HERBALISM = 182,
    INSCRIPTION = 773,
    JEWELCRAFTING = 755,
    LEATHERWORKING = 165,
    MINING = 186,
    SKINNING = 393,
    TAILORING = 197,
}

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
        debugp("Professions changed, clearing the cache.")
        Addon:ClearItemResultCache("Professions Changed")
    end
end

-- These may be nil if the character hasn't learned a profession yet or dropped one.
function Functions:GetProfessionIds()
    return prof1Id, prof2Id
end

local equipmentSetGUIDs = {}
function Functions:GetEquipmentSetsForGUID(itemGUID)
    return equipmentSetGUIDs[itemGUID]
end

-- Bag update is called on login when the bags are ready.
-- If we call GetItemLocations before this happens, we will get empty results
local firstScanCompleted = false
function firstEquipmentSetUpdate()
    if firstScanCompleted then return end
    updateEquipmentSetGUIDs()
    firstScanCompleted = true
end

-- Get all item guids and to which equipment set they belong.
-- TODO: add bank check, this hsould be safe to update more frequently, as long as it isn't constant.
-- if soemthing goes into inventory from bank, we need to update this list
function updateEquipmentSetGUIDs()
    debugp("Updating EquipmentSet GUIDs")
    local itemSets = C_EquipmentSet.GetEquipmentSetIDs();
    local startCount = #equipmentSetGUIDs
    local added = false
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
                    added = true
                end
            end
        end
    end

    if Addon.IsDebug then
        for k, v in pairs(equipmentSetGUIDs) do
            debugp("GUID = "..tostring(k).."  in "..tostring(#v).." sets")
        end
    end

    -- Check if first scan on reload is successful. This should be true
    -- if there are no equipment sets or if there are and we added at least one.
    if (itemSets == 0) or (startCount == 0 and added) then
        debugp("Reload scan completed")
        firstScanCompleted = true
    end
    debugp("Equipment set changed, clearing cache")
    Addon:ClearItemResultCache()
end

-- This is a fallback in case equipmentSetGUID scan has not yet occurred due to various race conditions.
local function delayLoadEquipmentSetInfo(delay)
    C_Timer.After(delay, function() 
        if not firstScanCompleted then
            debugp("First scan was not completed, delay load fallback engaged")
            updateEquipmentSetGUIDs()
        end
    end)
end

local functionDefinitions =
{
    {
        Name = "IsInEquipmentSet",
        Documentation = L["HELP_ISINEQUIPMENTSET_TEXT"],
        Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true },
        Function = function(...)
            local setsToCheck = {...}
            local inSets = Functions:GetEquipmentSetsForGUID(GUID)
            if not inSets then return false end
            if #setsToCheck == 0 and inSets then return true end

            for _, name in ipairs(setsToCheck) do
                local setId = C_EquipmentSet.GetEquipmentSetID(name)
                for _, set in ipairs(inSets) do
                    if set == setId then
                        return true
                    end
                end
            end

            return false
        end,
    },

    {
        Name = "HasProfession",
        Documentation = L["HELP_HASPROFESSION"],
        Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
        Function = function(...)
            local profsToCheck = {...}
            local prof1Id, prof2Id = Functions:GetProfessionIds()
            for _, id in pairs(profsToCheck) do
                if type(id) == "string" then
                    id = PROFESSION_MAP[string.upper(id)]
                end

                if id == prof1Id or id == prof2Id then
                    return true
                end
            end

            return false
        end,
    },
}

function Functions:OnInitialize()
    if Addon.IsDebug then
        Addon:RegisterDebugChannel(DEBUG_CHANNEL)
    end

    -- Register our functions first.
    Addon.Systems.Rules:RegisterFunctions(functionDefinitions)

    -- There is no event for when you respec and gain a profession
    -- However, anytime you learn a new profession, you get a new recipe
    Addon:RegisterEvent("NEW_RECIPE_LEARNED", updateProfessionIds)
    Addon:RegisterEvent("PLAYER_TALENT_UPDATE", updateProfessionIds)
    updateProfessionIds()

    -- Equipment sets do not exist on classic.
    if not Addon.Systems.Info.IsClassic then
        -- We only need to get equipment set data whenever a set changes.
        Addon:RegisterEvent("EQUIPMENT_SETS_CHANGED", updateEquipmentSetGUIDs)

        -- Equipment set items may be in the bank, so anytime we close the
        -- bank we need to regenerate the equipment set mappings.
        Addon:RegisterEvent("BANKFRAME_CLOSED", updateEquipmentSetGUIDs)

        -- Initial population of the equipment set data must happen on bag update
        Addon:RegisterEvent("BAG_UPDATE", firstEquipmentSetUpdate)


        -- Try to do an initial update
        updateEquipmentSetGUIDs()

        -- Fallback in case there's a race between BAG_UPDATE and registering
        -- for its event. Also on reloads we dont always call BAG_UPDATE.
        delayLoadEquipmentSetInfo(DELAY_LOAD_TIME)
    end
end

function Functions:Shutdown()
end

Addon.Features.Functions = Functions