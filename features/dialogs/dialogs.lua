local _, Addon = ...
local Dialogs = { 
    NAME = "Dialogs", 
    VERSION = 1,
    DEPENDENCIES = { "Rules", "Import" }
}

function Dialogs:OnInitialize(a, b, host)
    self:Debug("---> oninitialize")
    C_Timer.After(1, function()
        print("-----------> TIMER FUNCTOIN  <--------------------")
        if (not self.one) then
        local dlg = Addon:F_GetEditRule()
        print(dlg)
        dlg:NewRule()
        dlg:Show()
        self.one = true
        end
    end)

    return
        -- Internal API
        {
            F_GetEditRule = self.GetEditRule,
            F_CreateRule = self.CreateRule, 
            F_EditRule = self.EditRule
        }
end

function Dialogs:GetEditRule()
    if (not self.editRule) then
        self.editRule = self:CreateDialog("VendorEditRuleDialog2", "Vendor_Dialogs_EditRule", self.EditRule)
    else
        error("why are we here?")
    end

    print("create dialog", self, self.editRule)
    return self.editRule
end

function Dialogs:CreateRule()
    local dlg = self:GetEditRule()
    dlg:NewRule()
    dlg:Show()
end

function Dialogs:EditRule(rule)
    local dialog = self:GetEditRule()
    dialog:EditRule(rule)
    dialog:Show()
end

function Dialogs:OnTerminate()
end

Addon.Features.Dialogs = Dialogs