local _, Addon = ...
local locale = Addon:GetLocale()
local Lists = Addon.Features.Lists
local UI = Addon.CommonUI.UI
local ListEvents = Addon.Systems.Lists.ListEvents
local ListType = Addon.Systems.Lists.ListType
local ListsTab = {}

--[[ Handle loading the list ]]
function ListsTab:OnLoad()
    self.feature = Addon:GetFeature("Lists")
    UI.Enable(self.editList, false)
    UI.Enable(self.copyList, false)

    Addon:RegisterCallback(ListEvents.ADDED, self, function()
            self.lists:Rebuild()
        end)

    Addon:RegisterCallback(ListEvents.REMOVED, self, function()
        self.lists:Rebuild()
    end)
end

--[[ Called when the lists tab is activated ]]
function ListsTab:OnActivate()
    self.lists:EnsureSelection()
end

function ListsTab:OnDeactivate()
end

--[[ Retrieve the currently defined lists ]]
function ListsTab:GetCategories()
    return Addon:GetLists()
end

--[[ Called to display the contents of the list ]]
function ListsTab:ShowList()
    local selected = self.lists:GetSelected()
    if (selected) then
        self.items:SetList(selected)
    end

    UI.Enable(self.editList, selected ~= nil)
    UI.Enable(self.copyList, selected ~= nil and selected:GetType() ~= ListType.SYSTEM)
end

--[[ Create a new list ]]
function ListsTab:CreateList()
    Lists.ShowEditDialog()
end

--[[ Edit the selected list ]]
function ListsTab:EditList()
    local selected = self.lists:GetSelected()
    if (selected) then
        Lists.ShowEditDialog(selected)
    end
end

--[[ Copy the selected list ]]
function ListsTab:CopyList()
    local selected = self.lists:GetSelected()
    if (selected) then
        Lists.ShowEditDialog(selected, true)
    end
end

Addon.Features.Lists.ListsTab = ListsTab