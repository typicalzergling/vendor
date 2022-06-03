local AddonName, Addon = ...
local L = Addon:GetLocale()
local ConfigPanel = {
    _autoHookHandlers = true
}

--*****************************************************************************
-- Sets the version infromation on the version widget which is present
-- on all of the config pages.
--*****************************************************************************
function ConfigPanel:SetVersionInfo()
    if (self.VersionInfo) then
        self.VersionInfo:SetText(Addon:GetVersion())
    end
end

function ConfigPanel:OnShow()
end

function ConfigPanel:OnHide()
end

--*****************************************************************************
-- Called to handle a click on the "open rules" dialog
--*****************************************************************************
function ConfigPanel:OnOpenRules(tab)
    Addon:Debug("config", "Showing rules dialog: %s", tab or "rules")
    InterfaceOptionsFrame_Show()
    VendorRulesDialog:Open(tab or "rules")
end


--*****************************************************************************
-- Called to handle a click on the Open Keybindings button
--*****************************************************************************
function ConfigPanel:OpenBindings()
    Addon:Debug("config", "Showing key bindings")
    InterfaceOptionsFrame_Show()
    Addon:OpenKeybindings_Cmd()
end

--*****************************************************************************
-- Handles the initialization of the main configruation panel
--*****************************************************************************
function ConfigPanel:OnLoad()
    self.name = L["ADDON_NAME"]
    self:SetVersionInfo()
    InterfaceOptions_AddCategory(self)
end

Addon.ConfigPanel = ConfigPanel