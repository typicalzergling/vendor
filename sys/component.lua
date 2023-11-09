local AddonName, Addon = ...
local components = {}
local depenedencies = {}
local initOrder = {}
local inInit = false

local COMPONENT_NAME = "__componentName"
local COMPONENT_READY = "__componentReady"
local COMPONENT_DEPS = "__componentDeps"
local COMPONENT_BASE = "__componentBase"
local COMPONENT_SHORT_NAME = "__componentShortName"
local COMPONENT_ENABLED = "__componentEnabled"
local COMPONENT = "component"

local COMPONENT_INFO = {}
local COMPONENT_ID  ="component:id"
local COMPONENT_READY = "component:ready"

local ComponentManager = {}
local Component = {}

--[[ Retrieves the component info or a speciifed field ]]
local function GetComponentInfo(component, key)
    local info = rawget(component, COMPONENT_INFO)
    if (info) then
        if (type(key) == "string") then
            return info[key]
        end
    else
        info = {}
        rawset(component, COMPONENT_INFO, info)
    end

    return info
end

--[[ Sets the speciifed values on the component info ]]
local function SetComoenntInfo(component, values)
    assert(type(value) == "table", "Expected the values to be a table")
    local info = rawget(component, COMPONENT_INFO)
    if (not info) then
        info = {}
        rawset(component, COMPONENT_INFO, info)
    end

    for key, value in pairs(info) do
        info[key] = value
    end
end

--[[ Retrieves or generates the dependencies for the component ]]
local function GetComponentDependencies(component)
    local info = GetComponentInfo(component)
    if (type(info.dependencyList) == "table") then
        return info.dependencyList
    end

    local deps = {}
    local ctype = info.componentType

    if (type(info.Dependencies) == "table") then
        for _, depend in ipairs(info.Dependencies) do
            table.insert(deps, depend)
        end
    end

    deps = component:GetDependencies()
    if (#deps ~= 0) then
        local rawdeps = deps
        deps = {}

        local componentType = component:GetType()
        for _, dependecy in ipairs(rawdeps) do
            if (not string.match(dependecy, "^([^:]+):([^:]+)$")) then
                table.insert(deps, string.lower(componentType .. ':' .. dependecy))
            else
                table.insert(deps, string.lower(dependecy))
            end
        end
    end

    rawset(component, COMPONENT_DEPS, deps)
    return deps
end

--[[ CHecks of the dependencies for the component are complete ]]
local function AreDepeendenciesComplete(component)
    local deps = GetComponentDependencies(component)
    for _, dependency in ipairs(deps) do
        if (depenedencies[dependency] ~= true) then
            return false
        end
    end

    -- If we have an empty array, or we didn't create one we are okay
    return true
end

--[[ Handles the initialization of the components ]]
local function initComponents()
    if (not inInit) then
        inInit = true
        local count = 0
        while (true) do
            count = 0
            for name, component in pairs(components) do
                if (rawget(component, COMPONENT_READY) ~= true) then
                    if (AreDepeendenciesComplete(component)) then
                        local init = component.OnInitialize
                        if (type(init) == "function") then
                            init(component)
                        end

                        table.insert(initOrder, 1, name)
                        depenedencies[name] = true
                        rawset(component, COMPONENT_READY, true)
                        count = count + 1
                    end
                end
            end

            if (count == 0) then
                break
            end        
        end
        inInit = false
    end
end

--[[ Handlers termination of the components ]]
local function termComponents()
    for _, name in ipairs(initOrder) do
        local component = components[name]
        if (component) then
            local term = component.OnTerminate
            if (type(term) == "function") then
                term(component)
            end
        end
    end
end

local function sastifyDependency(dependency)
    dependency = string.lower(dependency)
    depenedencies[dependency] = true
    initComponents()
end

local function IsDependencySatisfied(dependency)
    dependency = string.lower(dependency)
    return (depenedencies[dependency] == true)
end

--[[ Create a component identifier ]]
local function CreateComponentName(component, name)
    if (type(component.GetType) == "function") then
        ctype = component.GetType(component)
    elseif (type(component.Type) == "string") then
        ctype = component.Type
    end

    if (type(name) ~= "string") then
        if (type(component.GetName) == "function") then
            name = component.GetName(component)
        elseif (type(component.Name) == "string") then
            name = component.Name
        else
            error("The component does not have a valid name")
        end
    end

    --@debug@
    if (not string.match(name, "^[a-zA-Z_0-9]+$")) then
        error("The component has an invalid name: " .. name)
    end
    --@end-debug@

    if (not ctype or string.len(ctype) == 0) then
        return name
    end

    return string.lower(ctype .. ':' .. name)
end

--[[ 
    Create a new component using the specified information

    Name - Required the name of the component
    Type - Optional, the type of the component
    Dependencies - The dependencies for this component
    Object - The implementation of this component
]]
function ComponentManager:Create(component, name)
    local fullname = CreateComponentName(component, name)

    --@debug@
    assert(not components[fullname], "A component with the name already exists")
    --@end-debug@

    local instance = {}
    for k,v in pairs(component) do
        instance[k] = v
    end

    for fname, func in pairs(Component) do
        if (type(func) == "function") then
            instance[fname] = func
        end
    end

    if (type(name) == "string") then
        rawset(instance, COMPONENT_SHORT_NAME, name)
    end

    setmetatable(instance, {  __metatable = fullname })
    rawset(instance, COMPONENT_NAME, fullname)
    rawset(instance, COMPONENT_BASE, component)

    local ctor = instance.OnCreate
    if (type(ctor) == "function") then
        ctor(instance)
    end

    components[fullname] = instance
    return instance
end

--[[ Removes the component by instance or by ID ]]
function ComponentManager:Remove(component)
    if (type(component) == "string") then
        component = components[component]
    end

    if (component) then
        local term = component.OnTerminate
        if (type(term) == "function") then
            term(component)
        end

        components[rawget(component, COMPONENT_NAME)] = nil
    end
end

--[[ Retrieves the component with the specified name ]]
function ComponentManager:Get(name)
    if (type(name) == "table") then
        name = rawget(name, COMPONENT_NAME)
    end
    
    --@debug--
    if (type(name) ~= "string") then
        error("Expected name to be astring")
    end
    --@end-debug@

    return components[string.lower(name)]
end

--[[ Called to attempt to initalize the components ]]
function ComponentManager:InitializeComponents()
    initComponents();
end

--[[ Gets the name for this component which must exist ]]
function Component:GetName()
    local name = rawget(self, COMPONENT_SHORT_NAME)
    if (type(name) == "string") then
        return name
    end

    local base = rawget(self, COMPONENT_BASE)
    if (base) then
        local getName = base.GetName
        if (type(getName) == "function") then
            name = getName(self)
        end

        if (type(name) == "string") then
            return name
        end

        if (type(base.Name) == "string") then
            return base.Name
        end
    end

    error("The component has no name")
end

--[[ Gets the type of this component ]]
function Component:GetType()
    local base = rawget(self, COMPONENT_BASE)
    if (base) then
        local getType = base.GetType
        if (type(getType) == "function") then
            local ctype = getType(self)
            if (type(ctype) == "string") then
                return ctype
            end
        end

        if (type(self.Type)) == "string" then
            return self.Type
        end
    end

    return COMPONENT
end

--[[ Gets the dependnecies for this component ]]
function Component:GetDependencies()
    local base = rawget(self, COMPONENT_BASE)
    if (base) then

        local getDeps = base.GetDependecies      
        if (type(getDeps) == "function") then
            local deps = getDeps(self)
            if (type(deps) == "table") then
                return deps
            end
        end

        if (type(base.Dependencies) == "table") then
            return base.Dependencies
        end
    end

    return {}
end

--[[ Make sure is an entry for each and every addon that was loaded ]]
local function satisfyAllAddons()
    local numAddons = GetNumAddOns();
    for i=1,numAddons do
        local addon, _, _, enabled = GetAddOnInfo(i);
        if (enabled) then
            local depenedency = "addon:" .. addon;
            if (not IsDependencySatisfied(depenedency)) then
                sastifyDependency(depenedency);
            end
        end
    end
end


local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent",
    function(_, name, arg1)
        if (type(name) == "string") then
            if (name == "PLAYER_ENTERING_WORLD") then
                eventFrame:UnregisterEvent(name)
                satisfyAllAddons()
                sastifyDependency("event:" .. name)
            elseif (name == "ADDON_LOADED") then
                if (arg1 == AddonName) then
                    sastifyDependency("event:loaded")
                elseif (type(arg1) == "string") then
                    sastifyDependency("addon:" .. arg1)
                end
            elseif (name == "PLAYER_LOGOUT") then
                termComponents()
                eventFrame:UnregisterAllEvents()
            else
                sastifyDependency("event:" .. name)
            end
        end
    end)

eventFrame:RegisterEvent("VARIABLES_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

Addon.ComponentManager = ComponentManager