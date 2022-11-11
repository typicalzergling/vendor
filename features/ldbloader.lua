-- This is a small lightweight to not take a dependency on LDB but still allow export of LDB data objects.
-- Note that consuming data objects would still require a dependency on libdatabroker, but
-- since any consumers of libdatabroker objects would necessarily include libdatabroker, we can
-- light up this functionality by enabling ldb and creating objects iff there are any LDB consumers.
-- If LDB exists, then we can assume consumers. If not, then we do nothing and it doesn't matter
-- since there are no consumers of it.

-- We also take opportunistic optional use of LDBIcon but do not require it.

local _, Addon = ...

local LibDataBroker = {}

function LibDataBroker:IsLDBAvailable()
    if (self.ldb) then
        return true
    end
    return false
end

function LibDataBroker:IsLDBIconAvailable()
    if (self.ldbi) then
        return true
    end
    return false
end

function LibDataBroker:OnInitialize()
    self.ldbObjects = {}
    self.ldbiObjects = {}

    if LibStub then
        -- To avoid the badness of ACE, we will always XP call everything from these libraries.
        xpcall(
            function()
                self.ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)
                self.ldbi = LibStub:GetLibrary("LibDBIcon-1.0", true)
            end,
            CallErrorHandler)
    end
end
    
    
function LibDataBroker:CreateLDBDataObject(name, definition)
    if (not self.ldb) then
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

    if not Addon:IsLDBAvailable() then return nil end
    if not name then error("Must provide a name to GetLDBDataObject") end
    return self.ldbObjects[name]
end
    
    -- A note about this one. minimaptable should be in a saved variable table.
    -- It uses a 'hide' member variable to control state, but adds other members for positioning.
    -- This may cause problems depending on how it is stored.
function LibDataBroker:CreateLDBIcon(name, minimaptable)
    if (not self.ldbi) then
        return
    end
    assert(type(name) == "string" and type(minimaptable) == "table", "Invalid arguments to CreateLDBIcon.")
    if not self.ldbObjects[name] then error("Data object not defined") end

    xpcall(
        function()
            self.ldbi:Register(name, self.ldbObjects[name], minimaptable)
        end,
        CallErrorHandler)
end
    
-- Once you have the minimap object you can call methods like:
-- Show()
-- Hide()
-- Lock()
-- Unlock()
function LibDataBroker:GetLDBIconMinimapButton(name)
    if (not self.ldbi) then
        return
    end

    assert(type(name) == "string", "Invalid arguments to GetLDBIconMinimapButton.")

    local _, button = xpcall(
        function()
            return self.ldbi:GetMinimapButton(name)
        end,
        CallErrorHandler)

    return button
end

Addon.Features.LibDataBroker = LibDataBroker