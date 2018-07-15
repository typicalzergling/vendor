local Addon, L, Config = _G[select(1,...).."_GET"]()

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
    -- If we are not auto-selling, do nothing.
    if not self:GetConfig():GetValue("autosell") then return end

    local name, link = tooltip:GetItem()
    if name then
        self:AddItemTooltipLines(tooltip, link)
    end
end

-- Result cache
local itemLink = nil
local willBeSold = nil
local blocklist = nil
local ruleId = nil
local ruleName = nil

-- Forcibly clear the cache, used when Blocklist or rules change to force a re-evaluation and update the tooltip.
function Addon:ClearTooltipResultCache()
    itemLink = nil
    willBeSold = nil
    blocklist = nil
    ruleId = nil
    ruleName = nil
end

function Addon:AddItemTooltipLines(tooltip, link)
    -- Check Cache if we already have data for this item from a previous update.
    -- If it isn't in the cache, we need to evaluate this item/link.
    -- If it is in the cache, then we already have our answer, so don't waste perf re-evaluating.
    -- TODO: We could keep a larger cache so we don't re-evaluate an item unless inventory changed, the rules changed, or the blocklist changed.
    if not (itemLink == link) then
        -- Evaluate the item for sell
        local item = self:GetItemPropertiesFromTooltip(tooltip, link)
        willBeSold, ruleId, ruleName  = self:EvaluateItemForSelling(item)

        -- Check if the item is in the Always or Never sell lists
        blocklist = self:GetBlocklistForItem(link)

        -- Mark it as the current cached item.
        itemLink = link
        --self:Debug("Cached item for tooltip: "..link)
    end

    -- Add lines to the tooltip we are scanning after we've scanned it.
    if (Config:GetValue(Addon.c_Config_Tooltip)) then
        if blocklist then
            -- Add Addon state to the tooltip.
            if blocklist == self.c_AlwaysSellList then
                tooltip:AddLine(L["TOOLTIP_ITEM_IN_ALWAYS_SELL_LIST"])
            else
                tooltip:AddLine(L["TOOLTIP_ITEM_IN_NEVER_SELL_LIST"])
            end
        end

        -- Add a warning that this item will be auto-sold on next vendor trip.
        if willBeSold then
            tooltip:AddLine(string.format("%s%s%s", RED_FONT_COLOR_CODE, L["TOOLTIP_ITEM_WILL_BE_SOLD"], FONT_COLOR_CODE_CLOSE))
            --@debug@
            if (ruleName and Config:GetValue(Addon.c_Config_Tooltip_Rule)) then
                tooltip:AddLine(string.format(L["RULEMATCH_TOOLTIP"], ruleName))
            end
            --@end-debug@
        end
    end

    --@debug@
    if (ruleId) then
        -- If we had a rule match (make a choice) then add it to the tooltip, if we didn't get a match then
        -- no line means we didn't match anything.
        tooltip:AddLine(string.format("%s RuleId: %s[%s]%s",L["ADDON_NAME"], ACHIEVEMENT_COLOR_CODE, ruleId, FONT_COLOR_CODE_CLOSE))
    end
    --@end-debug@
end

--@do-not-package@
function Addon:DumpItemPropertiesFromTooltip()
    Addon:DumpTooltipItemProperties()
end
--@end-do-not-package@
