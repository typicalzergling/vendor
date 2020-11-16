local _, Addon = ...;
local ItemInfo = {};
local Help = {};
local Matches = {};
local ItemInfoItem = {}

local function htmlEncode(str)
    return str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;");
end

local NIL_ITEM_STRING = GRAY_FONT_COLOR_CODE .. "nil" .. FONT_COLOR_CODE_CLOSE;
local MATCHES_HTML_START = "<html><body>";



function Matches:OnLoad() 
    self.Matches:SetContents({});
end

function Matches:SetMatches(matches)
    self.Matches:SetContents(matches);
end

Addon.EditPanels = {
    HelpPanel = Help,
    MatchesPanel = Matches,
};
