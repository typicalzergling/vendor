local _, Addon = ...
local ImportDialog = {}

local BUTTONS = {
    import = {
        label = "import",
        handler = "ImportRules"
    },

    cancel = {
        label = "cancel",
        handler = "Toggle"
    }
}

function ImportDialog:OnInitDialog(dialog)
    dialog:SetButtons(BUTTONS)
    dialog:SetCaption("IMPORT_IMPORT_RULES")
    --dialog:SetButtonEnabled("import", false)

    self.tabs:AddTab("step1", "test", "ImportRules_Step1", {})
    self.tabs:AddTab("step2", "test 2", "ImportRules_Step1", {})
    self.tabs:ShowTab("step1")
end

function ImportDialog:OnShow()
    print("import dialog on show")
end

function ImportDialog:OnHide()
    print("import diloag on hide")
end

function ImportDialog:ImportRules()
    print("import rules")
end

Addon.Features.Import.ImportDialog = ImportDialog