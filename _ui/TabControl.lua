local _, Addon = ...
local locale = Addon:GetLocale()
local TabControl = {}
local Tab = Mixin({}, Addon.CommonUI.Mixins.Border, CallbackRegistryMixin)

local TABCONTROL_BORDER = CreateColor(1, 1, 1, .60)
local TABCONROL_BACK = { r = 0, g = 0, b = 0, a = 0 }
local TABCONTROL_TEXT = YELLOW_FONT_COLOR
local TABCONTROL_INACTIVE_BORDER = CreateColor(1, 1, 1, .40)
local TABCONTROL_INACTIVE_TEXT = CreateColor(1, 1, 1, 0.6)
local TABCONTROL_INACTIVE_BACK = { r = 0, g = 0, b = 0, a = 0 }
local TAB_PADDING_X = 10

function Tab:OnLoad()
    self:OnBorderLoaded("lrtk", TABCONTROL_INACTIVE_BORDER, TABCONTROL_INACTIVE_BACK)
    self.text:SetTextColor(TABCONTROL_INACTIVE_TEXT:GetRGBA())
end

function Tab:SetName(name)
    local loc = locale[name]
    self.text:SetText(loc or name)
    self.text:SetWidth(0)
    self:SetWidth((TAB_PADDING_X * 2) + self.text:GetWidth())
end

--[[
    Call a method on the tab frame
]]
function Tab:Call(method, ...)
    local frame = self:GetFrame()
    if (frame) then
        local func = frame[method]
        if (type(func) == "function") then
            xpcall(func, CallErrorHandler, frame, ...)
        end
    end
end

function Tab:GetFrame()
    if (not self.frame) then
        local frame = CreateFrame("Frame", nil, self:GetParent(), self.template)
        Addon.CommonUI.DialogBox.Colorize(frame)
        if (type(self.class) == "table") then
            Addon.AttachImplementation(frame, self.class, 1)
        else
            Addon.LocalizeFrame(frame)
        end

        -- Provide a trigger event delegate
        frame.TriggerEvent = function(_, ...) 
                self:TriggerEvent(...) 
            end
        self.frame = frame
    end

    return self.frame
end

function Tab:Activate()
    self:SetBackgroundColor(TABCONROL_BACK)
    self:SetBorderColor(TABCONTROL_BORDER)
    self.text:SetTextColor(TABCONTROL_TEXT:GetRGBA())

    if (self.frame) then
        Addon.Invoke(self.frame, "OnActivate", self.frame)
        self.frame:Show()
    end
end

function Tab:Deactivate()
    self:SetBackgroundColor(TABCONTROL_INACTIVE_BACK)
    self:SetBorderColor(TABCONTROL_INACTIVE_BORDER)
    self.text:SetTextColor(TABCONTROL_INACTIVE_TEXT:GetRGBA())

    if (self.frame) then
        Addon.Invoke(self.frame, "OnDeactivate", self.frame)
        self.frame:Hide()
    end
end

function Tab:OnHide()
    if (self.active) then
        self:Deactive()
    end
end

function Tab:GetSize()
    local frame = self.text
    return (2 * TAB_PADDING_X) + frame:GetWidth(), frame:GetHeight()
end

function Tab:OnEnter()
end

function Tab:OnLeave()
end

function Tab:ShowFrame(show)
    local frame = self.frame
    if (frame) then
        if (show and not frame:IsShown()) then
            frame:Show()
        elseif (not show and frame:IsShown()) then
            frame:Hide()
        end
    end
end

--[[static]] function Tab.Create(parent, name, template, class)
    local tab = CreateFrame("Button", nil, parent, "CommonUI_Tab")
    Addon.CommonUI.DialogBox.Colorize(tab)
    tab.template = template
    tab.class = class

    Addon.AttachImplementation(tab, Tab, 1)
    if (type(name) == "string") then
        tab:SetName(name)
    end

    CallbackRegistryMixin.OnLoad(tab)
    tab:SetUndefinedEventsAllowed(true)

    return tab
end

--[[=========================================================================]]

local CONTENT_PADDING_X = 12
local CONTENT_PADDING_Y = 12

function TabControl:OnLoad()
    Mixin(self.frames, Addon.CommonUI.Mixins.Border)
    self.frames:OnBorderLoaded("rlbk", TABCONTROL_BORDER, TABCONROL_BACK)
    self.__tabs = {}

    self.tabsNear = self:CreateTexture(nil, "BORDER")
    self.tabsNear:SetColorTexture(TABCONTROL_BORDER:GetRGBA())
    self.tabsNear:SetHeight(1)
    self.tabsNear:SetPoint("TOPLEFT", self.frames)
    self.tabsNear:Show()

    self.tabsFar = self:CreateTexture(nul, "BORDER")
    self.tabsFar:SetColorTexture(TABCONTROL_BORDER:GetRGBA())
    self.tabsFar:SetHeight(1)
    self.tabsFar:SetPoint("TOPRIGHT", self.frames)
    self.tabsFar:Show()
end

function TabControl:AddTab(id, name, template, class, far)
    assert(not self.__tabs[id], "There is already a table with the specified id: " .. id)
    local tab = Tab.Create(self, name, template, class)
    self.__tabs[id] = tab

    tab:SetScript("OnClick", function(target)
        if (target ~= self.__active) then
            self:ActivateTab(target)
        end
    end)

    if (self:IsShown()) then
        self:Layout()
    end

    return tab
end

function TabControl:ActivateTab(tab)
    local frame = tab:GetFrame()

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", self.frames, CONTENT_PADDING_X, -CONTENT_PADDING_Y)
    frame:SetPoint("BOTTOMRIGHT", self.frames, -CONTENT_PADDING_X, CONTENT_PADDING_Y)
    
    -- Deactivate the old tab
    if (self.__active) then
        self.__active:Deactivate()
    end

    -- Activate the new tab
    tab:Activate()
    self.__active = tab;

    self.tabsNear:SetPoint("RIGHT", tab, "LEFT", 1, 0)
    self.tabsFar:SetPoint("LEFT", tab, "RIGHT", -1, 0)

    return tab
end

function TabControl:ShowTab(id)
    if (self.__tabs) then
        local tab = self.__tabs[id]
        if (tab) then            
            return self:ActivateTab(tab)
        end
    end
end

function TabControl:Layout()
   local last = nil
   for _, tab in pairs(self.__tabs) do
        tab:ClearAllPoints()

        if (not last) then
            tab:SetPoint("TOPLEFT", self, "TOPLEFT", 10, 0)
            self.frames:SetPoint("TOP", tab, "BOTTOM", 0, 1)
        else
            tab:SetPoint("BOTTOMLEFT", last, "BOTTOMRIGHT", 4, 0)
        end

        tab:Show()
        last = tab
    end
end

function TabControl:GetClientPoints()
    if (self.__tabs) then
        -- tabs on top
        local _, first = next(self.__tabs)
        local _, height = first:GetSize()
        return 4, -(4 + height), -4, 4
    end

    return 0, 0, 0, 0
end

function TabControl:OnShow()
    self:Layout()
end

Addon.CommonUI.TabControl = Mixin(TabControl, Addon.CommonUI.Mixins.Border)