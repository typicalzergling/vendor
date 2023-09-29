local AddonName, Addon = ...
local debugp = function (...) Addon:Debug("features", ...) end
local Features = {}
local compMgr = Addon.ComponentManager

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
        -- TODO: Verify Idempotency
        local success = callFeature(feature, "OnInitialize")
        if (not success) then
            return
        end

        -- Check for events (move to GetEvents)
        local events = GetFeatureValue(feature, "EVENTS", "GetEvents")
        if (type(events) == "table") then
            Addon:GenerateEvents(events)
        end

        -- Register event handlers for this feature
        for name, value in pairs(feature) do
            if (type(value) == "function") then
                if (Addon:RaisesEvent(name)) then
                    Addon:RegisterCallback(name, feature, value)
                elseif(string.find(name, "ON_") == 1) then
                    Addon:RegisterEvent(string.sub(name, 4),
                        function(...)
                            value(feature, ...)
                        end)
                end
            end
        end

    --[[
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
        --Addon:GenerateEvents(events)
    end

    -- Automatically hook events into the system
    for name, handler in pairs(system) do
        if (type(handler) == "function") then
            if (name == "ADDON_LOADED") then
                -- This is implicit sine we are already here.
                handler(system);
            elseif Addon:RaisesEvent(name) then
                print("---------> register", name);
                Addon:RegisterCallback(name, system, handler)
            elseif (string.find(name, "ON_") == 1) then
                print("------------> regisster", name);
                Addon:RegisterEvent(string.sub(name, 4),
                    function(...)
                        handler(system, ...)
                    end)
            end
        end
    end--]]

    if (string.lower(name) == "chat") then
        print("Init Chat:", type(self.features[string.lower(name)]))
    end

    self.features[string.lower(name)] = feature;
end

function Features:TerminateFeature(name, system)
    print("terminate system:", name)
end

function Features:CreateComponent(name, feature)
    debugp("Create commpoennt Feature[%s]", name)

    feature = setmetatable({},  {
        __metatable = name,
        __index = feature
    })

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
            --RaiseEvent("AllFeaturesReady")
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
    Addon:RaiseEvent("OnFeaturesReady")
end

--[[ Returns all the beta features ]]
function Features:GetBetaFeatures()
    local beta = {}
    for _, feature in pairs(self.features) do
        if (feature.beta) then
            table.insert(beta, {
                id = string.lower(feature.name),
                name = feature.instance.NAME or feature.name,
                description = feature.instance.DESCRIPTION or "",
                eanbled = feature.enabled
            })
        end
    end
    return beta
end

function Features:GetFeature(feature)
    return self.features[string.lower(feature)]
end

function Features:IsFeatureEnabled(name)
    if (string.lower(name) == "chat") then
        print("Chat:", type(self.features[string.lower(name)]))
        return self.features["chat"] ~= nil
    end
    return type(self.features[string.lower(name)] == "table")
end

function Features:EnableFeature(name)
    --[[local feature = self.features[string.lower(name)]
    if (not feature) then
        error("Attempting to enable non-existent feature '" .. name .. "'")
    end

    if (not feature.enabled) then
        debugp("Enabling feature '%s'", feature.name)

        -- Merge the locale into the table
        if (type(feature.instance.Locale) == "table") then
            for locale, strings in pairs(feature.instance.Locale) do
                assert(type(strings) == "table")

                local loc = Addon:FindLocale(locale);
                if (loc) then
                    loc:Add(strings)
                else
                    debugp("Clearing unsused locale[%s] from feature [%s]", locale, name)
                    feature.instance.Locale[locale] = nil
                end
            end
        end

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
    end]]--
end

function Features:DisableFeature(name)
    --[[
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

    -- Merge the locale into the table
    if (type(feature.instance.Locale) == "table") then
        for locale, strings in pairs(feature.instance.Locale) do
            assert(type(strings) == "table")

            local loc = Addon:FindLocale(locale);
            if (loc) then
                loc:Remove(strings)
            end
        end
    end

    -- TODO: Disable all features that depend on this one....
    --- .... and all features dependent on those features...
    -- For now lets just not disable features on which other features depend....

    feature.enabled = false
    ---]]
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

--[[ Retreive the events we raise ]]
function Features:GetEvents()
    return { "OnFeatureDisabled", "OnFeatureEnabled", "OnFeatureReady", "OnFeaturesReady" }
end


Addon.Features = {}
Addon.Systems.Features = Features


--[[Addon:RegisterEvent("ADDON_LOADED", function(addon)
    if (addon == AddonName) then
        local deps = { }
        local compMgr = Addon.ComponentManager
        
        for name, feature in pairs(Addon.Features or {}) do
            table.insert(deps, "feature:" .. name)

            -- todo check if should eanble the feature or not.

            compMgr:Create(CreateComponent(name, feature));
        end

        compMgr:Create({
            Name = "features",
            Type = "core",
            Dependencies = deps,
            OnInitialize = function(self)
                debugp("All features are ready")
                --RaiseEvent("AllFeaturesReady")
            end
        })
    end
end)]]--