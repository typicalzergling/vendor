--[[===========================================================================
    | publicAPI.lua
    |   This module is for a richer API experience, allowing targeted access to
    |    certain data, and providing enumeration and documentation of your API.
    |
    | This extends the base public exposure (which is Addon.Public) in three
    | important ways.
    |   1) It hides the public table from queries unless you know the method
    |      directly. This in effect makes all of your public values to be
    |      undocumented by default, but accessible if the caller knows it.
    |   2) It adds methods that control aliasing and querying of Addon.Public.
    |      You can still directly add methods to Addon.Public to make something
    |      public, but it will be undocumented (not easily discoverable).
    |   3) It adds methods to get and print the documentation. This can
    |      be exposed as a command-line interface, or a rich help page inside
    |      a UI - however you choose.
    |
    | Methods
    |   MakePublic      -- Aliases a value into Addon.Public and documents it.
    |   IsPublic        -- Queries if a value or path is in Addon.Public.
    |   GetPublic       -- Gets a table representing your entire public API.
    |   PrintPublic     -- Prints to console locale-neutral documentation.
    |
    | As with other skeleton files, this uses asserts and other checking to
    | help avoid making programming mistakes and has the principle of failing-
    | fast so you quickly find your errors rather than letting them compound.
    =======================================================================--]]

local AddonName, Addon = ...

--[[===========================================================================
    | This protects Addon.Public in two ways:
    |   1) It prevents you from overwriting your own API accidentally.
    |   2) It hides your entire API from direct query from other addons.
    |
    | If you table dump AddonName for example, you will get an empty table, 
    | because Addon.Public is actually empty. You can index into it, but you
    | must know the key, and you cannot enumerate the keys. To discover the
    | API, a user must use one of the supported methods.
    |
    | In effect this makes your entire public API undocumented by default, 
    | unless you choose to document it. This is a decent protective measure
    | against other addons. And it should be obvious to any addon developer 
    | using an undocumented API is risky and may break at any time.
    =======================================================================--]]
Addon.Public = {}
local addonPublic = Addon.Public    -- The real public API is now hidden.
Addon.Public = {}                   -- Aaaaaaaand it's gone.
_G[AddonName] = Addon.Public        -- Update the global reference.
local addonPublicMetaTable = {
    __call = function (t, ...)
        Addon:PrintPublic()
    end,
    __index = function (t, k)
        return addonPublic[k]
    end,
    __newindex =
        function(t, k, v)
            if not addonPublic[k] then
                rawset(addonPublic, k, v)
            else
                error("Addon.Public name "..tostring(k).." already exists.")
            end
        end,
    __metatable = AddonName,
}
setmetatable(Addon.Public, addonPublicMetaTable)

--[[===========================================================================
    | Helper which takes a path and returns the corresponding table value for
    | that path. Returns nil if the path isn't in the table. Used for looking
    | up a path key in the public API to a corresponding actual leaf node in
    | the public API tree.
    =======================================================================--]]
local function getKeyValueFromPath(path, tbl)
    local value = tbl
    local key = nil
    for token in string.gmatch(path, "[^%.]+") do
        key = token
        value = value[key]
        if not value then
            return nil
        end
    end
    return key, value
end

--[[===========================================================================
    | MakePublic
    |   This allows you to make anything you want public and cleanly alias it
    |   into Addon.Public while avoiding collisions. It also facilitates adding
    |   clean documentation for your API to expose up into UI or commands.
    |
    | It is recommended that if you intend to pass back internal table data to
    | external callers, you should make a deep copy unless you expect them
    | to modify the data. You can also set metatables for read-only access,
    | but this is not fool proof. Passing a copy is reliable (at a perf cost).
    |
    | Your public API access format will be: AddonName().name = value
    =======================================================================--]]
local publicAPI = {}                      -- This will hold our public API documentation.
function Addon:MakePublic(name, value, title, documentation)
    assert(type(name) == "string", "Invalid parameter: Name must be a string.")
    assert(string.len(name) > 0, "Invalid parameter: Name length must be greater than zero.")
    assert(type(title) == "string", "Invalid parameter: Title must be a string.")
    assert(type(documentation) == "string", "Invalid parameter: Documentation must be a string.")
    if value then
        assert(not Addon.Public[name], "MakePublic: Name '"..name.."' is already in use.")
    end
    assert(not publicAPI[name], "MakePublic: Name '"..name.."' is already in use.")

    -- If there is no value provided, then we assume the value already exists,
    -- and we are adding or updating documentation to a path. Ensure the path
    -- corresponds to a valid value in the public API.
    local targetKey = name
    local targetValue = value
    if not targetValue then
        targetKey, targetValue = getKeyValueFromPath(name, addonPublic)
    end
    assert(targetValue, "Invalid parameter: value by that path name does not exist in Addon.Public")

    -- If a value was provided and we got this far, alias the value into Addon.Public
    if value then
        -- Validate the string to make sure a path wasn't passed in.
        assert(not string.find(name, '%.'), "Invalid character in name: .")
        Addon.Public[name] = value
    end
    
    -- Add the documentation to the documentation table for the name/path provided.
    publicAPI[name] = {
        ["title"] = title,
        ["documentation"] = documentation
    }
end

--[[===========================================================================
    | IsPublic
    |   Query if something is in the public API and whether is is documented.
    |
    | Usage:
    |   public, documented = IsPublic(path)
    |
    | Returns:
    |   public - [boolean] True if the name is in the public API.
    |   documented - [boolean] True if the name is documented.
    =======================================================================--]]
function Addon:IsPublic(path)
    assert(type(path) == "string", "Invalid parameter: path must be a string.")
    local _, targetValue = getKeyValueFromPath(path, addonPublic)
    local documented = not not publicAPI[path]
    local undocumented = not not targetValue
    return (documented or undocumented), documented
end

--[[===========================================================================
    | GetPublic
    |   This is for pulling the raw API documentation for display in UI.
    |   It does not return the actual API, but rather the types of data and
    |   information about the API.
    |
    | Returns:
    |   A sorted (by path) table of API entries with the following fields:
    |       Name            -- Name of the value
    |       Path            -- Full path of the Value 
    |       Level           -- Depth of the Value (for indentation)
    |       Type            -- Type of Value (function, table, etc)
    |       Title           -- Title specified in MakePublic
    |       Documentation   -- Documentation specified in MakePublic
    |
    | Note: Path includes the AddonName root.
    =======================================================================--]]
function Addon:GetPublic(showUndocumented)

    local seen = {}
    local keys = {}
    local fullAPI = {}

    -- Build the information from MakePublic
    -- Value is assumed to be a table that has a non-nil tbl.value key
    local function getAPIInfo(name, parent, value)
    
        -- Cycle detection; the API must be a DAG
        if type(value) == "table" then
            if seen[value] then
                -- Detected a cycle. This is a programmer mistake.
                return
                --error("Detected a cycle at "..entry.Path)
            else
                seen[value] = true
            end
        end
        
        if not (type(name) == "string") then
            return
        end
    
        local entry = {}
        if parent then
            entry.Path = string.format("%s.%s", parent.Path, name)
            entry.Level = parent.Level + 1
        else
            entry.Path = name
            entry.Level = 0
        end

        entry.Name = name
        entry.Type = type(value)
        
        -- Get documentation if this path has it
        -- We need to strip out the AddonName from the path since that is
        -- not in our publicAPI lookup
        local apiLookupName = string.gsub(entry.Path, "^"..AddonName.."%.", "")
        local docs = publicAPI[apiLookupName]
        if docs then
            entry.Title = docs.title
            entry.Documentation = docs.documentation
        end
            
        -- Add it to the fullAPI
        fullAPI[entry.Path] = entry
        
        -- Add it to the final key list to be returned if it is documented or
        -- if we are including undocumented APIs.
        if showUndocumented or entry.Documentation then
            table.insert(keys, entry.Path)
        end
        
        -- If this was a table, walk the tree.
        -- Cycle detection will stop if we repeat a table.
        if entry.Type == "table" then
            for k, v in pairs(value) do
                getAPIInfo(k, entry, v)
            end
        end
    end
    
    -- Build the API from what was in Public
    getAPIInfo(AddonName, nil, addonPublic)

    -- Now build the sorted table.
    local sortedApi = {}
    table.sort(keys)
    for k, v in ipairs(keys) do
        table.insert(sortedApi, fullAPI[v])
    end
    
    return sortedApi
end

--[[===========================================================================
    | PrintPublic
    |   A simple implementation of API documentation. This demonstrates how you
    |   can easily display the API using GetPublic()
    |
    | Parameters:
    |   showUndocumented    -- Include undocumented values in the output
    |   showTree            -- Prints output as a tree instead of a path list
    |
    | Note: This method is called for AddonName() with no arguments to print
    | the documented public API as a built-in reference to developers.
    =======================================================================--]]
function Addon:PrintPublic(showUndocumented, showTree)
    local api = self:GetPublic(showUndocumented)
    
    local color = Addon.c_APIMethodColorCode

    -- Tree view w/ indentation
    if showTree then
        for k, v in ipairs(api) do
            local level = v.Level
            local indent = ""
            while level > 0 do
                indent = indent.."    "
                level = level - 1
            end
            self:Print("%s%s [%s]",indent, v.Name, v.Type)
        end

    -- List view with full paths
    else
        for k, v in ipairs(api) do
            local suffix = ""
            if v.Type == "function" or v.Level == 0 then
                suffix = "()"
            end
            if v.Title then
                self:Print("%s%s%s%s - %s", color, v.Path, suffix, FONT_COLOR_CODE_CLOSE, v.Title)
            else
                self:Print("%s%s%s%s", color, v.Path, suffix, FONT_COLOR_CODE_CLOSE)
            end
            if v.Documentation then
                self:Print("    %s", v.Documentation)
            end
        end
    end
end
