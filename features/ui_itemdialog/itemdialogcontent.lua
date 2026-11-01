local AddonName, Addon = ...
local locale = Addon:GetLocale()
local UI = Addon.CommonUI.UI
local Info = Addon.Systems.Info
local ItemDialogContent = {}

local function debugp(msg, ...) Addon:Debug("itemdialog", msg, ...) end


function ItemDialogContent:OnInitDialog(dialog)
    self.feature = Addon:GetFeature("itemdialog")
    self.itemInfo = Addon:GetSystem("ItemProperties")
    self:SetButtonState({ close = true })

    self.follow:RegisterCallback("OnChange", function()
            local profile = Addon:GetProfile()
            profile:SetValue("itemdialog_followmouse", self.follow:GetValue())
            self:UpdateFollowLabel(self.follow:GetValue())        
        end)
end

-- Called to h
function ItemDialogContent:OnProfileChanged()
    self:SetFollowState()
end

function ItemDialogContent:ON_CURSOR_CHANGED()
    local follow = Addon:GetProfile():GetValue("itemdialog_followmouse")
    if not follow then 
        return
    end

    local item = C_Cursor.GetCursorItem()
    if item then
        self.current = self.itemInfo:GetItemProperties(item)
        if self.current then
            self.item:SetItem(self.current.Id, false)
        end
        self.properties:Rebuild()
    end
end

function ItemDialogContent:OnShow()
    self.current = nil
    self:SetFollowState()

    local item = C_Cursor.GetCursorItem()
    if item then 
        self.current = self.itemInfo:GetItemProperties(item)
        if self.current then
            self.item:SetItem(self.current.Id, false)
        end

        self.properties:Rebuild()
    end
end

function ItemDialogContent:OnHide()
end

function ItemDialogContent:OnItemChanged()
    self.current = self.itemInfo:GetItemPropertiesFromItem(self.item)
    self.properties:Rebuild()
end

function ItemDialogContent:SetFollowState()
    local profile = Addon:GetProfile();
    local follow = profile:GetValue("itemdialog_followmouse") or false
    self.follow:SetValue(follow)
    self:UpdateFollowLabel(follow)
end

function ItemDialogContent:UpdateFollowLabel(enabled)
    if enabled then
        UI.SetColor(self.followLabel, "TEXT")
    else
        UI.SetColor(self.followLabel, "SECONDARY_TEXT")
    end
end

function ItemDialogContent:GetItem()
    if self.current then
        return self.current
    end

    return nil
end

function ItemDialogContent:GetItemProperties()
    local models = {}
    local item = self:GetItem()
    
    if item then
        self.item:SetItem(item.Id, false)
        return self.feature:CreateModels(item)
    end

    self.item:ClearItem()
    return {}
end

function ItemDialogContent:CreatePropertyItem(model)
    return self.feature:CreateItemForModel(model)
end

--[[ Show the export dialog with the contents provided ]]
function Addon.Features.ItemDialog:ShowDialog()
    if not self.dialog then
        self.dialog = UI.Dialog("ITEMDIALOG_CAPTION", "Vendor_ItemDialog_Content", ItemDialogContent, {
            { id="close", label = CLOSE, handler = "Hide" },
        })
    end

    self.dialog:Show()
    self.dialog:Raise()
end