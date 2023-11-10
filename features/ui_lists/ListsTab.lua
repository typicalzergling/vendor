local _, Addon = ...
local locale = Addon:GetLocale()
local Lists = nil
local UI = nil
local ListEvents = nil
local ListType = nil
local SystemListId = nil
local ChangeType = nil
local SYSTEM_ORDER = nil
local SORT_KEY = "listtab:sorttype"

local ListsTab = {}

--[[ Handle loading the list ]]
function ListsTab:OnLoad()

    Lists = Addon.Features.Lists
    UI = Addon.CommonUI.UI
    ListEvents = Addon.Systems.Lists.ListEvents
    ListType = Addon.Systems.Lists.ListType
    SystemListId = Addon.SystemListId
    ChangeType = Addon.Systems.Lists.ChangeType

    SYSTEM_ORDER = {
        [SystemListId.NEVER] = 1,
        [SystemListId.ALWAYS] = 100,
        [SystemListId.DESTROY] = 1000
    }

    self.sort.radio = true
    self.sort:AddChips({
        { id="id", text="LISTS_SORT_BY_ID_LABEL", tooltip="LISTS_SORT_BY_ID_TOOLTIP" },
        { id="name", text="LISTS_SORT_BY_NAME_LABEL", tooltip="LISTS_SORT_BY_NAME_TOOLTIP" },
        { id="quality", text="LISTS_SORT_BY_QUALITY_LABEL", tooltip="LISTS_SORT_BY_QUALITY_TOOLTIP" }
    })

    self.feature = Addon:GetFeature("Lists")
    UI.Enable(self.editList, false)
    UI.Enable(self.copyList, false)

    Addon:RegisterCallback(ListEvents.ADDED, self, function()
            self.lists:Rebuild()
        end)

    Addon:RegisterCallback(ListEvents.REMOVED, self, function()
            self.lists:Rebuild()
        end)

    self.lists:Sort(function (a, b)
            local typeA = a:GetType()
            local typeB = b:GetType()

            if (typeA ~= typeB) then
                return typeA < typeB
            else
                if (typeA == ListType.SYSTEM) then
                    return SYSTEM_ORDER[a:GetId()] < SYSTEM_ORDER[b:GetId()]
                end
               
                return a:GetName() < b:GetName()
            end
        end)

    self.lists:ScrollToTop()

    local profile = Addon:GetProfile()
    local sortType = profile:GetValue(SORT_KEY) or "id"
    self.items:SetItemSort(sortType)
    self.sort:SetSelected({ [sortType] = true})
end

--[[ Called when the lists tab is activated ]]
function ListsTab:OnActivate()
    self.lists:EnsureSelection()
end

function ListsTab:OnDeactivate()
end

function ListsTab:OnSortItems()
    local selected = self.sort:GetSelected()
    for id, val in pairs(selected) do
        if (val == true) then
            self.items:SetItemSort(id)
            Addon:GetProfile():SetValue(SORT_KEY, id)
            break
        end
    end
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
    else
        self.items:Clear()
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