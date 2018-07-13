-- This is a file exclusively for debug channels and functions. On a release build, debug statements are no-op and ignored.
-- This file will exist on a release build so Debug related code in the other files is defined.
Vendor = Vendor or {}

--@debug@
local debugEanbled = nil
local debugRuledEnabled = nil

function Vendor:IsDebug()
    local function update(config)
        debugEnabled = false
        if (config:GetValue("debug")) then
            debugEnabled = true
        end
    end
    if (debugEnabled == nil) then
        local config = Vendor:GetConfig()
        config:AddOnChanged(update)
        update(config)
    end
    return debugEnabled
end

function Vendor:IsDebugRules()
    local function update(config)
        print("update-debugrules")
        debugRulesEnabled = false
        if (config:GetValue("debugrules")) then
            debugRulesEnabled = true
        end
    end
    if (debugRulesEnabled == nil) then
        local config = Vendor:GetConfig()
        config:AddOnChanged(update)
        update(config)
    end
    return debugRulesEnabled
end
--@end-debug@

-- Debug print. On a release build this does nothing.
function Vendor:Debug(msg, ...)
    --@debug@
    if not self:IsDebug() then return end
    self:Print(msg, ...)
    --@end-debug@
end

-- Debug print function for rules
function Vendor:DebugRules(msg, ...)
    --@debug@
    if (self:IsDebugRules()) then
        self:Print(" %s[Rules]%s " .. msg, ACHIEVEMENT_COLOR_CODE, FONT_COLOR_CODE_CLOSE, ...)
    end
    --@end-debug@
end




--@do-not-package@
-- Beyond this point are debug related functions that are not packaged.

function Vendor:DumpTooltipItemProperties()
    local props = self:GetItemProperties(GameTooltip)
    self:Print("Properties for "..props["Link"])

    -- Print non-derived properties first.
    for i, v in Vendor.orderedPairs(props) do
        if not string.find(i, "^Is") then
            self:Print("    ["..tostring(i).."] "..tostring(v))
        end
    end

    -- Print all the derived properties ("Is*") together.
    for i, v in Vendor.orderedPairs(props) do
        if string.find(i, "^Is") then
            self:Print("    ["..tostring(i).."] "..tostring(v))
        end
    end
end



-- Sorted Pairs from Lua-Users.org. We use this for pretty-printing tables for debugging purposes.

function Vendor.__genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

function Vendor.orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = Vendor.__genOrderedIndex( t )
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1,table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function Vendor.orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return Vendor.orderedNext, t, nil
end

--@end-do-not-package@
