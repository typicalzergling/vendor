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

    return self.rule.Source
end

--[[ Gets the parameters for this rule ]]
function RuleEditor:GetParameters()
    if (not self.rule or type(self.rule.Params) ~= "table") then
        return nil
    end

    return self.rule.Params
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