local AddonName, Addon = ...
--[[===========================================================================
   | Features/Features
   |
   | Is a system from implementing addon features, they are contained and 
   | sandboxed (mostly), they have thier event automatically registered
   | when they are enabled and removed when they are disabled.
   |
   | Features can have 3 stats:
   |    "preview":     it is a preview feature, not enabled by default
   |                   only availbe to be enabled if "the preview" featurs
   |                   option is enabled.                     
   |    "beta":        The feature is further along than preview but is
   |                   still not enabled by default
   |    "retail"|nil:  Enabled when the addon is initialzied cnanot be 
   |                   disabled.
   |
   | Features are provided with account/character specific saved variables
   | the can leverage (savevariable.lua) thos are passed as arguments to 
   | the 'OnInitalize' method.
   |
   | Events are automatically connected when the feature is enabled based
   | on the following:
   |    * A function member "ON_WOW_EVENT" is connected the frame event
   |      via Frame:RegisterEvent()
   |    * A function member with a matching an addon generated event then
   |      it will be automatically connected.
   |
   |  Features generate the following addon level events:
   |    OnFeatureEnabled(feature): Dispatchd when a feature is eanbled
   |    OnFeatureReady(feature): Dispatched when the feature is ready
   |    OnFeatureDisabled(feature): Dispatched when the feature is disabled
   |
   | FeatureHost: (todo)
   |
   | The members of the Addon.Features table are processed during startup
   | and enabled if they are retail, or they have been eanbled in this
   | profile list of enabled features.
   ==========================================================================]]

local Feature = {}
local Features = {}
local FEATURE_PREVIEW = "preview"
local FEATURE_BETA = "beta"
local FEATURE_RETAIL = "retail"

if (type(table.unpack) ~= "function") then
    table.unpack = function(t, i, j) 
    ---@diagnostic disable-next-line: deprecated
        return unpack(t, i, j)
    end
end

local function debug(message, ...) 
    Addon:Debug("features", message, ...)
end

--[[===========================================================================
   | Checks the enabled state of this feature
   ==========================================================================]]
function Feature:IsEnabled()
    return self.enabled;
end

--[[===========================================================================
   | Checks if this feature is in beta
   ==========================================================================]]
function Feature:IsBeta()
    local state = self.impl.STATE or ""
    return (string.lower(state) == FEATURE_BETA)
end

--[[===========================================================================
   | Checks if this feature is in preview
   ==========================================================================]]
function Feature:IsPreview()
    local state = self.impl.STATE or ""
    return (string.lower(state) == FEATURE_PREVIEW)
end

--[[===========================================================================
   | Checks if this feature is in retail
   ==========================================================================]]
function Feature:IsRetail()
    local state = self.impl.STATE
    return (type(state) ~= "string") or (string.lower(state) == FEATURE_RETAIL)
end

--[[===========================================================================
   | Enables this feature
   ==========================================================================]]
function Feature:Enable()
    if (not self.enabled) then
        local name = self:GetName()
        local events = 0

        debug("Enabling feature '%s'", name)
        Addon:RaiseEvent("OnFeatureEnabled", self)

        -- Register the events which are produced
        if (type(self.impl.EVENTS) == "table") then
            Addon:GeneratesEvents(self.impl.EVENTS)
        end

        self.enabled = true

        self.feature = setmetatable({}, {
                __name = AddonName .. ":Feature:" .. name,
                __index = self.impl
            });

        self.frame = CreateFrame("Frame")
        self.frame:SetScript("OnEvent", function(frame, event, ...)
                self:invoke(("ON_" .. event), ...)
            end)

        -- Connect Addon and Frame events
        for event, handler in pairs(self.impl) do
            if (type(handler) == "function") then
                -- Check for frame events
                if (string.find(event, "ON_") == 1) then
                    --debug("Registered event '%s' for '%s'", string.sub(event, 4), name)
                    events = events + 1
                    self.frame:RegisterEvent(string.sub(event, 4))
                -- Check for addon events
                elseif (Addon.eventBroker:DoesFrameHaveEvent(event)) then
                    --debug("Registered event '%s' for '%s'", event, name)
                    events = events + 1
                    Addon.eventBroker:RegisterCallback(event, function (...) 
                        self:invoke(event, ...) 
                    end, self)
                end
            end
        end

        -- Add thunks for member functions
        self.feature.CreateDialog = function(feature, ...)
                return self:CreateDialog(...)
            end

        self.feature.Debug = function(_, ...)
                Addon:Debug("feature:" .. name, ...)
            end

        self.feature.GetHost = function(feature)
                return self
            end

        self.feature.GetDependency = function(_, name)
                return self.depends[string.lower(name)]
            end

        -- If the feature has an oninitialize method, it can return both a public
        -- and an intenral API, merge them into the respective apis.
        for name, depend in pairs(self.depends) do
            self.feature[name] = depend
        end

        local onInit = self.feature.OnInitialize
        if (type(onInit) == "function") then
            onInit(self.feature, self)
        end

        --[[local internalApi, publicApi = self:invoke("OnInitialize", self.account, self.character, self)

        if (type(internalApi) == "table") then
            for name, func in pairs(internalApi) do
                Addon[name] = function(addon, ...) return self:invoke(func, ...) end
            end
        end

        if (type(publicApi) == "table") then
            for name, func in pairs(publicApi) do
                Addon.Public[name] = function(addon, ...) returnself:invoke(func, ...) end
            end
        end]]

        debug("Feature '%s' is ready (%d events connected)", name, events)
        Addon:RaiseEvent("OnFeatureReady", self)

        -- Notify anything waiting
        for _, ready in ipairs(self.ready) do
            ready()
        end

        return true
    end
end

--[[===========================================================================
   | Disables this feature
   ==========================================================================]]
function Feature:Disable()
    if (self.enabled) then
        -- Disconnect Frame and Addon events
        self.frame:UnregisterAllEvents()
        for event, handler in pairs(self.impl) do
            if (Addon.eventBroker:DoesFrameHaveEvent(event)) then
                Addon:Debug("features", "Unregister event '%s' for '%s'", event, self.name)
                Addon.eventBroker:UnregisterCallback(event, self)
            end
        end

        -- terminate  the feature
        self:invoke("OnTerminate")
        if (type(self.impl.EVENTS) == "table") then
            Addon:RemoveEvents(self.impl.EVENTS)
        end

        self.enabled = false
        self.feature = false
        self.frame = false

        Addon:RaiseEvent("OnFeatureDisabled", self)
    end
end

--[[===========================================================================
   | Retrieves the name of this feature
   ==========================================================================]]
function Feature:GetName()
    return self.impl.NAME
end

--[[===========================================================================
   | Retrieves the description of this feature
   ==========================================================================]]
function Feature:GetDescription()
    return self.impl.DESCRIPTION or false
end

--[[
    Retrieve the version of the feature
]]
function Feature:GetVersion()
    local v = self.impl.VERSION
    if (v ~= nil) then
        return tostring(v)
    end
    return "0"
end

--[[
    Retrieves the dependecies for this feature
]]
function Feature:GetDependencies()
    return self.impl.DEPENDENCIES or {}
end

--[[
    Assigns a dependency to this feature
]]
function Feature:SetDependency(name, depend)
    assert(depend:IsEnabled())

    if (not self.depends[name]) then
        Addon:Debug("features", "Setting dependency '%s' of '%s'", name, self:GetName())
        local instance = depend:GetInstance()
        if (self.feature) then
            self.feature[name] = instance
        end
        self.depends[string.lower(name)] = instance
    end
end

--[[
    Retrieve the specified dependency
]]
function Feature:GetDependency(depend)
    local instance = self.depends[string.lower(depend)]
    if (not instance) then
        error("The depenedency \"" .. depend .. "\" was not found in \"" .. self:GetName() .. "\"")
    end

    return instance
end

--[[
    Returns the instance of the feature
]]
function Feature:GetInstance()
    return self.feature
end

--[[ When the feature is ready invoke the handler ]]
function Feature:WhenReady(callback)
    if (type(callback) ~= "function") then
        error("Usage: Feature.WhenReady( function )")
    end

    if (self.feature) then
        xpcall(callback, CallErrorHandler, self.feature)
    else
        table.insert(self.ready, function()
            xpcall(callback, CallErrorHandler, self.feature)
        end)
    end
end

--[[===========================================================================
   | Retrieves the features object used to manage features
   ==========================================================================]]
function Feature:Create(feature)
    assert(type(feature) == "table", "A feature should be a table")
    if (type(feature.NAME) ~= "string") then
        error("A feature implementation needs to provide a 'NAME' property")
    end
    
    local instance = {
        impl = feature,
        feature = false,
        enabled = false,
        frame = false,
        depends = {},
        dialogs = false,
        host = false,
        ready = {},

        invoke = function(this, what, ...)
            -- If we were not given a function then trt to resolve it
            if (type(what) ~= "function") then
                if this.feature and (type(this.feature[what]) == "function") then
                    what = this.feature[what]
                end
                --assert(type(what) == "function", string.format("attempted to invoke invalid method '%s' on '%s'", what, this:GetName()))
            end

            if (type(what) == "function") then
                local result = { xpcall(what, CallErrorHandler, this.feature, ...) }
                if (result[1] ~= true) then
                    Addon:Debug("errors", "Feature.invoke: failed to invoke '%s' on '%s' :: %s", what, this:GetName(), result[2] or "")
                else
                    return select(2, table.unpack(result))
                end
            end
        end,
    }

    return Addon.object(AddonName .. "Feature", instance, self)
end

local function attach(frame, ...)
    for _, impl in ipairs({...}) do
        if (impl and type(impl) == "table") then
            for name, what in pairs(impl) do
                if (type(what) == "function") then
                    if (frame:HasScript(name)) then
                        frame:SetScript(name, what)
                    end
                else
                    frame[name] = what
                end
            end
        end
    end

    if (type(frame.OnLoad) == "function") then
        local result, msg = xpcall(frame.OnLoad, CallErrorHandler, frame)
        if not result then
            Addon:Debug("errors", "%s.OnLoad: failed - %s", frame:GetName(), this:GetName(), msg)
        end
    end
end

-- creates a dialog, the diffrence between a dialog and a frame is that a dialog is added to the globals
-- and cleared when the feature is disabled.
function Feature:CreateDialog(name, template, class, buttons)
    assert(self:IsEnabled())

    local dialog = CreateFrame("Frame", name, UIParent, "DialogBox_Base")
    local frame = CreateFrame("Frame", name, dialog, template)

    dialog:SetContent(frame)
    Addon.LocalizeFrame(dialog)
    Addon.LocalizeFrame(frame)

    if (type(buttons) == "table") then
        dialog:SetButtons(buttons)
    end

    -- If there was an implementation provided, then we need to merge 
    -- it into the frame (meaning the frame becomes the instance), this will
    -- hook any events we've got, and then push the APIs onto the dialog
    if (type(class) == "table") then
        for name, value in pairs(class) do
            if (type(value) == "function") then
                if frame:HasScript(name) then
                    frame:SetScript(name, value)
                elseif Addon:RaisesEvent(name) then
                    Addon:RegisterCallback(name, value, frame)
                else
                    -- Expose the API through both the Dialog itself (Forward thunk) and
                    -- on the actual frame.
                    frame[name] = value                  
                    dialog[name] = function(_, ...) 
                        value(frame, ...)
                    end
                end
            else
                frame[name] = value
            end
        end
    end

    frame.GetDialog = function() 
            return dialog
        end

    frame.GetFeature = function()
            return self.feature
        end

    frame.GetDependency = function(_, dep)
            return self.depends[string.lower(dep)]
        end

    frame.Debug = self.feature.Debug
    if (type(frame.OnInitDialog) == "function") then
        xpcall(frame.OnInitDialog, CallErrorHandler, frame, dialog)
    end

    self.dialogs = self.dialogs or {}
    self.dialogs[name] = frame

    if (type(name) == "string") then
        _G[name] = dialog
    end

    return dialog
end

-- Creates a frame
function Feature:CreateFrame(parent, template, ...)
    local frame = CreateFrame("Frame", nil, parent or UIParent, template)
    Addon.LocalizeFrame(frame)
    attach(frame, frame.Implementation, ...)
    return frame
end


--[[===========================================================================
   | Called to initialize the the addons features
   ==========================================================================]]
function Features:Initialize()
    Addon:GeneratesEvents({ "OnFeatureEnabled", "OnFeatureDisabled", "OnFeatureReady" })

    -- After 10 seconds create all the feature objects and then start initialziing 
    -- all of our feastures
    Addon:Debug("%s loaded - checking for features", AddonName)
    if (type(Addon.Features) ~= "table") then
        Addon:Debug("features", "There are no features to register")
        return
    end

    -- TODO: here is where would fiter beta va not

    for feature, impl in pairs(Addon.Features) do
        local featureObj =  Feature:Create(impl)
        self.features[featureObj:GetName()] = featureObj
        Addon:Debug("features", "Registered feature '%s' (v%s)", featureObj:GetName(), featureObj:GetVersion())
    end

    -- Register a terminate handler
    Addon:AddTerminateAction(function()
        self:Terminate()
    end)

    C_Timer.After(10, function()
            self:EnableOneFeature()
        end)
end

--[[===========================================================================
   | Disables any currently enabled features and cleans up the list
   ==========================================================================]]
function Features:Terminate()
    for _, featureObj in ipairs(self.features) do
        if (featureObj:IsEnabled()) then
            featureObj:Disable()
        end
    end
end

--[[===========================================================================
   | Checks if the provided feature is eanbled
   ==========================================================================]]
function Features:IsFeatureEnabled(feature)
    if (type(feature) ~= "string") then
        error("Usage: IsFeatureEnabled(feature) got " .. type(feature) .. " for feature")
    end

    local featureObj = self.features[feature]
    return featureObj and featureObj:IsEnabled()
end

--[[
    Checks if all the dependecies of the specified featrure eare enabled (ready)
    if they are then 
]]
function Features:CheckDepdencies(feature)
    local deps = feature:GetDependencies()
    if (not deps or table.getn(deps) == 0) then
        return true
    end

    for _, dep in ipairs(deps) do
        local dependency = self.features[dep]
        if (not dependency) then
            Addon:Debug("features", "Feature '%s' depends on '%s' which doesn't exist", feature:GetName(), dep)
            error(string.format("Feature '%s' has an unsatisified dependency '%s'", feature:GetName(), dep))
            return false
        elseif dependency:IsEnabled() then
            feature:SetDependency(dep, dependency)
        else
            return false
        end
    end

    return true
end

--[[
    Enables a single feature, and then queues an operation to enable another one
]]
function Features:EnableOneFeature()
    -- Enable addons that should be enabled
    for _, feature in pairs(self.features) do
        if not feature:IsEnabled() then
            if (self:CheckDepdencies(feature)) then
                feature:Enable()
                C_Timer.After(1,
                    function()
                        self:EnableOneFeature()
                    end)
                return
            else
                Addon:Debug("features", "Feature '%s' has dependecies are not ready yet", feature:GetName())
            end
        end
    end
end

--[[===========================================================================
   | Checks the overall state for allowing preview features they have two
   | steps, they both need to be enabled themeselves and this master 
   | switch needs to be thrown.
   ==========================================================================]]
function Features:AllowPreviewFeatures()
    return true
end

--[[===========================================================================
   | Modifies the master preview switch but does not enable any of the
   | features.
   ==========================================================================]]
function Features:SetAllowPreview(allow)
end

-- Helper to filter a list based certain creteria
local function filter(features, enabled, retail, beta, preview)
    local list = {}
    for _, featureObj in ipairs(features) do
        if (enabled == featureObj:IsEnabled()) then
            if ((retail and featureObj:IsRetail()) or 
                (beta and featureObj:IsBeta()) or
                (preview and featureObj:IsPreview())) then
                table.insert(list, featureObj)
            end
        end
    end
    return list
end

--[[===========================================================================
   | Retrieves the features object used to manage features
   ==========================================================================]]
function Features:GetEnabled()
    return filter(self.features, true, true, true, true)
end

function Features:GetFeature(name)
    local featureObj = self.features[name]
    if (not featureObj) then
        error("Unable to locate feature: " .. name)
    end

    if (not featureObj:IsEnabled()) then
        error("Requested diabled feature: " .. name)
    end

    return featureObj:GetInstance()
end

function Features:Find(name)
    return self.features[name]
end

local FEATURES = {}

--[[===========================================================================
   | Retrieves the features object used to manage features
   ==========================================================================]]
function Addon:GetFeatures()
    local features = rawget(self, FEATURES);
    if (not features) then
        local instance = {
            features = {},
            account = Addon.SavedVariable:new("Acccount_Data"),
            chracter = Addon.SavedVariable:new("Character_Data"),
        };

        features = Addon.object(AddonName .. "Features", instance, Features);
        rawset(self, FEATURES, features);
    end

    return features;
end

--[[===========================================================================
   | Helper for determining if features are enabled
   ==========================================================================]]
function Addon:IsFeatureEnabled(feature)
    return Addon:GetFeatures():IsFeatureEnabled(feature)
end

function Addon:WithFeature(name, callback, ...)
    local features = self:GetFeatures()
    local feature = features:Find(name)

    if (type(callback) ~= "function") then
        error("Expected callback to be a valid function")
    end

    if (not feature) then
        error("Unable to locate feature: " .. name)
    end

    -- Queue or execute the callback
    local args = { ... }
    feature:WhenReady(function(instance)
            callback(instance, table.unpack(args))
        end)
end

--[[
    Retrieves the feature with the specified name
]]
function Addon:GetFeature(name)
    local features = self:GetFeatures()
    return features:GetFeature(name)
end