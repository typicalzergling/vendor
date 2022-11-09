local AddonName, Addon = ...
local systems = {}

--[[ Checks the local list for a dependency ]]
local function findDependency(depends, name)
    name = string.lower(name)
    for _, dep in pairs(depends) do
        if (name == dep.name) then
            return dep
        end
    end

    local dep = {
            name = name,
            count = 0,
            complete = false,
            error = false,
            pending = 0
        }
    table.insert(depends, dep)
    return dep
end

local DependencyInit = {}

--[[ Adds a target for initialization ]]
function DependencyInit:AddTarget(target, name, dependencies)
    self.targets = self.targets or {}
    -- The dependecy always needs to account for itself
    local main = findDependency(self.targets, name)
    main.count = main.count + 1
    main.target = target
    
    if (type(dependencies) == "table") then
        main.deps = {}
        for _, dep in pairs(dependencies) do
            local targetDep = findDependency(self.targets, dep)
            targetDep.count = targetDep.count + 1
            main.pending = main.pending + 1
            main.deps[targetDep.name] = true
        end
    end
end

--[[ Starts the initialization sequence ]]
function DependencyInit:BeginInit()
    self:Next()
end

--[[ Kicks of the next available target for initialization ]]
function DependencyInit:Next()
    local next = 1
    local total = table.getn(self.targets)
    local pending = false
    local errors = 0

    while (next <= total) do
        local target = self.targets[next]
        if (not target.complete and target.pending == 0) then
            pending = true
            if (target.target == nil) then
                Addon:DebugForEach("systems", target)
            end
            self:InitTarget(target.target, function(success)
                    target.success = success
                    target.complete = true

                    for _, notify in ipairs(self.targets) do
                        if (notify ~= target) then
                            if (notify.deps and notify.deps[target.name]) then
                                notify.pending = notify.pending - 1
                                self:DependencyReady(notify.target, target.name, success)
                            end
                        end
                    end

                    self:InitComplete(target.target, success)
                    self:Next()
                end)
            break
        elseif (target.complete and not target.success) then
            errors = errors + 1
        end
    
        next = next + 1
    end

    if (not pending) then
        self.targets = nil
        self:EndInit(errors == 0)
    end
end

--[[ Called when a dependency is ready ]]
function DependencyInit:DependencyReady(target, depend, success)
end

--[[ Called when we finish initializing a target ]]
function DependencyInit:InitComplete(target, success)
end

function DependencyInit:InitTarget(target, complete)
    assert(false, "Subclasses need to provide a method to initialize  target")
    complete(false)
end

--[[ Called when everything has been initialized ]]
function DependencyInit:EndInit(success)
end

local Systems = Mixin({}, DependencyInit)


--[[ Initialize any systems we've got ]]
function Systems:Init()
    Addon:Debug("systems", "Starting up systems")

    self.systems = {}
    if (type(Addon.Systems) == "table") then

        -- Create the system tracking data
        for name, system in pairs(Addon.Systems) do
            local systemData = {
                name = name,
                source = system,
            }

            local dependencies
            if (type(system.GetDependencies) == "function") then
                local success, deps = xpcall(system.GetDependencies, CallErrorHandler, system)
                if (not success) then
                    error("Failed to get depedencies for system '" .. name .. "'")
                end
                dependencies = deps
            end

            Systems:AddTarget(systemData, name, dependencies)
            self.systems[string.lower(name)] = systemData
        end
    end

    Systems:BeginInit()
end

--[[ Shutdown any systems we've got ]]
function Systems:Terminate()
    Addon:Debug("systems", "Shutting down systems")
    for _, system in pairs(self.systems) do

        -- Remove the APIs
        if (system.api) then
            for _, name in ipairs(system.api) do
                Addon[name] = nil
            end
        end

        -- Shutdown the system
        if (system.shutdown) then
            Addon:Debug("Shutting down system '%s'", system.name)
            system.shutdown()
        end
    end

    systems = {}
end

--[[ Called to check completion state ]]
function Systems:IsReady()
    return self.complete == true
end

--[[ Called when a single system has been initialized ]]
function Systems:InitComplete(target, success)
    Addon:Debug("systems", "System '%s' has been started [success=%s]", target.name, success)
end

--[[ Called to start a single system ]]
function Systems:InitTarget(system, complete)
    Addon:Debug("systems", "Finalizing system '%s'", system.name)

    local source = system.source
    local name = system.name

    -- If there is an initiailization handler then call it
    if (type(source.Startup) == "function") then
        local success, api = xpcall(source.Startup, CallErrorHandler, source)
        if (not success) then
            complete(false)
        end

        -- todo: should this be a public api, shoudl we return
        -- both and set it up?
        if (type(api) == "table") then
            system.api = api
            for _, funcname in ipairs(api) do
                --@debug@
                assert(not Addon[funcname], "An API with the name '" .. name .. "' already exists")
                assert(type(source[funcname]) == "function", "The API referres to an invalid functon : " .. funcname)
                --@end-debug@

                Addon[funcname] = function(_, ...)
                        local ret = { xpcall(source[funcname], CallErrorHandler, source, ...) }
                        if (ret[1]) then
                            table.remove(ret, 1)
                            return unpack(ret)
                        end
                    end

                Addon:Debug("systems", "System '%s' registered API '%s'", name, funcname)
            end
        end
    end

    -- Create our shutdown proxy if necessary
    if (type(source.Shutdown) == "function") then
        system.shutdown = function(...)
                xpcall(source.Shutdown, CallErrorHandler, source, ...)
            end
    end

    -- Check if system generates events
    if (type(source.GetEvents) == "function") then
        local success, events = xpcall(source.GetEvents, CallErrorHandler, source)        
        if (not success) then
            Addon:Debug("systems", "System '%s' failed to generate event list", name)
            complete(false)
        end

        Addon:GenerateEvents(events)
    end

    -- Automatically hook events into the system
    for name, handler in pairs(source) do
        if (type(handler) == "function") then
            if Addon:RaisesEvent(name) then
                Addon:RegisterCallback(name, source, handler)
            elseif (string.find(name, "ON_") == 1) then
                Addon:RegisterEvent(string.sub(name, 4),
                    function(...)
                        handler(source, ...)
                    end)
            end
        end
    end

    -- Create the system instance itself
    system.instance = setmetatable({}, {
            __metatable = string.format("System:%s", name),
            __newindex = function(_, key)
                    error("System '" .. name .. "' cannot be modified attempted to set '" .. key .. "'")
                end,
            __index =  function(_, key)
                    local func = source[key]
                    if (not key or type(key) ~= "string" or type(func) ~= "function") then
                        error("System '" .. name .. "' does not have a function : " .. tostring(key))
                    end

                    return function(_, ...)
                        xpcall(func, CallErrorHandler, source, ...)
                    end
                end
        })

    system.ready = true
    Addon:Debug("systems", "System '%s' is ready", system.name)
    Addon:RaiseEvent("OnSystemReady", name, system.instance)

    complete(true)
end

--[[ Called when a dependency is ready ]]
function Systems:DependencyReady(system, depend, success)
    Addon:Debug("systems", "The dependency '%s' for system '%s' has finished [success=%s]", depend, system.name, success)
    if (success) then
        local dependSystem = self.systems[string.lower(depend)]
        if (dependSystem and dependSystem.instance) then
            rawset(system.source, dependSystem.name, dependSystem.instance)
        end
    end
end

function Systems:EndInit(success)
    Addon:Debug("systems", "Systems startup complete [success=%s]", success)
    self.complete = true
end

--[[ Get the specified system ]]
function Systems:Get(system)
    local data = systems[string.lower(system)]
    if (data) then
        assert(data.ready, "Attempting to retrieve a system that isn't initiaized")
        return data.instance
    end
end

-- Hook up the events
Addon:GenerateEvents({ "OnSystemReady", "OnAllSystemsReady" })

--[[ When our addon is completely loaded start the initialization of our systems ]]
Addon:RegisterEvent("ADDON_LOADED", function(addon)
    if (addon == AddonName) then
        Systems:Init()
    end
end)

--[[ When the player enters the world, check if our systems are ready ]]
Addon:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    if (not Systems:IsReady()) then
        Addon:Debug("systems", RED_FONT_COLOR_CODE .. "All our systems should be ready by now|r")
    end

    Addon:RaiseEvent("OnAllSystemsReady")
end)

--[[ Terminate our systems when the player is leaving ]]
Addon:RegisterEvent("ADDONS_UNLOADING", function()
    Systems:Terminate()
end)

Addon.Systems = {}
Addon.Systems.Profile = {
    GetDependencies = function()
        return { "savedvariables" }
    end
}

--[[ Retrieve the named system ]]
function Addon:GetSystem(system)
    return Systems:Get(system)
end

Addon.DependencyInit = DependencyInit