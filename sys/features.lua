local AddonName, Addon = ...
local debugp = function (...) Addon:Debug("features", ...) end
local Features = {}
local compMgr = Addon.ComponentManager

--[[ Gets a property or calls a function on the specified featuire ]]
local function GetFeatureValue(feature, property, funcName)
    local func = feature[funcName]
    if (type(func) == "function") then
        return func(feature)
    end

    local prop = feature[property]
    if (type(prop) ~= "nil") then
        return prop
    end

    return nil
end

function Features:InitializeFeature(name, feature)
    debugp("Initialize Feature[%s]", name)
    local instance = feature

    -- In debug we create a proxy to the feature so that we can 
    -- catch typo's
    --@debug@
    instance = setmetatable({}, {
        __metatable = "feature:" .. name,
        __index = function(_self, member)
            local field = rawget(feature, member)
            if (type(field) ~= nil and type(field) ~= "function") then
                return field;
            end

            if (type(field) ~= 'function') then
                error(string.format("The feature '%s' does not have a method '%s'", name, member))
            end

            return function(_, ...)
                    local result = { xpcall(field, CallErrorHandler, feature, ...) }
                    assert(result[1] == true, "Failed to call member: " .. member .. " on feature: " .. name)
                    table.remove(result, 1)
                    return unpack(result)
                end
        end,
        __newindex = function(_, name, value)
            rawset(feature, name, value)
        end
    })
    rawset(instance, "#FEATURE#", feature)
    --@end-debug@

    -- Merge the locale into the table
    if (type(feature.Locale) == "table") then
        for locale, strings in pairs(feature.Locale) do
            assert(type(strings) == "table")

            local loc = Addon:FindLocale(locale);
            if (loc) then
                loc:Add(strings)
            end
        end
    end

    -- Call Initiaize on the feature
    -- We should have 2 core events:
    --      OnInitialize
    --      OnTerminate
    local init = feature.OnInitialize
    if (type(init) == "function") then
        debugp("Initializing  feature[%s]", name)
        local success = xpcall(init, CallErrorHandler, instance)
        assert(success, "Feature failed to initialize '" .. name .. "'")

        if (not success) then
            return
        end
    end

    -- Check for events (move to GetEvents)
    local events = GetFeatureValue(feature, "EVENTS", "GetEvents")
    if (type(events) == "table") then
        Addon:GenerateEvents(events)
    end

    Addon.RegisterForEvents(instance, feature)
    self.features[string.lower(name)] = instance;
    Addon:RaiseEvent("OnFeatureReady", name, instance)
    Addon:RaiseEvent("OnFeatureEnabled", name, instance)
end

function Features:TerminateFeature(name, feature)
    debugp("TerminateFeature[%s]", name)

    name = string.lower(name)
    if (self.features[name]) then
        local term = feature.OnTerminate
        if (type(term) == "function") then
            debugp("Terminating feature[%s]", name)
            local success = xpcall(term, CallErrorHandler, self.features[name])
            assert(success, "Feature failed to terminate '" .. name .. "'")
        end

        Addon.UnregisterFromEvents(self.features[name], feature)
        self.features[string.lower(name)] = nil;
        Addon:RaiseEvent("OnFeatureDisabled", name, feature)
    end
end

function Features:CreateComponent(name, feature)
    debugp("Create commpoennt Feature[%s]", name)

    local featureDeps = GetFeatureValue(feature, "DEPENDENCIES", "GetDependencies") or {}
    table.insert(featureDeps, "event:loaded" );
    table.insert(featureDeps, "core:systems" );
    table.insert(featureDeps, "event:PLAYER_ENTERING_WORLD" );

    local fs = self
    return {
        Type = "feature",
        Name = name,
        OnInitialize = function() Features.InitializeFeature(fs, name, feature) end,
        OnTerminate = function() Features.TerminateFeature(fs, name, feature) end,
        Dependencies = featureDeps
    }
end

function Features:GetDependencies() 
    return { "system:savedvariables", "system:accountsettings", "system:profile" }
end

--[[ Startup our features ]]
function Features:Startup(register)
    debugp("Checking for features to initialize")
    self.features = {}

    local deps = { }
    
    for name, feature in pairs(Addon.Features or {}) do
        table.insert(deps, "feature:" .. name)

        -- todo check if should eanble the feature or not.

        compMgr:Create(self:CreateComponent(name, feature));
    end

    compMgr:Create({
        Name = "features",
        Type = "core",
        Dependencies = deps,
        OnInitialize = function(self)
            debugp("All features are ready")
            --Addon:RaiseEvent("AllFeaturesReady")
        end
    })

    register({
        "GetFeature", 
        "IsFeatureEnabled", 
        "EnableFeature", 
        "DisableFeature",  
        "WithFeature", 
        "GetBetaFeatures"
    })
end

--[[ Called to handle shutting down the features ]]
function Features:Shutdown()
    self.features = {}
end

--[[ Returns all the beta features ]]
function Features:GetBetaFeatures()
    local beta = {}
    for name, feature in pairs(Addon.Features or {}) do
        if (feature.BETA == true) then
            table.insert(beta, {
                id = string.lower(name),
                name = feature.NAME or name,
                description = feature.DESCRIPTION or "",
                eanbled = self.features[string.lower(name)] ~= nil
            })
        end
    end
    return beta
end

function Features:GetFeature(feature)
    return self.features[string.lower(feature)]
end

function Features:IsFeatureEnabled(name)
    return self.features[string.lower(name)] ~= nil
end

function Features:EnableFeature(name)
    debugp("Enable feature '%s'", name)
    local component = compMgr:Get("feature:" .. string.lower(name))
    if (component ~= nil) then
        return
    end

    name = string.lower(name)
    for fname, feature in pairs(Addon.Features) do
        print("feature:", name, "--> ", feature)
        if (string.lower(fname) == name) then
            compMgr:Create(self:CreateComponent(name, feature))
            compMgr:InitializeComponents()
            break;
        end
    end
end

function Features:DisableFeature(name)
    debugp("Disable feature '%s'", name)
    local componentName = "feature:" .. string.lower(name)
    local component = compMgr:Remove(componentName)
end

function Features:WithFeature(name, callback)
    local feature = self.features[string.lower(name)]
    if (not feature) then
        error("There is no feature '" .. tostring(name) .. "'")
    end

    -- todo handle enabled
    Addon:DebugForEach("features", feature)
    Addon:Debug("features", "Name:: %s", getmetatable(feature.object))
    if (feature) then
        callback(feature)
    else
        feature.onready = feature.onready or {}
        table.insert(feature.onready, callback)
    end
end


Addon.Features = {}
Addon.Systems.Features = Features
Addon:GenerateEvents({ "OnFeatureDisabled", "OnFeatureEnabled", "OnFeatureReady", "OnFeaturesReady" })