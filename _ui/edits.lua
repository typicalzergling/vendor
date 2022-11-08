local _, Addon = ...
local locale = Addon:GetLocale()
local CommonUI = Addon.CommonUI
local Colors = Addon.CommonUI.Colors
local BaseEdit = Mixin({}, CommonUI.Mixins.Border, CommonUI.Mixins.Placeholder, CommonUI.Mixins.Debounce)

local EDIT_BORDER_COLOR = CreateColor(1, 1, 1, .4)
local EDIT_BACK_COLOR = CreateColor(.8, .8, .8, .1)
local EDIT_HIGHLIGHT_COLOR = CreateColor(1, 1, 1, .7)
local EDIT_DISABLED_COLOR = CreateColor(.5, .5, .5, .5)
local EDIT_COLOR = WHITE_FONT_COLOR

function BaseEdit:OnEditLoaded()
    self:InitializePlaceholder()
    self:OnBorderLoaded(nil, EDIT_BORDER_COLOR, EDIT_BACK_COLOR)

    -- If we have a label then set it
    if (self.labelText) then
        if (type(self.Label) == "string") then
            local loc = locale[self.Label]
            self.labelText:SetText(loc or self.Label)
        else
            self.labelText:Hide()
        end
    end

    -- Hook to our edit
    self.control:SetScript("OnEditFocusGained", function (_) self:_OnFocus() end)
    self.control:SetScript("OnEditFocusLost", function (_) self:_OnBlur() end)
    self.control:SetTextColor(Colors.TEXT:GetRGBA())
end

function BaseEdit:ShowHighlight(show)
    if (show) then
        self.highlight = (self.highlight or 0) + 1
    else
        self.highlight = (self.highlight or 1) - 1
    end

    if (self.highlight == 0) then
        self:SetBorderColor(EDIT_BORDER_COLOR)
    else
        self:SetBorderColor(EDIT_HIGHLIGHT_COLOR)
    end        
end

function BaseEdit:OnEnter()
end

function BaseEdit:OnLeave()
end

function BaseEdit:_OnFocus()
    self:ShowHighlight(true)
    self:ShowPlaceholder(false)
end

function BaseEdit:_OnBlur()
    self:ShowHighlight(false)
    self:ShowPlaceholder(not self:HasText())
end

function BaseEdit:OnDisable()
end

function BaseEdit:OnEnable()
end

function BaseEdit:OnMouseDown()
    self.control:SetFocus()
end

function BaseEdit:HasText()
    local text = self.control:GetText()
    if (type(text) == "string") then
        text = Addon.StringTrim(text)
    end

    return (type(text) == "string") and (string.len(text) ~= 0)
end

function BaseEdit:GetText()
    local text = self.control:GetText()
    if (type(text) ~= "string") then
        return nil
    end

    return Addon.StringTrim(text)
end

function BaseEdit:SetText(text)
    if type(text) ~= "string" then
        self.control:SetText("")
        self.__lastText = ""
    else
        text = Addon.StringTrim(text)
        self.control:SetText(text)
        self.__lastText = text
    end

    if (not self.control:HasFocus()) then
        self:ShowPlaceholder(not self:HasText())
    end
end

function BaseEdit:Insert(text)
    if (type(text) == "string") and (string.len(text) ~= 0) then
        self.control:Insert(text)
    end
end

function BaseEdit:IsEnabled()
    return self.control:IsEnabled()
end

function BaseEdit:SetFocus()
    return self.control:SetFocus()
end

function BaseEdit:Enable()
    -- enable the label
    self.control:Enable()
	self.control:SetTextColor(Colors.TEXT:GetRGBA())
end

function BaseEdit:Disable()
    -- disable the label
    self.control:Disable()
    self.control:SetTextColor(EDIT_DISABLED_COLOR:GetRGBA())
end

--[[ On hide clear the last text ]]
function BaseEdit:OnHide()
    self.__lastText = nil
end

function BaseEdit:_HandleTextChange()
    if (self.__timer) then
        self.__timer:Cancel()
        self.__timer = nil
    end

    self.__timer = C_Timer.NewTimer(0.25, function() 
        self.__timer = nil
        if (self.Handler) then
            local text = self.control:GetText()         
            if (type(text) == "string") then
                text = Addon.StringTrim(text)
            else
                text = nil
            end

            if (text ~= self.__lastText) then
                self.__lastText = text
                Addon.Invoke(self:GetParent(), self.Handler, text)
            end
        end
    end)
end

--[[=========================================================================]]

local Edit = {}

function Edit:OnLoad()
    self:OnEditLoaded()

    if (type(self.Numeric) == "boolean") then
        self.control:SetNumeric(self.Numeric)
    end

    self.control:SetScript("OnTextChanged", function()
        self:_HandleTextChange()
    end)
end

--[[ Sets this edit to be number ]]
function Edit:SetNumeric()
    self.control:SetNumeric(true)
end

--[[ Gets the number value of the edit ]]
function Edit:GetNumber()
    return self.control:GetNumber()
end

--[[=========================================================================]]

local TextArea = {}

function TextArea:OnLoad()
    self.control = self.scrollingEdit:GetScrollChild()
    ScrollingEdit_OnLoad(self.scrollingEdit)
    self:OnEditLoaded()

    self.scrollingEdit:SetScript("OnSizeChanged", function(_, width)
            self.control:SetWidth(width)
        end)

    self.control:SetScript("OnTextChanged", function(edit)
            self:_HandleTextChange()
            ScrollingEdit_OnTextChanged(edit, edit:GetParent())
        end)
end

CommonUI.Edit = Mixin(Edit, BaseEdit)
CommonUI.TextArea = Mixin(TextArea, BaseEdit)