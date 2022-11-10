local AddonName, Addon = ...
local L = Addon:GetLocale()

-- Will take whatever item is being moused-over and add it to the Always-Sell list.
function Addon:AddTooltipItemToList(list)
    -- Get the item from
    name, link = GameTooltip:GetItem();
    if not link then
        self:Print(string.format(L["TOOLTIP_ADDITEM_ERROR_NOITEM"], list))
        return
    end

    -- Add the link to the specified blocklist.
    local retval = self:ToggleItemInBlocklist(list, link)
    if retval == 1 then
        self:Print(string.format(L["CMD_LISTTOGGLE_ADDED"], tostring(link), list))
    elseif retval == 2 then
        self:Print(string.format(L["CMD_LISTTOGGLE_REMOVED"], tostring(link), list))
    end
end

-- Called by keybinds to direct-add items to the blocklists
function Addon:AddTooltipItemToSellList()
    self:AddTooltipItemToList(self.ListType.SELL)
end

function Addon:AddTooltipItemToKeepList()
    self:AddTooltipItemToList(self.ListType.KEEP)
end

function Addon:AddTooltipItemToDestroyList()
    self:AddTooltipItemToList(self.ListType.DESTROY)
end

-- Result cache
local itemGUID = nil
local result = 0
local blocklist = nil
local ruleId = nil
local ruleName = nil
local ruleType = nil
local callCount = 0
local recipe = false

-- Forcibly clear the cache, used when Blocklist or rules change to force a re-evaluation and update the tooltip.
function Addon:ClearTooltipResultCache()
    itemGUID = nil
    result = 0
    blocklist = nil
    ruleId = nil
    ruleName = nil
    ruleType = nil
    Addon:Debug("tooltip", "TooltipResultCache cleared.")
end

local function addItemTooltipLines(tooltip, tooltipData)
    if not tooltip or tooltip:IsForbidden() or not tooltipData or not tooltipData.guid then 
        -- No guid or forbidden or tooltip is a silent fail out.
        return nil
    end

    if not tooltip:IsShown() then return nil end

    -- Due to blizzard weirdness with locations not controlled by the player, we need to
    -- skip over any locations not owned by the player or the DoesItemExist() method will
    -- fail because it isn't in control of the player. Probably a blizzard bug, but alas
    -- we must work around it. Our workaround logic here ist hat we will only put tooltips
    -- on items that have a bag and slot or inventory id (i.e. equipped or in player bags).
    local location = C_Item.GetItemLocation(tooltipData.guid)
    if not location or not location:IsBagAndSlot() then
        return nil
    end


    local profile = Addon:GetProfile();

    -- We have a simple cache here for performance and so we don't constantly re-evaluate the same item repeatedly.
    -- Tooltips execute many times per second. If you hold your mouse over an item, it will keep generating a new
    -- tooltip, which will call this code over and over again, even when the item is the same item. Therefore,
    -- we will cache the result as you mouse over each item and only re-update a tooltip when the item changes
    -- or if rules change (which would clear the tooltip result cache).
    if itemGUID ~= tooltipData.guid then
        local item = Addon:GetItemForTooltip(tooltipData)
        itemGUID = item.Item.GUID
        result = item.Result.Action
        ruleId = item.Result.RuleID
        ruleName = item.Result.Rule
        ruleType = item.Result.RuleType

        -- Check if the item is in the Always or Never sell lists
        -- TODO: Change this to return a table of lists to which this item belongs.
        blocklist = Addon:GetBlocklistForItem(item.Item.Link)
        Addon:Debug("tooltip", "Cached item for tooltip: %s, [%s, %s, %s, %s]", item.Item.Link, tostring(result), tostring(ruleId), tostring(ruleName), tostring(ruleType))
    end

    -- Add lines to the tooltip we are scanning after we've scanned it.
    -- We always add if the item is in the Always-Sell or Never-Sell list.
    if blocklist then
        -- Add Addon state to the tooltip.
        -- TODO: After blocklist is changed to a table, iterate over each list to which the item belongs and add to
        -- the tooltip.
        if blocklist == Addon.ListType.SELL then
            tooltip:AddLine(L["TOOLTIP_ITEM_IN_ALWAYS_SELL_LIST"])
        elseif blocklist == Addon.ListType.KEEP then
            tooltip:AddLine(L["TOOLTIP_ITEM_IN_NEVER_SELL_LIST"])
        elseif blocklist == Addon.ListType.DESTROY then
            tooltip:AddLine(L["TOOLTIP_ITEM_IN_DESTROY_LIST"])
        end

        -- TODO: For custom lists, need to enumerate and list memberships.
    end

    -- Add a warning that this item will be auto-sold on next vendor trip.
    if (profile:GetValue(Addon.c_Config_Tooltip)) then
        if result == Addon.ActionType.SELL then
            tooltip:AddLine(string.format("%s%s%s", RED_FONT_COLOR_CODE, L["TOOLTIP_ITEM_WILL_BE_SOLD"], FONT_COLOR_CODE_CLOSE))
        elseif result == Addon.ActionType.DESTROY then
            tooltip:AddLine(string.format("%s%s%s", RED_FONT_COLOR_CODE, L["TOOLTIP_ITEM_WILL_BE_DELETED"], FONT_COLOR_CODE_CLOSE))    
        end
    end
    
    -- Add Advanced Rule information if set and available.
    if (ruleName and profile:GetValue(Addon.c_Config_Tooltip_Rule)) then
        if result == Addon.ActionType.SELL then
            tooltip:AddLine(string.format(L["TOOLTIP_RULEMATCH_SELL"], ruleName))
        elseif result == Addon.ActionType.DESTROY then
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

-- Amazing new tooltip functinality replacing nasty hooks and jankiness.
function Addon:InitializeItemTooltips()
    Addon:Debug("tooltip", "Adding tooltip processing for items.")
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, addItemTooltipLines)
end