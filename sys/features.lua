local AddonName, Addon = ...
local debugp = function (...) Addon:Debug("features", ...) end
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
    debugp("Checking for features to initialize")

    self.features = {}
    if (type(Addon.Features) == "table") then
        for name, feature in pairs(Addon.Features) do

            if (name == nil or feature == nil) then
                debugp("Feature named %s is nil", tostring(name))
            else
                local featureInfo = {
                    name = name,
                    instance = feature,
                    enabled = false,
                }
                self.features[string.lower(name)] = featureInfo
            end
        end
    end

    Addon:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        if Addon.Systems.Info.IsClassicEra then
            -- Classic has a saved variables race condition that does not occur on live where
            -- the variables are not yet loaded. This is a dirty hack to delay the feature init
            -- by 2s to let that nonsense settle.
            C_Timer.NewTimer(2, function() Features:BeginInit() end)
        else
            Features:BeginInit()
        end
    end)

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
    debugp("Feature '%s' has finished initialization [success=%s]", feature.name, success)
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
    assert(feature, "Attempt to initialize a nil feature, this is a developer error.")
    --C_Timer.After(.03, function()
        debugp("Initializing feature '%s'", feature.name)
            self:EnableFeature(feature.name)
            complete(feature.enabled)
    --    end)
end

function Features:EndInit(success)
    debugp("All features initialized")
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
        debugp("Enabling feature '%s'", feature.name)

        -- Call Initiaize on the feature
        -- We should have 4 core events:
        --      OnInitialize
        --      OnTerminate
        --      OnEnable
        --      OnDisable
        -- Initialize can serve both purposes IFF Initialize implementation
        -- is idempotent. Everything in this call and in the feature's call
        -- must be idempotent for this to not have strange bugs.
        -- It makes sense for Initialize to serve both purposes since the
        -- feature could begin disabled, so OnEnable would need to potentially
        -- call Initialize anyway and we'd need to track initialize state.
        -- That would be better served by the feature simply recognizing that
        -- Initialize will be called anytime it is enabled and can be called
        -- multiple times.
        -- TODO: Verify Idempotency
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
                elseif(string.find(name, "ON_") == 1) then
                    Addon:RegisterEvent(string.sub(name, 4), 
                        function(...)
                            value(feature.instance, ...)
                        end)
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
                                assert(result[1], "An error occured while trying to invoke "..feature.name.."::"..key)
                                table.remove(result, 1)
                                return unpack(result)
                            end
                    end

                    error(string.format("Feature '%s' has not method '%s'", feature.name, tostring(key)))
                end,
                __newindex = function(_, key, value)
                end
            })

        feature.enabled = true
    end
end

function Features:DisableFeature(name)
    local feature = self.features[string.lower(name)]
    if (not feature) then
        error("Attempting to disable non-existent feature '" .. name .. "'")
    end
    debugp("Disabling feature %s", name)

    -- Call OnTerminate
    local success = callFeature(feature.instance, "OnTerminate")
    if (not success) then
        debugp("Failed to call OnTerminate for feature %s", name)
        return
    end

    -- Remove for events
    if (feature.instance.EVENTS) then
        Addon:RemoveEvents(feature.instance.EVENTS)
    end

    -- TODO: Disable all features that depend on this one....
    --- .... and all features dependent on those features...
    -- For now lets just not disable features on which other features depend....

    feature.enabled = false
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

--[[ Retrun the systems we depend on ]]
function Features:GetDependencies()
    return { "profile", "savedvariables" }
end

--[[ Retreive the events we raise ]]
function Features:GetEvents()
    return { "OnFeatureDisabled", "OnFeatureEnabled", "OnFeatureReady" }
end

--[[ Called when all systems are ready ]]
function Features:OnAllSystemsReady()
    debugp("Checking for features to initialize")

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

        local success, dependencies = callFeature(feature.instance, "GetDependencies")
        if (not success) then 
            error("Failed to resolve dependencies for feature '" .. name .. "'")
        end

        -- TEMP
        if (not dependencies and feature.instance.DEPENDENCIES) then
            dependencies = feature.instance.DEPENDENCIES
        end

        self:AddTarget(feature, feature.name, dependencies)
    end
end

Addon.Features = {}
Addon.Systems.Features = Features