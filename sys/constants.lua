-- Define all constants here
-- This will not trigger loc loading because we have not defined the Default Locale yet
local Addon = _G[select(1,...).."_GET"]()

-- Default Constants 
Addon.c_AddonName = select(1, ...)
Addon.c_DefaultLocale = "enUS"

-- Addon Constants
Addon.c_AlwaysSellList = "always"
Addon.c_NeverSellList = "never"
Addon.c_RuleType_Sell = "Sell"
Addon.c_RuleType_Keep = "Keep"

-- Config Constants
Addon.c_ConfigSellNever = "sell_never"
Addon.c_ConfigSellAlways = "sell_always"