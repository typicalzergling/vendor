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

local function debug(message, ...) 
    Addon:Debug("features", message, ...)
end

--[[===========================================================================
   | Checks the enabled state of this feature
   ==========================================================================]]
function Feature:IsEnabled()
    return self.eanbled;
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

        -- Finally if the feature provides an "OnInitialize" invoke it
        if (not self:invoke("OnInitialize", self.account, self.character, self)) then
            Addon:Debug("Feature '%s' failed to initialize", name)
            self:Disable()
            return false;
        end

        debug("Feature '%s' is ready (%d events connected)", name, events)
        Addon:RaiseEvent("OnFeatureReady", self)
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

function Feature:GetVersion()
    local v = self.impl.VERSION
    if (v ~= nil) then
        return tostring(v)
    end
    return "0"
end

--[[===========================================================================
   | Retrieves the features object used to manage features
   ==========================================================================]]
function Feature:Create(feature, account, character)
    assert(type(feature) == "table", "A feature should be a table")
    if (type(feature.NAME) ~= "string") then
        error("A feature implementation needs to provide a 'NAME' property")
    end

    -- Create account wide data for this feature
    local accountData = account:Get(feature.NAME)
    if (not accountData) then
        accountData = {}
        account:Set(feature.NAME, accountData)
    end

    -- Create chracter specific data for this feature
    local characterData = character:Get(feature.NAME)
    if (not characterData) then
        characterData = {}
        character:Set(feature.NAME, characterData)
    end


    local instance = {
        impl = feature,
        feature = false,
        enabled = false,
        frame = false,
        account = accountData,
        character = characterData,
        dialogs = false,
        host = false,

        invoke = function(this, what, ...)
            table.forEach(this, print)
            -- If we were not given a function then trt to resolve it
            if (type(what) ~= "function") then
                if this.feature and (type(this.feature[what]) == "function") then
                    what = this.feature[what]
                end
                --assert(type(what) == "function", string.format("attempted to invoke invalid method '%s' on '%s'", what, this:GetName()))
            end

            if (type(what) == "function") then
                local result, msg = xpcall(what, CallErrorHandler, this.feature, ...)
                if (not result) then
                    Addon:Debug("errors", "Feature.invoke: failed to invoke '%s' on '%s' :: %s", what, this:GetName(), msg or "")
                end
                return result
            end

            return true
        end,

        CreateDialog = function(...)
            self.host:CreateDialog(...)
        end,
    }

    local api = table.copy(self)

    -- Put the feature object methods onto the object
    --for event, handler in pairs(self) do
        --api[event] = handler;
    --end

    -- Put he feature API into the object
    for name, method in pairs(feature) do
        if (type(method) == "function") then
            if (string.find("ON_", name) ~= 1) and (string.find("On", name) ~= 1) then
                assert(self[name] == nil)
                api[name] = function(this, ...) this.invoke(this.feature, method, ...) end
            end
        end
    end

    local t = Addon.object(AddonName .. "Feature", instance, api)
    instance.host = t
    return t
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
    local dialog = CreateFrame("Frame", name, UIParent, "DialogBox_Base")
    local frame = CreateFrame("Frame", name, dialog, template)

    dialog:SetContent(frame)
    Addon.LocalizeFrame(dialog)

    if (type(buttons) == "table") then
        dialog:SetButtons(buttons)
    end

    if (type(class) == "table") then
        Addon.AttachImplementation(frame, class, 1);
    end

    frame.GetDialog = function() 
            return dialog 
        end

    Addon.Invoke(frame, "OnInitDialog", dialog)
    self.dialogs = self.dialogs or {}
    self.dialogs[name] = frame
    _G[name] = dialog

    return dialog
end

-- Creates a frame
function Feature:CreateFrame(parent, template, ...)
    local frame = CreateFrame("Frame", nil, parent or UIParent, template)
    Addon.LocalizeFrame(frame)
    attach(frame, framne.Implementation, ...)
    return frame
end


--[[===========================================================================
   | Called to initialize the the addons features
   ==========================================================================]]
function Features:Initialize() 
    --Addon:AddInitializeAction(function()
    --    self:EnableFeatures()
    --end)

    C_Timer.After(10, function() self:EnableFeatures() end)
    Addon:GeneratesEvents({ "OnFeatureEnabled", "OnFeatureDisabled", "OnFeatureReady" })
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

--[[===========================================================================
   | Setup all of features including enabling/disabling them
   ==========================================================================]]
function Features:EnableFeatures()
    table.forEach(Addon.Features, print)
    Addon:Debug("%s loaded - checking for features", AddonName)
    if (type(Addon.Features) ~= "table") then
        Addon:Debug("features", "There are no features to register")
    else
        -- Create all of features
        for feature, impl in pairs(Addon.Features) do
            local featureObj =  Feature:Create(impl, self.account, self.chracter)
            self.features[featureObj:GetName()] = featureObj
            Addon:Debug("features", "Registered feature '%s' (v%s)", featureObj:GetName(), featureObj:GetVersion())
        end

        -- Enable addons that should be enabled
        for _, featureObj in pairs(self.features) do
            -- Enable our features
            if (featureObj:IsPreview()) then
                -- toto
                featureObj:Enable()
            elseif (featureObj:IsBeta()) then
                -- todo
                featureObj:Enable()
            else 
                featureObj:Enable()
            end
        end

        -- Register a terminate handler
        Addon:AddTerminateAction(function () 
            self:Terminate()
        end)
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