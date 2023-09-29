-- Item cache used to store results of scans and track item state for efficient retrieval. This is for bags only, not tooltips.
local AddonName, Addon = ...
local L = Addon:GetLocale()

local debugp = function (...) Addon:Debug("evaluate", ...) end

-- System Def
local Evaluation = {}

function Evaluation:GetDependencies()
    return { "info", "lists", "rules", "interop", "itemproperties"}
end

-- This now takes only a bag and slot
function Evaluation:EvaluateSource(bag, slot)
    Addon:Debug("extensions", "Received call into EvaluateSource")
    local action = 0
    local ruleid = nil
    local name = nil
    local ruletype = nil
    local result = Evaluation:GetItemResultForBagAndSlot(bag, slot)
    if result then
        action = result.Result.Action
        ruleid = result.Result.RuleID
        name = result.Result.Rule
        ruletype = result.Result.RuleType
    end
    return action, ruleid, name, ruletype
end

-- Evaluating items.
-- This is only used for the 'real' rules evaluation, not rules evaluation in the rules editor.
-- Rules for determining if an item should be sold.
-- Action meanings:
-- 0 = No action
-- 1 = Item will be sold
-- 2 = Item will be deleted
-- Both 1 and 2 will evaluate to True, so you can still use this function as a boolean.
-- The itemCount is returned separately since it depends on the source and is not used
-- for rule evaluations.
-- This method always returns a number as the first parameter, but the others may be nil.
function Evaluation:EvaluateItem(item, ignoreCache)
    -- Return a table of data. These are the default "no item" values.
    local result = {}
    result.Action = Addon.ActionType.NONE
    result.RuleID = nil
    result.Rule = nil
    result.RuleType = nil

    -- Check some cases where we know we should never ever sell the item
    if not item then
        return result
    end

    debugp("In Evaluate Item: %s", tostring(item.Link))
    -- Check the Cache for the result if we aren't ignoring it.
    -- We always ignore cache on Classic because a key method to
    -- validate the entry is not available in that version.
    if not ignoreCache and not Addon.Systems.Info.IsClassicEra then
        local cachedEntry = Evaluation:GetItemResultForGUID(item.GUID)
        if cachedEntry then
            debugp("Retrieved %s from cache with result: %s - [%s] %s", tostring(item.Link), tostring(cachedEntry.Result.Action), tostring(cachedEntry.Result.RuleType), tostring(cachedEntry.Result.Rule))
            -- Return deep copy so they don't ruin our actual data with this.
            return Addon.DeepTableCopy(cachedEntry.Result)
        end
    end

    if (not Addon.ruleManager) then
        Addon.ruleManager = Addon.RuleManager:Create();
    end
    
    -- First return value of rules manager is a boolean on whether it matched a rule.
    -- We must decode it into an integer Action:
    -- 0 = No action
    -- 1 = Item will be sold
    -- 2 = Item will be deleted
    local match = nil
    match, result.RuleID, result.Rule, result.RuleType = Addon.ruleManager:Run(item)
    if match then
        if Addon.RuleType.SELL == result.RuleType then
            if item.IsUnsellable then
                -- Items in sell list but are unsellable take no action.
                result.Action = Addon.ActionType.NONE
                result.RuleID = nil
                result.Rule = nil
                result.RuleType = nil
                debugp("Item %s is unsellable, changing result to no action.", tostring(item.Link))
            else
                result.Action = Addon.ActionType.SELL
            end
        elseif Addon.RuleType.DESTROY == result.RuleType then
            result.Action = Addon.ActionType.DESTROY
        elseif Addon.RuleType.KEEP == result.RuleType then
            result.Action = Addon.ActionType.NONE
        else
            error("Unknown ruletype: "..tostring(result.RuleType))
        end
    end

    --[[
    Addon:Debug("resultcache", "Adding %s to cache with result: %s - [%s] %s", tostring(item.Link), tostring(retval), tostring(ruletype), tostring(rule))
    Addon:AddResultToCache(item.GUID, retval, ruleid, rule, ruletype, item.Id)
    ]]
    -- TODO: We do not want to add the cache entry here, but for the external API wrapper, we should.
    debugp("Result: %s - %s", tostring(result.Action), tostring(result.RuleType))
    return result
end

function Evaluation:Startup(register)
    register({
        "EvaluateSource",                   -- Wrapped in Public API
        "ClearItemResultCacheByItemId",     -- Forced Cache Clear   - Used by Blocklists
        "ClearItemResultCache",             -- Forced Cache Clear   - Used in many places
        "GetItemResultForBagAndSlot",       -- Get Result - BagAndSlot
        "GetItemResultForTooltip",          -- Get Result - Tooltip
        "GetItemResultForLocation",         -- Get Result - Location
        "GetItemResultForGUID",             -- Get Result - GUID
        "IsBagAndSlotRefreshNeeded",        -- Refresh Test         - Used by Refresh
        "RefreshBagAndSlot",                -- Refresh Bag item     - Used by Refresh
    })
end

function Evaluation:Shutdown()
end

Addon.Systems.Evaluation = Evaluation