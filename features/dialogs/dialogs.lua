local _, Addon = ...
local Dialogs = { 
    NAME = "Dialogs", 
    VERSION = 1,
    DEPENDENCIES = { "Rules", "Import" }
}

function Dialogs:OnInitialize(a, b, host)
    self:Debug("---> oninitialize")
end

function Dialogs:GetEditRule()
    if (not self.editRule) then
        self.editRule = self:CreateDialog("VendorEditRuleDialog2", "Vendor_Dialogs_EditRule", self.EditRule)
    end

    return self.editRule
end

function Dialogs:CreateRule()
    local dialog = self:GetEditRule()

    dialog:NewRule()
    dialog:Show()
end

function Dialogs:ShowEditRule(ruleId)
    local rules = self:GetDependency("Rules")

    local rule = rules:FindRule(ruleId)
    if (not rule) then
        error("Unable to locate rule: " .. ruleId)
    end

    table.forEach(rule, print, "rule")

    local dialog = self:GetEditRule()
    dialog:SetRule(rule)
    dialog:Show()
end

function Dialogs:OnTerminate()
end

Addon.Features.Dialogs = Dialogs