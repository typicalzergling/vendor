local _, Addon = ...
local locale = Addon:GetLocale()
local CommonUI = Addon.CommonUI
local Colors = Addon.CommonUI.Colors
local HelpItem = {}
local UI = Addon.CommonUI.UI
local Layouts = Addon.CommonUI.Layouts
local CONTENT_PADDING = 12
local CONTENT_SPACING = 10

local COLORS = {
    property = {
        border = "HELPITEM_PROPERTY_BORDER",
        back = "HELPITEM_PROPERTY_BACK",
        text = "HELPITEM_PROPERTY_TEXT",
    },
    ["function"] = {
        border = "HELPITEM_FUNCTION_BORDER",
        back = "HELPITEM_FUNCTION_BACK",
        text = "HELPITEM_FUNCTION_TEXT",
    }
}

function HelpItem:OnLoad()
    Mixin(self.header, Addon.CommonUI.Mixins.Border):OnBorderLoaded("tbk")
    local content = CreateFrame("Frame", nil, self)
    content:SetPoint("TOPLEFT", self.header, "BOTTOMLEFT")
    content:SetPoint("TOPRIGHT", self.header, "BOTTOMRIGHT")
    content:SetScript("OnSizeChanged", function(frame, width)
            Layouts.Stack(frame, { frame:GetChildren() }, CONTENT_PADDING, CONTENT_SPACING, width)
        end)
    content:Hide()
    self.content = content
end

--[[ Called when the model changes, our model has Type, Markdown, and Name ]]
function HelpItem:OnModelChange(model)
    self.header.name:SetText(model.Name)
    self:SetColors(model.Type)

    if (model.Type == "function") then
        self.header.etype:SetText("(F)")
    else
        self.header.etype:SetText("(P)")
    end

    print("---> markdown", model.Markdown)
    if (type(model.Markdown) == "string") then
        self.markdown = Addon.CommonUI.CreateMarkdownFrames(self.content, model.Markdown)
    else
        self.markdown = Addon.CommonUI.CreateMarkdownFrames(self.content, "No information available")
    end

    self.content:Show()
end

function HelpItem:Layout(width)
    Layouts.Stack(self.content, { self.content:GetChildren() }, CONTENT_PADDING, CONTENT_SPACING, width)
    local height = self.content:GetHeight() + self.header:GetHeight()
    self:SetHeight(height)
end

function HelpItem:SetExpand(expand)
end

function HelpItem:ToggleExpand()
end

function HelpItem:SetColors(type)
    local colors = COLORS[type]
    if (colors) then
        local header = self.header
        header:SetBackgroundColor(colors.back)
        header:SetBorderColor(colors.border)
        UI.SetColor(header.name, colors.text)
        UI.SetColor(header.etype, colors.text)
    end
end

Addon.Features.EditRules = Addon.Features.EditRules or {}
Addon.Features.EditRules.HelpItem = HelpItem