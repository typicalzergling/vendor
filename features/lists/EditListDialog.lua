local _, Addon = ...
local locale = Addon:GetLocale()

local Colors = nil
local UI = nil
local Lists = nil
local ListType = nil

local EditListDialog = {}

--[[ Sets the list we are editing ]]
function EditListDialog:SetList(list, copy)
    if (self.editor) then
        self.editor:UnregisterCallback("OnDirty", self)
        self.editor:UnregisterCallback("OnChanged", self)
        end

    self.editor = Lists.CreateEditor(list, copy)
    self.editor:RegisterCallback("OnDirty", self.OnListDirty, self)
    self.editor:RegisterCallback("OnChanged", self.Update, self)

    self.name:SetText(self.editor:GetName())
    self.description:SetText(self.editor:GetDescription())
    self.items:SetList(self.editor)

    if (self.editor:IsNew()) then
        self:SetCaption("LISTDIALOG_CREATE_CAPTION")
    else
        self:SetCaption("LISTDIALOG_EDIT_CAPTION")
    end
end

function EditListDialog:OnShow()
    self:Update()
end

--[[ Called when the dialog box is closed ]]
function EditListDialog:OnClose()
    self.editor:Cleanup()
end

function EditListDialog:OnListDirty()
end

--[[ Handle the name change ]]
function EditListDialog:OnNameChanged(text)
    self.editor:SetName(text)
end

--[[ Handle the description change ]]
function EditListDialog:OnDescriptionChanged(text)
    self.editor:SetDescription(text)
end

--[[ Called when the item id changes ]]
function EditListDialog:OnItemIdChanged(text)
    self:EnableAddById()
end

--[[ Adds the item specified from the input box ]]
function EditListDialog:InsertById()
    local itemId = self.itemId:GetNumber()
    if (C_Item.DoesItemExistByID(itemId)) then
        self.editor:Add(itemId)
        self.items:Select(itemId)
        self.itemId:SetText()
        UI.Enable(self.addId, false)
    end
end

--[[ Handle saving the dialog ]]
function EditListDialog:OnSave()
    if (self:ValidateName()) then
        self.editor:Commit()
        self:Close()
    end
end

--[[ Valid our name is okay ]]
function EditListDialog:ValidateName()
    local valid = true
    local id = self.editor:GetId()
    local name = string.lower(self.editor:GetName())

    for _, list in ipairs(Addon:GetLists()) do
        if (list:GetId() ~= id) then
            if (name == string.lower(list:GetName())) then
                valid = false
                break
            end
        end
    end
    
    if (not valid) then
        UI.MessageBox("EDITLIST_DUPLICATE_NAME_CAPTION",
            locale:FormatString("EDITLIST_DUPLICATE_NAME_FMT1", self.editor:GetName()),
            OK, self)
        return false
    end

    return true
end

--[[ Handle deleting the list ]]
function EditListDialog:OnDelete()
    UI.MessageBox("DELETE_LIST_CAPTION",
        locale:FormatString("DELETE_LIST_FMT1", self.editor:GetName()), {
            {
                text = "CONFIRM_DELETE_LIST",
                handler = function()
                    Addon:DeleteList(self.editor:GetId())
                    self:Close()
                end,
            },
            "CANCEL_DELETE_LIST"
        }, self)
end

function EditListDialog:OnExport()
    assert(self.editor:CanExport(), "Expected the current list to be exportable")
    local import = Addon:GetFeature("import")
    import:ShowExportDialog("EXPORT_LIST_CAPTION", self.editor:GetExportValue())
end

--[[ Called to update our UX state ]]
function EditListDialog:Update()
    local buttons = {}
    local editor = self.editor

    buttons.cancel = true
    buttons.delete = { show = not editor:IsNew(), enabled = not editor:IsNew() and editor:CanDelete() }
    buttons.save =  { show = true, enabled = editor:IsDirty() and editor:CanCommit() }
    buttons.export = { show = true, enabled = true }
    -- 
    local canEditProperties = editor:CanChangeProperties()
    UI.Enable(self.name, canEditProperties)
    UI.Enable(self.description, canEditProperties)

    local canModifyItems = editor:CanModifyContents()
    UI.Enable(self.itemId, canModifyItems)
    self:EnableAddById()

    UI.Show(self.systemInfo, editor:GetType() == ListType.SYSTEM)

    self:SetButtonState(buttons)
    self.items:Rebuild()
end

--[[ Determine if the add by id button should be enabled ]]
function EditListDialog:EnableAddById()
    if (self.itemId:IsEnabled()) then
        local itemId = self.itemId:GetNumber()
        UI.Enable(self.addId,
            itemId ~= 0 and 
            type(itemId) == "number" and 
            C_Item.DoesItemExistByID(itemId) and
            not self.editor:Contains(itemId))
    else
        UI.Enable(self.addId, false)
    end
end

--[[ Show an edit list dialog ]]
function Addon.Features.Lists.ShowEditDialog(list, copy)
    Colors = Addon.CommonUI.Colors
    UI = Addon.CommonUI.UI
    Lists = Addon.Features.Lists
    ListType = Addon.Systems.Lists.ListType

    local dialog = UI.Dialog("EditList", "Lists_Editor", EditListDialog, {
            save = { label = SAVE, handler = "OnSave" },
            cancel = { label = CANCEL, handler = "Hide", default = true },
            delete = { label = DELETE, handler = "OnDelete" },
            export = { label = "Export", handler = "OnExport" },
        })

    dialog:SetList(list, copy)
    dialog:Show()
    return dialog
end