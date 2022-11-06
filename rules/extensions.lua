--[[===========================================================================
    | Copyright (c) 2018
    |
    | This file defines the extension points for vendor, we allow other
    | Addon to register functions and rule definitions with vendor.
    |
    | The structure for information is as following:
    |
    |   FunctionInformation:
    |       Name = <name>
    |       Help = <help text>
    |       Function = <function>
    |
    |   Name is the name as it will be exposed to the user, it will be prefixed
    |   by the source of your extension, so if your Source is "Bar" and you
    |   register a function "Foo" the function exposed to the rules will be
    |   Bar_Foo. The help text is required, and it explains to uses how the
    |   function works.
    |
    |   RuleDefinition:
    |       Id = <id>
    |       Name = <name>
    |       Description = <description>
    |       Script = <script>
    |       Type = "Sell" | "Keep"
    |       Order = #
    |
    |   All of these fields except for Order are required and must be
    |   non-empty strings.  Order is used for sorting the definition
    |   with the custom rule list.
    |
    |   ExtensionDefinition:
    |       Rules = { RuleDefinition1...RuleDefinitionN }
    |       Functions = { FunctionDefinition1...FunctionDefinitionN }
    |       Source = <source>
    |       Addon = <addon>
    |
    |   Rules and functions are a list of the rules and definitions which
    |   should be registered.  See the details above for each of them.
    |   Source - is the name of your Vendor extension, this can whatever
    |       you desire, but anything non-alpha numeric will be turned into
    |       underscores.
    |   Addon - This is the Addon making the call, this allows vendor
    |           to get version information and track where it came from
    |           we do verify this is valid. and for the most part
    |           you can just use the result of "select(1, ...)"
    ========================================================================--]]

local AddonName, Addon = ...
local L = Addon:GetLocale()

local Package = select(2, ...);
local AddonName = select(1, ...);
local RuleType = Addon.RuleType;
local ExtensionCallbacks = {};

local Extensions =
{
    _exts = {},
    _functions = {},
    _rules = {},
    _onruleupdate = {},
    OnChanged = Package.CreateEvent("Extensions.OnChanged");
};

-- Simple helper for validating a string.
local function validateString(s)
    return (s and (type(s) == "string") and (string.len(s) ~= 0));
end

-- Simple helper for validating a table (non-empty)
local function validateTable(t)
    return (t and (type(t) == "table") and (table.getn(t) ~= 0));
end

-- Simple helper for validating a function.
local function isValidFunction(f)
    return (f and (type(f) == "function"))
end

-- Simple helper which validates the string is not-only valid but also
-- one of the specified arguments.
local function validateStringValue(s, ...)
    if (not validateString(s)) then
        return false;
    end

    for i,v in ipairs({...}) do
        if (s == v) then
            return true;
        end
    end

    return false;
end

-- Helper function which makes sure the provided string is valid identifier.
local function validateIdentifier(s)
    if (not validateString(s)) then
        return false;
    end
    return string.len(s) == string.len(s:match("[A-Za-z_]+[A-Za0-9_]*"));
end

-- Simple helper function which copies the help table, extracting only the 
-- keys that we know how to display.
local function copyHelpTable(help)
    local t = {};
    for k,v in pairs(help) do
        if (type(v) == "string") then
            if ((k == "Text") or (k == "Notes") or (k == "Examples")) then            
                t[k] = value;
            end
        end
    end
    return t;
end

local function addFunctionDefinition(ext, fdef)
    local f =
    {
        Extension = ext,
        Name = string.format("%s_%s", ext.Source, fdef.Name),
        Function = fdef.Function;
    };

    if (type(fdef.Help) == "string") then
        f.Help = {
            Text = fdef.Help,
            Extension = ext
        };
    elseif (type(fdef.Help) == "table") then
        f.Help = copyHelpTable(fdef.Help);
        f.Help.Extension = ext;
    end

    Addon:Debug("extensions", "Added function '%s' from:", f.Name, ext.Name);
    table.insert(Extensions._functions, f);
end

-- Helper function which adds an entry for the extension.
local function addExtension(source, addon)
    local a =
    {
        Source = source,
        Name = addon,
        Functions = 0,
        Rules = 0,
        OnUpdate = 0
    };

    table.insert(Extensions._exts, a);
    return a;
end

-- Helper function to traverse the extension array and find the specified
-- extension.
local function findExtension(source)
    for _,ext in ipairs(Extensions._exts) do
        if (ext.Source == source) then
            return ext;
        end
    end
end

-- Helper function to add a rule definition to the extension
local function addRuleDefinition(ext, rdef)
    local r =
    {
        Id = string.lower(string.format("E[%s.%s])", ext.Source, rdef.Id)),
        Name = rdef.Name,
        Description = rdef.Description,
        Script = rdef.Script,
        ScriptText = rdef.ScriptText,
        Type = rdef.Type,
        ReadOnly = true,
        Extension = ext,
        Params = rdef.Params,
        Order = tonumber(rdef.Order) or nil,
    };

    Addon:Debug("extensions", "Added rule '%s' from: %s", r.Name, ext.Name);
    table.insert(Extensions._rules, r);
end

-- Helper function to add an OnRuleUpdate callback to Vendor
-- This attaches as a profile callback, so anytime state is changed in Vendor it will fire.
local function addOnRuleUpdateCallback(ext, cbdef)
    local cb =
    {
        Source = ext.Source,
        Function = cbdef,
    };

    -- Add callback to our list of callbacks in case we want to call them later.
    Addon:Debug("extensions", "Added OnRuleUpdate callback from %s", cb.Source);
    table.insert(Extensions._onruleupdate, cb);

    -- Add the callback to the config table.concat, this is the primary invocation point.
    local function fn()
        Addon:Debug("extensions", "Executing callback from (%s)...", ext.Source)
        local result, msg = xpcall(cbdef, CallErrorHandler);
        --@debug@
        if (not result) then
            Addon:Debug("extensions", "%sFailed to invoke extenion callback %s: %s|r", RED_FONT_COLOR_CODE, cb.Source, msg);
        end
        --@end-debug@
    end

    table.insert(ExtensionCallbacks, fn);
end


-- Function to compare two rule definitions and sort them by "order"
local function compareRules(a, b)
    if (a.Order and not b.Order) then
        return true;
    elseif (not a.Order and b.Order) then
        return false;
    elseif (not a.Order and not b.Order) then
        return (a.Name < b.Name);
    end
    return (a.Order < b.Order);
end

--[[===========================================================================
    | validateFunction:
    |   This handles the validation of a function definition, this verifies
    |   the name is a valid identifier and that help text was provided.
    ========================================================================--]]
local function validateFunction(fdef)
    if (not validateIdentifier(fdef.Name)) then
        return false, "The function definition did not contain a valid name";
    end

    if (not validateString(fdef.Help)) then
        return false, "The function definition did not contain a valid help information";
    end

    if (not fdef.Function or (type(fdef.Function) ~= "function")) then
        return false, string.format("The function definition for (%s) did not contain a valid 'Function' field", fdef.Name);
    end

    return true;
end

--[[===========================================================================
    | validateRule:
    |   This validates the specified rule definition and returns ether
    |   success, or failure and an error.
    ========================================================================--]]
local function validateRule(rdef)
    -- Id
    if (not validateString(rdef.Id)) then
        return false, "The rule definition did not contain a valid 'Id' field";
    end

    -- Name
    if (not validateString(rdef.Name)) then
        return false, string.format("The rule (%s) did not contain a valid 'Name' field", rdef.Id);
    end

    -- Description
    if (not validateString(rdef.Description)) then
        return false, string.format("The rule (%s) did not contain a valid 'Description' field", rdef.Id);
    end

    -- Script can be either a function or a string.
    if type(rdef.Script) == "function" then
        -- function is OK, but we need a ScriptText value
        if not rdef.ScriptText and not type(rdef.ScriptText) == "string" then
            return false, string.format("The rule (%s) is a function script but did not have a ScriptText defined.", rdef.Id)
        end

    -- If not a function, we need to create one
    else
        if (not validateString(rdef.Script)) then
            return false, string.format("The rule (%s) did not contain a valid 'Script' field", rdef.Id);
        end
        local result, message = loadstring(string.format("return(%s)", rdef.Script));
        if (not result) then
            return false, string.format("The rule (%s) has an invalid 'Script' field [%s]", rdef.Id, message);
        end
    end

    -- Rule Type
    if (not validateStringValue(rdef.Type, RuleType.SELL, RuleType.KEEP, RuleType.DESTROY)) then
        return false, string.format("The rule (%s) has an invalid 'Type' field", rdef.Id);
    end

    -- Params
    if rdef.Params and not type(rdef.Params) == "table" then
        return false, string.format("The rule (%s) has an invalid 'Params' field", rdef.Id);
    end

    -- Order if provided.
    if (rdef.Order and not tonumber(rdef.Order)) then
        return false, string.format("The rule (%s) provided a non-numeric 'Order' field", rdef.Id);
    end

    return true;
end

--[[===========================================================================
    | validateExtension:
    |   Validates the extension contains the proper information, returns
    |   either failure and a message, or success and the full name of the
    |   addon we will use to identify it.
    ========================================================================--]]
local function validateExtension(extension)
    if (not validateString(extension.Addon) and not IsAddOnLoaded(extension.Addon)) then
        return false, "The specified AddOn was either invalid or not loaded";
    end

    if (not validateIdentifier(extension.Source)) then
        return false, string.format("The extension 'Source' field was invalid. (%s)",extension.Addon);
    end

    if (string.lower(extension.Source) == string.lower(AddonName)) then
        return false, string.format("The extension 'Source' field was invalid. (%s)", extension.Addon);
    end

    local version = GetAddOnMetadata(extension.Addon, "Version");
    local _, title = GetAddOnInfo(extension.Addon);
    if (not validateString(version) or not validateString(title)) then
        return false, string.format("Unable to get information about '%s' addon", extension.Addon);
    end

    return true, string.format("%s - %s[%s]", extension.Source, title, version);
end

--[[===========================================================================
    | GetFunctions:
    |   The gets an associative array of the functions which were registered
    |   by our extensions.
    ========================================================================--]]
function Extensions:GetFunctions()
    local funcs = {};
    for _, func in ipairs(self._functions) do
        funcs[func.Name] = func.Function;
    end
    return funcs;
end

--[[===========================================================================
    | GetFunctionDocs:
    |   Retrieves the list of documentation for the functions that
    |   were registered by an addon.
    ========================================================================--]]
function Extensions:GetFunctionDocs()
    local docs = {};
    for _, func in ipairs(self._functions) do
        docs[func.Name] = func.Help;
    end
    return docs;
end

--[[===========================================================================
    | GetRules:
    |   This gets all of the rules which were registered by our extensions,
    |   optionally filtered by the specified filter.
    ========================================================================--]]
function Extensions:GetRules(filter)
    local rules = {};
    for _, rule in ipairs(self._rules) do
        if (not filter or (rule.Type == filter)) then
            table.insert(rules, rule);
        end
    end
    return rules;
end

--[[===========================================================================
    | GetOnUpdateCallbacks:
    |   This gets all the callbacks when a rule change occurs and we need to
    |   notify other addons.
    ========================================================================--]]
function Extensions:GetOnUpdateCallbacks()
    local callbacks = {};
    for _, callback in ipairs(self._onruleupdate) do
        table.insert(callbacks, callback);
    end
    return callbacks;
end

--[[===========================================================================
    | GetRule:
    |   Searches for a particular rule registered by an extension, optinally
    |   making sure it matches the specified filter.
    ========================================================================--]]
function Extensions:GetRule(ruleId, filter)
    local id = string.lower(ruleId);
    for _, rule in ipairs(self._rules) do
        if ((rule.Id == id) and (not filter or (rule.Type == filter))) then
            return rule;
        end
    end
end

--[[===========================================================================
    | Register:
    |   This is our public API for registering
    ========================================================================--]]
function Extensions:Register(extension)
    -- Valid our argument [These will error out the load (of the extensions LUA not ours)]
    if (not extension or (type(extension) ~= "table")) then
        error("An invalid argument was provided for the extension.", 2);
    end
    local valid, name = validateExtension(extension);
    if (not valid) then
        error(name, 2);
    end

    -- Make sure we've actually got something to to.
    if (not validateTable(extension.Functions) and not validateTable(extension.Rules) and not isValidFunction(extension.OnRuleUpdate)) then
        error(string.format("An extension must provide rules, and/or functions, and or an update callback to be registered. (%s)", extension.Source), 2);
    end


    -- Validate all of the function definitions are valid.
    if (validateTable(extension.Functions)) then
        Addon:Debug("extensions", "Validating %s function definition(s) for: %s (%s)", table.getn(extension.Functions), extension.Source, name);
        for i,fdef in ipairs(extension.Functions) do
            local valid, message = validateFunction(fdef);
            if (not valid) then
                Addon:Debug("extensions", "Failed to validate function definition %s: %s (%s): %s", i, extension.Source, name, message);
                return false;
            end
        end
    end

    -- Validate all of the rules for this extension.
    if (validateTable(extension.Rules)) then
        Addon:Debug("extensions", "Validating %s rule definition(s) for: %s (%s)", table.getn(extension.Rules), extension.Source, name);
        for i,rdef in ipairs(extension.Rules) do
            local valid, message = validateRule(rdef);
            if (not valid) then
                Addon:Debug("extensions", "Failed to validate rule definition %s: %s (%s): %s", i, extension.Source, name, message);
                return false;
            end
        end
    end
    
    -- Validate the OnUpdate function
    if (extension.OnRuleUpdate) then
        Addon:Debug("extensions", "Validating OnRuleUpdate callback for: %s (%s)", extension.Source, name)
        if not isValidFunction(extension.OnRuleUpdate) then
            Addon:Debug("extensions", "Failed validating OnRuleUpdate callback for %s (%s).", extension.Source, name)
            return false
        end
    end

    -- Now that we've validated everything register it into our objects.
    local ext = addExtension(extension.Source, name);
    if (extension.Functions) then
        ext.Functions = table.getn(extension.Functions);
        for _, fdef in ipairs(extension.Functions) do
            addFunctionDefinition(ext, fdef);
        end
    end
    if (extension.Rules) then
        ext.Rules = table.getn(extension.Rules);
        for _, rdef in ipairs(extension.Rules) do
            addRuleDefinition(ext, rdef);
        end
        table.sort(self._rules, compareRules);
    end
    if (extension.OnRuleUpdate) then
        ext.OnRuleUpdate = 1
        addOnRuleUpdateCallback(ext, extension.OnRuleUpdate)
    end

    self.OnChanged("ADDED", ext);
    Addon:Debug("extensions", "Completed registration of %s (%s) with %s function(s), %s rule(s) and %s OnRuleUpdate functions.", ext.Source, ext.Name, ext.Functions or 0, ext.Rules or 0, ext.OnRuleUpdate or 0);
    Addon:GetExtensionManger():TriggerEvent("OnFunctionsChanged")
    return true;
end

-- Handle notifying our extensions of a change. THis is async, which allows vendor
-- to update before our addons, it also, allows us to not require special handling 
-- for our addons.
function Extensions:ChangeCallback()
    if (self.timer) then
        self.timer:Cancel();
        self.timer = nil;
    end
    
    self.timer = C_Timer.NewTimer(0.05, 
        function()
            if (self.timer) then
                self.timer:Cancel();
                self.timer = nil;
            end            

            for _, fn in ipairs(ExtensionCallbacks) do 
                fn();
            end                    
        end);
end

-- Expose the extensions (private to the addon) and public
-- for main registration function.
Package.Extensions = Extensions;
function Addon:RegisterExtension(extension)
    local result = Extensions:Register(extension);
    if (result) then
        if (not Extensions.registeredCallbacks) then
            Extensions.registeredCallbacks = true;
            Addon:GetProfileManager():RegisterCallback("OnProfileChanged", Extensions.ChangeCallback, Extensions);
            --Addon.Rules:RegisterCallback("OnDefinitionsChanged", ....)
            Addon.Rules.OnDefinitionsChanged:Add(
                function()
                    Extensions:ChangeCallback();
                end);
        end
        --Addon.Panels.RuleHelp:CreateModels()
    end
    return result;
end

