local _, Addon = ...
local locale = Addon:GetLocale()
local CommonUI = Addon.CommonUI
local Colors = Addon.CommonUI.Colors
local CategoryItem = Mixin({}, Addon.CommonUI.SelectableItem)
local UI = CommonUI.UI

--[[ Shows a new tag on the frame ]]
local function createNewLabel(frame, point, x, y)
    if (Addon.Systems.Info.IsRetailEra) then
        local tag = CreateFrame("Frame", nil,  frame, "NewFeatureLabelTemplate")
        tag:SetPoint("TOPRIGHT", frame, point, x, y)
        tag:Show()
        return tag
    end

    return nil
end

--[[ Called when the model is changed ]]
function CategoryItem:OnModelChange(model)
    if (type(model.GetName) == "function") then
        UI.SetText(self.text, model:GetName())
    elseif (type(model.Name) == "string") then
        UI.SetText(self.text, model.Name)
    elseif (type(model.Text) == "string") then
        UI.SetText(self.text, model.Text)
    else
        self.text:SetText()
    end

    -- Show / Hide the new tag
    for _, frame in ipairs(self.new) do
        if (model.IsNew == true) then
            frame:Show()
        else
            frame:Hide()
        end
    end
end

--[[ Gets the tooltip text ]]
function CategoryItem:GetHelpText()
    local model = self:GetModel()

    if (type(model.GetDescription) == "function") then
        return model:GetDescription()
    elseif (type(model.Help) == "string") then
        return model.Help
    elseif (type(model.Description) == "string") then
        return model.Description
    end

    return nil
end

--[[ Check if we have a tooltop ]]
function CategoryItem:HasTooltip()
    local help = self:GetHelpText()
    return type(help) == "string" and string.len(help) ~= 0
end

--[[ Show a tooltip for this item ]]
function CategoryItem:OnTooltip(tooltip)
    local text = self:GetHelpText()
    local loc = locale:GetString(text)
    local nameColor = Colors:Get("SELECTED_PRIMARY_TEXT")
    local textColor = Colors:Get("SECONDARY_TEXT")

    tooltip:SetText(self.text:GetText(), nameColor:GetRGB())
    tooltip:AddLine(loc or text, textColor.r, textColor.g, textColor.b, true)
end

Addon.CommonUI.CategoryItem = CategoryItem
