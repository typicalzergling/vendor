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

local Systems = {}

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