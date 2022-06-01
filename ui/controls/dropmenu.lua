local _, Addon = ...
local DropMenu = {}

--[[============================================================================
    | Called to load this control, initalize our state.
    ==========================================================================]]
function DropMenu:OnLoad()
    self.expanded = false

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
        if (self.items and not self.noAutoSelect) then            
            self:OnItemSelected(1)
        end
    end)

    self:SetScript("OnEnter", function()
        if (self.Current:IsTruncated()) then
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            GameTooltip:AddLine(self.Current:GetText(), self.Current:GetTextColor())
            GameTooltip:Show()
        end
    end)

    self:SetScript("OnLeave", function()
        if (GameTooltip:GetOwner() == self) then
            GameTooltip:Hide()
        end
    end)
end

--[[============================================================================
    | Calld the set the list of items in the list
    ==========================================================================]]
function DropMenu:SetItems(items)
    self.items = items or {}
    if (self.items[1] and not self.noAutoSelect) then
        self:OnItemSelected(1)
    end
end

--[[============================================================================
    | sets the text for the menu
    ==========================================================================]]
function DropMenu:SetText(text)
    self.Current:SetText(text or "")
end

--[[============================================================================
    | Called when an item is choosen from the menu
    ==========================================================================]]
function DropMenu:OnItemSelected(value, checked)
    if (self.selected ~= value and self.items) then
        local text = self.items[value]
        if (type(text) == "string") then
            self.Current:SetText(text)
        end
        Addon.Invoke(self, "OnSelection", value, checked)
    end

    if (not self.noCloseOnSelect) then
        if (self.expanded) then
            self.Expand:Show()
            self.Collapse:Hide()
            self.expanded = false
        end
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
    
    for value, item in pairs(items) do
        if (type(item) ~= "table") then
            UIDropDownMenu_AddButton({
                isNotRadio = true,
                notCheckable = true,
                text = item,
                minWidth = width,
                func = function()
                    owner:OnItemSelected(value)
                end
            }, level)
        else
            UIDropDownMenu_AddButton({
                isNotRadio = true,
                minWidth = width,
                text = item.Text,
                checked = item.Checked or false,
                keepShownOnClick = true,
                func = function(_, _, _, checked)
                    owner:OnItemSelected(value, checked)
                end
            }, level)
        end
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