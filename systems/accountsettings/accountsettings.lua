local _, Addon = ...
local AccountSettings = {}
local function debugp(...) Addon:Debug("accountsettings", ...) end

--[[ Retrieve our depenedencies ]]
function AccountSettings:GetDependencies()
    return { "savedvariables" }
end

--[[ Called when the settings have changed ]]
function AccountSettings:GetEvents()
    return { "OnAccountSettingChange"}
end

--[[ Startup our system ]]
function AccountSettings:Startup()
    self.savedVariable = Addon:CreateSavedVariable("AccountSettings")

    return { "GetAccountSetting", "SetAccountSetting" }
end

--[[ Shutdown our system ]]
function AccountSettings:Shutdown()
    if (self.timer) then
        self.timer:Cancel()
        self.timer = nil
    end
end

--[[ Retrieve an account setting ]]
function AccountSettings:GetAccountSetting(name, default)
    assert(type(name) == "string", "Invalid input to GetAccountSetting")
    local value = self.savedVariable:Get(name)
    debugp("GetAccountSetting: %s = %s (%s), default = %s", name, tostring(value), type(value), tostring(default))
    if (type(value) == "nil") then

        -- Default value provided 
        if (type(default) ~= nil) then
            debugp("Return the default value for '%s'", name)
            return default
        end

        -- Are there addon defaults?
        if (type(Addon.Defaults) == "table" and type(Addon.Defaults.Account) == "table") then
            debugp("Returning the default value from 'Addon.Defaults.Account[%s]'", name)
            value = Addon.Defaults.Account[name]
        end
    end

    return value
end

--[[ Modify an account setting ]]
function AccountSettings:SetAccountSetting(name, value)
    self.changed = self.changed or {}
    self.changed[name] = true

    local current = self:GetAccountSetting(name)
    if (value ~= current) then
        self.savedVariable:Set(name, value)
        debugp("The value '%s' as been changed to '%s", name, tostring(value))

        if (self.timer) then
            self.timer:Cancel()
            self.timer = nil
        end

        self.timer = C_Timer.After(0.25, function()
                self.timer = nil
                if (self.changed) then
                    Addon:RaiseEvent("OnAccountSettingChange", self.changed)
                    self.changed = nil
                end
            end)
    end
end

Addon.Systems.AccountSettings = AccountSettings