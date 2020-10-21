local AddonName, Addon = ...

-- Hooking helpers. Keeping It Simple.

-- For Hooking Widgets, there's a pre hook and a post hook.

-- This does a secure hook on a widget function, which is a post-hook.
function Addon:SecureHookWidget(widget, method, func)
    -- Fail fast if bad arguments so developers can find this error quickly and easily, and we dont have to worry about it later.
    assert(widget, "Invalid argument to SecureHookWidget: Widget cannot be nil.")
    assert(method and type(method) == "string", "Invalid argument to SecureHookWidget: Method must be a string.")
    assert(func and (type(func) == "function" or type(func) == "string"), "Invalid argument to SecureHookWidget: Function must be a function or string.")

    -- Func can be an actual function or a name of one in our Addon
    if type(func) == "function" then
        widget:HookScript(method, func)
    else
        if self[func] then
            widget:HookScript(method, function(...) self[func](self, ...) end)
        else
            error("Function "..func.." does not exist in "..AddonName)
        end
    end
end

-- This does a pre-hook on a widget function. This is an insecure hook.
-- This is for simple hooking and does not permit not calling the original function.
-- If you want to alter the function, you should a) know what you're doing, and b) do that manually.
function Addon:PreHookWidget(widget, method, func)
    -- Fail fast if bad arguments so developers can find this error quickly and easily, and we dont have to worry about it later.
    assert(widget, "Invalid argument to SecureHookWidget: Widget cannot be nil.")
    assert(method and type(method) == "string", "Invalid argument to SecureHookWidget: Method must be a string.")
    assert(func and (type(func) == "function" or type(func) == "string"), "Invalid argument to SecureHookWidget: Function must be a function or string.")
    assert(not widget.IsProtected or not widget:IsProtected(), "Cannot insecurely hook "..widget:GetName()..":"..method.." because it is tainted secure method.")
    
    -- Func can be an actual function or a name of one in our Addon
    local hookedFunc = nil
    if type(func) == "function" then
        hookedFunc = func
    else
        if self[func] then
            hookedFunc = function(...) self[func](self, ...) end
        else
            error("Function "..func.." does not exist in "..AddonName)
        end
    end

    -- Set up the Pre-Hook
    local originalFunc = widget:GetScript(method) or function() end
    local newFunc = function(...)
        -- Call our function
        hookedFunc(...)
        -- Return the original
        return originalFunc(...)
    end

    -- Set the script
    widget:SetScript(method, newFunc)
end


-- This does a pre-hook on a function. This is an insecure hook. It also does not alter the behavior of the original.
-- This allows you to capture state and know when something happens before the result is populated somewhere, which
-- a secure hook (which is a post-hook) does not allow. Some functions may not allow this type of hook.
-- This wrapper intentionally does not alter the behavior of the original.
function Addon:PreHookFunction(funcTable, functionName, hookFunction)
    -- Fail fast if bad arguments so developers can find this error quickly and easily, and we dont have to worry about it later.
    assert(not funcTable or type(funcTable) == "table", "funcTable must be a table")
    assert(functionName and type(functionName) == "string", "Invalid argument to PreHookFunction: functionName cannot be nil.")
    assert(hookFunction and (type(hookFunction) == "function" or type(hookFunction) == "string"), "Invalid argument to PreHookFunction: Function must be a function or string.")

    -- Func can be an actual function or a name of one in our Addon
    local hookedFunc = nil
    if type(hookFunction) == "function" then
        hookedFunc = hookFunction
    else
        if self[hookFunction] then
            hookedFunc = function(...) self[hookFunction](self, ...) end
        else
            error("Function "..hookFunction.." does not exist in "..AddonName)
        end
    end

    -- Set up the Pre-Hook
    local originalFunc = nil
    if funcTable then
        originalFunc = funcTable[functionName]
    else
        originalFunc = _G[functionName]
    end
    local newFunc = function(...)
        -- Call our function
        hookedFunc(...)
        -- Return the original
        return originalFunc(...)
    end
 
    -- Hook it
    if funcTable then
        funcTable[functionName] = newFunc
    else
        _G[functionName] = newFunc
    end
end


-- This wraps the Blizzard hooksecurefunc in the same syntactic sugar as above.
function Addon:SecureHookFunction(funcTable, functionName, hookFunction)
    -- Fail fast if bad arguments so developers can find this error quickly and easily, and we dont have to worry about it later.
    assert(not funcTable or type(funcTable) == "table", "funcTable must be a table")
    assert(functionName and type(functionName) == "string", "Invalid argument to SecureHookFunction: functionName cannot be nil.")
    assert(hookFunction and (type(hookFunction) == "function" or type(hookFunction) == "string"), "Invalid argument to SecureHookFunction: Function must be a function or string.")

    -- Func can be an actual function or a name of one in our Addon
    if type(hookFunction) == "function" then
        hooksecurefunc(funcTable, functionName, hookFunction)
    else
        if self[hookFunction] then
            hooksecurefunc(funcTable, functionName, function(...) self[hookFunction](self, ...) end)
        else
            error("Function "..hookFunction.." does not exist in "..AddonName)
        end
    end
end