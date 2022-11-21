--[[
    This is for setting the tooltip with game state.
    It is a system so it loads immediately as the addon is loading. 
]]

local _, Addon = ...
local L = Addon:GetLocale()
local debugp = function (...) Addon:Debug("tooltip", ...) end

local Tooltip = {}

local Info = Addon.Systems.Info
local ItemProperties = Addon.Systems.ItemProperties

function Tooltip:GetDependencies()
    return {"info", "itemproperties", "profile", "lists", "rules", "evaluation"}
end

-- We are tracking the location to which the tooltip is currently set. This is because blizzard does not expose
-- a way to get the item location of the tooltip item. So we track the state and the location by hooking SetBagItem
-- and SetInventoryItem to squirrel away that data and clear it whenever the tooltip is hidden. This allows us to
-- know whether a tooltip is referring to an item in the player's bags and then get that item information.
local tooltipLocation = nil
function Addon:GetTooltipItemLocation()
    return tooltipLocation
end

local function clearTooltipState()
    tooltipLocation = nil
end

-- Hook for tooltip SetBagItem
-- Since this is an insecure hook, we will wrap our actual work in a pcall so we try not to be bad
-- for everyone else.
function Addon:OnGameTooltipSetBagItem(tooltip, bag, slot)
    local status, err = xpcall(
        function(b, s)
            tooltipLocation = ItemLocation:CreateFromBagAndSlot(b, s)
        end,
        CallErrorHandler, bag, slot)
    if not status then
        Addon:Debug("tooltip", "Error executing OnGameTooltipSetBagItem: ", tostring(err))
    end
end

-- Hook for SetInventoryItem
-- Since this is an insecure hook, we will wrap our actual work in a pcall so we can't create taint to blizzard.
function Addon:OnGameTooltipSetInventoryItem(tooltip, unit, slot)
    local status, err = xpcall(
        function(u, s)
            if u == "player" then
                tooltipLocation = ItemLocation:CreateFromEquipmentSlot(s)
            else
                clearTooltipState()
            end
        end,
        CallErrorHandler, unit, slot)
    if not status then
        Addon:Debug("tooltip", "Error executing OnGameTooltipSetInventoryItem: ", tostring(err))
    end
end

-- Hook for Hide
-- This is a secure hook.
function Addon:OnGameTooltipHide(tooltip)
    clearTooltipState()
end


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
    self:AddTooltipItemToList(Addon.SystemListId.ALWAYS)
end

function Addon:AddTooltipItemToKeepList()
    self:AddTooltipItemToList(Addon.SystemListId.NEVER)
end

function Addon:AddTooltipItemToDestroyList()
    self:AddTooltipItemToList(Addon.SystemListId.DESTROY)
end

-- Hooks for item tooltips
function Addon:OnTooltipSetItem(tooltip, ...)
    -- Insecure hook, so wrap what we call in xpcall to prevent being bad to others.
    local status, err = xpcall(
        function(t, ...)
            local name = t:GetItem()
            if name then
                Tooltip:AddItemTooltipLines(t)
            end
        end,
        CallErrorHandler, tooltip)
    if not status then
        Addon:Debug("tooltiperrors", "Error executing OnTooltipSetItem: ", tostring(err))
    end
end


-- Result cache
local itemGUID = nil
local result = 0
local blocklist = nil
local ruleId = nil
local ruleName = nil
local ruleType = nil

-- Forcibly clear the cache, used when Blocklist or rules change to force a re-evaluation and update the tooltip.
function Addon:ClearTooltipResultCache()
    itemGUID = nil
    result = 0
    blocklist = nil
    ruleId = nil
    ruleName = nil
    ruleType = nil
end

function Tooltip:AddItemTooltipLines(tooltip)
    -- Combat Check
    if UnitAffectingCombat("player") then 
        Addon:Debug("tooltip", "Player in combat, skipping tooltip writing.")
        return nil 
    end

    local profile = Addon:GetProfile();

    local location = Addon:GetTooltipItemLocation()
    if not location or not C_Item.DoesItemExist(location) then
        -- This is expected for anything that isn't in our inventory.
        return
    end

    local guid = C_Item.GetItemGUID(location)
    -- We have a simple cache here for performance and so we don't constantly re-evaluate the same item repeatedly.
    -- Tooltips execute many times per second. If you hold your mouse over an item, it will keep generating a new
    -- tooltip, which will call this code over and over again, even when the item is the same item. Therefore,
    -- we will cache the result as you mouse over each item and only re-update a tooltip when the item changes
    -- or if rules change (which would clear the tooltip result cache).
    if itemGUID ~= guid then
        local item = Addon:GetItemResultForLocation(location)
        if not item then
            -- If we get this far we have an invalid item but a valid GUID.
            -- Keystones will show up this way, so handle them gracefully.
            itemGUID = guid
            result = 0
            blocklist = nil
            ruleId = nil
            ruleName = nil
            ruleType = nil
            Addon:Debug("tooltip", "Invalid item with valid GUID: %s - %s", tostring(guid))
        else
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
    if not profile:GetValue(Addon.c_Config_Tooltip_Rule) then return end
    if (ruleName) then
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


function Tooltip:Startup()

    -- Register for tooltip events
    -- Tooltip hooks
    Addon:PreHookWidget(GameTooltip, "OnTooltipSetItem", "OnTooltipSetItem")
    Addon:PreHookFunction(GameTooltip, "SetBagItem", "OnGameTooltipSetBagItem")
    Addon:PreHookFunction(GameTooltip, "SetInventoryItem", "OnGameTooltipSetInventoryItem")
    Addon:SecureHookWidget(GameTooltip, "OnHide", "OnGameTooltipHide")

    return {
        -- None yet
    }
end

function Tooltip:Shutdown()
end

Addon.Systems.Tooltip = Tooltip