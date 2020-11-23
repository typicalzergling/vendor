-- enUS Localization.
local _, Addon = ...
Addon:AddLocale("enUS",
{
FILTER_VENDOR_SELL_NAME = "Vendor: Sell",
FILTER_VENDOR_SELL_DESC = "Put items that the Vendor addon will sell into this collection."..
" This filter must be a very high priority to work correctly, as it can reclassify any item in your inventory.",
CATEGORY_VENDOR_SELL = "Sell (Vendor)",

FILTER_VENDOR_DESTROY_NAME = "Vendor: Destroy",
FILTER_VENDOR_DESTROY_DESC = "Put items that the Vendor addon will destroy into this collection."..
" This filter must be a very high priority to work correctly, as it can reclassify any item in your inventory.",
CATEGORY_VENDOR_DESTROY = "Destroy (Vendor)",

}) -- END OF LOCALIZATION TABLE
