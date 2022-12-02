local _, Addon = ...
local UI = Addon.CommonUI.UI
local Dialogs = { 
    NAME = "Dialogs", 
    VERSION = 1,
    DEPENDENCIES = { "Rules" }
}

function Dialogs:OnInitialize(a, b, host)
end

function Dialogs:GetEditRule()    
    if (not self.editRule) then
        local BUTTONS = {
            close = { id="close", label = CLOSE, handler = "Toggle" },
            cancel = { id="cancel", label = CANCEL, handler = "Toggle"  },
            save = { id="save", label = SAVE, handler = "SaveRule" },
            delete = { id="delete", label = DELETE, handler = "DeleteRule" },
            export = { id="export", label = "Export", handler = "ExportRule", near = true },
        }
    
        self.editRule = UI.Dialog(nil, "Vendor_Dialogs_EditRule", self.EditRule, BUTTONS)
    end

    return self.editRule
end

function Dialogs:CreateRule()
    local dialog = self:GetEditRule()

    dialog:NewRule()
    dialog:Show()
end

function Dialogs:ShowEditRule(ruleId, parameters, tab)
    local rules = Addon:GetFeature("Rules")

    local rule = rules:FindRule(ruleId)
    if (not rule) then
        error("Unable to locate rule : " .. tostring(ruleId))
        return
    end

    local dialog = self:GetEditRule()
    dialog:SetRule(rule, parameters)
    if (type(tab) == "string") then
        dialog:NavigateTo(tab)
    end
    dialog:Show()
end

--[[ Show a dialog with a copied rule ]]
function Dialogs:CopyRule(ruleId, parameters, tab)
    local rules = Addon:GetFeature("rules")

    local rule = rules:FindRule(ruleId)
    if (not rule) then
        error("Unable to locate rule : " .. tostring(ruleId))
        return
    end

    local dialog = self:GetEditRule()
    dialog:CopyRule(rule, parameters)
    if (type(tab) == "string") then
        dialog:NavigateTo(tab)
    end
    dialog:Show()
end

function Dialogs:OnTerminate()
end

Addon.Features.Dialogs = Dialogs