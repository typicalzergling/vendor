local _, Addon = ...

local Feature = {
    NAME = "Import",
    DESCRIPTION = " [tbd] ",
    VERSION = 1
}

function Feature:OnInitialize(a, b, host)
    Addon:Debug("import feature initialize")

    local f = host:CreateDialog("VendorImportDialog", "Import_ImportDialog")
    f:SetCaption("IMPORT_IMPORT_RULES")
    f:Toggle()
    return true;
end

function Feature:OnTerminate()
end

Addon.Features.Import = Feature
