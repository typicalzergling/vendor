local _, Addon = ...
local locale = Addon:GetLocale()
local Setting = {}

--[[ Initialize a setting ]]
function Setting:Init(name, defaultValue, getValue, setValue)
    CallbackRegistryMixin.OnLoad(self)
    self:GenerateCallbackEvents({"OnChanged"})

    self.name = name
    self.default = defaultValue
    self.handlers = {}

    if (type(getValue) ~= "function") then
        self.getValue = function()
            local profile = Addon:GetProfile()
            local value = profile:GetValue(name)
            if (value == nil) then
                value = defaultValue
                profile:SetValue(name, value)
            end
            return value
        end
    else
        self.getValue = getValue
    end

    if (type(setValue) ~= "function") then
        self.setValue = function(value)
            assert(type(value) == type(defaultValue), "Incompatible value was passed")
            Addon:GetProfile():SetValue(name, value)
        end
    else
        self.setValue = setValue
    end

    Addon:RegisterCallback("OnProfileChanged", self, self.OnProfileChanged)
end

--[[ Gets the value of this setting ]]
function Setting:GetValue()
    return self.getValue()
end

--[[ Sets the value of this setting ]]
function Setting:SetValue(value)
    assert(type(value) == self:GetType())
    local current = self.getValue()
    if (value ~= current) then
        self.setValue(value)
        for _, handler in ipairs(self.handlers) do
            handler(self)
        end
        self:TriggerEvent("OnChanged", value)
    end
end

--[[ Handle profile changed ]]
function Setting:OnProfileChanged()
    local value = self:GetValue()
    self:SetValue(value)
end

--[[ Gets the default value for this setting ]]
function Setting:SetDefault()
    self.set(self.default)
end

--[[ Gets the type this setting stores ]]
function Setting:GetType()
    return type(self.default) or "nil"
end

--[[ Gets the name of this setting ]]
function Setting:GetName()
    return self.name
end

--[[ Register a handler for changes ]]
function Setting:RegisterHandler(handler, owner)
    if (type(owner) == "table") then
        table.insert(self.handlers, function(setting)
                handler(owner, setting)
            end)
    else
        table.insert(self.handlers, handler)
    end
end

function Addon.Features.Settings.CreateSetting(name, defaultValue, getValue, setValue)
    local setting = CreateFromMixins(Setting, CallbackRegistryMixin)
    setting:Init(name, defaultValue, getValue, setValue)
    return setting
end

--[[ Creates a feature which controls the enabling/disabling of a feature ]]
function Addon.Features.Settings.CreateFeatureSetting(name)
    local setting = CreateFromMixins(Setting, CallbackRegistryMixin)

    -- Gets the current value
    local get = function()
        return Addon:IsFeatureEnabled(name) == true
    end

    -- Sets the current value
    local set = function(value)
        if (value) then
            Addon:EnableFeature(name)
        else
            Addon:DiableFeature(name)
        end
    end

    setting:Init(name, get(), get, set)
    return setting
end