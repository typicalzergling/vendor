local AddonName, Addon = ...
local L = Addon:GetLocale()

-- Will take whatever item is being moused-over and add it to the Always-Sell list.
function Addon:AddTooltipItemToSellList(list)
    -- Get the item from
    name, link = GameTooltip:GetItem();
    if not link then
        self:Print(string.format(L["TOOLTIP_ADDITEM_ERROR_NOITEM"], list))
        return
    end

    -- Add the link to the specified blocklist.
    local retval = self:ToggleItemInBlocklist(list, link)
    if retval == 1 then
        self:Print(string.format(L["CMD_SELLITEM_ADDED"], tostring(link), list))
    elseif retval == 2 then
        self:Print(string.format(L["CMD_SELLITEM_REMOVED"], tostring(link), list))
    end
end

-- Called by keybinds to direct-add items to the blocklists
function Addon:AddTooltipItemToAlwaysSellList()
    self:AddTooltipItemToSellList(self.c_AlwaysSellList)
end

function Addon:AddTooltipItemToNeverSellList()
    self:AddTooltipItemToSellList(self.c_NeverSellList)
end

-- Hooks for item tooltips
function Addon:OnTooltipSetItem(tooltip, ...)
    -- Insecure hook, so wrap what we call in xpcall to prevent taint.
    local status, err = xpcall(
        function(t, ...)
            local name, link = t:GetItem()
            if name then
                Addon:AddItemTooltipLines(t, link)
            end
        end,
        CallErrorHandler, tooltip)
    if not status then
        Addon:Debug("tooltiperrors", "Error executing OnTooltipSetItem: ", tostring(err))
    end
end

-- Result cache
local itemLink = nil
local result = 0
local blocklist = nil
local ruleId = nil
local ruleName = nil
local ruleType = nil
local callCount = 0
local recipe = false

-- Forcibly clear the cache, used when Blocklist or rules change to force a re-evaluation and update the tooltip.
function Addon:ClearTooltipResultCache()
    itemLink = nil
    result = 0
    blocklist = nil
    ruleId = nil
    ruleName = nil
    ruleType = nil
    callCount = 0
    recipe = false
    Addon:Debug("tooltip", "TooltipResultCache cleared.")
end

function Addon:AddItemTooltipLines(tooltip, link)
    local profile = self:GetProfile();
    -- Check Cache if we already have data for this item from a previous update.
    -- If it isn't in the cache, we need to evaluate this item/link.
    -- If it is in the cache, then we already have our answer, so don't waste perf re-evaluating.
    -- TODO: We could keep a larger cache so we don't re-evaluate an item unless inventory changed, the rules changed, or the blocklist changed.
    if not (itemLink == link) then
        -- Evaluate the item
        local item = self:GetItemPropertiesFromTooltip(tooltip, link)
        result, ruleId, ruleName, ruleType  = self:EvaluateItem(item)

        -- Check if the item is in the Always or Never sell lists
        -- TODO: Change this to return a table of lists to which this item belongs.
        blocklist = self:GetBlocklistForItem(link)

        -- This is for suppressing every other call due to recipe items calling this for the embedded tooltip item also.
        callCount = 0
        if item and item.TypeId == 9 then
            recipe = true
        else
            recipe = false
        end

        -- Mark it as the current cached item.
        itemLink = link
        self:Debug("tooltip", "Cached item for tooltip: %s, [%s, %s, %s, %s]", link, tostring(result), tostring(ruleId), tostring(ruleName), tostring(ruleType))
    end

    -- Check for recipe item, which means this will be called twice
    -- We want to skip the first call, which is the embedded tooltip item.
    callCount = callCount + 1
    if recipe then
        if callCount % 2 == 1 then
            return
        end
    end

    -- Add lines to the tooltip we are scanning after we've scanned it.
    -- We always add if the item is in the Always-Sell or Never-Sell list.
    if blocklist then
        -- Add Addon state to the tooltip.
        -- TODO: After blocklist is changed to a table, iterate over each list to which the item belongs and add to
        -- the tooltip.
        if blocklist == self.ListType.SELL then
            tooltip:AddLine(L["TOOLTIP_ITEM_IN_ALWAYS_SELL_LIST"])
        elseif blocklist == self.ListType.KEEP then
            tooltip:AddLine(L["TOOLTIP_ITEM_IN_NEVER_SELL_LIST"])
        elseif blocklist == self.ListType.DESTROY then
            tooltip:AddLine(L["TOOLTIP_ITEM_IN_DESTROY_LIST"])
        end

        -- TODO: For custom lists, need to enumerate and list memberships.
    end

    -- Add a warning that this item will be auto-sold on next vendor trip.
    if (profile:GetValue(Addon.c_Config_Tooltip)) then
        if result == 1 then
            tooltip:AddLine(string.format("%s%s%s", RED_FONT_COLOR_CODE, L["TOOLTIP_ITEM_WILL_BE_SOLD"], FONT_COLOR_CODE_CLOSE))
        elseif result == 2 then
            tooltip:AddLine(string.format("%s%s%s", RED_FONT_COLOR_CODE, L["TOOLTIP_ITEM_WILL_BE_DELETED"], FONT_COLOR_CODE_CLOSE))    
        end
    end
    
    -- Add Advanced Rule information if set and available.
    if (ruleName and profile:GetValue(Addon.c_Config_Tooltip_Rule)) then
        if result == 1 then
            tooltip:AddLine(string.format(L["TOOLTIP_RULEMATCH_SELL"], ruleName))
        elseif result == 2 then
            tooltip:AddLine(string.format(L["TOOLTIP_RULEMATCH_DESTROY"], ruleName))
        else
            tooltip:AddLine(string.format(L["TOOLTIP_RULEMATCH_KEEP"], ruleName))
        end
    end


    --@debug@
    if (ruleId) then
        -- If we had a rule match (make a choice) then add it to the tooltip, if we didn't get a match then
        -- no line means we didn't match anything.
        tooltip:AddLine(string.format("%s RuleId: %s[%s] %s%s",L["ADDON_NAME"], ACHIEVEMENT_COLOR_CODE, ruleType, ruleId, FONT_COLOR_CODE_CLOSE))
    end
    --@end-debug@
end

