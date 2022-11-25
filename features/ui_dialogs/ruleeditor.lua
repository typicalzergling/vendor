local _, Addon = ...
local locale = Addon:GetLocale()
local RuleEditor = Mixin({}, CallbackRegistryMixin)
local RuleSource = Addon.RuleSource
local RuleType = Addon.RuleType

local Events = {
    DIRTY = "rule-editor-dirty",
    SCRIPT_VALID = "rule-editor-script-valid",
    SCRIPT_INVALID = "rule-editor-script-invalid",
    CHANGED = "rule-editor-changed"
}

local Errors  = {
    DUPLICATE_PARAM = "duplicate-param",
    INVALID_PARAM_TYPE = "invalid-param-type",
    INVALID_PARAM_NAME = "invalid-param-name"
}

function RuleEditor:Init(rule, copy)
    self.dirty = false

    CallbackRegistryMixin.OnLoad(self)
    local events = {}
    for _, event in pairs(Events) do
        table.insert(events, event)
    end
    self:GenerateCallbackEvents(events)
    
    if (rule) then
        self.name = rule.Name
        self.description = rule.Description
        self.type = rule.Type
        if (type(rule.Script) == "function") then
            self.script = rule.ScriptText
        else
            self.script = rule.Script
        end

        if (copy) then
            self.name = locale:FormatString("EDITRULE_DEFAULT_COPY_NAME_FMT1", rule.name)
        else
            self.rule = rule
        end
    else
        self.name = locale.EDITRULE_DEFAULT_NAME
        self.type = RuleType.KEEP
    end
end

--[[ Get the ID of the rule if we have one ]]
function RuleEditor:GetId()
    if (self.rule) then
        return self.rule.Id
    end
    
    return nil
end

--[[ Retrieve the name of this rule ]]
function RuleEditor:GetName()
    return self.name
end

--[[ Change the name ]]
function RuleEditor:SetName(name)
    if (self.name ~= name) then
        self:SetDirty(true)
        self.name = name
        self:TriggerEvent(Events.CHANGED, "name")
    end
end

--[[ Retrieve the description of this rule ]]
function RuleEditor:GetDescription()
    return self.description
end

--[[ Change the description ]]
function RuleEditor:SetDescription(description)
    if (self.description ~= description) then
        self:SetDirty(true)
        self.description = description
        self:TriggerEvent(Events.CHANGED, "description")
    end
end

--[[ Retrieve the script for this rule ]]
function RuleEditor:GetScript()
    return self.script
end

--[[ Change the script ]]
function RuleEditor:SetScript(script)
    if (self.script ~= script) then
        self:SetDirty(true)
        self.script = script
        self:TriggerEvent(Events.CHANGED, "script")
    end
end

--[[ Retrieve the type for this rule ]]
function RuleEditor:GetType()
    return self.type
end

--[[ Sets the rule type ]]
function RuleEditor:SetType(type)
    if (self.type ~= type) then
        self:SetDirty(true)
        self.type = type
        self:TriggerEvent(Events.CHANGED, "type")
    end
end

--[[ Get the source of the rule ]]
function RuleEditor:GetSource()
    if (not self.rule) then
        return RuleSource.CUSTOM
    end

    if self.rule.Source == RuleSource.EXTENSION then
        return self.rule.Source, self.rule.ExtensionName
    end

    return self.rule.Source
end

--[[ Gets the parameters for this rule ]]
function RuleEditor:GetParameters()
    if (not self:IsReadOnly()) then
        if (type(self.params) == "table") then
            return self.params
        else
            return nil
        end
    else
        if (not self.rule or type(self.rule.Params) ~= "table") then
            return nil
        end

        return self.rule.Params
    end
end

--[[ Add a new parameter to this rule ]]
function RuleEditor:AddParameter(type, key, name, default)
    local params = self:GetParameters()
    if (type(params) == "table") then
        for _, param in ipairs(params) do
            if (param.Key == string.upper(key)) then
                return false, Errors.DUPLICATE_PARAM
            end
        end
    end

    if (type(name) ~= "string" or string.len(type) == 0) then
        return false, Errors.INVALID_PARAM_NAME
    end

    if ((type ~= "boolean") or (type ~= "number") or
        (type ~= "numeric") or (type ~= "string")) then
        return false, Errors.INVALID_PARAM_TYPE
    end

    assert(type(type(default) == "nil" or default) == type)
    
    self.params = self.parmas or {}
    table.insert(self.params, {
            Key = string.upper(key),
            Name = name,
            Type = type,
            Default = default
        })

    self:SetDirty(true)
    self:TriggerEvent(Events.CHANGED, "params")
end

--[[ Remove a parameter from the rule ]]
function RuleEditor:RemoveParameter(key)
    if (type(self.params) == "table") then
        for i, param in ipairs(self.params) do
            if (param.Key == string.upper(key)) then
                table.remove(self.params, i)
                self:SetDirty(true)
                self:TriggerEvent(Events.CHANGED, "params")
                break
            end
        end
    end
end

--[[ Returns true if the rule is read-only ]]
function RuleEditor:IsReadOnly()
    return (self:GetSource() ~= RuleSource.CUSTOM)
end

--[[ Returns true if the rule is new ]]
function RuleEditor:IsNew()
    return (self.rule == nil)
end

--[[ Checks if we can delete this rule ]]
function RuleEditor:CanDelete()
    if (self:IsReadOnly()) then
        return false
    end

    return not self:IsNew()
end

--[[ Checks if we can save this rule ]]
function RuleEditor:CanSave()
    if (self:IsReadOnly()) then
        return false
    end

    if (type(self.name) ~= "string") or string.len(self.name) == 0 then
        return false
    end

    if (type(self.script) ~= "string") or string.len(self.script) == 0 then
        return false
    end

    return self.dirty
end

--[[ Check if we can export this rule ]]
function RuleEditor:CanExport()
    if (self:IsReadOnly()) then
        return false
    end
    
    if (type(self.name) ~= "string") or string.len(self.name) == 0 then
        return false
    end

    if (type(self.script) ~= "string") or string.len(self.script) == 0 then
        return false
    end

    if (type(self.description) ~= "string" or string.len(self.description) == 0) then
        return false
    end

    return true
end

--[[ Get the exported value ]]
function RuleEditor:GetExportValue()
    return {
        Content = "customrule",
        Items = {
            Name = self.name,
            Description = self.description,
            Script = self.script,
            Type = self.type,
            Params = nil,
        }
    }
end

--[[ Save the changes to this rule ]]
function RuleEditor:Save()
    assert(self:GetSource() == RuleSource.CUSTOM, "Only custom rules are savable")
    assert(self:CanSave(), "Why are trying to save a non-saveable rule")

    local rule = {
        Name = self.name,
        Description = self.description,
        Script = self.script,
        Type = self.type
    }

    if (self.rule) then
        rule.Id = self.rule.Id
    end

    Addon:DebugForEach("editrule", rule)

    local rules = Addon:GetFeature("Rules")
    if (self:IsNew()) then
        rules:SaveRule(rule, true)
    else
        rules:SaveRule(rule)
    end
end

--[[ Save the changes to this rule ]]
function RuleEditor:Delete()
    assert(self:GetSource() == RuleSource.CUSTOM, "Only custom rules are savable")
    assert(self:CanDelete(), "Why are you trying to delete a non-deletable rule?")
    assert(self.rule and self.rule.Id, "Delete() called with no rule Id")

    local ruleId = self.rule.Id
    Addon:Debug("editrule", "Deleting Rule: %s (%s)", tostring(self.name), ruleId)
    Addon:GetFeature("Rules"):DeleteRule(ruleId)
end

--[[ Set the dirty state for the rule editor ]]
function RuleEditor:SetDirty(dirty)
    if (dirty ~= self.dirty) then
        self.dirty = dirty
        self:TriggerEvent(Events.DIRTY, dirty)
    end
end

--[[ Create a new rule editor ]]
function Addon.Features.Dialogs.CreateRuleEditor(rule, copy)
    return CreateAndInitFromMixin(RuleEditor, rule, copy)
end

Addon.Features.Dialogs.RuleEditorEvents = Events