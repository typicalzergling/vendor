local _, Addon = ...
local locale = Addon:GetLocale()
local CreateListDialog = {}

function CreateListDialog:OnLoad()
	Addon:Debug("listdialog", "CreateListDialog:OnLoad")
	
    self:SetClampedToScreen(true)    
    self:RegisterForDrag("LeftButton")
    table.insert(UISpecialFrames, self:GetName())	
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

function CreateListDialog:OnListChanged(listId, action)
	if (listId ~= self.editId) then
		return
	end
end

Addon.Dialogs = Addon.Dialogs  or {}
Addon.Dialogs.CreateList = CreateListDialog