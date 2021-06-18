local _, Addon = ...
local locale = Addon:GetLocale()
local CreateListDialog = {}

function CreateListDialog:OnLoad()
	Addon:Debug("listdialog", "CreateListDialog:OnLoad")
	
    self:SetClampedToScreen(true)    
    self:RegisterForDrag("LeftButton")
    table.insert(UISpecialFrames, self:GetName())	

	self.ItemId:GetControl():SetNumeric(true)
	self.ItemId:RegisterCallback("OnChange", self.OnItemIdChanged, self);
	self:SetValidItem(-1, false);
	self.ItemId.Add:SetScript("OnClick", function() 
			self.items[self.ItemInfo:GetItemID()] = true
			self:UpdateList()
			self.ItemId:SetText("")
			self:SetValidItem(-1, false);
		end)

    self.ItemInfo:SetScript("OnEnter", function() self:ShowItemTooltip() end)
	self.ItemInfo:SetScript("OnLeave", function() self:HideItemTooltip() end)

	self.Items:SetReadOnly(false);
	self.Items.OnAddItem = function(_, item) self:OnAddItem(item) end
	self.Items.OnDeleteItem = function(_, item) self:OnDeleteItem(item) end
	self.items = {};
end

function CreateListDialog:Create()
	self.listId = Addon:GetExtensionManger():CreateUniqueId()
	self.listItems = {}
	self.listName = locale.NEW_LIST_NAME
	self.listDescription = ""

	self:SetCaption("LISTDIALOG_CREATE_CAPTION")
	self:Show()
end

function CreateListDialog:Edit(listId)
	local list = assert(Addon:GetListManager():GetList(listId), "Expected to be given a valid listId to edit")

	self.listId = list.Id
	self.listItems = list.Items
	self.listName = list.Name
	self.listDescription = list.Description
	
	self:SetCaption("LISTDIALOG_EDIT_CAPTION")
	self:Show()
end

function CreateListDialog:OnShow()
	self.listManager = Addon:GetListManager()
	self.listManager:RegisterCallback("OnListChanged", self.OnListChanged, self)
end

function CreateListDialog:OnHide()
	self.listManager:UnregisterCallback("OnListChanged", self)
	self.listManager = nil
end

function CreateListDialog:UpdateList()
	local items = {}
	for id, v in pairs(self.items) do
		if (v == true) then
			table.insert(items, id)
		end
	end
	self.Items:SetContents(items);
end

function CreateListDialog:OnAddItem(item)
	local itemId = Addon.ItemList.GetItemId(item)
	if (type(itemId) == "number") then
		self.items[itemId] = true
		self:UpdateList()
	end
end

function CreateListDialog:OnDeleteItem(itemId)
	if (type(itemId) == "number") then
		self.items[itemId] = nil
		self:UpdateList()
	end
end

function CreateListDialog:OnListChanged(listId, action)
	if (listId ~= self.editId) then
		return
	end
end

--177665
function CreateListDialog:SetValidItem(itemId, isValid)
	assert(type(itemId) == "number")

	function onItemData(item)
		Addon:Debug("listdialog", "Updating to valid item '%s'", item:GetItemName())
		self.ItemId.Add:Enable()
		self.ItemInfo.Link:SetText(item:GetItemLink())
		self.ItemInfo:SetItemID(item:GetItemID())
		self.ItemInfo:Show()
	end

	if (isValid) then
		local item = Item:CreateFromItemID(itemId)
		item:ContinueOnItemLoad(function() onItemData(item) end)
	else
		self.ItemId.Add:Disable()
		self.ItemInfo:Hide();
	end
end

function CreateListDialog:ShowItemTooltip()
	local itemInfo = self.ItemInfo
	if (not itemInfo:IsItemEmpty()) then
		GameTooltip:SetOwner(itemInfo, "ANCHOR_BOTTOM")
		GameTooltip:SetHyperlink(itemInfo:GetItemLink())
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("TOPLEFT", itemInfo, "BOTTOMLEFT", 0, -2)
		GameTooltip:Show()
	end
end

function CreateListDialog:HideItemTooltip()
	if (GameTooltip:GetOwner() == self.ItemInfo) then
		GameTooltip:Hide()
	end
end

function CreateListDialog:OnItemIdChanged()
	local id = self.ItemId:GetNumber();
	if ((id ~= nil) and (id ~= 0) and C_Item.DoesItemExistByID(id)) then
		self:SetValidItem(id, true)
	else
		self:SetValidItem(-1, false)
	end
end

Addon.Dialogs = Addon.Dialogs  or {}
Addon.Dialogs.CreateList = CreateListDialog