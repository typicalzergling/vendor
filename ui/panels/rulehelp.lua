local _, Addon = ...
local L = Addon:GetLocale()
local RuleHelp = {}
local RuleDocumentation = {}
local SPACE_X = 10
local FRAME_KEY = {}
local SOURCE = L.RULEHELP_SOURCE
local NOTES = L.RULEHELP_NOTES
local POSSIBLE_VALUES = L.RULEHELP_MAP
local EXAMPLES = L.RULEHELP_EXAMPLES

--[[===========================================================================
   |  Called when the model changes for this frame.
   ===========================================================================]]
function RuleDocumentation:OnModelChanged(model)
    if (model.IsFunction) then
        self.Background:Hide()
        self.FunctionBackground:Show()
        self.Name:SetFormattedText("%s(%s)", model.Name, model.Args or "")
        self.Name:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())
    else
        self.Background:Show()
        self.FunctionBackground:Hide()
        self.Name:SetText(model.Name)
        self.Name:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())
    end

    local contents = self.Contents;

    -- If we have documentation then we want to add a line for it.
    if (type(model.Text) == "string") then
        local child = contents:CreateFontString(nil, "ARTWORK", "Vendor_Doc_BodyText")
        child:SetText(model.Text)
        child:SetWordWrap(true)
        self.needsLayout = true
    end

    -- If we have notes, then add the notes frame
    if (type(model.Notes) == "string") then
        local header = contents:CreateFontString(nil, "ARTWORK", "Vendor_Doc_SubHeader")
        header.noMargin = true
        header:SetText(NOTES)

        local text = contents:CreateFontString(nil, "ARTWORK", "Vendor_Doc_BodyText")
        text:SetText(model.Notes)
        text:SetWordWrap(true)
    end

    if (type(model.Map) == "table") then
        local header = contents:CreateFontString(nil, "ARTWORK", "Vendor_Doc_SubHeader")
        header.noMargin = true
        header:SetText(POSSIBLE_VALUES)

        local values = {}
        for name in pairs(model.Map) do
            table.insert(values, name)
        end

        local text = contents:CreateFontString(nil, "ARTWORK", "Vendor_Doc_BodyText")
        text:SetText(table.concat(values, ", "))
        text:SetWordWrap(true)
    end

    if (type(model.Examples) == "string") then
        local header = contents:CreateFontString(nil, "ARTWORK", "Vendor_Doc_SubHeader")
        header.noMargin = true
        header:SetText(EXAMPLES)

        local text = contents:CreateFontString(nil, "ARTWORK", "Vendor_Doc_BodyText")
        text:SetText(model.Examples)
        text:SetWordWrap(true)
    end

    -- If we have an extension, then add a line for it.
    if (model.Extension) then
        local child = contents:CreateFontString(nil, "ARTWORK", "Vendor_Doc_Extension")
        child:SetTextColor(HEIRLOOM_BLUE_COLOR:GetRGB())
        child:SetFormattedText(SOURCE, model.Extension.Name)
    end

end

--[[===========================================================================
   | Called when this frame needs to be updated. This makes sure we know
   | the width before we lay it  out.
   ===========================================================================]]
function RuleDocumentation:OnUpdate()
    if (self.needsLayout) then
        self.needsLayout = false

        local top = SPACE_X
        local contents = self.Contents;
        local width = contents:GetWidth()
        for _, child in pairs({ contents:GetRegions() }) do
            child:ClearAllPoints()
            child:SetWidth(width)
            child:SetPoint("TOPLEFT", contents, "TOPLEFT", 0, -top)
            top = top + child:GetHeight()
            if (not child.noMargin) then
                top = top + SPACE_X
            else
                top = top + 2
            end
        end

        if (top ~= SPACE_X) then
            contents:SetHeight(top)
            self:SetHeight(self.Background:GetHeight() + (top))
        else
            contents:SetHeight(0)
            self:SetHeight(self.Background:GetHeight())
        end
    end
end

-- Local helper function to create a model item
local function CreateModel(name, help)
    local model = { Name = name, Frame = false }
    if (type(help) == "table") then
        model = Addon.TableMerge(model, help)
    elseif (type(help) == "string") then
        model.Text = help
    else
        error(string.format("Unknown documentation type '%s'", type(help)))
    end

    return model
end

-- Helper to ensure we've got a model
local function EnsureModel(current, models, name, help)
    local key = string.lower(name)
    local existing = current[key];
    if (not existing) then
        models[key] = CreateModel(name, help)
    else
        models[key] = existing
    end
end

--[[===========================================================================
   | Creates all the models for our rule documentatino and addons
   ===========================================================================]]
function RuleHelp:CreateModels()
    local current = self.models or {}
    local models = {}

    self.models = self.models or {}
    if (Addon.Extensions) then
        for name, help in pairs(Addon.Extensions:GetFunctionDocs()) do
            EnsureModel(current, models, name, help)
        end
    end

    for cat, section in pairs(Addon.ScriptReference) do
        for name, help in pairs(section) do
            EnsureModel(current, models, name, help)
        end
    end

    self.models = models
    self.items = nil
end


--[[===========================================================================
   |  Crates a fitlered list of models
   ===========================================================================]]
function RuleHelp:CreateItems(filter)
    if (type(filter) == "string") then
        filter = Addon.StringTrim(filter)
        if (string.len(filter) == 0) then
            filter = nil
        else
            filter = string.lower(filter)
        end
    end

    local items = {}
    for key, model in pairs(self.models) do
        if (not filter or key:find(filter)) then
            table.insert(items, model)
        end
    end

    table.sort(items, function(a, b)
            return (a.Name < b.Name)
        end)

    self.items = items
end

--[[===========================================================================
   |  Filters our list of models, creating a new item list
   ===========================================================================]]
function RuleHelp:Filter()	
    if (not self.ignoreUpdate) then
        self.ignoreUpdate = false
        local text = Addon.StringTrim(self.FilterText:GetText() or  "");
        self:CreateItems(text);
        self.View:Update()
    end
end

--[[===========================================================================
   |  Called when the panel is loaded.
   ===========================================================================]]
function RuleHelp:OnLoad()
    self.View.ItemTemplate = "Vendor_RuleDoc_Root"
    self.View.ItemClass = RuleDocumentation
    self.View.FrameType = "Frame"
    self.View:SetEmptyText(L.RULEHELP_NO_MATCHES)
    Addon:GetExtensionManger():RegisterCallback("OnFunctionsChanged", 
        function()
            self:CreateModels()
            if (self:IsVisible()) then
                self.View:Update()
            end
        end, self)

    self.View.GetItems = function()
        if (not self.models) then
            self:CreateModels()
        end
        if (not self.items) then
            self:CreateItems()
        end
        return self.items
    end

    self.View.GetItemForModel = function(list, model)
        local frame = rawget(model, FRAME_KEY)
        if (not frame) then
            frame = list:CreateItem()
            frame:SetModel(model)
            rawset(model, FRAME_KEY, frame)
        end
        return frame
    end

    self:SetScript("OnShow", self.OnShow)
    self:SetScript("OnHide", self.OnHide)
    self.View:Update()
end

--[[===========================================================================
   |  Called whenthe rule help panel is shown
   ===========================================================================]]
function RuleHelp:OnShow()
    self.FilterText:RegisterCallback("OnChange", self.Filter, self);
    self:CreateModels()
end

--[[===========================================================================
   |  Called when the rule help panel is hidden
   ===========================================================================]]
function RuleHelp:OnHide()
    self.FilterText:UnregisterCallback("OnChange", self);
end

--[[===========================================================================
   |  Display a particular item, basically pre-can the filter
   ===========================================================================]]
function RuleHelp:DisplayHelp(filter)
    if (type(filter) ~= "string") then
        filter = ""
    end

    self.FilterText:SetText(filter)
    self:Filter()
end

--[[===========================================================================
   | Display a partical help topic (must match)
   ===========================================================================]]
function RuleHelp:DisplayKeyword(keyword)
    if (not self.models) then
        self:CreateModels()
    end 

    local items = {}
    local model = self.models[string.lower(keyword)]
    if (model) then
        table.insert(items, model)
    end

    self.ignoreUpdate = true
    self.FilterText:SetText(keyword)
    self.items = items
    self.View:Update()
    
end

Addon.Panels = Addon.Panels or {}
Addon.Panels.RuleHelp = RuleHelp