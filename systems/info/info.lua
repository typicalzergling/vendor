--[[
    Info System

    This populates information and properties for all systems to use or make available to other
    systems. 
]]

local _, Addon = ...
local L = Addon:GetLocale()
local debugp = function (...) Addon:Debug("info", ...) end

-- Actual version and then assumed "next" version is the next minor version bump.
local RETAIL_VERSION = 100002
local RETAIL_VERSION_NEXT = 100100
local CLASSIC_VERSION =  30401
local CLASSIC_VERSION_NEXT = 30500
local tocVersion = {
    RetailNext = RETAIL_VERSION_NEXT,
    Retail = RETAIL_VERSION,
    ClassicNext = CLASSIC_VERSION_NEXT,
    Classic = CLASSIC_VERSION,
}

local releaseOrder = { "RetailNext", "Retail", "ClassicNext", "Classic" }

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
    elseif (relase == Info.ReleaseType.Classic or release == Info.ReleaseType.ClassicNext) then
        return self.IsClassicEra
    end
    return false
end

function Info:Startup(onready)
    populateBuildInfo()
    onready({
        "GetPriceString",
        "CheckReleaseForClient"
    })
end

function Info:Shutdown()
end

Addon.Systems.Info = Info