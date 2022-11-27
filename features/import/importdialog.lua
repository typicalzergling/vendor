local AddonName, Addon = ...
local L = Addon:GetLocale()
local UI = Addon.CommonUI.UI
local Encoder = Addon.Features.Import.Encoder
local ImportDialog = {}

--@debug@
local function debugp(msg, ...) 
    Addon:Debug("importdialog", msg, ...)
end
--@end-debug@

local ImportHandlers = {
    customlist = "Features.Import.ImportList",
    customrule = "Features.Import.ImportRule"
}

function ImportDialog:OnInitDialog(dialog, importString)
    debugp("Initialize import dialog : %s", importString or "<none>")
    self:SetButtonState({ import = false, cancel = true })
end

function ImportDialog:OnShow()
end

function ImportDialog:OnHide()
end

function ImportDialog:OnImportText(text)
    debugp("Got import text: ", text or "")

    local import = Encoder.Decode(text)
    if (type(import) == "table") then
        assert(AddonName == import.Source, "The source does not match the expected source : " .. AddonName)

        Addon:DebugForEach("importdialog", import)
        
        local handler = ImportHandlers[import.Content]
        debugp("Using import handler : %s", handler or "<unknown>")
        if (not handler) then
            debugp("There is no import handler for '%s'", import.Content)
            -- error 1
            return
        end

        handler = UI.Resolve(handler)
        if (not handler) then
            debugp("Unable to resolve import handler '%s'", ImportDialog[import.Content] or "<unknown>")
            -- error 2 
            return
        end

        if (not handler:Validate(import)) then
            debugp("Failed to validate import payload")
            -- error 4
            return
        else
            debugp("Resolved import handler")
        end

        local frame = handler:CreateUI(self, import)
        self.handler = handler
        self.payload = import

        self.import:Hide()
        self.help:Hide()
        frame:SetPoint("TOPLEFT", self, "TOPLEFT")
        frame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
        frame:Show()

        local buttons = {}
        buttons.cancel = true
        buttons.confirm = true
        debugp("Enabling confirm button")
        self:SetButtonState(buttons)
    end
end

--[[ Handle importing the actual data ]]
function ImportDialog:DoImport()
    if (self.handler) then
        self.handler:Import(self.payload)
        self:Close()
    end
end

--[[ Show the export dialog with the contents provided ]]
function Addon.Features.Import:ShowImportDialog(importString)
    local dialog = UI.Dialog("IMPORT_DIALOG_CAPTION", "Import_ImportDialog", ImportDialog, {
            { id="cancel", label = L["EXPORT_CLOSE_BUTTON"], handler = "Hide" },
            { id="confirm", label = L["DIALOG_TEXT_CONFIRM"], handler="DoImport" }
        }, importString)

    dialog:Show()
    dialog:Raise()
end