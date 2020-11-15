-- Useful helper functions prior to other files loading. Ideally this is the first file loaded after Localization, right before Config
local AddonName, Addon = ...

function Addon:IsShadowlands()
    return select(4, GetBuildInfo()) >= 90000
end

-- Gets the version of the addon
function Addon:GetVersion()
    local version = GetAddOnMetadata(AddonName, "version")
    --@debug@
    if version == "@project-version@" then version = "Debug" end
    --@end-debug@
    return version
end

-- Counts size of the table
function Addon:TableSize(T)
    local count = 0
    if (T) then
        for _ in pairs(T) do count = count + 1 end
    end
    return count
end

-- Merges the contents of source into dest, source can be nil
function Addon:MergeTable(dest, source)
    if source then
        for key, value in pairs(source) do
            rawset(dest, key, value)
        end
    end
end

-- Table deep copy, as seen on StackOverflow
-- https://stackoverflow.com/questions/640642/how-do-you-copy-a-lua-table-by-value
function Addon.DeepTableCopy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[Addon.DeepTableCopy(k, s)] = Addon.DeepTableCopy(v, s) end
    return res
end

-- Helper function for invoking a method on the specified object,
-- if the function doesn't exist this does nothing, otherwise it
-- invokes the function and wraps it.
function Addon.invoke(object, method, ...)
    if (type(object) == "table") then
        local fn = object[method];
        if (type(fn) == "function") then
            local results = { xpcall(fn, CallErrorHandler, object, ...) };
            if (results[1]) then
                table.remove(results, 1);
                return unpack(results);
            elseif (not results[1] and results[2]) then
                Addon:Debug("errors", "Failed to invoke '%s': %s", method, results[2]);            
            end
        end 
    end
	return nil;
end

local TypeInformation = {};

--[[===========================================================================
   | Create a new "class" which may or may not raise events.  
   ==========================================================================]]
function Addon.object(typeName, instance, API, events)
    local fullName = string.format("%s.%s", AddonName, typeName);
    local fullApi = rawget(TypeInformation, fullName);

    if (not fullApi) then
        fullApi = {};

        -- Copy the functions over the API
        for name, value in pairs(API) do
            if (type(value) == "function") then
                fullApi[name] = value;
            else
                --@debug@
                error(string.format("Type '%s' API contains member '%s' which is not a function", fullName, name));
                --@end-debug@                    
            end
        end

        -- If the object has events then mixin the callback registry
        if (type(events) == "table") then
            fullApi.RegisterCallback = CallbackRegistryMixin.RegisterCallback;
            fullApi.TriggerEvent = CallbackRegistryMixin.TriggerEvent;
            fullApi.UnregisterCallback = CallbackRegistryMixin.UnregisterCallback;
        end

        rawset(TypeInformation, fullName, fullApi);
    end

    -- If the object has events, then register them
    if (type(events) == "table") then
        CallbackRegistryMixin.OnLoad(instance);
        CallbackRegistryMixin.SetUndefinedEventsAllowed(instance, false);
        CallbackRegistryMixin.GenerateCallbackEvents(instance, events);
    end
    
    if (Addon.Debug) then
        --@debug@
        local thunk = {};
        return setmetatable(thunk, {
            __metatable = fullName,
            __index = function(self, key)
            -- Check for a member function
                local member = rawget(fullApi, key);
                if (type(member) == "function") then
                    return function(...) 
                            return member(...);
                        end;
                else
                    member = rawget(instance, key);
                    if (member ~= nil) then
                        return member;
                    end

                    error(string.format("Type '%s' has no member '%s'", typeName, key));
                end
            end,
            __newindex = function(self, key, value)
                -- Don't allow new fields/members that didn't exist when
                -- we were created.
                if (rawget(instance, key) == nil) then
                    error(string.format("New members are not allowed on '%s' attempted to set '%s'", typeName, key));                
                else
                    rawset(instance, key, value);
                end
            end,
        })
        --@end-debug@
    end

    return setmetatable(instance, {
        __metatable = fullName,
        __index = fullApi,
    });
end