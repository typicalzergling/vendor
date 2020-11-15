local _, Addon = ...
local DropMenu = {}

--[[============================================================================
    | Called to load this control, initalize our state.
    ==========================================================================]]
function DropMenu:OnLoad()
    self.expanded = false
    self:OnBackdropLoaded()
    self:SetScript("OnMouseDown", function(_, button)
        if (not self.expanded) then
            self.expanded = true
            self:OnExpand()
        else
            self.expanded = false
            self:OnCollapse()
        end
    end)
    self:SetScript("OnShow", function()
        if (self.items) then
            self:OnItemSelected(1)
        end
    end)
end

--[[============================================================================
    | Calld the set the list of items in the list
    ==========================================================================]]
function DropMenu:SetItems(items)
    assert(table.getn(items) >= 1, "There are no items in the drop-list")
    self.items = items or {}
    self:OnItemSelected(1)
end

--[[============================================================================
    | Called when an item is choosen from the menu
    ==========================================================================]]
function DropMenu:OnItemSelected(value)
    if (self.selected ~= value and self.items) then
        local text = self.items[value]
        self.Current:SetText(text)
        Addon.invoke(self, "OnSelection", value)
    end

    if (self.expanded) then
        self.Expand:Show()
        self.Collapse:Hide()
        self.expanded = false
    end
end

--[[============================================================================
    | Initialize the drop menu from our items
    ==========================================================================]]
local function initalizeMenu(owner, width, frame, level, items)
    assert(level == 1)
    if (not items) then
        return
    end
    
    for value, text in pairs(items) do
        UIDropDownMenu_AddButton({
            isNotRadio = true,
            notCheckable = true,
            text = text,
            minWidth = width,
            func = function()
                owner:OnItemSelected(value)
            end
        }, level)
    end
end

--[[============================================================================
    | Called to expand the menu
    ==========================================================================]]
function DropMenu:OnExpand()
    if (not self.menu) then
        self.menu = CreateFrame("Frame", "xxx", UIParent, "UIDropDownMenuTemplate")
        UIDropDownMenu_Initialize(self.menu, function(...) initalizeMenu(self, self.Current:GetWidth(), ...) end, "MENU", 1, {})
        UIDropDownMenu_SetAnchor(self.menu, 0, -1, "TOPLEFT", self, "BOTTOMLEFT")
	end
	
    ToggleDropDownMenu(1, nil, self.menu, nil, 0, 0, self.items)
    self.Expand:Hide()
    self.Collapse:Show()
end

--[[============================================================================
    | Called to collapse the menu
    ==========================================================================]]
function DropMenu:OnCollapse()
    if (self.menu) then
        ToggleDropDownMenu(1, nil, self.menu)
    end
    self.Expand:Show()
    self.Collapse:Hide()
end

Addon.Controls = Addon.Controls or {}
Addon.Controls.DropMenu = DropMenu