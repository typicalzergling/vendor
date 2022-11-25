-- Define all constants here
-- This will not trigger loc loading because we have not defined the Default Locale yet
local AddonName, Addon = ...

-- Skeleton Constants
Addon.c_DefaultLocale = "enUS"
Addon.c_PrintColorCode = ORANGE_FONT_COLOR_CODE
Addon.c_APIMethodColorCode = YELLOW_FONT_COLOR_CODE
Addon.c_ThrottleTime = .15  -- Default Throttle Time

-- Addon Constants
Addon.c_BuybackLimit = 12
Addon.c_ItemSellerThreadName = "ItemSeller"

-- Config Constants
Addon.c_Config_AutoSell = "autosell"
Addon.c_Config_Tooltip = "tooltip_basic"
Addon.c_Config_Tooltip_Rule = "tooltip_addrule"
Addon.c_Config_SellLimit = "autosell_limit"
Addon.c_Config_MaxSellItems = "max_items_to_sell"
Addon.c_Config_SellThrottle = "sell_throttle"
Addon.c_Config_RefreshThrottle = "refresh_throttle"
Addon.c_Config_ThrottleTime = "throttle_time"
Addon.c_Config_AutoRepair = "autorepair"
Addon.c_Config_GuildRepair = "guildrepair"
Addon.c_Config_MinimapData = "minimapdata"
Addon.c_Config_MinimapButton = "minimapbutton"
Addon.c_Config_MerchantButton = "merchantbutton"

-- Merchant button
Addon.MerchantButton = {
    NEVER = 0,
    ALWAYS = 1,
    AUTO = 2
}

-- Rule Types
Addon.RuleType = {
    SELL = "Sell",
    KEEP = "Keep",
    DESTROY  = "Destroy",
    HIDDEN = "-Hidden-",
}

-- Action Types
Addon.ActionType = {
    NONE = 0,
    SELL = 1,
    DESTROY = 2,
}

Addon.ListType = {
    SELL = "sell",
    KEEP = "keep",
    DESTROY = "destroy",
    CUSTOM = "custom",
    EXTENSION = "extension"
}

Addon.SystemListId = {
    NEVER = "system:never-sell",
    ALWAYS = "system:always-sell",
    DESTROY = "system:always-destroy",
}

Addon.Events = {
    AUTO_SELL_START = "auto-sell-start",
    AUTO_SELL_COMPLETE = "auto-sell-end",
    AUTO_SELL_ITEM = "auto-sell-item",
    DESTROY_START = "destroy-start",
    DESTROY_COMPLETE = "destroy-complete",
    PROFILE_CHANGED = "profile-changed",
    ITEMRESULT_REFRESH_START = "itemresult-refresh-start",
    ITEMRESULT_REFRESH_STOP = "itemresult-refresh-stop",
    ITEMRESULT_REFRESH_COMPLETE = "itemresult-refresh-complete",
    ITEMRESULT_REFRESH_TRIGGERED = "itemresult-refresh-triggered",
    ITEMRESULT_ADDED = "itemresult-added",
    ITEMRESULT_REMOVED = "itemresult-removed",
    ITEMRESULT_CACHE_CLEARED = "itemresult-cache-cleared",
    EVALUATION_STATUS_UPDATED = "evaluation-status-updated",
}

-- Blizzard Color Codes that are not in all versions
-- We create local versions so we can still use these colors regardless of game version.
Addon.COMMON_GRAY_COLOR		    = CreateColor(0.65882,	0.65882,	0.65882);
Addon.UNCOMMON_GREEN_COLOR	    = CreateColor(0.08235,	0.70196,	0.0);
Addon.RARE_BLUE_COLOR			= CreateColor(0.0,		0.56863,	0.94902);
Addon.EPIC_PURPLE_COLOR		    = CreateColor(0.78431,	0.27059,	0.98039);
Addon.LEGENDARY_ORANGE_COLOR	= CreateColor(1.0,		0.50196,	0.0);
Addon.ARTIFACT_GOLD_COLOR		= CreateColor(0.90196,	0.8,		0.50196);
Addon.HEIRLOOM_BLUE_COLOR		= CreateColor(0.0,		0.8,		1);

Addon.Colors = {
    CUSTOMLIST_TEXT = CreateColor(0.0, 0.56863, 0.94902, .8),
    CUSTOMLIST_HOVER_TEXT = CreateColor(0.0, 0.56863, 0.94902, 1),
    CUSTOMLIST_SELECTED_TEXT = CreateColor(0.0, 0.56863, 0.94902, 1),

    HELPITEM_FUNCTION_BORDER = CreateColor(0.0, 0.8, 1, .6),
    HELPITEM_FUNCTION_BACK = CreateColor(0.0, 0.8, 1, .1),
    HELPITEM_FUNCTION_TEXT = "TEXT",

    HELPITEM_PROPERTY_BORDER = CreateColor(0.08235,	0.70196, 0.0, .6),
    HELPITEM_PROPERTY_BACK = CreateColor(0.08235, .70196, 0.0, .1),
    HELPITEM_PROPERTY_TEXT = "TEXT",

    ACTIVE_RULE_BACK = CreateColor(0.08235,	0.70196, 0.0, .05),
    ACTIVE_RULE_HOVER_BACK = CreateColor(0.09235, 0.70196, 0, 0.1),

    UNHEALTHY_RULE_BACK = CreateColor(1.0, 0.50196, 0.0, .05),
    UNHEALTHY_RULE_HOVER_BACK = CreateColor(1.0, 0.50196, 0.0, 0.1),

    MIGRATE_RULE_BACK = CreateColor(0.90196, 0.8, 0.50196, .05),
    MIGRATE_RULE_HOVER_BACK = CreateColor(0.90196, 0.8, 0.50196, 0.1),
}