local _, Addon = ...
local MatchItem = Mixin({}, ItemMixin)
local MatchesTab = {}
local Dialog = Addon.CommonUI.Dialog
local EditRuleEvents = Addon.Features.Dialogs.EditRuleEvents
local UI = Addon.CommonUI.UI
local Colors = Addon.CommonUI.Colors

--[[
    Called when the matches 
]]
function MatchItem:OnModelChange(model)
    self:SetItemLocation(model)
    self.name:SetText(nil)
    self:ContinueOnItemLoad(function()
            self.name:SetText(self:GetItemName())
            local color = self:GetItemQualityColor() or GRAY_FONT_COLOR
            self.name:SetTextColor(color.r, color.g, color.b, color.a or 1)
        end)
end

--[[
    Called when the mouse enters this item
]]
function MatchItem:OnEnter()
    self.hilite:Show()
    if (not self:IsItemEmpty()) then        
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 16, -4)
        if (self:HasItemLocation()) then
            local location = self:GetItemLocation()
            assert(location:IsBagAndSlot())
            GameTooltip:SetBagItem(location:GetBagAndSlot())
        else
            GameTooltip:SetHyperlink(self:GetItemLink())
        end

        GameTooltip:Show()
    end
end

--[[
    Called when the mouse leaves this item
]]
function MatchItem:OnLeave()
    self.hilite:Hide()
    if (GameTooltip:GetOwner() == self and GameTooltip:IsShown()) then
        GameTooltip:Hide()
    end
end

--[===========================================================================]

--[[
    Called when the matches tab is loaded
]]
function MatchesTab:OnLoad()
    Dialog.RegisterCallback(self, EditRuleEvents.CLEAR_MATCHES, self.ClearMatches)
    Dialog.RegisterCallback(self, EditRuleEvents.SHOW_MATCHES, self.ShowMatches)
end

--[[
    Called when the list wants the match items
]]
function MatchesTab:GetMatches()
    return self.matchItems
end

local function formatValue(value)
    if (type(value) == "boolean") then
        return Colors.EPIC_PURPLE_COLOR:WrapTextInColorCode(tostring(value))
    elseif (type(value) == "number") then
        return Colors.LEGENDARY_ORANGE_COLOR:WrapTextInColorCode(tostring(value))
    elseif (type(value) == "string") then
        return Colors.GREEN_FONT_COLOR:WrapTextInColorCode("\"" .. value .. "\"")
    end

    return value
end

--[[ Remove the parameter items from thew view ]]
function MatchesTab:ClearParameters()
    if (self.params) then
        for _, frame in ipairs(self.params) do
            frame:ClearAllPoints()
            frame:Hide()
        end
        self.params = nil
    end

    self.parameters:SetHeight(2)
    self.parameters:Hide()
end

--[[ Add p arameter items if needed ]]
function MatchesTab:BuildMatchParameters(parameters)
    self:ClearParameters()
    
    -- If there are no parameters we are done
    if (type(parameters) ~= "table" or table.getn(parameters) == 0) then
        return
    end

    self.params = {}
    for _, param in ipairs(parameters) do
        Addon:Debug("editrule", "Add parameter :: %s = %s", param.Name, param.Value)
        local frame = CreateFrame("Frame", nil, self.parameters, "EditRule_MatchParameter")
        frame.value:SetText(formatValue(param.Value))
        frame.name:SetText(param.Key)
        frame.Layout = function(_, width)
            frame:SetWidth(width)
            frame:SetHeight(math.max(frame.name:GetHeight(), frame.value:GetHeight()))
        end
        UI.Prepare(frame)
        frame:Show()
        table.insert(self.params, frame)
    end

    local padding = { left = 12, right = 12, bottom = 12 }
    Addon:Debug("editrule", "Layout parameters (%s)", table.getn(self.params))
    self.parameters:Show()
    Addon.CommonUI.Layouts.Stack(self.parameters, self.params, padding, 0)
end

--[[
    Called to set the matches we should show    
]]
function MatchesTab:ShowMatches(matches, parameters)
    Addon:Debug("editrule", "Show matches")

    self.matchItems = matches or {}
    self.matches:Rebuild()
    self:BuildMatchParameters(parameters)
end

function MatchesTab:ClearMatches()
    Addon:Debug("editrule", "Clear matches")
    self:ClearParameters()
    self.matchItems = nil
    self.matches:Rebuild()
end

Addon.Features.Dialogs.MatchesTab = MatchesTab
Addon.Features.Dialogs.MatchItem = MatchItem