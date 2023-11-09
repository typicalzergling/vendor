local _, Addon = ...

Addon.Features.Adibags.Locale = { 
enUS = {
ADIBAGS_FEATURE = "AdiBags Integration",
ADIBAGS_ENABLE = "Enable",
ADIBAGS_DISABLE = "Disable",

ADIBAGS_SETTINGS_NAME  = "AdiBags Integration",
ADIBAGS_SETTINGS_SUMMARY = "Configure the integration with AdiBags",

ADIBAGS_JUNK_LABEL = "Enable Junk Filter",
ADIBAGS_JUNK_TEXT = "Enables the AdiBag filter to dislay vendor junk",

ADIBAGS_DESTROY_LABEL ="Enable Destroy Filter",
ADIBAGS_DESTROY_TEXT = "Enable the AdiBags filter for items that will be destroyed by venADIBAGS_RULEFILTER_NAME_dor",

ADIBAGS_RULETYPE_SELL = "[Sell]",
ADIBAGS_RULETYPE_KEEP = "[Keep]",
ADIBAGS_RULETYPE_DESTROY = "[Destory]",

ADIBAGS_TOOLTIP_TYPE = "Rule Type:",
ADIBAGS_TOOLTIPTYPE_SELL = "Sell",
ADIBAGS_TOOLTIPTYPE_KEEP = "Keep",
ADIBAGS_TOOLTIPTYPE_DESTROY = "Destory",


ADIBAGS_HELP_TEXT = [[The following options allow you to configure how Vendor interacts with AdiBags, there are two canned filters which can be nabled as well as you can ask vendor to expose an particular rule to just an AdiBags categrory]],

-- Adibags extension
ADIBAGS_FILTER_VENDOR_SELL_NAME = "Vendor: Sell",
ADIBAGS_FILTER_VENDOR_SELL_DESC = "Put items that the Vendor addon will sell into this collection. " ..
    "This filter must be a very high priority to work correctly, as it can reclassify any item in your inventory." ..
    "\n\nNote: The enabled state of this filter is controller in the Vendor settings",
ADIBAGS_CATEGORY_VENDOR_SELL = "Sell (Vendor)",

ADIBAGS_FILTER_VENDOR_DESTROY_NAME = "Vendor: Destroy",
ADIBAGS_FILTER_VENDOR_DESTROY_DESC = "Put items that the Vendor addon will destroy into this collection. " ..
    "This filter must be a very high priority to work correctly, as it can reclassify any item in your inventory." ..
    "\n\nNote: The enabled state of this filter is controller in the Vendor settings",
ADIBAGS_CATEGORY_VENDOR_DESTROY = "Destroy (Vendor)",

ADIBAGS_RULEFILTER_NAME_SELL = "Vendor: %s [Sell]",
ADIBAGS_RULEFILTER_NAME_KEEP = "Vendor: %s [Keep]",
ADIBAGS_RULEFILTER_NAME_DESTROY = "Vendor: %s [Destroy]",

ADIBAGS_RULEFILTER_CATEGORY_SELL = "Sell: %s",
ADIBAGS_RULEFILTER_CATEGORY_KEEP = "Keep: %s",
ADIBAGS_RULEFILTER_CATEGORY_DESTROY = "Destroy: %s",

ADIBAGS_RULEFILTER_DESCRIPTION_FMT = "%s\n\nNote: The enabled state of this filter is controller in the Vendor settings",
ADIBAGS_RULEFILTER_NO_DESCRIPTION = "Note: The enabled state of this filter is controller in the Vendor settings.", 

}

}