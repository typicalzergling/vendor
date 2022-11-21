local _, Addon = ...;

-- Check if the character is a space
local function isspace(c)
    return (c == '\n') or (c == '\t') or (c == '\r') or (c == ' ');
end

-- Trim the front of a string
function Addon.StringLTrim(str)
    local s = 1;
    local l = string.len(str);

    while (isspace(string.sub(str, s, s)) and s <= l) do
        s = s + 1;
    end

    return string.sub(str, s, l);
end


-- Gets item ID from an itemstring or item link
-- If a number is passed in it assumes that is the ID
function Addon.GetItemIdFromString(str)
    -- extract the id
    if type(str) == "number" or tonumber(str) then
        return tonumber(str)
    elseif type(str) == "string" then
        return tonumber(string.match(str, "item:(%d+):"))
    else
        return nil
    end
end

-- Trim the end of a string
function Addon.StringRTrim(str)
    local e = string.len(str);
    while (isspace(string.sub(str, e, e)) and (e >= 1)) do
        e = e - 1;
    end
    return string.sub(str, 1, e);
end

-- Trim both the front and end of a string.
function Addon.StringTrim(str)
    return Addon.StringLTrim(Addon.StringRTrim(str));
end

-- Add string splitting based on the specified delimiter.
function Addon.StringSplit(str, delim) 
    local result = {};
    for match in (str .. delim):gmatch("(.-)" .. delim) do
        table.insert(result, match);
    end
    return result;
end

-- Add Addon.TableForEach
function Addon.TableForEach(t, c, ...) 
    if (t) then
        assert(type(t) == "table");
        assert(type(c) == "function");
        if (t and table.getn(t)) then
            for k, v in pairs(t) do
                xpcall(c, CallErrorHandler, v, k, ...);
            end
        end
    end
end

-- Add Addon.TableHasKey
function Addon.TableHasKey(t, k)
    return (t[k] ~= nil);
end

-- Add Addon.TableFind
function Addon.TableFind(t, p, ...)
    assert(type(t) == "table");
    assert(type(p) == "function");
    for k, v in pairs(t) do
        local r, f = xpcall(p, CallErrorHandler, v, k, ...);
        if (r and f) then
            return v, k
        end
    end
    return nil;
end

-- Add Addon.TableFilter
function Addon.TableFilter(t, p, ...)
    assert(type(t) == "table");
    assert(type(p) == "function");
    local f = {};
    for k, v in pairs(t) do
        local r, f = xpcall(p, CallErrorHandler, v, k, ...);
        if (r and f) then
            f[k] = v;
        end
    end
    return f;
end

-- Add Addon.TableMerge
function Addon.TableMerge(...)
    local r = {};
    local args = { ... };
    for _, s in ipairs(args) do 
        if (type(s) == "table") then
            for k, v in pairs(s) do
                r[k] = v;
            end
        end
    end
    return r;
end

-- Gets character name with spaces for pretty-printing.
local characterName = nil
function Addon:GetCharacterFullName()
    if not characterName then
        local name, server = UnitFullName("player")
        -- Sometimes the server or name fails to load, rather than fail in lua,
        -- return empty string and handle it.
        if name and server then
            characterName = string.format("%s - %s", name, server)
        else
            characterName = ""
        end
    end
    return characterName
end

-- Helper function for invoking a method on the specified object,
-- if the function doesn't exist this does nothing, otherwise it
-- invokes the function and wraps it.
function Addon.Invoke(object, method, ...)
    if (type(object) == "table") then
        local fn = method
        if (type(fn) == "string") then
            fn = object[method];
        end
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