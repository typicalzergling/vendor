local _, Addon = ...
local MarkdownFrame = {}
local Markdown = Mixin({}, Addon.CommonUI.List)
local FRAMES_KEY = {}
local Colors = Addon.CommonUI.Colors
local UI = Addon.CommonUI.UI
local Layouts = Addon.CommonUI.Layouts

local MARGINS = {
    header = { top = 4, bottom = 2 },
    list = { left = 16,  top = 4, bottom = 4 },
    paragraph = { left = 16, top = 4, bottom = 4 }
}

--[[ Iterate the lines provided string ]]
local function lines(str)
    local s = 1
    local e = string.len(str)

    return function()
        if (s >= e) then
            return nil
        end

        local i = str:find("\n", s)
        if not i then
            local t = s
            s = e + 1
            return str:sub(t)
        else
            if (i == s) then
                s = s + 1
                return ""
            end
            local t = s
            s = i + 1
            return str:sub(t, i - 1)
        end
    end
end

--[[ Process a paragraph ]]
local function paragraph(parent, line, nextLine)
    local paragraph

    while (line and string.len(line) ~= 0) do
        if (string.len(line) ~= 0) then
            if (paragraph) then
                paragraph = paragraph .. " " .. Addon.StringTrim(line)
            else
                paragraph = Addon.StringTrim(line)
            end
        end

        line = nextLine()       
        if (line) then
            line  = Addon.StringTrim(line)
        end
    end

    local frame = CreateFrame("Frame", nil, parent, "Markdown_Paragraph")
    frame.content:SetWordWrap(true)
    frame.content:SetText(paragraph or "")
    frame.content:SetTextColor(Colors.SECONDARY_TEXT:GetRGBA())
    
    return frame
end

--[[ Process a header line from the markdown ]]
local function header(parent, line, nextLine)
    local level = 0
    local s = 1

    while (line:sub(s, s) == "#") do
        s = s + 1
        level = level + 1
    end

    local frame = CreateFrame("Frame", nil, parent, "Markdown_Header_One")
    frame.content:SetText(Addon.StringTrim(line:sub(s)))
    frame.content:SetTextColor(Colors.TEXT:GetRGBA())
    
    return frame
end

local function isListChar(c)
    return (c == "*") or (c == "-")
end

--[[ Process a list markdown ]]
local function list(parent, line, nextLine)
    local frame = CreateFrame("Frame", nil, parent, "Markdown_List")

    local makeItem = function(text)
        local item = CreateFrame("Frame", nil, frame, "Markdown_ListItem")
        item.content:SetText(text)
        item:SetPoint("TOPLEFT")
        item:SetPoint("TOPRIGHT")
        UI.Attach(item, MarkdownFrame)
    end

    local itemText = ""
    while (line and string.len(line) ~= 0) do
        if isListChar(line:sub(1, 1)) then
            if (string.len(itemText) ~= 0) then
                makeItem(itemText)
            end

            itemText = Addon.StringTrim(line:sub(2))
        else
            itemText = (itemText .. " " .. Addon.StringTrim(line))
        end

        line = nextLine()
    end

    if (string.len(itemText) ~= 0) then
        makeItem(itemText)
    end

    return frame
end

--[[ When the size changes we want to recompute our height based on total height
     of each region. ]]
function MarkdownFrame:OnSizeChanged(width, height)
    self:Layout(width)
end

function MarkdownFrame:Layout(width, height)
    if (self.content) then
        self.content:SetHeight(0)
        self:SetHeight(self.content:GetHeight())
    elseif (type(self.contents) == "table") then
        width = width or self:GetWidth()        

        local padding = 0
        if (type(self.Padding) == "number") then
            padding = self.Padding
        end

        local spacing = 0
        if (type(self.Spacing) == "number") then
            spacing = self.Spacing
        end
    
        Layouts.Stack(self, self.contents, padding, spacing, width)
    else
        self:SetHeight(0)
    end

    Addon:Debug("layouts", "*MarkdownFrame* = %d x %s", width, self:GetHeight())
end

--[[ Handle load ]]
function Markdown:OnLoad()
    Addon.CommonUI.List.OnLoad(self)
    rawset(self, FRAMES_KEY, {})
end

--[[ Get the list of our models ]]
function Markdown:OnGetItems()
    return rawget(self, FRAMES_KEY)
end

--[[ Create an item ]]
function Markdown:OnCreateItem(model)
    return model
end

--[[ Set the markdown on the control ]]
function Markdown:SetMarkdown(markdown)
    local frames = Addon.CommonUI.CreateMarkdownFrames(self, markdown, function(type, frame)
            if (MARGINS[type]) then
                frame.margins = MARGINS[type]
            end
        end)
    rawset(self, FRAMES_KEY, frames)
    self:Rebuild()
end

function Addon.CommonUI.CreateMarkdownFrames(parent, markdown, callback)
    if (type(markdown) ~= "string") then
        error("Usage: CreateMarkdown( frame, string )")
    end
    
    local frames = {}
    local getLine = lines(markdown)
    local line = getLine()
    
    while (type(line) == "string") do
        local first = line:sub(1,1)
        local frame

        if first == "#" then
            frame = header(parent, line, getLine)
            if (type(callback) == "function") then
                callback("header", frame)
            end
        elseif (isListChar(first)) then
            frame = list(parent, line, getLine)
            if (type(callback) == "function") then
                callback("list", frame)
            end
        else
            line = Addon.StringTrim(line)
            if (string.len(line) ~= 0) then
                frame = paragraph(parent, line, getLine)
                if (type(callback) == "function") then
                    callback("paragraph", frame)
                end
            end
        end

        if (frame) then
            UI.Attach(frame, MarkdownFrame)
            table.insert(frames, frame)
        end

        line = getLine()
    end

    return frames
end

Addon.CommonUI.Markdown = Markdown