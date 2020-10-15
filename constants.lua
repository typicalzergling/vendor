-- Define all constants here
-- This will not trigger loc loading because we have not defined the Default Locale yet
local AddonName, Addon = ...

-- Default Constants
Addon.c_AddonName = select(1, ...)
Addon.c_DefaultLocale = "enUS"
Addon.c_PrintColorCode = ORANGE_FONT_COLOR_CODE
Addon.c_APIMethodColorCode = YELLOW_FONT_COLOR_CODE

-- Addon Constants
Addon.c_AlwaysSellList = "always"
Addon.c_NeverSellList = "never"
Addon.c_RuleType_Sell = "Sell"
Addon.c_RuleType_Keep = "Keep"
Addon.c_RuleType_Custom = "Custom"
Addon.c_RuleType_Scrap = "Scrap"
Addon.c_BuybackLimit = 12

-- Config Constants
Addon.c_Config_SellNever = "sell_never"
Addon.c_Config_SellAlways = "sell_always"
Addon.c_Config_AutoSell = "autosell"
Addon.c_Config_Tooltip = "tooltip_basic"
Addon.c_Config_Tooltip_Rule = "tooltip_addrule"
Addon.c_Config_SellLimit = "autosell_limit"
Addon.c_Config_MaxSellItems = "max_items_to_sell"
Addon.c_Config_SellThrottle = "sell_throttle"
Addon.c_Config_ThrottleTime = "throttle_time"
Addon.c_Config_AutoRepair = "autorepair"
Addon.c_Config_GuildRepair = "guildrepair"

