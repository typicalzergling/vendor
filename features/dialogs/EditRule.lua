local _, Addon = ...
local locale = Addon:GetLocale()
local Dialogs = Addon.Features.Dialogs
local EditRule = Mixin({}, Addon.CommonUI.Mixins.Debounce)
local RuleType = Addon.RuleType.SELL

local BUTTONS = {
    cancel = { label = CANCEL, handler = "Toggle"  },
    save = { label = SAVE, handler = "SaveRule" },
    delete = { label = DELETE, handler = "DeleteRule" },
    close = { label = CLOSE, handler = "Toggle" }
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

--[[
    Checks if the specified  rule is read-only (will diable the dialog)
]]
local function _isReadOnlyRule(rule)
end

--[[
    Initialize the edit rule dialog
]]
function EditRule:OnInitDialog(dialog)
    local feature = self:GetFeature()
    local tabs = self.tabs

    dialog:SetButtons(BUTTONS)
    dialog:SetCaption("EDITRULE_CAPTION")
    Addon.AttachImplementation(self.ruleStatus, Dialogs.RuleStatus)

    for _, type in ipairs(self.ruleType) do
        Addon.AttachImplementation(type, RuleType, true)
        type:SetScript("OnClick", function(ruleType)
            self:SetRuleType(ruleType.Type)
        end)
    end

    self.help = tabs:AddTab("help", "help", "Vendor_EditRule_Help", HelpTab)
    self.matches = tabs:AddTab("matches", "matches", "Vendor_EditRule_Matches", self.MatchesTab)
    self.items = tabs:AddTab("iteminfo", "iteminfo", "Vendor_EditRule_ItemInfo", self.ItemInfoTab)
    self.items:RegisterCallback("INSERT_TEXT", self.InsertText, self)

    self:SetRuleType("SELL")
    tabs:ShowTab("help")
    self.ruleStatus:SetStatus("unhealthy")
end

--[[
    Invoked when something wants to insert text into the script control
]]
function EditRule:InsertText(_, text)
    local script = self.script

    if (script:IsEnabled()) then
        if script:HasText() then
            if (string.find(text, "[\t ]")) then
                script:Insert(" (" .. text .. ") ")
            else
                script:Insert(" " .. text)
            end
        else
            script:SetText(text)
        end
        script:SetFocus()
    end
end

function EditRule:UpdateMatches()
    local rules = self:GetDependency("rules")
    local matches

    if (self.readonly) then
        assert(self.rule, "Expected a valid rule definition")
        local params

        if (type(self.rule.Params) == "table") then
            params = {}
            for _, param in ipairs(self.rule.Params) do
                local default = param.Default
                if (type(default) == "function") then
                    default = default()
                end

                params[param.Key] = default
            end
        end

        matches = rules:GetMatches(self.rule.Script, params)
    elseif (self.changes.scriptValid) then
        local params
        if (type(self.rule) == "table") then
            params = self.rule.Params
        end
        local matches = rules:GetMatches(self.changes.script, params)
    end

    if (matches) then
        self.matches:Call("SetMatches", matches)
    else
        self.matches:Call("ClearMatches", matches)
    end
end

--[[
    Called when the script changes
]]
function EditRule:OnScriptChanged(text)
    local rules = self:GetDependency("Rules")

    if (not self.readonly) then
        local errorMessage = nil
        local scriptValid = false

        if (text and string.len(text) ~= 0) then
            local valid, msg = rules:ValidateRule(text)
            self:Debug("Validate script '%s' [%s, %s]", text, valid, msg or "")

            if (valid) then
                scriptValid = true
                self.changes.scriptValid = true
                self.changes.script = text
                self.ruleStatus:SetStatus("ok")
            else
                print(string.match(msg, "(%[.*%]:%d:)(.*)"))
                local _, err = string.match(msg, "(%[.*%]:%d:)(.*)")
                if (err) then
                    errorMessage = string.trim(err)
                else
                    errorMessage = string.trim(msg)
                end
            end
        end

        if (not scriptValid) then
            if (not errorMessage) then
                self.ruleStatus:Clear()
            else
                self.ruleStatus:SetStatus("invalid", errorMessage)
            end
    
            self.changes.scriptValid = false
        end
    end

    self:Debounce(.75, function() 
        self:UpdateMatches() 
    end)

    self:UpdateButtons()
end

--[[
    Called when the name changes
]]
function EditRule:OnNameChanged(text)
    self.changes.name = text
    self:UpdateButtons()
end

--[[
    Called when the description changes
]]
function EditRule:OnDescriptionChanged(text)
    self.changes.description = text
end

--[[
    Set the rule type
]]
function EditRule:SetRuleType(type)
    local uctype = string.upper(type or "")
    for _, ruleType in ipairs(self.ruleType) do
            ruleType:SetSelected(ruleType.Type == uctype)
    end
    
    if (self.changes) then
        self.changes.type = uctype
    end
end

--[[
    Determines the current rule type
]]
function EditRule:GetRuleType()
    for _, ruleType in ipairs(self.ruleType) do
        if (ruleType:IsSelected()) then
            return ruleType.Type
        end
    end

    return "SELL"
end

--[[
    Checks if the specified string is both a valid string, and also no empty
]]
local function validateString(str)    
    if (type(str) == "string") then
        str = string.trim(str)
        return string.len(str) ~= 0
    end

    return false;
end

--[[
    Determine if the current rule is read-only
]]
function EditRule:InViewMode()
    local rule = self.rule
    return (type(rule) == "table") and (rule.IsSystem or rule.IsExtension)
end

--[[
    Determines if this is a new rule (or an existing rule)
]]
function EditRule:IsNewRule()
    local changes = self.changes or {}
    return (changes.newRule == true)
end

--[[
    Update the button state in the dialog
]]
function EditRule:UpdateButtons()
    local buttons = {}
    local changes = self.changes or {}

    -- If hte dialog is in "view" mode then only meaningful button to have
    -- enabled is close.
    if (self:InViewMode()) then
        buttons.close = true
    else
        buttons.close = false
        buttons.delete = self:IsNewRule()
        buttons.cancel = true  
        buttons.save = { show = true, enabled = true }

        if not validateString(changes.name) then
            self:Debug("Cannot save rule because name is invalid")
            buttons.save.enabled = false
        end

        if not validateString(changes.script) or not changes.scriptValid then
            self:Debug("cannot save rule because script is invalid")
            buttons.save.enabled = false
        end
    end

    self:GetDialog():SetButtonState(buttons)
end

--[[
    Sets the rule we are viewing or editing this requries a valid rule
]]
function EditRule:SetRule(rule)
    assert(type(rule) == "table", "Expected the rule definition to be a table")

    local dialog = self:GetDialog()
    self.changes = {}
    
    self.rule = rule;
    self:SetRuleType(rule.Type or "sell")
    self.description:SetText(rule.Description or "")
    self.name:SetText(rule.Name or "")
    local script = rule.Script
    if (type(script) ~= "string") then
        script = rule.ScriptText
    end
    self.script:SetText(script or "")

    if (self:InViewMode()) then
        self.readonly = true
        dialog:SetCaption("VIEWRULE_CAPTION")

        self.script:Disable()
        self.name:Disable()
        self.description:Disable()
    else
        dialog:SetCaption("EDITRULE_CAPTION")

        self.script:Enable()
        self.name:Enable()
        self.description:Enable()
    end

    self:UpdateButtons()
end

--[[
    Sets the dialog to create a new rule
]]
function EditRule:NewRule()
    local dialog = self:GetDialog()
    self.changes = { newRule = true }

    dialog:SetCaption("EDITRULE_CAPTION")
    self:SetRuleType("sell")

    self.script:Enable()
    self.script:SetText("")

    self.name:Enable()
    self.name:SetText("")

    self.description:Enable()
    self.description:SetText("")

    self.ruleStatus:Clear()
    self:UpdateButtons()
end

function EditRule:SaveRule()
    local rule = {}
    local changes = self.changes or {}
    local rules = self:GetDependency("Rules")

    -- If we have a rule, then copy it into the rule
    if (type(self.rule) == "table") then
        for k, v in pairs(self.rule) do
            rule[k] = value
        end
    end

    -- Assign the type
    local type = self:GetRuleType()
    if type == "SELL" then
        rule.Type = RuleType.SELL
    elseif (type == "KEEP") then
        rule.Type = RuleType.KEEP
    elseif (type == "DESTROY") then
        rule.Type = RuleType.DESTROY
    end

    -- Merge in our changes
    rule.Name = changes.name or rule.Name
    rule.Description = changes.description or rule.Description
    rule.Script = changes.script or rule.Script

    -- Save the rule
    rules:SaveRule(rule)
end

Dialogs.EditRule = EditRule