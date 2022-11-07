local _, Addon = ...;

-- Check if the character is a space
local function isspace(c)
    return (c == '\n') or (c == '\t') or (c == '\r') or (c == ' ');
end

-- Trim the front of a string
if (type(Addon.StringLTrim) ~= "function") then
	Addon.StringLTrim = function(str)
		local s = 1;
		local l = string.len(str);

		while (isspace(string.sub(str, s, s)) and s <= l) do
			s = s + 1;
		end

		return string.sub(str, s, l);
	end
end

-- Trim the end of a string
if (type(Addon.StringRTrim) ~= "function") then
	Addon.StringRTrim = function(str)
		local e = string.len(str);
		while (isspace(string.sub(str, e, e)) and (e >= 1)) do
			e = e - 1;
		end
		return string.sub(str, 1, e);
	end
end

-- Trim both the front and end of a string.
if (type(Addon.StringTrim) ~= "function") then
	Addon.StringTrim = function(str) 
		return Addon.StringLTrim(Addon.StringRTrim(str));
	end
end


-- Add Addon.TableForEach
if (type(Addon.TableForEach) ~= "function") then
	Addon.TableForEach = function(t, c, ...) 
		assert(type(t) == "table");
        assert(type(c) == "function");
        if (t and table.getn(t)) then
			for k, v in pairs(t) do
                xpcall(c, CallErrorHandler, v, k, ...);
            end
        end
    end;
end

-- Add Addon.TableHasKey
if (type(Addon.TableHasKey) ~= "function") then
	Addon.TableHasKey = function(t, k)
		return (t[k] ~= nil);
	end
end

-- Add Addon.TableFind
if (type(Addon.TableFind) ~= "function") then
	Addon.TableFind = function(t, p, ...)
		if (not t) then
			return nil;
		end

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
end

-- Add Addon.TableFilter
if (type(Addon.TableFilter) ~= "function") then
	Addon.TableFilter = function(t, p, ...)
		local f = {};
		if (not t) then
			return f;
		end

		assert(type(t) == "table");
		assert(type(p) == "function");
		for k, v in pairs(t) do
			local r, f = xpcall(p, CallErrorHandler, v, k, ...);
			if (r and f) then
				f[k] = v;
			end
		end
		return f;
	end
end

-- Add Addon.DeepTableCopy
if (type(Addon.DeepTableCopy) ~= "function") then
	Addon.DeepTableCopy = function(t)
		assert(type(t) == "table");
		return Addon.DeepTableCopy(t);
	end
end