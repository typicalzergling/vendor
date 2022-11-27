local AddonName, Addon = ...
local L = Addon:GetLocale()
local UI = Addon.CommonUI.UI
local ExportDialog = {}
local CURRENT_EXPORT_VERSION = 1
local Encoder = Addon.Features.Import.Encoder
local Info = Addon.Systems.Info

--@debug@
local function debugp(msg, ...) Addon:Debug("exportdialog", msg, ...) end
--@end-debug@

--[[ Initialize the export dialog ]]
function ExportDialog:OnInitDialog(dialog, export)
    assert(type(export) == "table", "On exporting tables is allowed")
    local character, realm = UnitFullName("player")

    export.Version = CURRENT_EXPORT_VERSION
    export.Source = AddonName
    export.Player = character
    export.Realm = realm
    export.InterfaceVersion = Info.Build.InterfaceVersion

    self.exportText = Encoder.Encode(export)
    self.export:SetText(self.exportText)
end

function ExportDialog:OnShow()
    self.export:SetFocus()
end

function ExportDialog:EditOnChar()
    self:SetText(rawget(self, "exportText"))
end

function ExportDialog:EditOnTextChanged()
    self:SetText(rawget(self, "exportText"))
end

function ExportDialog:EditOnEditFocusGained()
    self:HighlightText();
end

function ExportDialog:EditOnEditFocusLost()
    self:HighlightText(0,0);
end

function ExportDialog:OnHide()
end

function ExportDialog:ImportRules()
end

--[[ Show the export dialog with the contents provided ]]
function Addon.Features.Import:ShowExportDialog(caption, export)
    assert(type(caption) == "string", "Expected a string for the caption")
    assert(type(export) == "table", "The export object must be a table")
  
    local dialog = UI.Dialog(caption, "Import_ExportDialog", ExportDialog, {
            { id="close", label = L["EXPORT_CLOSE_BUTTON"], handler = "Hide" }
        }, export)

    dialog:Show()
end