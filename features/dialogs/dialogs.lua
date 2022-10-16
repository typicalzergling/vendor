local _, Addon = ...
local Dialogs = { NAME = "Dialogs", VERSION = 1 }

function Dialogs:OnInitialize(a, b, host)
    local dlg = host:CreateDialog("VendorEditRuleDialog2", "Vendor_Dialogs_EditRule", self.EditRule)
    dlg:Toggle()
    
    return
        -- Internal API
        {
            GetEditRule = self.GetEditRule, 
            CreateRule = self.CreateRule, 
            EditRule = self.EditRule 
        },
        -- Public API
        {
            CeateRule = self.GetEditRule
        }
end

function Dialogs:GetEditRule()
    if (not self._editRule) then
        self._editRule = self:CreateDialog("VendorEditRuleDialog2", "Vendor_Dialogs_EditRule", self.EditRule)
    end
    return self._editRule
end

function Dialogs:CreateRule()
    local dlg = self:GetEditRule()
    dlg:Show()
end

function Dialogs:EditRule(rule)
    local dialog = self:GetEditRule()
    dialog:Show()
end

function Dialogs:OnTerminate()
end

Addon.Features.Dialogs = Dialogs