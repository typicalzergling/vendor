local _, Addon = ...
local locale = Addon:GetLocale()
local UI = Addon.CommonUI.UI
local ContextMenu = Mixin({}, Addon.CommonUI.Mixins.Border)
local Layouts = Addon.CommonUI.Layouts
local MENU_PADDING = 8
local ITEM_SPACING = 4

--[[ Create a line for the context menu ]]
local function createSeparator(parent)
    local frame = CreateFrame("Frame", nil, parent, "CommonUI_ContextMenu_Separator")
    UI.Prepare(frame)
    return frame
end

--[[ Create a menu item for the context menu ]]
local function createItem(parent, label)
    local frame = CreateFrame("Button", nil, parent, "CommonUI_ContextMenu_Item")
    UI.Prepare(frame)
    frame.text:SetText(locale:GetString(label) or label)

    frame:SetScript("OnEnter", function()
            UI.SetColor(frame.text, "BUTTON_HOVER_TEXT")
            frame.backdrop:Show()
        end)
    frame:SetScript("OnLeave", function()
            UI.SetColor(frame.text, "BUTTON_TEXT")
            frame.backdrop:Hide()
        end)
    frame:SetScript("OnClick", function()
            parent:OnItemClicked(frame:GetID())
        end)
    frame.Layout = function(_, width)
            frame:SetWidth(width)
            frame:SetHeight(frame.text:GetHeight())
        end

    frame:Show()
    return frame, 150
end

function ContextMenu:OnLoad()
    self.items = {}
    self.handlers = {}
    self.maxWidth = 0

    self:OnBorderLoaded(nil, "DIALOG_BORDER_COLOR", "DIALOG_CONTENT_BACKGROUND_COLOR")
end

function ContextMenu:AddItem(text, handler)
    local item
    local width = 0

    if (text == "-") then
        item = createSeparator(self)
    else
        item, width = createItem(self, text)
        Addon:Debug("contextmenu", "Created item frame [%s]", width)
        if (not self.maxWidth or width > self.maxWidth) then
            self.maxWidth = width
        end

        if (type(handler) == "function") then
            local id = table.getn(self.handlers) + 1
            item:SetID(id)
            table.insert(self.handlers, handler)
        end
    end

    table.insert(self.items, item)
end

function ContextMenu:OnShow()
    Addon:Debug("contextmenu", "Showing context menu [width=%d]", self.maxWidth)
    self:SetWidth(math.max(self.maxWidth or 0, 150))
    Layouts.Stack(self, self.items, MENU_PADDING, ITEM_SPACING)
end

function ContextMenu:OnItemClicked(id)
    self:Hide()
    if (type(self.handlers[id]) == "function") then
        self.handlers[id]()
    end
end

function ContextMenu:OnEvent(event)
    if (event == "GLOBAL_MOUSE_DOWN") then
        if (not self:IsMouseOver()) then
            self:Hide()
        end
    end
end

function Addon.CommonUI.ShowContextMenu(frame, entries)
    local menu = CreateFrame("Frame", nil, UIParent)
    menu:SetFrameStrata("DIALOG")
    menu:SetToplevel(true)
    menu:Hide()
    menu:RegisterEvent("GLOBAL_MOUSE_DOWN")
    UI.Attach(menu, ContextMenu)

    for _, entry in ipairs(entries) do
        if (type(entry) == "string") then
            Addon:Debug("contextmenu", "Adding text only item '%s'", entry)
            menu:AddItem(entry)
        elseif (type(entry) == "table") then
            Addon:Debug("contextmenu", "Adding item '%s' [%s]", entry.text, entry.handler)
            menu:AddItem(entry.text, entry.handler)
        end
    end

    Addon:Debug("contextmenu", "Showing context menu for '%s' with %s items", frame:GetDebugName() or "<unamed>", table.getn(entries))
    menu:SetPoint("TOP", frame, "CENTER", 0, 0)
    menu:Show()
    menu:EnableMouse(true)
    menu:EnableKeyboard(true)
    menu:Raise()
end
