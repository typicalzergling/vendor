-- Item cache used to store results of scans and track item state for efficient retrieval. This is for bags only, not tooltips.
local AddonName, Addon = ...
local L = Addon:GetLocale()

local debugp = function (...) Addon:Debug("evaluate", ...) end

-- This is a wrapper for Evaluate Item that takes GetItemProperties parameters as input.
-- This is for use cases where you do not need the item itself and just want to know
-- the result. This is also the public api implementaion.
function Addon:EvaluateSource(arg1, arg2)
    return Addon:EvaluateItem(Addon:GetItemProperties(arg1, arg2))
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
function Addon:EvaluateItem(item, ignoreCache)

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
    if not ignoreCache then
        local cachedEntry = Addon:GetItemResultFromItemResultCacheByGUID(item.GUID)
        if cachedEntry then
            debugp("Retrieved %s from cache with result: %s - [%s] %s",
                tostring(item.Link),
                tostring(cachedEntry.Result.Action),
                tostring(cachedEntry.Result.RuleType),
                tostring(cachedEntry.Result.Rule)
            )
            -- Return deep copy so they don't ruin our actual data with this.
            return Addon.DeepTableCopy(cachedEntry.Result)
        end
    end

    if (not self.ruleManager) then
        self.ruleManager = Addon.RuleManager:Create();
    end
    
    -- First return value of rules manager is a boolean on whether it matched a rule.
    -- We must decode it into an integer Action:
    -- 0 = No action
    -- 1 = Item will be sold
    -- 2 = Item will be deleted
    local match = nil
    match, result.RuleID, result.Rule, result.RuleType = self.ruleManager:Run(item)
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
        elseif Addon.RuleType.DESTROY == ruletype then
            result.Action = Addon.ActionType.DESTROY
        elseif Addon.RuleType.KEEP == ruletype then
            result.Action = Addon.ActionType.NONE
        else
            error("Unknown ruletype: "..tostring(ruletype))
        end
    end

    --[[
    self:Debug("resultcache", "Adding %s to cache with result: %s - [%s] %s", tostring(item.Link), tostring(retval), tostring(ruletype), tostring(rule))
    Addon:AddResultToCache(item.GUID, retval, ruleid, rule, ruletype, item.Id)
    ]]
    -- TODO: We do not want to add the cache entry here, but for the external API wrapper, we should.
    debugp("Result: %s - %s", tostring(result.Action), tostring(result.RuleType))
    return result
end

-- Returns num kept, num sold, and num destroyed for a given item id.
-- Note that if this is called while evaluations are still occurring, it will
-- give you a running count, thus far, of items that have been kept/sold/destroyed
-- for this particular item id. This is the basis for the "keep at least N" type
-- rule behavior.
function Addon:GetResultCountsForItemId(id)
    local resultCount = {}
    resultCount[0] = 0
    resultCount[1] = 0
    resultCount[2] = 0

    for guid, entry in pairs(resultCache) do
        -- Find entries with the specified item ID
        if entry.Id == id then
            resultCount[entry.Result] = resultCount[entry.Result] + 1
        end
    end
    -- Num Kept, Num Sold, Num Destroyed
    return resultCount[0], resultCount[1], resultCount[2]
end

function Addon:AddResultToCache(guid, result, ruleid, rule, ruletype, id)
    assert(type(guid) == "string" and type(result) == "number")

    local cacheEntry = {}
    cacheEntry.Result = result
    cacheEntry.RuleId = ruleid
    cacheEntry.Rule = rule
    cacheEntry.RuleType = ruletype
    cacheEntry.Id = id

    assert(guid ~= "")
    self:Debug("resultcache", "Cached result: %s = %s", guid, result)
    resultCache[guid] = cacheEntry
end



local escache = {}
local escachestale = true
function Addon:ClearEvaluationStatusCache()
    escache = {}
    escachestale = true
end

function Addon:GetEvaluationStatus()
    print("Evaluate Status")
    if escachestale then
        -- No cache, generate the status.
        local count = 0
        local value = 0
        local tosell = 0
        local todestroy = 0
        local sellitems = {}
        local destroyitems = {}
        for bag=0, NUM_TOTAL_EQUIPPED_BAG_SLOTS  do
            for slot=1, C_Container.GetContainerNumSlots(bag) do
                local item, itemCount = Addon:GetItemPropertiesFromBagAndSlot(bag, slot)
                local result = Addon:EvaluateItem(item)
                
                if result > 0 then
                    count = count + 1
                end

                if result == 1 then
                    value = value + item.TotalValue
                    tosell = tosell + 1
                    table.insert(sellitems, item.Link)
                elseif result == 2 then
                    todestroy = todestroy + 1
                    table.insert(destroyitems, item.Link)
                end
            end
        end
        escache = {}
        escache.count = count
        escache.value = value
        escache.tosell = tosell
        escache.todestroy = todestroy
        escache.sellitems = sellitems
        escache.destroyitems = destroyitems
        escachestale = false
    end

    return escache.count, escache.value, escache.tosell, escache.todestroy, escache.sellitems, escache.destroyitems
end

function Addon:GetEvaluationDetails()
    local results = {}
    for bag=0, NUM_TOTAL_EQUIPPED_BAG_SLOTS  do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local item, itemCount = Addon:GetItemPropertiesFromBagAndSlot(bag, slot)
            if item then
                local result, ruleid, rule, ruletype = Addon:EvaluateItem(item)
                local entry = {}
                entry.GUID = item.GUID
                entry.Id = item.Id
                entry.Count = itemCount
                entry.Result = result
                entry.RuleId = ruleid
                entry.Rule = rule
                entry.RuleType = ruletype
                table.insert(results, entry)
            end
        end
    end
    return results
end

-- This is a bit of a hack to do a call for blizzard to fetch all the item links in our bags to populate the item links.
function Addon:LoadAllBagItemLinks()
    for bag=0, NUM_TOTAL_EQUIPPED_BAG_SLOTS  do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            C_Container.GetContainerItemInfo(bag, slot)
        end
    end
end

-- Placeholder for now
--function Addon:OnBagUpdate(event, bag)
--end