local _, Addon = ...
local locale = Addon:GetLocale()
local Dialogs = Addon.Features.Dialogs
local EditRule = {}

local BUTTONS = 
{
    save = {
        label = SAVE,
        handler = "SaveRule"
    },

    delete = {
        label = DELETE,
        hanlder = "DeleteRule"
    },

    cancel = {
        label = CANCEL,
        handler = "Toggle"
    }
}

local RuleType = Mixin({}, Addon.CommonUI.Mixins.Border)
local RULETYPE_BORDER = CreateColor(.5, .5, .5, .5)
local RULETYPE_BACK = CreateColor(0, 0, 0, 0)
local RULETYPE_HOVER_BORDER = CreateColor(0.8, 0.8, 0.8, .5)
local RULETYPE_HOVER_BACK = CreateColor(1, 1, 1, 0.1)
local RULETYPE_TEXT = CreateColor(1, 1, 1, 0.8)
local RULETYPE_SELECTED_TEXT = YELLOW_FONT_COLOR
local RULETYPE_SELECTED_BORDER = CreateColor(1, 1, 0, .45)
local RULETYPE_SELECTED_BACK = CreateColor(1, 1, 0, .05)

function RuleType:OnLoad()
    self:OnBorderLoaded(nil, RULETYPE_BORDER, RULETYPE_BACK)
    self.selected = false

    local label = locale[self.Label]
    self.label:SetText(label or self.Label or "")

    local help = locale[self.Help]
    self.help:SetText(help or self.Help or "")

    self.help:SetTextColor(RULETYPE_TEXT:GetRGBA())
    self.label:SetTextColor(RULETYPE_TEXT:GetRGBA())
end

function RuleType:OnEnter()
    if (not self.selected) then
        self:SetBorderColor(RULETYPE_HOVER_BORDER)
        self:SetBackgroundColor(RULETYPE_HOVER_BACK)
        self.label:SetTextColor(RULETYPE_SELECTED_TEXT:GetRGBA())
    end
end

function RuleType:OnLeave()
    if (not self.selected) then
        self:SetBorderColor(RULETYPE_BORDER)
        self:SetBackgroundColor(RULETYPE_BACK)
        self.label:SetTextColor(RULETYPE_TEXT:GetRGBA())
    end
end

function RuleType:SetSelected(selected)
    self.selected = selected or false
    if (selected) then
        self.label:SetTextColor(RULETYPE_SELECTED_TEXT:GetRGBA())
        self:SetBorderColor(RULETYPE_SELECTED_BORDER)
        self:SetBackgroundColor(RULETYPE_SELECTED_BACK)
    else
        self.label:SetTextColor(RULETYPE_TEXT:GetRGBA())
        self:SetBorderColor(RULETYPE_BORDER)
        self:SetBackgroundColor(RULETYPE_BACK)
    end
end

local HELP_FUNCTION_BACK = CreateColor(0, .5, .5, .125)
local HELP_PROPERTY_BACK = CreateColor(.5, .5, 0, .125)
local HELP_HEADER = YELLOW_FONT_COLOR
local HELP_BODY = CreateColor(1, 1, 1, .8)
local NO_MARGIN = {}
local INDENT = { left = 10 }

local HelpItem = {
    OnLoad = function()
    end,

    OnModelChange = function(item, model)
        local contents = item.contents
        item.title:SetTextColor(HELP_HEADER:GetRGBA())

        if (model.IsFunction) then
            item.headerBackground:SetColorTexture(HELP_FUNCTION_BACK:GetRGBA())
            item.title:SetFormattedText("%s(%s)", model.Name, model.Args or "")
        else
            item.headerBackground:SetColorTexture(HELP_PROPERTY_BACK:GetRGBA())
            item.title:SetText(model.Name)
        end

        if (type(model.Text) == "string") then
            item:CreateContent("body", model.Text)
        end

        if (type(model.Map) == "table") then
            item:CreateContent("subheader", locale["RULEHELP_MAP"])

            local values = {}
            for name in pairs(model.Map) do
                table.insert(values, name)
            end

            local content = item:CreateContent("body", table.concat(values, ", "))
            content.margins = INDENT
        end
    
        if (type(model.Examples) == "string") then
            item:CreateContent("subheader", locale["RULEHELP_EXAMPLES"])
            local content = item:CreateContent("body", model.Examples)
            content.margins = INDENT
        end
    
        -- If we have an extension, then add a line for it.
        if (model.Extension) then
            local child = contents:CreateFontString(nil, "ARTWORK", "Vendor_Doc_Extension")
            item:CreateContent("extension", string.format(locale["RULEHELP_SOURCE"], model.Extension.Name))
        end
    
    end,

    --[[
        Called whe our size changed, when our width is set we re-compute our height 
        and set it the computed value
    ]]
    OnSizeChanged = function(item, width, height)
        local contents = item.contents;
        local cx = contents:GetWidth()
        local top = 0

        for _, child in pairs({ contents:GetRegions() }) do
            local margins = child.margins or NO_MARGIN

            child:ClearAllPoints()
            child:SetWidth(cx - (margins.left or 0) - (margins.right or 0))
            top = top + (margins.top or 0)
            child:SetPoint("TOPLEFT", contents, "TOPLEFT", (margins.left or 0), -top)
            top = top + child:GetHeight() + (margins.bottom or 0)
        end

        item:SetHeight(item.baseHeight + top)
    end,

    --[[
        Creates content for the item
    ]]
    CreateContent = function(item, type, text)
        local inherits = "GameFontNormal"
        local margins = nil
        local color = HELP_BODY
        local wordwrap = true

        if (type == "body") then
            margins = { top = 4, bottom = 4 }
        elseif (type == "subheader") then
            margins = { top = 10, bottom = 4 }
            color = YELLOW_FONT_COLOR
            wordwrap = false
        elseif (type == "externsion") then
            inherits = "GameFontNormalSmall"
            color = HEIRLOOM_BLUE_COLOR
            wordwrap = false
        end

        local content = item.contents:CreateFontString("ARTWORK", nil, inherits)
        content.margins = margins
        content:SetText(text)
        content:SetTextColor(color:GetRGBA())
        content:SetWordWrap(wordwrap)
        content:SetJustifyH("LEFT")
        content:SetJustifyV("TOP")

        return content
    end,
}

local HelpTab = {
    OnLoad = function(t)
        t.items.ItemClass = HelpItem
        t.items:Sort(function (modelA, modelB)
            return (modelA.Name < modelB.Name)
        end)
    end,

    CreateHelpItem = function(self)
        local frame = CreateFrame("Frame", nil, self, "Vendor_EditRule_HelpItem")
        Addon.AttachImplementation(frame, HelpItem, true)
        return frame
    end,

    GetHelpItems = function()
        local models = {}

        for _, section in pairs(Addon.ScriptReference) do
            for name, help in pairs(section) do
                local model = { Name = name, filter = string.lower(name) }
                if (type(help) == "table") then
                    for key, value in pairs(help) do
                        model[key] = value
                    end
                elseif (type(help) == "string") then
                    model.Text = help
                else
                    error("Unknown model type: " .. type(help))
                end

                table.insert(models, model)
            end
        end

        return models
    end,

    FilterHelp = function(helptab, text)
        if (not text or string.len(text) == 0) then
            helptab.items:Filter(nil)
        else
            text = string.lower(text)
            helptab.items:Filter(function(model)
                return string.find(model.filter, text) ~= nil
            end)
        end
    end
}

function RuleType:IsSelected()
    return (self.selected == true)
end

function EditRule:OnInitDialog(dialog)
    dialog:SetButtons(BUTTONS)
    dialog:SetCaption("EDITRULE_CAPTION")

    Addon.AttachImplementation(self.ruleStatus, Dialogs.RuleStatus)

    for _, type in ipairs(self.ruleType) do
        Addon.AttachImplementation(type, RuleType, true)
        type:SetScript("OnClick", function(ruleType)
            self:SetRuleType(ruleType.Type)
        end)
    end

    local tabs = self.tabs
    tabs:AddTab("matches", "matches", "Vendor_EditRule_Matches")
    tabs:AddTab("iteminfo", "iteminfo", "Vendor_EditRule_ItemInfo")
    tabs:AddTab("help", "help", "Vendor_EditRule_Help", HelpTab)

    self:SetRuleType("SELL")
    tabs:ShowTab("help")
    self.ruleStatus:SetStatus("unhealthy")

    dialog:SetButtonEnabled("save", false)
end

function EditRule:OnScriptChanged(text)
end

function EditRule:OnNameChanged(text)
end

function EditRule:OnDescriptionChanged(text)
end

function EditRule:SetRuleType(type)
    local uctype = string.upper(type or "")
    for _, ruleType in ipairs(self.ruleType) do
            ruleType:SetSelected(ruleType.Type == type)
    end
end

function EditRule:GetRuleType()
    for _, ruleType in ipairs(self.ruleType) do
        if (ruleType:IsSelected()) then
            return ruleType.Type
        end
    end

    return "SELL"
end

Dialogs.EditRule = EditRule