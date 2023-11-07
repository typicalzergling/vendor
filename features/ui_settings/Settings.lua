local _, Addon = ...
local locale = Addon:GetLocale()
local SettingsFeature = {
    NAME = "Settings", 
    VERSION = 1,
    Categories = {},
    DEPENDENCIES = {
        "MinimapButton",    -- Minimap button needs to be initialized to get correct state.
    },
}

SettingsFeature.Events = {
    OnPagesChanged = "settings:OnPagesChanged"
}

--[[
    Called when feature is initialized
]]
function SettingsFeature:OnInitialize()
    Addon:Debug("settings", "Initialize settings")
    Addon:GenerateEvents(self.Events)
    self.pages = {}

    local profile = Addon:GetProfile()
	local buyback = profile:GetValue(Addon.c_Config_SellLimit)
    if (buyback) then
        profile:SetValue(Addon.c_Config_SellLimit, true)
    else
        profile:SetValue(Addon.c_Config_SellLimit, false)
    end
end

function SettingsFeature:RegisterPage(name, help, creator, order, new)
    assert(type(name) == "string", "The page name must be a string")
    assert(type(creator) == "function", "The page creator must be a function")
    assert(not order or type(order) == "number", "The page order must be a numer")

    local localizedName = locale:GetString(name) or name
    local localizedHep = locale:GetString(help) or help

    table.insert(self.pages, {
            Key = name,
            Text = localizedName,
            Help = localizedHep,
            CreateList = creator,
            Order = order or 9000,
            IsNew = new or false
        })

    Addon:RaiseEvent(self.Events.OnPagesChanged)
end

--[[ Removes the settings page with the sepcified name ]]
function SettingsFeature:UnregisterPage(name)
    assert(type(name) == "string", "The page name must be a string")

    local pages = {}
    local changed = false;

    for _, page in ipairs(self.pages) do
        if (page.Key ~= name) then
            table.insert(pages, page)
        else
            changed = true
        end
    end

    self.pages = pages
    if (changed) then
        Addon:RaiseEvent(self.Events.OnPagesChanged)
    end
end

--[[
     Retrieves a list of all the settings supported, this is an ordered list of items
     based on the categoriies order.  each entry also has a function to create the list
]]
function SettingsFeature:GetSettings()
    local settings = {}

    -- Add the built in pages
    local categories = self.Categories
    if type(categories) == "table" then
        for _, category in pairs(categories) do
            if (type(category.ShowShow) ~= "function") or (category:ShowShow() == true) then

                local order = 1000
                if (type(category.GetOrder) == "function") then
                    order = category:GetOrder()
                    if (type(order) ~= "number") then
                        order = 1000
                    end
                end

                local isNew = false
                if (type(category.GetIsNew) == "function") then
                    isNew =category:GetIsNew()
                    if (type(isNew) ~= "boolean") then
                        isNew = false
                    end
                end

                local catName = category:GetText()
                catName = locale:GetString(catName) or catName
                local catDesc = category:GetSummary()
                catDesc = locale:GetString(catDesc) or catDesc

                table.insert(settings, {
                    Key = category:GetName(),
                    Text = catName,
                    Help = catDesc,
                    Order = order,
                    IsNew = isNew,
                    CreateList = function(parent)
                        return category:CreateList(parent)
                    end
                })
            end
        end
    end

    -- Add our custom pages 
    for _, page in ipairs(self.pages) do
        table.insert(settings, Addon.DeepTableCopy(page))
    end

    table.sort(settings, function(a, b)
            if (a.Order and not b.Order) then
                return true
            elseif (not a.Order and b.Order) then
                return false
            end

            if (a.Order and b.Order) then
                return (a.Order < b.Order)
            end

            return a.Text < b.Text
        end)


    Addon:Debug("settings", "There are %d active setting categories", table.getn(settings))
    return settings
end

--[[  Retrieve the lists tab ]]
function SettingsFeature:GetTab()
    return {
            Id = "settings",
            Name = "RULES_DIALOG_CONFIG_TAB",
            Template = "Vendor_SettingsTab",
            Class = self.SettingsTab,
            Far = true
        }
end

--[[
    Callback for when the feature is terminated
]]
function SettingsFeature:OnTerminate()
    Addon:RemoveEvents(self.Events)
end

Addon.Features.Settings = SettingsFeature