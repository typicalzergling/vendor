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
local CLASSIC_VERSION =  30400
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

    -- Set Booleans
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

function Info:Startup()
    populateBuildInfo()
    return {}
end

function Info:Shutdown()
end

Addon.Systems.Info = Info