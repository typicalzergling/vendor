local AddonName, Addon = ...
local Features = Mixin({}, Addon.DependencyInit)

--[[ A simple helper for calling an optional method on a feature ]]
local function callFeature(feature, method, ...)
    if (type(feature[method]) == "function") then
        local result = { xpcall(feature[method], CallErrorHandler, feature, ... ) }
        if (not result[1]) then
            return false
        end

        table.remove(result, 1)
        return true, unpack(result)
    end

    return true
end

--[[ Startup our features ]]
function Features:Startup()
    Addon:Debug("features", "Checking for features to initialize")

    self.features = {}
    if (type(Addon.Features) == "table") then
        for name, feature in pairs(Addon.Features) do
            local featureInfo = {
                name = name,
                instance = feature,
                enabled = false,
            }

            self.features[string.lower(name)] = featureInfo
        end
    end

    return { "GetFeature", "IsFeatureEnabled", "EnableFeature", "DisableFeature",  "WithFeature" }
end

--[[ Called to handle shutting down the features ]]
function Features:Shutdown()
    for _, feature in pairs(self.features) do
        callFeature(feature.instance, "OnTerminate")
    end
end

--[[ Called when single feature has finished initialzation ]]
function Features:InitComplete(feature, success)
    Addon:Debug("features", "Feature '%s' has finished initialization [success=%s]", feature.name, success)
    if (success) then
        feature.ready = true
        --Addon:RaiseEvent("OnFeatureReady", feature.name)
        if (feature.onready) then
            for _, callback in pairs(feature.onready) do
                xpcall(callback, CallErrorHandler, feature.object)
            end
        end
    end
end

--[[ Called to start a single system ]]
function Features:InitTarget(feature, complete)
    C_Timer.After(.25, function()
            Addon:Debug("feature", "Iniitaling feature '%s'", feature.name)
            self:EnableFeature(feature.name)
            complete(feature.enabled)
        end)
end

function Features:EndInit(success)
    Addon:Debug("feature", "All features initialized")
end

function Features:GetFeature(feature)
    local info = self.features[string.lower(feature)]
    if (info) then
        return info.object
    end
end

function Features:IsFeatureEnabled(name)
    local feature = self.features[string.lower(name)]
    if (feature and feature.enabled) then
        return true
    end

    return false
end

function Features:EnableFeature(name)
    local feature = self.features[string.lower(name)]
    if (not feature) then
        error("Attempting to enable non-existent feature '" .. name .. "'")
    end

    if (not feature.enabled) then
        Addon:Debug("features", "Enabling feature '%s'", feature.name)

        -- Call Initiaize on the feature
        local success = callFeature(feature.instance, "OnInitialize")
        if (not success) then
            return
        end

        -- Check for events (move to GetEvents)
        if (feature.instance.EVENTS) then
            Addon:GenerateEvents(feature.instance.EVENTS)
        end

        -- Register event handlers for this feature
        for name, value in pairs(feature.instance) do
            if (type(value) == "function") then
                if (Addon:RaisesEvent(name)) then
                    Addon:RegisterCallback(name, feature.instance, value)
                end
            end
        end

        -- Wrap the feature to produce and instance        
        local instance = feature.instance
        feature.object = setmetatable({}, {
                __metatable = string.format("Feature[%s]", feature.name),
                __index = function(_, key)
                    local value = instance[key]
                    if (type(value) == "function") then
                        return function(_, ...)
                                local result = { xpcall(value, CallErrorHandler, instance, ...) }
                                if (not result[1]) then
                                    Addon:Debug("features", "An error occured while trying to invoke %s::%s", feature.name, key)
                                    return
                                end

                                table.remove(result, 1)
                                return unpack(result)
                            end
                    end

                    error(string.format("Feature '%s' has not method '%s'", featire.name, tostring(key)))
                end,
                __newindex = function(_, key, value)
                end
            })

        feature.enabled = true
    end
end

function Features:DisableFeature(name)
    Addon:Debug("features", "Disabling feature %s -- NYI", name)
end

function Features:WithFeature(name, callback)
    local feature = self.features[string.lower(name)]
    if (not feature) then
        error("There is no feature '" .. tostring(feature) .. "'")
    end

    -- todo handle enabled

    if (feature.ready) then
        callback(feature.object)
    else
        feature.onready = feature.onready or {}
        table.insert(feature.onready, callback)
    end
end

--[[ Retrun the systems we dpeend on ]]
function Features:GetDependencies()
    return { "profile", "savedvariables" }
end

--[[ Retreive the events we raise ]]
function Features:GetEvents()
    return { "OnFeatureDisabled", "OnFeatureEnabled", "OnFeatureReady" }
end

--[[ Called when all systems are ready ]]
function Features:OnAllSystemsReady()
    Addon:Debug("features", "Checking for features to initialize")

    for _, feature in pairs(self.features) do
        assert(type(feature) == "table", "Expected the feature to be a table")

        --@debug@
        local success, systems = callFeature(feature.instance, "GetSystems")
        if (not success) then
            error("Failed to get the systems feature '" .. name .. "' depends on")
        end

        if (type(systems) == "table") then
            for _, system in pairs(systems) do
                if (not Addon:GetSystem(system)) then
                    error("Feature '" .. name .. "' depends on system '" .. system .. "' which is not available")
                end
            end
        end
        --@end-debug@

        local success, depenencies = callFeature(feature.instance, "GetDependencies")
        if (not success) then 
            error("Failed to resolve dependencies fsor feature '" .. name .. "'")
        end

        -- TEMP
        if (not depenencies and feature.instance.DEPENDENCIES) then
            depenencies = feature.instance.DEPENDENCIES
        end

        self:AddTarget(feature, feature.name, depenencies)
    end

    C_Timer.After(10, function()
            self:BeginInit()
        end)
end

Addon.Features = {}
Addon.Systems.Features = Features