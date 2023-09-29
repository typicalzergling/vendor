local AddonName, Addon = ...
local debugp = function (...) Addon:Debug("systems", ...) end
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
            else
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
            end
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
                    error("Failed to get dependencies for system '" .. name .. "'")
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
                -- On classic this is firing before Features OnTerminate
                -- Doesn't seem to be necessary so commenting out for now.
                --Addon[name] = nil
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

--[[ Create the callbacks for system initialization ]]
local function createStartupCallbacks(system, complete)
    return function(api)
            local source = system.source
            local name = system.name            
            Addon:Debug("syustems", "System '%s' has finished initialization", name)

            -- todo: should this be a public api, shoudl we return
            -- both and set it up?
            if (type(api) == "table") then
                system.api = api
                for _, funcname in ipairs(api) do
                    assert(not Addon[funcname], "An API with the name '" .. funcname .. "' already exists")
                    assert(type(source[funcname]) == "function", "The API refers to an invalid functon : " .. funcname)

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

        -- Create our shutdown proxy if necessary
        if (type(source.Shutdown) == "function") then
            system.shutdown = function(...)
                    xpcall(source.Shutdown, CallErrorHandler, source, ...)
                end
        end

        -- Create the system instance itself
        system.instance = setmetatable({}, {
                __metatable = string.format("System:%s", name),
                __newindex = function(_, key)
                        assert(false, "System '" .. name .. "' cannot be modified attempted to set '" .. key .. "'")
                    end,
                __index =  function(_, key)
                        assert(key and type(key) == "string", "System "..name.." invalid key "..tostring(key))
                        local value = source[key]
                        if type(value) == "function" then
                            return function(_, ...)
                                local result = { xpcall(source[key], CallErrorHandler, source, ...) }
                                assert(result[1], "Error occurred while trying to invoke "..name.." function "..tostring(key))
                                table.remove(result, 1)
                                return unpack(result)
                            end
                        else
                            return value
                        end
                    end
            })

        system.ready = true
        Addon:Debug("systems", "System '%s' is ready", system.name)
        Addon:RaiseEvent("OnSystemReady", name, system.instance)
        C_Timer.After(0.001, function() complete(true) end)
    end,
    function()
        C_Timer.After(0.001, function() complete(false) end)
    end
end

--[[ Called to start a single system ]]
function Systems:InitTarget(system, complete)
    Addon:Debug("systems", "Finalizing system '%s'", system.name)

    local source = system.source
    local name = system.name

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

    -- If there is an initiailization handler then call it
    local systemReady, systemError = createStartupCallbacks(system, complete)
    if (type(source.Startup) == "function") then
        local success, api = xpcall(source.Startup, CallErrorHandler, source, systemReady, systemError)
        Addon:Debug("systems", "System '%s' has Startup function [result=%s]", system.name, tostring(success))
        if (not success) then
            systemError()
        end
    else    
        Addon:Debug("systems", "System '%s' is ready", system.name)
        systemReady()
    end
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
    Addon:RaiseEvent("OnAllSystemsReady")
end

--[[ Get the specified system ]]
function Systems:Get(system)
    local data = self.systems[string.lower(system)]
    if (data) then
        assert(data.ready, "Attempting to retrieve a system that isn't initialized")
        return data.instance
    end
end

-- Hook up the events
Addon:GenerateEvents({ "OnAllSystemsReady" })

--[[ When our addon is completely loaded start the initialization of our systems ]]
Addon:RegisterEvent("ADDON_LOADED", function(addon)
    if (addon == AddonName) then
    --    Systems:Init()
    end
end)

--[[ Terminate our systems when the player is leaving ]]
Addon:RegisterEvent("ADDONS_UNLOADING", function()
    Systems:Terminate()
end)

Addon.Systems = {}
Addon.Systems.Profile = {
    GetDependencies = function()
        return { "system:savedvariables" }
    end
}

--[[ Retrieve the named system ]]
function Addon:GetSystem(system)
    local key = string.lower(system);
    local result = systems[key];
    if (result) then
        return result;
    end

    error("Unable to locate the specified system: " .. system);
end

Addon.DependencyInit = DependencyInit

local compMgr = Addon.ComponentManager

local SystemComponent = {
    Type = "system"
}

function SystemComponent.Create(name, system)
    local instance = {
        name = name,
        system = system,
    };

    return setmetatable(instance, { 
        __index = SystemComponent, 
        __metatable = "system:" .. name 
    });
end

function SystemComponent:GetDependencies()
    local getDeps = self.system.GetDependencies;
    local deps = {}

    if (type(getDeps) == "function") then
        deps = self.system.GetDependencies();
    end
    
    table.insert(deps, "event:loaded");
    return deps;
end

function SystemComponent:GetName()
    return self.name
end

function SystemComponent:OnInitialize()

    local startup = self.system.Startup;
    if (type(startup) == "function") then
        --local success, api = xpcall(source.Startup, CallErrorHandler, source, systemReady, systemError)
    end
end

function SystemComponent:OnTerminate()
end
    

local function RegisterApi(name, system, handler)
    if (type(handler) == "table") then
        for _, value in ipairs(handler) do
            RegisterApi(name, system, value)
        end
    elseif (type(handler) == "string") then
        local func = system[handler];
        assert(type(func) == "function", "Expected handler '" .. handler .. "' to resolve to a function on " .. name)

        assert(not Addon[handler], "An API with the name '" .. handler .. "' has already been registered")
        Addon[handler] = function(_, ...)
            return func(system, ...) 
        end;
        debugp("System[%s] registered API '%s'", name, handler);
    end
end

local function InitializeSystem(name, system)
    local startup = system.Startup;
    if (type(startup) == "function") then
        local success = xpcall(startup, CallErrorHandler, system, 
            function(...) 
                RegisterApi(name, system, ...)
            end)
    end

    -- Check if system generates events
    if (type(system.GetEvents) == "function") then
        local events = system.GetEvents(system);
        Addon:GenerateEvents(events)
    end

    Addon.RegisterForEvents(system, system)
    systems[string.lower(name)] = system
end

local function TerminateSystem(name, system)
    Addon.UnregisterFromEvents(system, system)

    if (type(system.GetEvents) == "function") then
        local events = system.GetEvents(system);
        Addon:RemoveEvents(events)
    end
end

local function CreateComponent(name, system)
    local systemDeps = {}
    if (type(system.GetDependencies) == "function") then
        systemDeps = system.GetDependencies(system)
    end
    table.insert(systemDeps, "event:loaded" );

    return {
        Type = "system",
        Name = name,
        OnInitialize = function(self)  InitializeSystem(name, system) end,
        OnTerminate = function(self) TerminateSystem(name, system) end,
        Dependencies = systemDeps
    }
end

--[[ Simple helper for automatically connecting to events ]]
Addon.RegisterForEvents = function(instance, metatable)
    for name, handler in pairs(metatable) do
        if (type(handler) == "function") then
            if Addon:RaisesEvent(name) then
                Addon:RegisterCallback(name, instance, handler)
            elseif (string.find(name, "ON_") == 1) then
                Addon:RegisterEvent(string.sub(name, 4),
                    function(...)
                        handler(instance, ...)
                    end
                )
            end
        end
    end
end

--[[ Simple helper for automatically connecting to events ]]
Addon.UnregisterFromEvents = function(instance, metatable)
    for name, handler in pairs(metatable) do
        if (type(handler) == "function") then
            if Addon:RaisesEvent(name) then
                Addon:UnregisterCallback(name, instance)
            end
        end
    end
end

Addon:RegisterEvent("ADDON_LOADED", function(addon)
    if (addon == AddonName) then
        local deps = {}
        
        for name, system in pairs(Addon.Systems or {}) do
            table.insert(deps, "system:" .. name)
            compMgr:Create(CreateComponent(name, system));
        end

        compMgr:Create({
            Name = "systems",
            Type = "core",
            Dependencies = deps,
            OnInitialize = function(self)
                Addon:RaiseEvent("OnAllSystemsReady")
            end
        })

        compMgr:InitializeComponents()
    end
end)


--local systemsx  = compMgr:Create(SystemComponent)