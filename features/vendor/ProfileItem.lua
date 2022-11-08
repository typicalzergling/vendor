local _, Addon = ...
local Vendor = Addon.Features.Vendor
local ProfileItem = {}
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

--ProfileItem:OnProfileUpdated(profile)

--[[ Called when the item is clicked ]]
function ProfileItem:OnClick()
    local list = self:GetList()
    list:Select(self:GetModel())
end

--[[ Called when the item is selected ]]
function ProfileItem:OnSelected(selected)
    UI.SetColor(self.backdrop, "SELECTED_BACKGROUND")
    self.backdrop:Show()
end

--[[ Called when the item is unselected ]]
function ProfileItem:OnUnselected(selected)
    local mouseOver = self:IsMouseOver()

    if (not mouseOver) then
        self.backdrop:Hide()
    else
        UI.SetColor(self.backdrop, "HOVER_BACKGROUND")
    end
end

--[[ Called on mouse over ]]
function ProfileItem:OnEnter()
    if (not self:IsSelected()) then
        UI.SetColor(self.backdrop, "HOVER_BACKGROUND")
        self.backdrop:Show()
    end
end

--[[ Called to handle mouse leave ]]
function ProfileItem:OnLeave()
    if (not self:IsSelected()) then
        self.backdrop:Hide()
    end
end

Vendor.ProfileItem = ProfileItem