local _, Addon = ...
local ItemList = Mixin({}, Addon.CommonUI.List)
local Colors = Addon.CommonUI.Colors
local UI = Addon.CommonUI.UI
local ItemItem = Addon.Features.Lists.ItemItem

local SORTS = {
    --[[ Sort the two items by ID ]]
    id = function(itemA, itemB)
         return tonumber(itemA) < tonumber(itemB)
    end,
    --[[ Sort the two items by namne ]]
    name = function (itemA, itemB)
        return C_Item.GetItemNameByID(itemA) < C_Item.GetItemNameByID(itemB)
    end,
    --[[ Sort the two items by quality ]]
    quality = function(itemA, itemB)
        return C_Item.GetItemQualityByID(itemA) > C_Item.GetItemQualityByID(itemB)
    end
}

--[[ Handle load ]]
function ItemList:OnLoad()
    Addon.CommonUI.List.OnLoad(self)
    self.sort = SORTS.id
end

function ItemList:OnShow()
    Addon:RegisterCallback("OnListChanged", self, self.OnListChanged)
    Addon:RegisterCallback("OnListRemoved", self, self.OnListRemoved)
    Addon:RegisterCallback("OnProfileChanged", self, self.OnListChanged)
    if (self.sort) then
        self:Sort(self.sort)
    end
    self:Rebuild()
end

function ItemList:OnHide()
    Addon:UnregisterCallback("OnListChanged", self)
    Addon:UnregisterCallback("OnListRemoved", self)
    Addon:UnregisterCallback("OnProfileChanged", self)
end

--[[ Get the list of our models ]]
function ItemList:OnGetItems()
    local items
    if (not self.list) then
        items = {}
    else
        items = self.list:GetContents()
    end

    if (self.sort) then
        table.sort(items, self.sort)
    end
    return items
end

function ItemList:SetItemSort(sortType)
    assert(SORTS[string.lower(sortType)], "expected a valid sort type: " .. sortType)
    local sort = SORTS[string.lower(sortType)] or SORTS.id
    assert(type(sort) == "function", "Expected the sort to resolve to a function: " .. sortType)
    self.sort = sort
    self:Sort(sort)
end

--[[ Create an item ]]
function ItemList:OnCreateItem(model)
    local template = "Vendor_Lists_Item"
    if (self.list:IsReadOnly()) then
        template = "Vendor_Lists_ReadOnly_Item"
    end

    local frame = CreateFrame("Frame", nil, self, template)
    UI.Attach(frame, ItemItem)

    return frame
end

--[[ Set the markdown on the control ]]
function ItemList:SetList(list)
    self.list = list
    self:Rebuild()
end

--[[ clear the current items ]]
function ItemList:Clear()
    self.list = nil
    self:Rebuild()
end

--[[ Retrieve the list ]]
function ItemList:GetList()
    return self.list
end

--[[ When the list changes we need to rebuild it ]]
function ItemList:OnListChanged(list)
    if (self.list and self.list:GetId() == list:GetId()) then
        self:Rebuild()
    end
end

--[[ When the list changes we need to rebuild it ]]
function ItemList:OnListRemoved(list)
    if (self.list and self.list:GetId() == list:GetId()) then
        self.list = nil
        self:Rebuild()
    end
end


function ItemList:OnDelete(itemId)
    if (self.list and not self.list:IsReadOnly()) then
        self.list:Remove(itemId)
    end
end

function ItemList:OnMouseDown()
    self:OnDropItem()
end

function ItemList:OnDropItem()
    if (self.list and not self.list:IsReadOnly()) then
        local item = Addon.CommonUI.ItemLink.GetCursorItem()
        if (item ~= nil) then
            local itemId
            if (type(item) == "table") then
                itemId = C_Item.GetItemID(item)
            elseif (type(item) == "string") then
                itemId = GetItemInfoInstant(item)
            end
            if (type(itemId) == "number") then
                self.list:Add(itemId)
            end
            ClearCursor()
        end
    end
end

Addon.Features.Lists.ItemList = ItemList
Addon.CommonUI._ItemList = ItemList