local _, Addon = ...
local locale = Addon:GetLocale()
local CommonUI = Addon.CommonUI
local Colors = Addon.CommonUI.Colors
local UI = Addon.CommonUI.UI

--[[=========================================================================]]

local Edit = Mixin({}, Addon.CommonUI.Mixins.Border, Addon.CommonUI.Mixins.Debounce, Addon.CommonUI.Mixins.Placeholder)
local function debugp(m, ...) Addon:Debug("edit", m, ...) end

--[[ One time edit initialization ]]
function Edit:OnLoad()
    debugp("Edit[%s] loaded", self:GetDebugName())
    self:InitializePlaceholder("LEFT")
    self:OnBorderLoaded(nil, "EDIT_BORDER", "EDIT_BACK")
    UI.SetColor(self, "EDIT_REST")
    self.setText = self.SetText
    self.SetText = function(_, text) self:SetEditText(text) end
end

--[[ Handle hiding the edit (clearing any pending changes) ]]
function Edit:OnHide()
    self:DebounceNow()
end

function Edit:OnDisable()
    UI.SetColor(self, Colors.EDIT_DISABLED)
    self:SetBorderColor(Colors.EDIT_DISABLED)
end

function Edit:OnEnable()
    if (not self:HasFocus()) then
        UI.SetColor(self, Colors.EDIT_REST)
        self:SetBorderColor(Colors.EDIT_BORDER)
    else
        UI.SetColor(self, Colors.EDIT_TEXT)
        self:SetBorderColor(Colors.EDIT_HIGHLIGHT)
    end
end

--[[ Handle the text in the edit changing ]]
function Edit:OnTextChanged()
    debugp("Edit[%s] - OnTextChanged :: %s (%s)", self:GetDebugName(), self:GetText(), self.current or "")

    local value = self:GetText()
    if (value ~= self.current) then
        self.current = value
        self:Debounce(.75, GenerateClosure(self.NotifyChange, self))
    end
end

--[[ Handle gaining focus ]]
function Edit:OnEditFocusGained()
    self:SetBorderColor("EDIT_HIGHLIGHT")
    UI.SetColor(self, "EDIT_TEXT")
    self:ShowPlaceholder(false)
end

--[[ Handle losing focus ]]
function Edit:OnEditFocusLost()
    self:SetBorderColor("EDIT_BORDER")
    UI.SetColor(self, "EDIT_REST")
    self:DebounceNow()
    local value = self:GetText()
    if (type(value) ~= "string" or string.len(value) == 0) then
        self:ShowPlaceholder(true)
    end
end

--[[ Override the set text for our behavior ]]
function Edit:SetEditText(text)
    local current = self:GetText() or ""
    if (type(text) ~= "string") then
        text = ""
    else
        text = Addon.StringTrim(text)
    end

    if (current ~= text) then
        self.current = text
        if (string.len(text) ~= 0) then
            self:ShowPlaceholder(false)
        end
        self.setText(self, text)
    end
end

--[[ Check if this control has text ]]
function Edit:HasText()
    local text = self:GetText()
    if (type(text) ~= "string") then
        return false
    end

    text  = Addon.StringTrim(text)
    return string.len(text) ~= 0
end

--[[ Handle notifying the the change for this edit field ]]
function Edit:NotifyChange()
    local value = self:GetText() or ""
    if (value == nil) then
        value = ""
    elseif (type(value) == "string") then
        value = Addon.StringTrim(value)
    end

    debugp("Edit[%s] - Notify changes :: %s", self:GetDebugName(), tostring(value))

    if (type(self.Handler) == "string") then
        local parent = self:GetParent()
        local func = parent[self.Handler]
        if (type(func) == "function") then
            func(parent, value)
        end
    elseif (type(self.Handler) == "function") then
        self.Handler(value)
    end
end

--[[=========================================================================]]

local TextArea = Mixin({}, Addon.CommonUI.Mixins.Border, Addon.CommonUI.Mixins.Debounce, Addon.CommonUI.Mixins.Placeholder)

function TextArea:OnLoad()
    self.enabled = true

    self.scrollbar = CreateFrame("EventFrame", nil, self, "MinimalScrollBar")
    self.scrollbar:SetFrameStrata("HIGH")
    self.scrollbar:SetPoint("TOPRIGHT", -8, -4)
    self.scrollbar:SetPoint("BOTTOMRIGHT", -8, 4)
    self.scrollbar.minThumbExtent = 16

    self.editbox = CreateFrame("Frame", nil, self, "ScrollingEditBoxTemplate")
    self.editbox:SetPoint("TOPLEFT", 8, -8)
    self.editbox:SetPoint("BOTTOMRIGHT", self.scrollbar, "BOTTOMLEFT", -8, 0);
    ScrollUtil.RegisterScrollBoxWithScrollBar(self.editbox:GetScrollBox(), self.scrollbar);

    self.editbox:SetTextColor(Colors.EDIT_REST);
    if (type(self.Placeholder) == "string") then
        local loctext = locale:GetString(self.Placeholder)
        self.editbox:SetDefaultText(loctext)
        self.editbox:SetDefaultTextColor(Colors.EDIT_PLACEHOLDER)
    end

    --multiLine="true" letters="4000" autoFocus="false"
    self:OnBorderLoaded(nil, "EDIT_BORDER", "EDIT_BACK")
    
    local editbox = self.editbox

    editbox:RegisterCallback("OnFocusGained", GenerateClosure(self.OnFocus, self))
    editbox:RegisterCallback("OnFocusLost", GenerateClosure(self.OnBlur, self))

    if (self.ReadOnly == true) then
        self.readonly = true
        editbox:RegisterCallback("OnTextChanged", GenerateClosure(self.RestoreText, self))
    else
        self.readonly = false
        editbox:RegisterCallback("OnTextChanged", GenerateClosure(self.OnTextChanged, self))
        editbox:RegisterCallback("OnEnterPressed", GenerateClosure(self.NotifyChange, self))
     end
end

function TextArea:OnMouseDown()
    self.editbox:SetFocus()
end

function TextArea:RestoreText()
    assert(type(self.current) == "string")
    assert(self.ReadOnly)
    self.editbox:SetText(self.current)

    if (self.HighlightOnFocus == true) then
        local edit = self.editbox:GetEditBox()
        edit:HighlightText()
    end
end

function TextArea:OnDisable()
    self.editbox:SetTextColor(Colors.EDIT_DISABLED)
    self:SetBorderColor(Colors.EDIT_DISABLED)
end

function TextArea:HasFocus()
    local edit = self.editbox:GetEditBox()
    return edit and edit:HasFocus()
end

function TextArea:OnEnable()
    if (not self:HasFocus()) then
        self.editbox:SetTextColor(Colors.EDIT_REST)
        self:SetBorderColor(Colors.EDIT_BORDER)
    else
        self.editbox:SetTextColor(Colors.EDIT_TEXT)
        self:SetBorderColor(Colors.EDIT_HIGHLIGHT)
    end
end

function TextArea:SetText(text)
    debugp("TextArea[%s] : Set text '%s' [%s]",  self:GetDebugName(), text or "", self.current or "")
    if (type(text) ~= "string") then
        text = ""
    else
        text = Addon.StringTrim(text)
    end

    local current = self:GetText()
    if (text ~= current) then
        self.current = text
        self.editbox:SetText(text)
        --self:SetVerticalScroll(0)
        if (string.len(text) ~= 0) then
            self:ShowPlaceholder(false)
        end
    end
end

function TextArea:OnFocus()
    self:SetBorderColor("EDIT_HIGHLIGHT")
    UI.SetColor(self, "EDIT_TEXT")
    self:ShowPlaceholder(false)

    if (self.HighlightOnFocus == true) then
        self.editbox:GetEditBox():HighlightText()
    end
end

function TextArea:OnBlur()
    self:SetBorderColor("EDIT_BORDER")
    UI.SetColor(self, "EDIT_REST")
    self:DebounceNow()
    if (self.HighlightOnFocus == true) then
        self.editbox:GetEditBox():ClearHighlightText()
    end
end

function TextArea:OnTextChanged()
    local text = self:GetText()
    if (text ~= self.current) then
        debugp("TextArea[%s] - text changed '%s'", self:GetDebugName(), text)
        self:Debounce(0.5, GenerateClosure(self.NotifyChange, self))
    end
end

function TextArea:NotifyChange()
    local value = self:GetText()
    debugp("TextArea[%s] - Notify changes :: '%s'", self:GetDebugName(), tostring(value))

    if (type(self.Handler) == "string") then
        local parent = self:GetParent()
        local func = parent[self.Handler]
        if (type(func) == "function") then
            func(parent, value)
        end
    elseif (type(self.Handler) == "function") then
        self.Handler(value)
    end
end

function TextArea:IsEnabled()
    return self.enabled
end

function TextArea:Enable()
    self.enabled = true
    self.editbox:SetEnabled(true)
    self:OnEnable()
end

function TextArea:Disable()
    self.enabled = false
    self.editbox:SetEnabled(false)
    self:OnDisable()
end

function TextArea:HasText()
    local text = self:GetText()
    if (type(text) ~= "string") then
        return false
    end

    text = Addon.StringTrim(text)
    return string.len(text) ~= 0
end

function TextArea:GetText()
    local text = self.editbox:GetInputText()
    if (type(text) ~= "string") then
        return ""
    end
    return Addon.StringTrim(text)
end

function TextArea:Insert(text)
    if (type(text) == "string") and (string.len(text) ~= 0) then
        local edit = self.editbox:GetEditBox()

        if (edit:IsDefaultTextDisplayed()) then
            self.editbox:SetText(text)
        else
            edit:Insert(text)
        end
        self:Debounce(.5, GenerateClosure(self.NotifyChange, self))
    end
end

function TextArea:SetFocus()
    self.editbox:SetFocus()
end

CommonUI.Edit = Edit
CommonUI.TextArea = TextArea