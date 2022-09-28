local _, Addon = ...

local Feature = {
    NAME = "Import",
    DESCRIPTION = " [tbd] ",
    VERSION = 1
}

function Feature:OnInitialize(a, b, host)
    Addon:Debug("import feature initialize")

    for a,b in pairs(host) do print("xxx --->", a, b) end

    local f = host:CreateDialog("VendorImportDialog", "Import_ImportDialog")
    f:Show()
    return true;
end

function Feature:OnTerminate()
end

Addon.Features.Import = Feature
