local AddonName, Addon = ...
local locale = Addon:GetLocale()
local UI = Addon.CommonUI.UI
local ImportRule = {}
local RuleType = Addon.RuleType
local function debugp(m,...) Addon:Debug("importrule", m, ...) end

-- Common utility?
local function validateString(rule, field)
    local val = rule[field]
    if (type(val) ~= "string") or string.len(val) == 0 then
        debugp("Failed to validate '%s' : %s", field, tostring(val))
        return false
    end
    return true
end

--[[ Validate the list payload ]]
function ImportRule:Validate(payload)
    if (type(payload.Items) ~= "table") then
        debugp("There item field is invalid")
        return false
    end

    local rule = payload.Items[1]
    Addon:DebugForEach("importrule", payload.Items)
    if (not rule) then
        debugp("There is not a rule in the item field : %s", tostring(rule))
        return false
    end

    if (not validateString(rule, "Name") or
        not validateString(rule, "Description") or
        not validateString(rule, "Script")) then
        return false
    end

    if (not rule.Type) then
        debugp("There is not rule type in the payload")
        return false
    end

    for _, rtype in pairs(RuleType) do
        if (rule.Type == rtype) then
            return true
        end
    end

    debugp("The rule type '%s' is not valid", tostring(rule.Type))
    return false
end

--[[ Ensure the imported list has a unique name ]]
function ImportRule:CreateName(imported)
    local rules = Addon:GetFeature("rules")
    local canidate = imported
    local unique = false
    local loop = 1

    while (not unique) do
        unique = true
        local name = string.lower(canidate)
        for _, def in ipairs(rules:GetRules(nil, true)) do
            if (name == string.lower(def.Name)) then
                unique = false
                break
            end
        end

        if (not unique) then
            if (loop == 1) then
                canidate = locale:FormatString("IMPORTLIST_UNIQUE_NAME0", imported)
            else
                canidate = locale:FormatString("IMPORTLIST_UNIQUE_NAME1", imported, loop)
            end
            loop = loop + 1
        end
    end

    return canidate
end

--[[ Create the UI to show what you are importing ]]
function ImportRule:CreateUI(parent, payload)
    local rule = payload.Items[1]
    payload.ImportName = self:CreateName(rule.Name)
    
    local markdown = locale:FormatString("IMPORTRULE_MARKDOWN_FMT", 
            payload.ImportName, rule.Description, 
            payload.Player, payload.Realm)

    return Addon.CommonUI.MarkdownView.Create(parent, markdown)
end

--[[ Handle the importing of the actual list ]]
function ImportRule:Import(payload)
    local rule = payload.Items[1]
    assert(type(rule) == "table", "Expected a valid list for import")
    assert(type(payload.ImportName) == "string", "We haven not computed the import name")

    local rules = Addon:GetFeature("rules")
    local ruleDef = Addon.DeepTableCopy(rule)
    ruleDef.Name = payload.ImportName
    ruleDef.ImportedFrom = string.format("%s / %s", payload.Player, payload.Realm)
    ruleDef.IsImported = true

    local newRule = rules:SaveRule(ruleDef, true)
    local editDialog = Addon:GetFeature("dialogs")
    if (editDialog) then
        editDialog:ShowEditRule(newRule.Id)
    end
end

Addon.Features.Import.ImportRule = ImportRule