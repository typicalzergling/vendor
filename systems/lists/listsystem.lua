local _, Addon = ...
local ListSystem = {}

--[[ Retrieve our depenedencies ]]
function ListSystem:GetDependencies()
    return { "savedvariables", "profile" }
end

--[[ Retrieves the events we produce ]]
function ListSystem:GetEvents()
    return {}
end

--[[ Startup our system ]]
function ListSystem:Startup()
end

--[[ Shutdown our system ]]
function ListSystem:Shutdown()
end


Addon.Systems.Lists = ListSystem