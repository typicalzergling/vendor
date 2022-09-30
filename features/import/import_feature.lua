local _, Addon = ...

local Feature = {
    NAME = "Import",
    DESCRIPTION = " [tbd] ",
    VERSION = 1
}

function Feature:OnInitialize(a, b, host)
    Addon:Debug("import feature initialize")
    
    local dlg = host:CreateDialog("VendorImportDialog", "Import_ImportDialog", self.ImportDialog)
    dlg:Toggle()
    return true;
end

function Feature:OnTerminate()
end

Addon.Features.Import = Feature