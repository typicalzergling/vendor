local _, Addon = ...

Addon.Features.BetterBags.Locale = { 
enUS = {
BETTERBAGS_FEATURE = "BetterBags Integration",
BETTERBAGS_ENABLE = "Enable",
BETTERBAGS_DISABLE = "Disable",

BETTERBAGS_SETTINGS_NAME  = "BetterBags Integration",
BETTERBAGS_SETTINGS_SUMMARY = "Configure the integration with BetterBags",

BETTERBAGS_JUNK_LABEL = "Enable Junk Filter",
BETTERBAGS_JUNK_TEXT = "Enables the AdiBag filter to dislay vendor junk",

BETTERBAGS_DESTROY_LABEL ="Enable Destroy Filter",
BETTERBAGS_DESTROY_TEXT = "Enable the BetterBags filter for items that will be destroyed by vendor",

BETTERBAGS_RULETYPE_SELL = "[Sell]",
BETTERBAGS_RULETYPE_KEEP = "[Keep]",
BETTERBAGS_RULETYPE_DESTROY = "[Destroy]",

BETTERBAGS_TOOLTIP_TYPE = "Rule Type:",
BETTERBAGS_TOOLTIPTYPE_SELL = "Sell",
BETTERBAGS_TOOLTIPTYPE_KEEP = "Keep",
BETTERBAGS_TOOLTIPTYPE_DESTROY = "Destroy",


BETTERBAGS_HELP_TEXT = [[The following options allow you to configure how Vendor interacts with BetterBags, there are two canned filters which can be nabled as well as you can ask vendor to expose an particular rule to just an BetterBags categrory]],

-- BetterBags extension
BETTERBAGS_FILTER_VENDOR_SELL_NAME = "Vendor: Sell",
BETTERBAGS_FILTER_VENDOR_SELL_DESC = "Put items that the Vendor addon will sell into this collection. " ..
    "This filter must be a very high priority to work correctly, as it can reclassify any item in your inventory." ..
    "\n\nNote: The enabled state of this filter is controller in the Vendor settings",
BETTERBAGS_CATEGORY_VENDOR_SELL = "Sell (Vendor)",

BETTERBAGS_FILTER_VENDOR_DESTROY_NAME = "Vendor: Destroy",
BETTERBAGS_FILTER_VENDOR_DESTROY_DESC = "Put items that the Vendor addon will destroy into this collection. " ..
    "This filter must be a very high priority to work correctly, as it can reclassify any item in your inventory." ..
    "\n\nNote: The enabled state of this filter is controller in the Vendor settings",
BETTERBAGS_CATEGORY_VENDOR_DESTROY = "Destroy (Vendor)",

BETTERBAGS_RULEFILTER_NAME_SELL = "Vendor: %s [Sell]",
BETTERBAGS_RULEFILTER_NAME_KEEP = "Vendor: %s [Keep]",
BETTERBAGS_RULEFILTER_NAME_DESTROY = "Vendor: %s [Destroy]",

BETTERBAGS_RULEFILTER_CATEGORY_SELL = "Sell: %s",
BETTERBAGS_RULEFILTER_CATEGORY_KEEP = "Keep: %s",
BETTERBAGS_RULEFILTER_CATEGORY_DESTROY = "Destroy: %s",

BETTERBAGS_RULEFILTER_DESCRIPTION_FMT = "%s\n\nNote: The enabled state of this filter is controlled in the Vendor settings",
BETTERBAGS_RULEFILTER_NO_DESCRIPTION = "Note: The enabled state of this filter is controlled in the Vendor settings.", 

},
zhCN = {
BETTERBAGS_FEATURE = "BetterBags整合",
BETTERBAGS_ENABLE = "启用",
BETTERBAGS_DISABLE = "禁用",

BETTERBAGS_SETTINGS_NAME  = "BetterBags整合",
BETTERBAGS_SETTINGS_SUMMARY = "配置BetterBags整合",

BETTERBAGS_JUNK_LABEL = "启用垃圾过滤器",
BETTERBAGS_JUNK_TEXT = "启用AdiBag过滤显示垃圾",

BETTERBAGS_DESTROY_LABEL ="启用摧毁过滤器",
BETTERBAGS_DESTROY_TEXT = "启用BetterBags过滤标记为摧毁的物品",

BETTERBAGS_RULETYPE_SELL = "[出售]",
BETTERBAGS_RULETYPE_KEEP = "[保留]",
BETTERBAGS_RULETYPE_DESTROY = "[摧毁]",

BETTERBAGS_TOOLTIP_TYPE = "规则类型:",
BETTERBAGS_TOOLTIPTYPE_SELL = "出售",
BETTERBAGS_TOOLTIPTYPE_KEEP = "保留",
BETTERBAGS_TOOLTIPTYPE_DESTROY = "摧毁",


BETTERBAGS_HELP_TEXT = [[下列选项可配置Vendor与BetterBags的交互，有2个预设过滤器可使Vendor规则转换为BetterBags类别]],

-- BetterBags extension
BETTERBAGS_FILTER_VENDOR_SELL_NAME = "Vendor: 出售",
BETTERBAGS_FILTER_VENDOR_SELL_DESC = "将Vendor标记为出售的物品放入此类。" ..
    "该过滤器会重新分类背包中的物品，需要设置为最高优先级才能正常工作" ..
    "\n\n注意: 需要在Vendor设置中更改该过滤器启用状态",
BETTERBAGS_CATEGORY_VENDOR_SELL = "出售（Vendor）",

BETTERBAGS_FILTER_VENDOR_DESTROY_NAME = "Vendor: 摧毁",
BETTERBAGS_FILTER_VENDOR_DESTROY_DESC = "将Vendor标记为摧毁的物品放入此类。" ..
    "该过滤器会重新分类背包中的物品，需要设置为最高优先级才能正常工作" ..
    "\n\n注意: 需要在Vendor设置中更改该过滤器启用状态",
BETTERBAGS_CATEGORY_VENDOR_DESTROY = "摧毁（Vendor）",

BETTERBAGS_RULEFILTER_NAME_SELL = "Vendor: %s [出售]",
BETTERBAGS_RULEFILTER_NAME_KEEP = "Vendor: %s [保留]",
BETTERBAGS_RULEFILTER_NAME_DESTROY = "Vendor: %s [摧毁]",

BETTERBAGS_RULEFILTER_CATEGORY_SELL = "出售: %s",
BETTERBAGS_RULEFILTER_CATEGORY_KEEP = "保留: %s",
BETTERBAGS_RULEFILTER_CATEGORY_DESTROY = "摧毁: %s",

BETTERBAGS_RULEFILTER_DESCRIPTION_FMT = "%s\n\n注意: 需要在Vendor设置中更改该过滤器启用状态",
BETTERBAGS_RULEFILTER_NO_DESCRIPTION = "注意: 需要在Vendor设置中更改该过滤器启用状态", 

}

}