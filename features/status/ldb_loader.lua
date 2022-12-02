-- This is a small lightweight to not take a dependency on LDB but still allow export of LDB data objects.
-- Note that consuming data objects would still require a dependency on libdatabroker, but
-- since any consumers of libdatabroker objects would necessarily include libdatabroker, we can
-- light up this functionality by enabling ldb and creating objects iff there are any LDB consumers.
-- If LDB exists, then we can assume consumers. If not, then we do nothing and it doesn't matter
-- since there are no consumers of it.

-- We also take opportunistic optional use of LDBIcon but do not require it.

local _, Addon = ...
local function debugp(...) Addon:Debug("libdatabroker", ...) end

-- Feature Definition
local LibDataBroker = {
    NAME = "LibDataBroker",
    VERSION = 1,
    DEPENDENCIES = {},
}

function LibDataBroker:IsLDBAvailable()
    if (self.ldb) then
        return true
    end
    return false
end

function LibDataBroker:OnInitialize()
    debugp("Initializing LibDataBroker")
    self.ldbObjects = {}
    self.ldbiObjects = {}

    if LibStub then
        -- To avoid the badness of ACE, we will always XP call everything from these libraries.
        xpcall(
            function()
                self.ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)
                debugp("Loaded LibDataBroker-1.1: %s", tostring(not not self.ldb))
            end,
            CallErrorHandler)
    else
        debugp("LibStub not present, skipping loading of LDB.")
    end
end

function LibDataBroker:CreateLDBDataObject(name, definition)
    if (not self:IsLDBAvailable()) then
        return
    end

    assert(type(name) == "string" and type(definition) == "table", "Invalid arguments to CreateLDBObject")
    assert(not self.ldbObjects[name], "Data object by that name already exists.")
    local _, ldbobject = xpcall(
        function()
            local ldbo = self.ldb:NewDataObject(name, definition)
            if not ldbo then
                error("Failure creating LDB Data Object")
                return nil
            end
            return ldbo
        end,
        CallErrorHandler)

    self.ldbObjects[name] = ldbobject
    return ldbobject
end

function LibDataBroker:GetLDBDataObject(name)
    if (not self.ldb) then
        return nil
    end

    if not self:IsLDBAvailable() then return nil end
    if not name then error("Must provide a name to GetLDBDataObject") end
    return self.ldbObjects[name]
end

Addon.Features.LibDataBroker = LibDataBroker