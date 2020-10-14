-- Useful helper functions prior to other files loading. Ideally this is the first file loaded after Localization, right before Config
local Addon, L = _G[select(1,...).."_GET"]()

-- Simplified print to DEFAULT_CHAT_FRAME. Replaces need for AceConsole with 4 lines. Thanks AceConsole for the inspiriation and color code.
-- Assume if multiple arguments it is a format string.
local printPrefix = string.format("%s[%s%s%s]%s%s%s", HIGHLIGHT_FONT_COLOR_CODE, ORANGE_FONT_COLOR_CODE, L["ADDON_NAME"], HIGHLIGHT_FONT_COLOR_CODE, FONT_COLOR_CODE_CLOSE, FONT_COLOR_CODE_CLOSE, " ")
function Addon:Print(msg, ...)
    DEFAULT_CHAT_FRAME:AddMessage(printPrefix .. string.format(msg, ...))
end

function Addon:IsShadowlands()
    return select(4, GetBuildInfo()) >= 90000
end

-- Gets the version of the addon
function Addon:GetVersion()
    local version = GetAddOnMetadata(self.c_AddonName, "version")
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


