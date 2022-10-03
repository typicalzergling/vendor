local _, Addon = ...
local locale = Addon:GetLocale()
local TabControl = {}
local Tab = {}

function Tab:OnLoad()
end

function Tab:SetName(name)
end

function Tab:GetFrame()
    if (not self.frame) then
        local frame = CreateFrame("Frame", nil, self:GetParent(), self.template)
        if (type(self.class) == "table") then
            Addon.AttachImplementation(frame, self.class, 1)
        else
            Addon.LocalizeFrame(frame)
        end
        self.frame = frame
    end

    return self.frame
end

function Tab:Activate()
end

function Tab:Deactive()
end

function Tab:GetSize()
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
    local tab = CreateFrame("Button", nil, parent, template)
    tab.template = template
    tab.class = class
    tab.name = name
    Addon.AttachImplementation(tab, Tab, 1)
    return tab
end

--[[=========================================================================]]

function TabControl:OnLoad()
    print("table control on load", self)
    self.__tabs = {}
end

function TabControl:AddTab(id, name, template, class, far)
    assert(not self.__tabs[id], "There is already a table with the specified id: " .. id)
    local tab = Tab.Create(self, name, template, class)
    self.__tabs[id] = tab
end

function TabControl:ActivateTab(tab)
    local frame = tab:GetFrame()
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT")
    frame:SetPoint("BOTTOMRIGHT")
    frame:Show()
end

function TabControl:ShowTab(id)
    if (self.__tabs) then
        local tab = self.__tabs[id]
        if (tab) then
            self:ActivateTab(tab)
        end
    end
end

function TabControl:LayoutTabs()
end

Addon.CommonUI.TabControl = TabControl