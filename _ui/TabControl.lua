local _, Addon = ...
local locale = Addon:GetLocale()
local UI = Addon.CommonUI.UI
local Colors = Addon.CommonUI.Colors
local TabControl = {}
local Tab = Mixin({}, Addon.CommonUI.Mixins.Border, CallbackRegistryMixin)
local TAB_PADDING_X = 10
local CONTENT_PADDING_X = 12
local CONTENT_PADDING_Y = 12

function Tab:OnLoad()
    self.active = false
    self:OnBorderLoaded("lrtk", Colors:Get("TABCONTROL_INACTIVE_BORDER"), Colors:Get("TABCONTROL_INACTIVE_BACK"))
    UI.SetColor(self.text,  "TABCONTROL_INACTIVE_TEXT")
end

function Tab:SetName(name)
    UI.SetText(self.text, name)
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
    if (not self.active) then
        self.active = true

        self:SetBackgroundColor(Colors:Get("TABCONROL_BACK"))
        self:SetBorderColor(Colors:Get("TABCONTROL_BORDER"))
        UI.SetColor(self.text, "TABCONTROL_TEXT")

        local frame = self:GetFrame()
        if (type(frame.OnActivate) == "function") then
            frame:OnActivate()
        end

        frame:Show()
    end
end

function Tab:Deactivate()
    if (self.active) then
        self.active = false

        self:SetBackgroundColor(Colors:Get("TABCONTROL_INACTIVE_BACK"))
        self:SetBorderColor(Colors:Get("TABCONTROL_INACTIVE_BORDER"))
        UI.SetColor(self.text, "TABCONTROL_INACTIVE_TEXT")


        local frame = self.frame
        if (frame) then
            if (type(frame.OnDeactivate) == "function") then
                frame:OnDeactivate()
            end

            frame:Hide()
        end
    end
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

--[[ Gets the ID of this tab ]]
function Tab:GetId()
    return self.id or ""
end

--[[static]] function Tab.Create(parent, id, name, template, class)
    local tab = CreateFrame("Button", nil, parent, "CommonUI_Tab")
    UI.Prepare(tab)

    tab.id = id
    tab.template = template
    tab.class = class
    if (type(tab.class) == "string") then
        tab.class = UI.Resolve(class)
    end

    UI.Attach(tab, Tab)
    if (type(name) == "string") then
        tab:SetName(name)
    end

    CallbackRegistryMixin.OnLoad(tab)
    tab:SetUndefinedEventsAllowed(true)

    return tab
end

--[[=========================================================================]]

function TabControl:OnLoad()
    Mixin(self.frames, Addon.CommonUI.Mixins.Border)
    self.frames:OnBorderLoaded("rlbk", Colors:Get("TABCONTROL_BORDER"), Colors:Get("TABCONROL_BACK"))
    self.__tabs = {}

    self.tabsNear = self:CreateLine("BORDER")
    UI.SetColor(self.tabsNear, "TABCONTROL_BORDER")
    self.tabsNear:SetThickness(1)
    self.tabsNear:SetStartPoint("TOPLEFT", self.frames, 0, -1)
    self.tabsNear:Show()

    self.tabsFar = self:CreateLine("BORDER")
    UI.SetColor(self.tabsFar, "TABCONTROL_BORDER")
    self.tabsFar:SetThickness(1)
    self.tabsFar:SetEndPoint("TOPRIGHT", self.frames, 0, -1)
    self.tabsFar:Show()

    self.tabsMiddle = self:CreateLine("BORDER")
    UI.SetColor(self.tabsFar, "TABCONTROL_BORDER")
    self.tabsMiddle:SetThickness(1)
    self.tabsMiddle:Hide()
end

--[[ Find a tab with the specified id ]]
function TabControl:GetTab(tabId)
    for _, tab in ipairs(self.__tabs) do
        if (tab:GetId() == tabId) then
            return tab
        end
    end

    return nil
end

function TabControl:AddTab(id, name, template, class, far)
    assert(not self:GetTab(id), "There is already a table with the specified id: " .. id)
    local tab = Tab.Create(self, id, name, template, class)
    table.insert(self.__tabs, tab)

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

--[[ True if there is an active tab ]]
function TabControl:HasActiveTab()
    return self.__active ~= nil
end

function TabControl:ActivateTab(tab)
    local frame = tab:GetFrame()
    local host = self.frames

    frame:ClearAllPoints()
    --frame:SetWidth(host:GetWidth() - (2 * CONTENT_PADDING_X))
    --frame:SetHeight(host:GetHeight() - ( 2 * CONTENT_PADDING_Y))
    frame:SetPoint("TOPLEFT", self.frames, CONTENT_PADDING_X, -CONTENT_PADDING_Y)
    frame:SetPoint("BOTTOMRIGHT", self.frames, -CONTENT_PADDING_X, CONTENT_PADDING_Y)
    
    -- Deactivate the old tab
    if (self.__active) then
        self.__active:Deactivate()
    end

    -- Activate the new tab
    tab:Activate()
    self.__active = tab;

    self.tabsNear:SetEndPoint("BOTTOMLEFT", tab, 0, 0)
    self.tabsFar:SetStartPoint("BOTTOMRIGHT", tab, -1, 0)

    return tab
end

function TabControl:ShowTab(id)
    local tab = self:GetTab(id)
    if (tab) then
        return self:ActivateTab(tab)
    end
end

function TabControl:Layout()
   local last = nil
   for _, tab in ipairs(self.__tabs) do
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

function TabControl:OnShow()
    self:Layout()
end

Addon.CommonUI.TabControl = Mixin(TabControl, Addon.CommonUI.Mixins.Border)