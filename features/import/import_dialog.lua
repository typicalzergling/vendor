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

function ImportDialog:OnInitDialog()
    self:SetButtons(BUTTONS)
    self:SetCaption("IMPORT_IMPORT_RULES")
    --self:SetButtonEnabled("import", false)
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