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

local ItemInfoItem = {
    OnModelChanged = function(self, model)
        local t = type(model.Value);
        local value = self.Value;
        self.Name:SetText(model.Name);

        if (model.Value == nil) then
            value:SetText("nil");
            value:SetTextColor(DISABLE_FONT_COLOR:GetRGB());
        elseif (t == "string") then
            value:SetFormattedText("\"%s\"", model.Value);
            value:SetTextColor(GREEN_FONT_COLOR:GetRGB());
        elseif (t == "boolean") then
            value:SetText(tostring(model.Value));
            value:SetTextColor(EPIC_PURPLE_COLOR:GetRGB());
        elseif (t == "number") then
            value:SetText(tostring(model.Value));
            value:SetTextColor(ORANGE_FONT_COLOR:GetRGB());
        else
            value:SetText(tostring(model.Value));
            value:SetTextColor(WHITE_TEXT_COLOR:GetRGB());
        end
    end
}

function ItemInfo:OnLoad()
    self.props = {};
    self:EnableMouse(true);
    self.dropHandler = function()
        self:Drop();
    end;

    self.View.GetItems = function()
        return self.props or  {};
    end;

    self.View.OnItemCreated = function(_, item)
        Mixin(item, ItemInfoItem);
        item:SetScript("OnMouseDown", self.dropHandler);
        item:SetScript("OnMouseUp", self.dropHandler);
    end;
end

function ItemInfo:Drop()
    local item = Addon.ItemList.GetCursorItem();
    if (not item or (type(item) ~= "table") or not item:IsBagAndSlot()) then
        return;
    end

    ClearCursor();
    local itemProps = Addon:GetItemProperties(item:GetBagAndSlot());
    local model = {}
    for name, value in pairs(itemProps) do 
        if (type(value) ~= "table") then
            if (name ~= "GUID") then
                table.insert(model, { Name=name, Value=value });
            end
        end
    end

    table.sort(model, 
        function (a, b)
            return a.Name < b.Name
        end);

    self.props = model;
    self.View:Update();
end

local LARGE_MARGIN = 12;
local SMALL_MARGIN = 6;
local OFFSET = 2;
local BIG_OFFSET = 12;
local EXT_FORMAT = "Source: %s";
local NOTES_HEADER_TEXT = "Notes:";
local EXAMPLES_HEADER_TEXT = "Examples:";
local EMPTY_FMT = [[There are no help entries which match "%s".]];

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

--[[===========================================================================
  |  Cretes the text for an extension (we need to set the color as well)
  ===========================================================================]]
function Help:CreateExtension(parent, ext)
    local frame = parent:CreateFontString(nil, "ARTWORK", "Vendor_Doc_Extension");
    frame:SetTextColor(HEIRLOOM_BLUE_COLOR.r, HEIRLOOM_BLUE_COLOR.g, HEIRLOOM_BLUE_COLOR.b);
    frame:SetFormattedText(EXT_FORMAT, ext.Name);
    return frame;
end


function Help:CreateSection(parent, width, offset, header, text)
    if (not text or (type(text) ~= "string") or (string.len(text) == 0)) then
        return 0;
    end

    local height = 0;
    local subheader = self:CreateSubHeaderText(parent, header);
    subheader:SetWidth(width);
    subheader:SetPoint("TOPLEFT", parent, "TOPLEFT", LARGE_MARGIN, -(offset + BIG_OFFSET));
    height = subheader:GetHeight() + BIG_OFFSET;

    local text = self:CreateBodyText(parent, text);
    text:SetPoint("TOPLEFT", parent, "TOPLEFT", LARGE_MARGIN + SMALL_MARGIN, -(offset + height + OFFSET));
    text:SetWidth(width - SMALL_MARGIN);
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
    local textWidth = self.FrameWidth - (2 * LARGE_MARGIN);

    frame:SetWidth(self.FrameWidth);
    local header = name;
    if (doc.IsFunction) then
        header = string.format("%s(%s)", name, doc.Args or "");
    end

    local headerFrame = self:CreateHeaderFrame(frame, header);
    height = height + headerFrame:GetHeight();

    -- If this is an extension, then we want to put that right under
    -- the header.
    if (doc.Extension) then
        local extFrame = self:CreateExtension(frame, doc.Extension);
        extFrame:SetWidth(textWidth);
        extFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", LARGE_MARGIN, -(height + OFFSET));
        height = height + extFrame:GetHeight() + OFFSET;
    end

    -- Every entry should either have text, or be text, however,
    -- if it doesn't then we simply skip it.
    local itemText;
    if (type(doc) == "string") then
        itemText = doc;
    elseif (doc.Text and (type(doc.Text) == "string") and (string.len(doc.Text) ~= 0)) then
        itemText = doc.Text;
    else
        itemText = "";
    end

    if (string.len(itemText) ~= 0) then
        local textFrame = self:CreateBodyText(frame, itemText);
        textFrame:SetWidth(textWidth);
        textFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", LARGE_MARGIN, -(height + BIG_OFFSET));	
        height = height + textFrame:GetHeight() + (2 * BIG_OFFSET);
    end

    -- Sections
    if (type(doc) == "table") then		
        height = height + self:CreateSection(frame, textWidth, height, NOTES_HEADER_TEXT, doc.Notes);
        height = height + self:CreateSection(frame, textWidth, height, EXAMPLES_HEADER_TEXT, doc.Examples);
    end

    frame:SetHeight(height + BIG_OFFSET);
    return frame;
end


--[[===========================================================================
  |  Creates the documentation cache, which consists of table which has
  |  a frame (Created on demand), the help object itself, and the name
  |  which are sorted by name.
  ===========================================================================]]
function Help:CreateCaches()
    local cache = {};

    for cat, section in pairs(Addon.ScriptReference) do
        for n, h in pairs(section) do
            table.insert(cache, {
                frame = nil,
                name = n,
                key = string.lower(n),
                help = h
            });
        end
    end

    if (Addon.Extensions) then
        for n, h in pairs(Addon.Extensions:GetFunctionDocs()) do
            table.insert(cache, {
                frame = nil,
                name = n,
                key = string.lower(n),
                help = h,
            })
        end
    end

    table.sort(cache,
        function(a, b)
            return (a.key < b.key);
        end)

    self.cache = cache;
end

 --[[===========================================================================
   |  Creates a sub heading for our documentation (e.g. "Notes:"
   ===========================================================================]]
function Help:ClearCaches()	
end

function Help:Filter()	
    local entries = {};
    local text = string.trim(self.FilterText:GetText() or  "");
    local filter = string.lower(text);
    self.FrameWidth = (self.View.Frame:GetScrollChild():GetWidth() - 2);

    for _, cache in ipairs(self.cache) do
        if ((not filter) or (string.len(filter) == 0) or string.find(cache.key, filter)) then
            table.insert(entries, cache);
        end

        if (cache.frame) then
            cache.frame:Hide();
        end
    end

    if (table.getn(entries) == 0) then
        self.View.Empty.Text:SetFormattedText(EMPTY_FMT, text or "");
        self.View.Empty:Show();
        self.View.Frame:Hide();
    else
        local frame = self.View.Frame:GetScrollChild();
        frame:SetWidth(self.FrameWidth);
        local prev = nil;
        local height = 0;

        for _, cache in ipairs(entries) do
            if (not cache.frame) then
                cache.frame = self:CreateDocFrame(frame, cache.name, cache.help);
            end

            cache.frame:Show();
            if (not prev) then
                cache.frame:SetPoint("TOPLEFT");
            else
                cache.frame:SetPoint("TOPLEFT", prev, "BOTTOMLEFT");
            end

            height = height + cache.frame:GetHeight();
            prev = cache.frame;
        end

        frame:SetHeight(height);
        self.View.Frame:Show();
        self.View.Empty:Hide();
    end
end

function Help:OnLoad()
    Mixin(self, Addon.Controls.AutoScrollbarMixin);
    self.HelpText:Hide();
    self:AdjustScrollBar(self.View.Frame, false);
end

function Help:OnShow()
    self:Filter();
    self.FilterText:RegisterCallback("OnChange", self.Filter, self);
end

function Help:OnHide()
    self.FilterText:UnregisterCallback("OnChange", self);
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
