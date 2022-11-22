local _, Addon = ...
local locale = Addon:GetLocale()
local SettingsFeature = {
    NAME = "Settings", 
    VERSION = 1,
    Categories = {}
}

--[[
    Called when feature is initialized
]]
function SettingsFeature:OnInitialize()
    Addon:Debug("settings", "Initialize settings")
    self.pages = {}

    local profile = Addon:GetProfile()
	local buyback = profile:GetValue(Addon.c_Config_SellLimit)
    if (buyback) then
        profile:SetValue(Addon.c_Config_SellLimit, true)
    else
        profile:SetValue(Addon.c_Config_SellLimit, false)
    end
end

function SettingsFeature:RegisterPage(name, help, creator, order)
    assert(type(name) == "string", "The page name must be a string")
    assert(type(creator) == "function", "The page creator must be a function")
    assert(not order or type(order) == "number", "The page order must be a numer")

    table.insert(self.pages, {
            Key = name,
            Text = name,
            Help = help,
            CreateList = creator,
            Order = order
        })
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
            table.insert(settings, {
                Key = category:GetName(),
                Text = category:GetText(),
                Help = category:GetSummary(),
                Order = category:GetOrder() or 1000,
                CreateList = function(parent)
                    return category:CreateList(parent)
                end
            })
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

            return a.Name < b.Name
        end)


    Addon:Debug("settings", "There are %d active setting categories", table.getn(settings))
    return settings
end

--[[
    Callback for when the feature is terminated
]]
function SettingsFeature:OnTerminate()
end

Addon.Features.Settings = SettingsFeature