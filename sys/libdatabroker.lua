-- This is a small lightweight to not take a dependency on LDB but still allow export of LDB data objects.
-- Note that consuming data objects would still require a dependency on libdatabroker, but
-- since any consumers of libdatabroker objects would necessarily include libdatabroker, we can
-- light up this functionality by enabling ldb and creating objects iff there are any LDB consumers.
-- If LDB exists, then we can assume consumers. If not, then we do nothing and it doesn't matter
-- since there are no consumers of it.

-- We also take opportunistic optional use of LDBIcon but do not require it.

local _, Addon = ...

local ldb = nil
function Addon:IsLDBAvailable()
    if ldb then return true else return false end
end

local ldbi = nil
function Addon:IsLDBIconAvailable()
    if ldbi then return true else return false end
end

local function initializeLDB()
    if LibStub then
        ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)
        ldbi = LibStub:GetLibrary("LibDBIcon-1.0", true)
    end
end
Addon:AddInitializeAction(initializeLDB)

local ldb_dataobjects = {}
function Addon:CreateLDBDataObject(name, definition)
    if not Addon:IsLDBAvailable() then return end
    assert(type(name) == "string" and type(definition) == "table", "Invalid arguments to CreateLDBObject")
    assert(not ldb_dataobjects[name], "Data object by that name already exists.")
    ldbobject = ldb:NewDataObject(name, definition)
    if not ldbobject then return error("Failure creating LDB Data Object") end
    ldb_dataobjects[name] = ldbobject
    return ldbobject
end

function Addon:GetLDBDataObject(name)
    if not Addon:IsLDBAvailable() then return nil end
    if not name then error("Must provide a name to GetLDBDataObject") end
    return ldb_dataobjects[name]
end

-- A note about this one. minimaptable should be in a saved variable table.
-- It uses a 'hide' member variable to control state, but adds other members for positioning.
-- This may cause problems depending on how it is stored.
function Addon:CreateLDBIcon(name, minimaptable)
    if not Addon:IsLDBIconAvailable() then return end
    assert(type(name) == "string" and type(minimaptable) == "table", "Invalid arguments to CreateLDBIcon.")
    if not ldb_dataobjects[name] then error("Data object not defined") end
    ldbi:Register(name, ldb_dataobjects[name], minimaptable)
end

-- Once you have the minimap object you can call methods like:
-- Show()
-- Hide()
-- Lock()
-- Unlock()
function Addon:GetLDBIconMinimapButton(name)
    if not Addon:IsLDBIconAvailable() then return end
    assert(type(name) == "string", "Invalid arguments to GetLDBIconMinimapButton.")
    return ldbi:GetMinimapButton(name)
end
