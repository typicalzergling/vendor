local AddonName, Addon = ...
local UI = Addon.CommonUI.UI
local ExportDialog = {}
local CURRENT_EXPORT_VERSION = 1
local Encoder = Addon.Features.Import.Encoder

--@debug@
local function debugp(msg, ...) Addon:Debug("exportdialog", msg, ...) end
--@end-debug@

function ExportDialog:OnInitDialog(dialog, export)
    assert(type(export) == "table", "On exporting tables is allowed")
    local character, realm = UnitFullName("player")

    export.Version = CURRENT_EXPORT_VERSION
    export.Source = AddonName
    export.Player = character
    export.Realm = realm

    self.export:SetText(Encoder.EncodeValue(export))
    self.export:SetFocus()
end

function ExportDialog:OnShow()
    --print("import dialog on show")
end

function ExportDialog:OnHide()
    --print("import diloag on hide")
end

function ExportDialog:ImportRules()
    --print("import rules")
end

--[[ Show the export dialog with the contents provided ]]
function Addon.Features.Import:ShowExportDialog(export)
   local dialog = UI.Dialog("EXPORT_DIALOG_CAPTOIN", "Import_ExportDialog", ExportDialog, {
        CLOSE
    }, export)

    dialog:Show()
end