local _, Addon = ...
local Vendor = Addon.Features.Vendor
local ProfileItem = Mixin({}, Addon.CommonUI.SelectableItem)
local UI = Addon.CommonUI.UI


--[[ Called to set the model ]]
function ProfileItem:OnModelChange(profile)
    UI.Prepare(self)
    self.name:SetText(profile:GetName())
    if (profile:IsActive()) then
        self.check:Show()
    else
        self.check:Hide()
    end

    profile:RegisterCallback("OnChanged", function()
            self.name:SetText(profile:GetName())
        end, self)
end

--[[ Called when the profile changes ]]
function ProfileItem:OnProfileChanged(profile)
    if (self:GetModel():Equals(profile)) then
        self.check:Show()
    else
        self.check:Hide()
    end
end

Vendor.ProfileItem = ProfileItem