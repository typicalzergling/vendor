local _, Addon = ...
local locale = Addon:GetLocale()
local CommonUI = Addon.CommonUI

local BaseEdit = Mixin({}, CommonUI.Mixins.Border, CommonUI.Mixins.Placeholder)

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
end

function BaseEdit:ShowHighlight(show)
    if (show) then
        self.highlight = (self.highlight or 0) + 1
    else
        self.highlight = (self.highlight or 1) - 1
    end

    print("---> edit highlight", self.highlight)
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
    return (type(text) == "string") and (string.len(text) ~= 0)
end

function BaseEdit:GetText()
end

function BaseEdit:SetText(text)
end

function BaseEdit:_HandleTextChange()
    if (self.__timer) then
        self.__timer:Cancel()
        self.__timer = nil
    end

    self.__timer = C_Timer.NewTimer(0.25, function() 
        self.__timer = nil
        print("--------> text changed", self.control:GetText())
        if (self.Handler) then
            Addon.Invoke(self:GetParent(), self.Handler, self.control:GetText())
        end
    end)
end

--[[=========================================================================]]
local Edit = {}

function Edit:OnLoad()
    self:OnEditLoaded()

    self.control:SetScript("OnTextChanged", function()
        self:_HandleTextChange()
    end)
end

--[[=========================================================================]]

local TextArea = {}
function TextArea:OnLoad()
    self.control = self.scrollingEdit:GetScrollChild()
    ScrollFrame_OnLoad(self.scrollingEdit)
    self:OnEditLoaded()

    self.control:SetScript("OnTextChanged", function(edit)
            ScrollingEdit_OnTextChanged(edit, edit:GetParent())
            self:_HandleTextChange()
        end)
end

CommonUI.Edit = Mixin(Edit, BaseEdit)
CommonUI.TextArea = Mixin(TextArea, BaseEdit)