local _, Addon = ...
local RuleSystem = {}

RuleEvents = {
    FUNCTIONS_CHANGED = "_OnRuleFunctionsChanged",
    DOCS_CHANGED = "_OnRFDocumenationChange",
    CONFIG_CHANGED = "rule-config-changed",
}

RuleSource = {
    SYSTEM = "system",
    CUSTOM = "custom",
    EXTENSION = "extension"
}

--[[ Retrieve our depenedencies ]]
function RuleSystem:GetDependencies()
    return { "savedvariables", "profile" }
end

--[[ Retrieves the events we produce ]]
function RuleSystem:GetEvents()
    return RuleEvents
end

--[[ Startup our system ]]
function RuleSystem:Startup()
    self.functions = {}
    xpcall(
    self.RegisterSystemFunctions, CallErrorHandler, self)

    return { "GetRuleFunctions", "GetFunctionDocumentation", "RegisterFunctions", "UnregisterFunctions" }
end

--[[ Shutdown our system ]]
function RuleSystem:Shutdown()
end

--[[ Retrieve a list of all the rule functins ]]
function RuleSystem:GetRuleFunctions()
    local functions = {}

    for name, definition in pairs(self.functions) do
        functions[name] = definition.Function
    end

    return functions
end

--[[ Retrieve a list of all the rule documentation ]]
function RuleSystem:GetFunctionDocumentation()
    local docs = {}

    for name, definition in pairs(self.functions) do
        if (type(definition.Documentation) == "string") then
            docs[name] = definition.Documentation
        else
            docs[name] = 0
        end
    end

    return docs

end

--[[ 
    Register the function contained in the table 
    
    A function definition looks like the following:
        Name - the name of the function
        Function - The function itself
        Documentation - The documentation for this function [optional]
]]
function RuleSystem:RegisterFunctions(functions, source)
    if (type(functions) ~= "table") then
        error("Usage: RegisterFunctions( table [, source] )")
    end

    for _, definition in ipairs(functions) do
        if (type(definition.Name) ~= "string") then
            error("An invalid function definition was provided (Name)")
        end

        if (type(definition.Function) ~= "function") then
            error("An invalid function definition was provided (Function)")
        end

        if (self.functions[definition.Name]) then
            error("A duplicate function name was found '" .. definition.Name .. "'")
        end

        self.functions[definition.Name] = definition
        Addon:Debug("rules", "Registering a new rule function '%s'", definition.Name)
    end

    --Addon:RaiseEvent(RuleEvents.FUNCTIONS_CHANGED)
    --Addon:RaiseEvent(RuleEvents.DOCS_CHANGED)
end

--[[ Removes the functions from our list ]]
function RuleSystem:UnregisterFunctions(functions)
end

Addon.Systems.Rules = RuleSystem
Addon.Systems.Rules.RuleEvents = RuleEvents
Addon.RuleSource = RuleSource