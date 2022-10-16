local _, Addon = ...
local locale = Addon:GetLocale();
Addon.Controls = Addon.Controls or {}
local CommonUI = Addon.CommonUI

local WHITE = WHITE_FONT_COLOR
local GRAY = GRAY_FONT_COLOR

local BACKDROP = 
{
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Glues\\Common\\TextPanel-Border",
    tile = true,
    tileEdge = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },    
}



local TEXTAREA_BORDER = CreateColor(0.5, 0.5, 0.5, .5)
local TEXTAREA_BACK = CreateColor(0.9, 0.9, 0.9, .08)

local TextArea = 
{
    OnLoad = function(textarea) 
        print("$$$$$ textarea on load ")
        textarea:OnBorderLoaded(nil, TEXTAREA_BORDER, TEXTAREA_BACK)

        Mixin(textarea, CommonUI.Mixins.Placeholder, CommonUI.Mixins.ScrollView)
        textarea:InitializePlaceholder()
        textarea:InitializeScrollView(textarea.Scroller)

        local edit = textarea.Scroller:GetScrollChild()
        edit:SetScript("OnEditFocusGained", function()
                textarea:ShowPlaceholder(false)
            end)

        edit:SetScript("OnEditFocusLost", function()
                textarea:ShowPlaceholder(not textarea:HasText())
            end)

        edit:SetScript("OnTextChanged", function()
                ScrollingEdit_OnTextChanged(edit, edit:GetParent())
                if (textarea.__timer) then
                    textarea.__timer:Cancel()
                end

                textarea.__timer = C_Timer.NewTimer(0.25, function() 
                        textarea.__timer = nil
                        if (textarea.Handler) then
                            Addon.Invoke(textarea:GetParent(), textarea.Handler, edit:GetText())
                        end
                    end)
            end)

        ScrollFrame_OnLoad(textarea.Scroller)
    end,

    HasText = function(textarea)
        local text = textarea.Scroller:GetScrollChild():GetText()
        return (type(text) == "string") and (string.len(text) ~= 0)
    end,

    OnMouseDown = function(textarea)
        textarea.Scroller:GetScrollChild():SetFocus()
    end,
}

Addon.CommonUI.XTextArea = Mixin(TextArea, Addon.CommonUI.Mixins.Border)