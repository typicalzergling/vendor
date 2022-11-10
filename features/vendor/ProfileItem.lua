local _, Addon = ...
local Vendor = Addon.Features.Vendor
local ProfileItem = Mixin({}, Addon.CommonUI.Mixins.Border)
local UI = Addon.CommonUI.UI
local Colors = Addon.CommonUI.Colors

local COLORS = {
    normal = {
        back = Colors.TRANSPARENT,
        border = Colors.TRANSPARENT,
        text = "TEXT",
    },
    hover = {
        back = "HOVER_BACKGROUND",
        border = Colors.TRANSPARENT,
        text = "HOVER_TEXT",
    },
    selected = {
        back = "SELECTED_BACKGROUND",
        border = "SELECTED_BORDER",
        text = "SELECTED_TEXT"
    }
}

--[[ Handle load]]
function ProfileItem:OnLoad()
    self:OnBorderLoaded("tbk")
    self:SetColors("normal")
end

function ProfileItem:SetColors(state)
    local colors = COLORS[state]
    if (colors) then
        self:SetBorderColor(colors.border)
        self:SetBackgroundColor(colors.back)
        UI.SetColor(self.name, colors.text)
    end
end

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
    if (not self:IsSelected()) then
        self:Select()
    end
end

--[[ Called when the item is selected ]]
function ProfileItem:OnSelected(selected)
    self:SetColors("selected")
end

--[[ Called when the item is unselected ]]
function ProfileItem:OnUnselected(selected)
    local mouseOver = self:IsMouseOver()

    if (not mouseOver) then
        self:SetColors("normal")
    else
        self:SEtColors("hover")
    end
end

--[[ Called on mouse over ]]
function ProfileItem:OnEnter()
    if (not self:IsSelected()) then
        self:SetColors("hover")
    end
end

--[[ Called to handle mouse leave ]]
function ProfileItem:OnLeave()
    if (not self:IsSelected()) then
        self:SetColors("normal")
    end
end

Vendor.ProfileItem = ProfileItem