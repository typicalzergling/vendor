local _, Addon = ...
local locale = Addon:GetLocale()
local Dialogs = Addon.Features.Dialogs
local EditRule = Mixin({}, Addon.CommonUI.Mixins.Debounce)
local RuleType = Addon.RuleType
local Dialog = Addon.CommonUI.Dialog
local UI  = Addon.CommonUI.UI
local RuleSource = Addon.RuleSource
local Colors = Addon.CommonUI.Colors

Dialogs.EditRuleEvents = {
    HELP_CONTEXT = "set-help-context",
    CLEAR_MATCHES = "clear-matches",
    SHOW_MATCHES = "show-matches",
}

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
        t.filters:AddChip("function", "Functions", nil, true)
        t.filters:AddChip("property", "Properties", nil, true)

        t.items:Sort(function (modelA, modelB)
            return (modelA.Name < modelB.Name)
        end)
        Dialog.RegisterCallback(t, Dialogs.EditRuleEvents.HELP_CONTEXT, t.OnSetHelpContext)
    end,

    OnActivated = function(self)
        self:ApplyFilters()
    end,

    ApplyFilters = function(self)
        local types = self.filters:GetSelected()
        
        local term = nil
        -- TODO: Investigate why HasText is missing on classic.
        if self.filter.HasText and self.filter:HasText() then
            term = string.lower(self.filter:GetText())
            if (string.len(term) == 0) then
                term = nil
            end
        end

        self.items:Filter(function(model)
                if (not types[model.Type]) then
                    return false
                end

                if (type(term) == "string") then
                    return type(string.find(model.Keywords, term)) == "number"
                end

                return true
            end)
    end,

    GetHelpItems = function()
        local models = {}

        for name, markup in pairs(Addon:GetFunctionDocumentation()) do
            table.insert(models, {
                    Name = name,
                    Keywords = string.lower(name),
                    Type = "function",
                    Markdown = markup
                })
        end

        for name, markup in pairs(Addon:GetPropertyDocumentation()) do
            table.insert(models, {
                Name = name,
                Keywords = string.lower(name),
                Type = "property",
                Markdown = markup
            })
        end

        return models
    end,

    OnSetHelpContext = function(self, dialog, term, type)
        self.filters:SetSelected({ [type] = true })
        self.filter:SetText(term)
        self:ApplyFilters()
    end,
}

--[[
    Initialize the edit rule dialog
]]
function EditRule:OnInitDialog(dialog)
    dialog:SetCaption("EDITRULE_CAPTION")

    local tabs = self.tabs

    self.ruleType:AddChips({
        { id=RuleType.KEEP, text="EDITRULE_KEEPRULE_LABEL", tooltip="EDITRULE_KEEPRULE_TEXT" },
        { id=RuleType.SELL, text="EDITRULE_SELLRULE_LABEL", tooltip="EDITRULE_SELLRULE_TEXT" },
        { id=RuleType.DESTROY, text="EDITRULE_DELETERULE_LABEL", tooltip="EDITRULE_DELETERULE_TEXT" }
    })

    Addon.AttachImplementation(self.ruleStatus, Dialogs.RuleStatus)

    self.help = tabs:AddTab("help", "EDITRULE_HELP_TAB_NAME", "Vendor_EditRule_Help", HelpTab)
    self.matches = tabs:AddTab("matches", "EDITRULE_MATCHES_TAB_NAME", "Vendor_EditRule_Matches", Dialogs.MatchesTab)
    self.items = tabs:AddTab("iteminfo", "EDITRULE_ITEMINFO_TAB_NAME", "Vendor_EditRule_ItemInfo", Dialogs.ItemInfoTab)
    self.items:RegisterCallback("INSERT_TEXT", self.InsertText, self)

    self:SetRuleType(RuleType.KEEP)
    tabs:ShowTab("matches")
    tabs:ShowTab("help")
    self.ruleStatus:SetStatus("unhealthy", "Empty rule")
    self.open = {}
end

--[[ Navigat to a specific tab ]]
function EditRule:NavigateTo(tab)
    self.tabs:ShowTab(tab)
end

function EditRule:OnHide()
    self.matches:Call("ClearMatches")
    for _, open in ipairs(self.open) do
        open:Hide()
    end
    self.open = {}
end

--[[
    Invoked when something wants to insert text into the script control
]]
function EditRule:InsertText(_, text)
    local script = self.script

    if (script:IsEnabled()) then
        if (script:HasText()) then
            text = " " .. text
        end

        if (string.find(text, "[\t ]")) then
            script:Insert("(" .. text .. ") ")
        else
            script:Insert(text)
        end
        
        script:SetFocus()
    end
end

--[[ Compute the current parameters for this rule ]]
function EditRule:GetCurrentParameters()
    local parameters = self.editor:GetParameters()
    if (parameters) then
        local params = {}
        local info = {}

        for _, param in ipairs(parameters) do
            local paramInfo = {
                Name = param.Name,
                Type = param.Type,
                Key = param.Key,
            }
            
            if (type(self.parameters) == "table" and self.parameters[param.Key] ~= nil) then
                params[param.Key] = self.parameters[param.Key]
                paramInfo.Value = self.parameters[param.Key]
            else
                local default = param.Default
                if (type(default) == "function") then
                    default = default()
                end

                params[param.Key] = default
                paramInfo.Value = default
            end

            table.insert(info, paramInfo)
        end
        Addon:DebugForEach("editrule", info)
        Addon:DebugForEach("editrule", params)
        return params, info
    end

    return nil
end

function EditRule:UpdateMatches()
    local rules = Addon:GetFeature("rules")
    local matches

    Addon:Debug("editrule", "UpdateMatches :: START")

    local script = self.editor:GetScript()
    if (self.editor:IsScriptValid()) then
        local parameters, info = self:GetCurrentParameters()
        local matches = rules:GetMatches(script, parameters)

        if (matches) then        
            Addon:Debug("editrule", "UpdateMatches :: %s", table.getn(matches))
            self:RaiseEvent(Dialogs.EditRuleEvents.SHOW_MATCHES, matches, info)
        else
            Addon:Debug("editrule", "UpdateMatches :: no matches found")
            self:RaiseEvent(Dialogs.EditRuleEvents.SHOW_MATCHES, {}, info)
        end
    else
        Addon:Debug("editrule", "UpdateMatches :: invalid script clearing matches")
        self:RaiseEvent(Dialogs.EditRuleEvents.SHOW_MATCHES, {}, info)
    end
end

--[[
    Called when the script changes
]]
function EditRule:OnScriptChanged(text)
    if (not self.editor:IsReadOnly()) then
        self.editor:SetScript(text)
        self:ValidateScript()
    end
end

--[[ Validate our script ]]
function EditRule:ValidateScript()
    local text = self.editor:GetScript()
    if (text and string.len(text) ~= 0) then
        local rules = Addon:GetFeature("Rules")
        local valid, msg = rules:ValidateRule(text, self:GetCurrentParameters())
        Addon:Debug("editrule", "Validate script '%s' [%s, %s]", text, valid, msg or "")

        if (valid) then
            self.ruleStatus:SetStatus("ok")
            self:Debounce(.75, self.UpdateMatches)
            self.editor:SetScriptValid(true)
        else
            local errorMessage = nil
            local _, err = string.match(msg, "(%[.*%]:%d:)(.*)")
            if (err) then
                errorMessage = Addon.StringTrim(err)
            else
                errorMessage = Addon.StringTrim(msg)
            end
            self.ruleStatus:SetStatus("invalid", errorMessage)
            self.editor:SetScriptValid(false)
        end
    end
end

--[[
    Called when the name changes
]]
function EditRule:OnNameChanged(text)
    if (not self.editor:IsReadOnly()) then
        self.editor:SetName(text)
    end
end

--[[
    Called when the description changes
]]
function EditRule:OnDescriptionChanged(text)
    if (not self.editor:IsReadOnly()) then
        self.editor:SetDescription(text)
    end
end

--[[
    Set the rule type
]]
function EditRule:SetRuleType(type)
    self.ruleType:SetSelected({ [type] = true })
end

--[[ Handle a type change ]]
function EditRule:OnRuleTypeChanged()
    if (not self.editor:IsReadOnly()) then
        self.editor:SetType(self:GetRuleType())
    end
end

--[[
    Determines the current rule type
]]
function EditRule:GetRuleType()
    local ruleType = self.ruleType:GetSelected()

    if (ruleType[RuleType.SELL]) then
        return RuleType.SELL
    elseif (ruleType[RuleType.KEEP]) then
        return RuleType.KEEP
    elseif (ruleType[RuleType.DESTROY]) then
        return RuleType.DESTROY
    end

    return RuleType.KEEP
end

--[[
    Update the button state in the dialog
]]
function EditRule:UpdateButtons()
    local buttons = {}
    local changes = self.changes or {}

    -- If the dialog is in "view" mode then only meaningful button to have
    -- enabled is close.
    if (self:InViewMode()) then
        buttons.close = true
    else
        buttons.close = false
        buttons.delete = self:IsNewRule()
        buttons.cancel = true  
        buttons.save = { show = true, enabled = true }

        if not validateString(changes.name) then
            Addon:Debug("editrule", "Cannot save rule because name is invalid")
            buttons.save.enabled = false
        end

        if not validateString(changes.script) or not changes.scriptValid then
            Addon:Debug("editrule", "cannot save rule because script is invalid")
            buttons.save.enabled = false
        end
    end

    self:GetDialog():SetButtonState(buttons)
end

--[[ Sets the edtitor attached to this dialog ]]
function EditRule:Update()
    local editor = self.editor
    assert(self.editor, "We should have a valid editor to update our state")

    local readonly = editor:IsReadOnly()

    UI.Enable(self.name, not readonly)
    UI.Enable(self.description, not readonly)
    UI.Enable(self.script, not readonly)
    UI.Enable(self.ruleType, not readonly)

    self:SetButtonState({
        close = {
            enabled = true,
            show = readonly,
        },
        cancel = {
            enabled = true,
            show = not readonly,
        },
        delete = {
            enabled = editor:CanDelete(),
            show = not editor:IsNew() and not readonly
        },
        save = {
            show = not readonly,
            enabled = editor:CanSave()
        },
        export = {
            show = not readonly,
            enabled = editor:CanExport()
        }
    })
end

--[[
    Sets the rule we are viewing or editing this requries a valid rule
]]
function EditRule:SetRule(rule, parameters)
    assert(type(rule) == "table", "Expected the rule definition to be a table")

    self:SetCaption("EDITRULE_CAPTION")
    self.editor = Dialogs:CreateRuleEditor(rule)
    self.parameters = parameters

    self:Setup()
    self:Update()
    self:Debounce(0.05, self.UpdateMatches)
end

--[[ Sync the dialog state to the editor ]]
function EditRule:Setup()
    local editor = self.editor
    assert(editor, "we should have a valid editor")

    --- Determine our caption
    if (editor:IsNew()) then
        self:SetCaption("CREATERULE_CAPTION")
    elseif (not editor:IsReadOnly()) then
        self:SetCaption("EDITRULE_CAPTION")
    else
        self:SetCaption("VIEWRULE_CAPTION")
    end

    -- Transfer our text
    self.name:SetText(editor:GetName())
    self.description:SetText(editor:GetDescription())
    self.script:SetText(editor:GetScript())
    self.ruleType:SetSelected({ [editor:GetType()] = true })
    self.paramList:Rebuild()

    -- Setup the rule status if applicable
    local source, name = editor:GetSource()
    if (source == RuleSource.CUSTOM) then
        if (editor:IsNew()) then
            self.ruleStatus:SetStatus()
        else
            self:ValidateScript()
        end
    elseif (source == RuleSource.SYSTEM) then
        self.ruleStatus:SetStatus("system")
    elseif (source == RuleSource.EXTENSION) then
        self.ruleStatus:SetStatus("extension", tostring(name))
    end

    local readOnly = editor:IsReadOnly()
    if (not readOnly) then
        editor:RegisterCallback(Dialogs.RuleEditorEvents.CHANGED,
            function(_, what)
                if (what == "params") then
                    self:Debounce(.25, self.UpdateMatches)
                    self.paramList:Rebuild()
                end
                self:Update()
            end, self)
    end

    if (readOnly) then
        UI.Enable(self.viewParam, false)
    else
        UI.Enable(self.addParam, not readOnly)
        UI.Enable(self.editParam, false)
        UI.Enable(self.delParam, false)
        UI.Show(self.viewParam, false)
    end

    UI.Show(self.addParam, not readOnly)
    UI.Show(self.viewParam, readOnly)
    UI.Show(self.delParam, not readOnly)
    UI.Show(self.editParam, not readOnly)
end

--[[
    Sets the dialog to create a new rule
]]
function EditRule:NewRule()    
    self.editor = Dialogs:CreateRuleEditor()
    self:Setup()
    self:RaiseEvent(Dialogs.EditRuleEvents.CLEAR_MATCHES)
    self:Update()
end

function EditRule:CopyRule(rule, parameters)
    assert(type(rule) == "table", "Expected the rule definition to be a table")

    self.editor = Dialogs:CreateRuleEditor(rule, true)
    self.parameters = parameters

    self:Setup()
    self:Update()
    self:Debounce(0.05, self.UpdateMatches)
end

function EditRule:SaveRule()
    if (not self.editor:IsReadOnly()) then
        local rules = Addon:GetFeature("rules")
        local duplicateName = false
        
        -- Check for duplicates
        local name = string.lower(self.editor:GetName())
        for _, rule in ipairs(rules:GetRules(nil, true)) do
            if (string.lower(rule.Name) == name) then
                if (self.editor:IsNew() or (self.editor:GetId() ~= rule.Id)) then
                    Addon:Debug("editrule", "Found duplicate rule '%s'", rule.Id)
                    duplicateName = true
                end
            end
        end

        if (duplicateName) then
            UI.MessageBox("DUPLICATE_RULE_NAME_CAPTION",
                locale:FormatString("DUPLICATE_RULE_FMT1", self.editor:GetName()), {
                    "DUPLICATE_RULE_OK"
                })
        else
            self.editor:Save()
            self:Close()
        end
    end
end

--[[ Called to delete the rule ]]
function EditRule:DeleteRule()
    if (not self.editor:IsReadOnly()) then
        UI.MessageBox("DELETE_RULE_CAPTION",
            locale:FormatString("DELETE_RULE_FMT1", self.editor:GetName()), {
                {
                    text = "CONFIRM_DELETE_RULE",
                    handler = function()
                        self.editor:Delete()
                        --self:Close()
                    end,
                },
                "CANCEL_DELETE_RULE"
            }, self)
        end
end

--[[ Called to handle exporting the rule ]]
function EditRule:ExportRule()
    local export = Addon:GetFeature("import")
    if (export) then
        assert(self.editor:CanExport(), "This rule cannot be exported")
        export:ShowExportDialog("EXPORT_RULE_CAPTION", self.editor:GetExportValue())
    end
end

--[[ Get the rule paramaters for this rule ]]
function EditRule:GetParameters()
    Addon:Debug("editrule", "Get rule parameters")
    return self.editor:GetParameters()
end

--[[ Handle parameter selection change ]]
function EditRule:OnParamSelected()
    local  param = self.paramList:GetSelected()
    if (self.editor:IsReadOnly()) then
        UI.Enable(self.viewParam, param ~= nil)
    else
        UI.Enable(self.editParam, param ~= nil)
        UI.Enable(self.delParam, param ~= nil)
    end
end

local EditRuleParamItem = Mixin({}, Addon.CommonUI.SelectableItem)

function EditRuleParamItem:OnModelChange(model)
    self.name:SetText(model.Name)
    self.key:SetText(string.upper(model.Key))

    -- Set the type and color
    if (model.Type == "boolean") then
        self.type:SetText("B")
        self.type:SetTextColor(Colors:Get("EPIC_PURPLE_COLOR"):GetRGBA())
    elseif (model.Type == "number" or model.Type == "numeric") then
        self.type:SetText("N")
        self.type:SetTextColor(Colors:Get("LEGENDARY_ORANGE_COLOR"):GetRGBA())
    elseif (model.Type == "string") then
        self.type:SetText("S")
        self.type:SetTextColor(Colors:Get("GREEN_FONT_COLOR"):GetRGBA())
    end

    if (self.ReadOnly) then
        UI.SetColor(self.name, "BUTTON_DISABLED_TEXT")
        UI.SetColor(self.key, "BUTTON_DISABLED_TEXT")
        UI.SetColor(self.type, "BUTTON_DISABLED_TEXT")
    end
end

--[[ Create a new parameter item ]]
function EditRule:CreateParameterItem(model, parent)
    local frame
    if (self.editor:IsReadOnly()) then
        frame = CreateFrame("Button", nil, parent, "Rule_ParamItem_ReadOnly")
    else
        frame = CreateFrame("Button", nil, parent, "Rule_ParamItem")
    end

    UI.Attach(frame, EditRuleParamItem)
    return frame
end

function EditRule:OnEditParam()
    local param = self.paramList:GetSelected()
    if (param) then
        local parameters = self:GetCurrentParameters()
        local currentValue = nil

        if (type(parameters) == "table") then
            currentValue = parameters[param.Key]
        end

        if (self.editor:IsReadOnly()) then
            Dialogs:ViewRuleParam(param, currentValue)
        else 
            Dialogs:EditRuleParam(self.editor, param, currentValue)
        end
    end
end

function EditRule:OnCreateParam()   
    assert(not self.editor:IsReadOnly(), "Why are trying to create a parameter on a read-only rule")
    table.insert(self.open, Dialogs:CreateRuleParam(self.editor))
end

function EditRule:OnRemoveParam()
    local param = self.paramList:GetSelected()
    if (param) then
        self:MessageBox("EDITPARM_REMOVE_PARAM_CAPTION", 
            locale:FormatString("EDITPARAM_REMOVE_PARAM", param.Name, param.Key),
            {
                { text = "EDITPARAM_CONFIRM_REMOVE", handler = function()
                        self.editor:RemoveParameter(param.Key)
                    end
                },
                { text = "EDITPARAM_KEEP_PARAM", default = true },
            })
    end
end

Dialogs.EditRule = EditRule