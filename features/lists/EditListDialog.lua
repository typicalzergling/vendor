local _, Addon = ...
local Colors = Addon.CommonUI.Colors
local UI = Addon.CommonUI.UI
local EditListDialog = {}
local Lists = Addon.Features.Lists

--[[

for edit make a class which track trasnactions

list:GetEditor
    - Add/Remove/Contains
    - SetName/SetDescription
    - CanModifyMetadata
    - OnChanged/OnDirty
    - Disccard/Commit
    - Create -- Uses the changes in the list to create a new custom
                list returns the result

]]

--[[ Sets the list we are editing ]]
function EditListDialog:SetList(list)
    if (self.editor) then
        self.editor:UnregisterCallback("OnDirty", self)
        self.editor:UnregisterCallback("OnChanged", self)
        end

    self.editor = Lists.CreateEditor(list)
    self.editor:RegisterCallback("OnDirty", self.OnListDirty, self)
    self.editor:RegisterCallback("OnChanged", self.Update, self)

    self.name:SetText(self.editor:GetName())
    self.description:SetText(self.editor:GetDescription())
    self.items:SetList(self.editor)

    if (self.editor:IsNew()) then
        self:SetCaption("Create List")
    else
        self:SetCaption("Edit List")
    end
end

function EditListDialog:OnShow()
    self:Update()
end

function EditListDialog:OnListDirty()
    print("--> list is dirty")
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
    print("save list")
end

--[[ Handle deleting the list ]]
function EditListDialog:OnDelete()
    print("delete list")
end

--[[ Called to update our UX state ]]
function EditListDialog:Update()
    local buttons = {}
    local editor = self.editor

    buttons.cancel = true
    buttons.delete = { show = not editor:IsNew(), enabled = not editor:IsNew() and editor:CanDelete() }
    buttons.save =  { show = true, enabled = editor:IsDirty() and editor:CanCommit() }
    buttons.export = { show = true, enabled = false }
    -- 
    local canEditProperties = editor:CanChangeProperties()
    UI.Enable(self.name, canEditProperties)
    UI.Enable(self.description, canEditProperties)

    local canModifyItems = editor:CanModifyContents()
    UI.Enable(self.itemId, canModifyItems)
    self:EnableAddById()

    self:SetButtonState(buttons)
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
function Addon.Features.Lists.ShowEditDialog(list)
    local dialog = UI.Dialog("EditList", "Lists_Editor", EditListDialog, {
            save = { label = SAVE, handler = "OnSave" },
            cancel = { label = CANCEL, handler = "Hide" },
            delete = { label = DELETE, handler = "OnDelete" },
            export = { label = "Export", handler = "OnExport" },
        })

    dialog:SetList(list)
    dialog:Show()
    return dialog
end