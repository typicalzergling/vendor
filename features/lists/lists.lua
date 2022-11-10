local _, Addon = ...
local locale = Addon:GetLocale()
local ListType = Addon.ListType
local SystemListId = Addon.SystemListId

local Lists = { 
    NAME = "Lists", 
    VERSION = 1, 
    DEPENDECIES = { "Rules" },
}

--[[ Initialize the list feature ]]
function Lists:OnInitialize()
end

--[[  Retrieve the lists tab ]]
function Lists:GetTab()
    return {
            Id = "lists",
            Name = "CONFIG_DIALOG_LISTS_TAB",
            Template = "Vendor_Lists_Tab",
            Class = self.ListsTab
        }
end

Addon.Features.Lists = Lists