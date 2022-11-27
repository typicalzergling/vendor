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

local TextArea = Mixin({}, Addon.CommonUI.Mixins.Border, Addon.CommonUI.Mixins.Debounce, Addon.CommonUI.Mixins.Placeholder, Addon.CommonUI.Mixins.ScrollView)

function TextArea:OnLoad()
    self:InitializeScrollView(self, 4)
    self:InitializePlaceholder("LEFT", "TOP")
    self:OnBorderLoaded(nil, "EDIT_BORDER", "EDIT_BACK")
    UI.SetColor(self.editbox, Colors.EDIT_REST)

    local edit = self.editbox
    edit:SetScript("OnEditFocusGained", GenerateClosure(self.OnFocus, self))
    edit:SetScript("OnEditFocusLost", GenerateClosure(self.OnBlur, self))
    edit:SetScript("OnTextChanged", GenerateClosure(self.OnTextChanged, self))
    edit:SetScript("OnEnable", GenerateClosure(self.OnEnable, self))
    edit:SetScript("OnDisable", GenerateClosure(self.OnDisable, self))
    ScrollFrame_OnLoad(self)

    if (self.ReadOnly == true) then
        self.readonly = true
        edit:SetScript("OnChar", GenerateClosure(self.RestoreText, self))
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
        self.editbox:HighlightText()
    end
end

function TextArea:OnDisable()
    UI.SetColor(self.editbox, Colors.EDIT_DISABLED)
    self:SetBorderColor(Colors.EDIT_DISABLED)
end

function TextArea:OnEnable()
    if (not self.editbox:HasFocus()) then
        UI.SetColor(self.editbox, Colors.EDIT_REST)
        self:SetBorderColor(Colors.EDIT_BORDER)
    else
        UI.SetColor(self.editbox, Colors.EDIT_TEXT)
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
        self:SetVerticalScroll(0)
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
        self.editbox:HighlightText()
    end
end

function TextArea:OnBlur()
    self:SetBorderColor("EDIT_BORDER")
    UI.SetColor(self, "EDIT_REST")
    self:DebounceNow()
    if (not self:HasText()) then
        self:ShowPlaceholder(true)
    end

    if (self.HighlightOnFocus == true) then
        self.editbox:ClearHighlightText()
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
    return self.editbox:IsEnabled()
end

function TextArea:Enable()
    self.editbox:Enable()
end

function TextArea:Disable()
    self.editbox:Disable()
end

function TextArea:HasText()
    local text = self.editbox:GetText()
    if (type(text) ~= "string") then
        return false
    end

    text = Addon.StringTrim(text)
    return string.len(text) ~= 0
end

function TextArea:GetText()
    local text = self.editbox:GetText()
    if (type(text) ~= "string") then
        return ""
    end
    return Addon.StringTrim(text)
end

function TextArea:Insert(text)
    if (type(text) == "string") and (string.len(text) ~= 0) then
        self.editbox:Insert(text)
        self:Debounce(.5, GenerateClosure(self.NotifyChange, self))
    end
end

function TextArea:SetFocus()
    self.editbox:SetFocus()
end

CommonUI.Edit = Edit
CommonUI.TextArea = TextArea