-- Define all constants here
local Addon = _G[select(1,...).."_GET"]()

-- Constants 
Addon.c_AddonName = select(1, ...)		-- First argument to the file load is Addon Name, 2nd is apparently an empty table.
Addon.c_DefaultLocale = "enUS"
Addon.c_AlwaysSellList = "always"
Addon.c_NeverSellList = "never"
Addon.c_RuleType_Sell = "Sell"
Addon.c_RuleType_Keep = "Keep"
