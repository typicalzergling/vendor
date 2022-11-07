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
			self:OnAddItem(self.ItemInfo:GetItemID())
			self.ItemId:SetText("")
			self:SetValidItem(-1, false);
		end)

    self.ItemInfo:SetScript("OnEnter", function() self:ShowItemTooltip() end)
	self.ItemInfo:SetScript("OnLeave", function() self:HideItemTooltip() end)

	self.Items:SetReadOnly(false);
	self.Items.OnAddItem = function(_, item) self:OnAddItem(item) end
	self.Items.OnDeleteItem = function(_, item) self:OnDeleteItem(item) end
	self.items = {};

	self.CreateBtn:SetScript("OnClick", function() self:OnCreate() end)
	self.SaveBtn:SetScript("OnClick", function() self:OnSave() end)
end

function CreateListDialog:Create()
	self.listId = nil;
	self.Name:SetText(locale.NEW_LIST_NAME)
	self.Description:SetText("")
	self:SetCaption("LISTDIALOG_CREATE_CAPTION")
	self.Name:Enable()
	self.Description:Enable()
	self.SaveBtn:Hide()
	self.CreateBtn:Show()
	self.items = {};
	self.changes = nil;
	self:Show()
end

function CreateListDialog:OnCreate()
	-- Need to verify the name is non-empty (We should disable save in that case)
	local name = self.Name:GetText();
	local description = self.Description:GetText();
	local list = Addon:GetListManager():CreateList(name, description, self.items);	
	self:Hide();
end

function CreateListDialog:Edit(id, name, description)
	self.listId = id;
	self.Name:SetText(name)
	self.Description:SetText(description)
	self:SetCaption("LISTDIALOG_EDIT_CAPTION")

	local list = Addon:GetList(id)
	self.items = list:GetContents()
	self.listObject = list;
	self.changes = {}
	if (not list:IsType(Addon.ListType.CUSTOM)) then
		self.Name:Disable()
		self.Description:Disable()
	else
		self.Name:Enable()
		self.Description:Enable()
	end

	self.CreateBtn:Hide();
	self.SaveBtn:Show();	
	self:UpdateList()
	self:Show()
end

function CreateListDialog:OnSave()
	--if (self.changes) then
	--	Addon.TableForEach(self.changes, print)
	--end
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

		if (self.changes) then
			if (self.changes[itemId] == "REMOVE") then
				self.changes[itemId] = nil
			else
				self.changes[itemId] = "ADD"
			end
		end
	end
end

function CreateListDialog:OnDeleteItem(itemId)
	if (type(itemId) == "number") then
		self.items[itemId] = nil
		self:UpdateList()

		if (self.changes) then
			if (self.changes[itemId] == "ADD") then
				self.changes[itemId] = nil
			else 
				self.changes[itemId] = "REMOVE"
			end
		end
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