local _, Addon = ...
local locale = Addon:GetLocale()
local MatchItem = {}
local MatchesTab = {}

--[[
    Called when the matches 
]]
function MatchItem:OnModelChange(model)
end

--[===========================================================================]

function MatchesTab:OnLoad()
end

function MatchesTab:SetMatches(matches)
    self.matchItems = matches or {}
    self.matches:Rebuild()
end

Addon.Features.Dialogs.EditRule.MatchesTab = MatchesTab