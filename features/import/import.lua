local _, Addon = ...
local UI = Addon.CommonUI.UI

local ImportFeature = {
    NAME = "Import",
    DESCRIPTION = " [tbd] ",
    VERSION = 1
}

function ImportFeature:OnInitialize(a, b, host)
    Addon:Debug("import feature initialize")
end

function ImportFeature:OnTerminate()
end

function ImportFeature:ShowImportDialg()
end

function ImportFeature:ShowExport(title, export)
end

Addon.Features.Import = ImportFeature