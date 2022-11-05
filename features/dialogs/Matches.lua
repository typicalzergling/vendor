local _, Addon = ...
local MatchItem = Mixin({}, ItemMixin)
local MatchesTab = {}
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
    self.label:SetTextColor(Colors.SECONDARY_TEXT:GetRGBA())
end

--[[
    Called to create the item for a match in the UX
]]
function MatchesTab:CreateMatchItem()
    return Mixin(CreateFrame("Frame", nil, self, "Vendor_EditRule_MatchItem"), MatchItem)
end

--[[
    Called when the list wants the match items
]]
function MatchesTab:GetMatches()
    return self.matchItems
end

--[[
    Called to set the matches we should show    
]]
function MatchesTab:SetMatches(matches)
    self.matchItems = matches or {}
    self.matches:Rebuild()
end

function MatchesTab:ClearMatches()
    self.matchItems = nil
    self.matches:Rebuild()
end

Addon.Features.Dialogs.EditRule.MatchesTab = MatchesTab