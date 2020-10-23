local _, Addon = ...;
local ItemInfo = {};
local Help = {};
local Matches = {};

local function htmlEncode(str)
	return str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;");
end

local ITEM_INFO_HTML_BODY_FMT = "<html><body><h1>%s</h1>%s</body></html>";
local ITEM_HTML_FMT = "<p>%s == %s%s%s</p>";
local NIL_ITEM_STRING = GRAY_FONT_COLOR_CODE .. "nil" .. FONT_COLOR_CODE_CLOSE;
local MATCHES_HTML_START = "<html><body>";

function ItemInfo:OnLoad()
	print("ItemInfo onLoad");
	self:EnableMouse(true);
end

local function spairs(t, order)
    local keys = {};
    for key in pairs(t) do
        table.insert(keys, key);
    end
    table.sort(keys)

    local iter = 0
    return function()
        iter = iter + 1
        return keys[iter], t[keys[iter]];
    end
end


function ItemInfo:Drop()
    if (not CursorHasItem()) then
        return;
    end

    local _, _, link = GetCursorInfo();
    ClearCursor();

    local itemProps = Addon:GetItemProperties(GameTooltip, link);
    local props = {}
    if (itemProps) then
        for name, value in spairs(itemProps) do
            if ((type(name) == "string") and
                ((type(value) ~= "table") and (type(value) ~= "function"))) then
                local valStr = tostring(value);
                if (type(value) == "string") then
                    valStr = string.format("\"%s\"", value);
                else
                    if ((value == nil) or (valStr == "") or (string.len(valStr) == 0)) then
                        valStr = NIL_ITEM_STRING;
                    end
                end

                table.insert(props, string.format(ITEM_HTML_FMT, name, GREEN_FONT_COLOR_CODE, htmlEncode(valStr), FONT_COLOR_CODE_CLOSE));
            end
        end

        self.View:SetHtml(string.format(ITEM_INFO_HTML_BODY_FMT, link, table.concat(props)));
    end
end

local LARGE_MARGIN = 12;
local SMALL_MARGIN = 6;
local OFFSET = 2;
local BIG_OFFSET = 12;

--[[===========================================================================
  |  Create a simple header frame for our documentation.
  ===========================================================================]]
function Help:CreateHeaderFrame(parent, text)
	local frame = CreateFrame("Frame", nil, parent, "Vendor_Doc_Header");
	frame.Text:SetText(text);
	frame:SetWidth(self.FrameWidth);
	frame:SetPoint("TOPLEFT");
	return frame;
end

--[[===========================================================================
  |  Creates a block of body text for our documentation
  ===========================================================================]]
function Help:CreateBodyText(parent, text)
	local frame = parent:CreateFontString(nil, "ARTWORK", "Vendor_Doc_BodyText");
	frame:SetText(text);
	return frame;
end

--[[===========================================================================
  |  Creates a sub heading for our documentation (e.g. "Notes:"
  ===========================================================================]]
function Help:CreateSubHeaderText(parent, text)
	local frame = parent:CreateFontString(nil, "ARTWORK", "Vendor_Doc_SubHeader");
	frame:SetText(text);
	return frame;
end

function Help:CreateSection(parent, width, offset, header, text)
	if (not text or (type(text) ~= "string") or (string.len(text) == 0)) then
		return 0;
	end

	local height = 0;
	local subheader = self:CreateSubHeaderText(parent, header);
	subheader:SetWidth(width - (LARGE_MARGIN * 2));
	subheader:SetPoint("TOPLEFT", parent, "TOPLEFT", LARGE_MARGIN, -(offset + BIG_OFFSET));
	height = subheader:GetHeight() + BIG_OFFSET;

	local text = self:CreateBodyText(parent, text);
	text:SetPoint("TOPLEFT", parent, "TOPLEFT", 2 * LARGE_MARGIN, -(offset + height + OFFSET));
	text:SetWidth(width - (2 * LARGE_MARGIN + SMALL_MARGIN));
	height = height + text:GetHeight() + OFFSET;	

	return height;
end

--[[===========================================================================
  |  Creates a sub heading for our documentation (e.g. "Notes:"
  ===========================================================================]]
function Help:CreateDocFrame(parent, name, doc)
	local height = 0;
	local width = self.FrameWidth;
	local frame = CreateFrame("Frame", nil, parent);

	frame:SetWidth(self.FrameWidth);
	local header = name;
	if (doc.IsFunction) then
		header = string.format("%s(%s)", name, doc.Args or "");
	end

	local headerFrame = self:CreateHeaderFrame(frame, header);
	height = height + headerFrame:GetHeight();
	--width = headerFrame:GetWidth();

	-- Every entry should either have text, or be text, however,
	-- if it doesn't then we simply skip it.
	local itemText;
	if (type(doc) == "string") then
		itemText = doc;
		print("string doc", doc);
	elseif (doc.Text and (type(doc.Text) == "string") and (string.len(doc.Text) ~= 0)) then
		itemText = doc.Text;
	else
		itemText = "";
	end

	if (string.len(itemText) ~= 0) then
		local textFrame = self:CreateBodyText(frame, itemText);
		textFrame:SetWidth(width - LARGE_MARGIN);
		textFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", LARGE_MARGIN, -height);		
		height = height + textFrame:GetHeight();
	end

	-- Sections
	if (type(doc) == "table") then		
		height = height + self:CreateSection(frame, width, height, "Notes:", doc.Notes);
		height = height + self:CreateSection(frame, width, height, "Examples:", doc.Examples);
	end

	frame:SetHeight(height + BIG_OFFSET);
	return frame;
end
  

function Help:OnLoad()
	print("Help onLoad");
	self.HelpText:Hide();

	self.FrameWidth = self:GetWidth();

	local docs = {};
	local height = 0;

	local topFrame = CreateFrame("Frame", nil, self.View.Frame);
	local prevFrame = nil;
	topFrame:SetWidth(self.View.Frame:GetWidth());
	
	for cat, section in pairs(Addon.ScriptReference) do
		for name, content in pairs(section) do
			local frame = self:CreateDocFrame(topFrame, name, content);
			height = height + frame:GetHeight();

			if (prevFrame) then
				frame:SetPoint("TOPLEFT", prevFrame, "BOTTOMLEFT");
			else
				frame:SetPoint("TOPLEFT");
			end

			prevFrame = frame;
		end
	end

	topFrame:SetHeight(height);
	topFrame:Show();
	self.topFrame = topFrame;
	self.View.Frame:SetScrollChild(topFrame);
end

function Matches:OnLoad() 
	self.Matches:SetContents({});
end

function Matches:SetMatches(matches)
	self.Matches:SetContents(matches);
end

Addon.EditPanels = {
	ItemInfoPanel = ItemInfo,
	HelpPanel = Help,
	MatchesPanel = Matches,
};
