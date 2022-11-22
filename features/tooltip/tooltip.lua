--[[
    This is for setting the tooltip with game state.
    It is a system so it loads immediately as the addon is loading. 
]]

local _, Addon = ...
local L = Addon:GetLocale()
local debugp = function (...) Addon:Debug("tooltip", ...) end

local Info = Addon.Systems.Info
local ItemProperties = Addon.Systems.ItemProperties

local Tooltip = {
    NAME = "Tooltip",
    VERSION = 1,
    DEPENDENCIES = {
    },
}

-- Will take whatever item is being moused-over and add it to the Always-Sell list.
function Tooltip:AddTooltipItemToList(list)
    -- Get the item from
    name, link = GameTooltip:GetItem();
    if not link then
        Addon:Print(string.format(L["TOOLTIP_ADDITEM_ERROR_NOITEM"], list))
        return
    end

    -- Add the link to the specified blocklist.
    local retval = Addon:ToggleItemInBlocklist(list, link)
    if retval == 1 then
        Addon:Print(string.format(L["CMD_LISTTOGGLE_ADDED"], tostring(link), list))
    elseif retval == 2 then
        Addon:Print(string.format(L["CMD_LISTTOGGLE_REMOVED"], tostring(link), list))
    end
end

-- Called by keybinds to direct-add items to the blocklists
function Addon:AddTooltipItemToSellList()
    Tooltip:AddTooltipItemToList(Addon.SystemListId.ALWAYS)
end

function Addon:AddTooltipItemToKeepList()
    Tooltip:AddTooltipItemToList(Addon.SystemListId.NEVER)
end

function Addon:AddTooltipItemToDestroyList()
    Tooltip:AddTooltipItemToList(Addon.SystemListId.DESTROY)
end

-- Result cache
local itemGUID = nil
local result = 0
local blocklist = nil
local ruleId = nil
local ruleName = nil
local ruleType = nil
local itemId = 0

-- Forcibly clear the cache, used when Blocklist or rules change to force a re-evaluation and update the tooltip.
function Addon:ClearTooltipResultCache()
    itemGUID = nil
    result = 0
    blocklist = nil
    ruleId = nil
    ruleName = nil
    ruleType = nil
    itemId = 0
end

local function addItemTooltipLines(tooltip, tooltipData)
    if not tooltip or tooltip:IsForbidden() or not tooltipData or not tooltipData.guid then 
        -- No guid or forbidden or tooltip is a silent fail out.
        return nil
    end

    -- Combat check - printing vendor tooltips is not worth risking scans and other things
    -- happening while you are in combat. You can get the tooltip info when you are out
    -- of combat. Note we will still scan and do the right thing if you were to interact
    -- with a vendor in combat.
    if UnitAffectingCombat("player") then 
        Addon:Debug("tooltip", "Player in combat, skipping tooltip writing.")
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

    -- We have a simple cache here for performance and so we don't constantly re-evaluate the same item repeatedly.
    -- Tooltips execute many times per second. If you hold your mouse over an item, it will keep generating a new
    -- tooltip, which will call this code over and over again, even when the item is the same item. Therefore,
    -- we will cache the result as you mouse over each item and only re-update a tooltip when the item changes
    -- or if rules change (which would clear the tooltip result cache).
    if itemGUID ~= tooltipData.guid then
        local item = Addon:GetItemResultForTooltip(tooltipData)
        if not item then
            -- If we get this far we have an invalid item but a valid GUID.
            -- Keystones will show up this way, so handle them gracefully.
            itemGUID = tooltipData.guid
            result = 0
            blocklist = nil
            ruleId = nil
            ruleName = nil
            ruleType = nil
            itemId = 0
            Addon:Debug("tooltip", "Invalid item with valid GUID: %s - %s", tostring(tooltipData.guid), tostring(C_Item.GetItemLinkByGUID(tooltipData.guid)))
        else
            itemGUID = item.Item.GUID
            result = item.Result.Action
            ruleId = item.Result.RuleID
            ruleName = item.Result.Rule
            ruleType = item.Result.RuleType
            itemId = item.Item.Id

            -- Check if the item is in the Always or Never sell lists
            -- TODO: Change this to return a table of lists to which this item belongs.
            blocklist = Addon:GetBlocklistForItem(item.Item.Link)
            Addon:Debug("tooltip", "Cached item for tooltip: %s, [%s, %s, %s, %s]", item.Item.Link, tostring(result), tostring(ruleId), tostring(ruleName), tostring(ruleType))
        end
    end

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

    local profile = Addon:GetProfile();

    -- Add a warning that this item will be auto-sold on next vendor trip.
    if not profile:GetValue(Addon.c_Config_Tooltip) then return end
    if result == Addon.ActionType.SELL then
        tooltip:AddLine(string.format("%s%s%s", RED_FONT_COLOR_CODE, L["TOOLTIP_ITEM_WILL_BE_SOLD"], FONT_COLOR_CODE_CLOSE))
    elseif result == Addon.ActionType.DESTROY then
        tooltip:AddLine(string.format("%s%s%s", RED_FONT_COLOR_CODE, L["TOOLTIP_ITEM_WILL_BE_DELETED"], FONT_COLOR_CODE_CLOSE))    
    end
    
    -- Add Advanced Rule information if set and available.
    if profile:GetValue(Addon.c_Config_Tooltip_Rule) then
        if (ruleName) then
            if result == Addon.ActionType.SELL then
                tooltip:AddLine(string.format(L["TOOLTIP_RULEMATCH_SELL"], ruleName))
            elseif result == Addon.ActionType.DESTROY then
                tooltip:AddLine(string.format(L["TOOLTIP_RULEMATCH_DESTROY"], ruleName))
            else
                tooltip:AddLine(string.format(L["TOOLTIP_RULEMATCH_KEEP"], ruleName))
            end
        end
    end

    --@debug@
    if (ruleId) then
        -- If we had a rule match (make a choice) then add it to the tooltip, if we didn't get a match then
        -- no line means we didn't match anything.
        tooltip:AddLine(string.format("%s RuleId: %s[%s] %s%s",L["ADDON_NAME"], ACHIEVEMENT_COLOR_CODE, ruleType, ruleId, FONT_COLOR_CODE_CLOSE))
    end

    if (itemId) then
        -- Add item ID tooltip, it's handy for debugging.
        tooltip:AddLine(string.format("%sItem ID: %s%s", HEIRLOOM_BLUE_COLOR_CODE, tostring(itemId), FONT_COLOR_CODE_CLOSE))
    end
    --@end-debug@
end

function Tooltip:OnInitialize()
    local initializeTooltips = function ()
        Addon:Debug("tooltip", "Adding tooltip processing for items.")
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, addItemTooltipLines)
    end

    -- Tooltip. Delay this one second so other things intializing don't move the tooltip over them and
    -- cause unnecessary evaluations.
    C_Timer.After(1, initializeTooltips)
end

function Tooltip:OnTerminate()
end

Addon.Features.Tooltip = Tooltip