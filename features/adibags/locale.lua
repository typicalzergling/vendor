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

},

zhCN = {
    ADIBAGS_FEATURE = "AdiBags 集成",
    ADIBAGS_ENABLE = "启用",
    ADIBAGS_DISABLE = "禁用",
    
    ADIBAGS_SETTINGS_NAME = "AdiBags 集成",
    ADIBAGS_SETTINGS_SUMMARY = "配置与 AdiBags 的集成",
    
    ADIBAGS_JUNK_LABEL = "启用垃圾过滤器",
    ADIBAGS_JUNK_TEXT = "启用 AdiBag 过滤器以显示商人垃圾",
    
    ADIBAGS_DESTROY_LABEL = "启用销毁过滤器",
    ADIBAGS_DESTROY_TEXT = "启用 AdiBags 过滤器以显示将被商人销毁的物品",
    
    ADIBAGS_RULETYPE_SELL = "[出售]",
    ADIBAGS_RULETYPE_KEEP = "[保留]",
    ADIBAGS_RULETYPE_DESTROY = "[销毁]",
    
    ADIBAGS_TOOLTIP_TYPE = "规则类型：",
    ADIBAGS_TOOLTIPTYPE_SELL = "出售",
    ADIBAGS_TOOLTIPTYPE_KEEP = "保留",
    ADIBAGS_TOOLTIPTYPE_DESTROY = "销毁",
    
    ADIBAGS_HELP_TEXT = [[以下选项允许您配置商人如何与 AdiBags 交互，有两个预设过滤器可以启用，您也可以要求商人将特定规则暴露给 AdiBags 类别]],
    
    -- Adibags 扩展
    ADIBAGS_FILTER_VENDOR_SELL_NAME = "商人：出售",
    ADIBAGS_FILTER_VENDOR_SELL_DESC = "将商人插件将要出售的物品放入此集合。" ..
        "此过滤器必须具有非常高的优先级才能正常工作，因为它可以重新分类您库存中的任何物品。" ..
        "\n\n注意：此过滤器的启用状态在商人设置中控制",
    ADIBAGS_CATEGORY_VENDOR_SELL = "出售（商人）",
    
    ADIBAGS_FILTER_VENDOR_DESTROY_NAME = "商人：销毁",
    ADIBAGS_FILTER_VENDOR_DESTROY_DESC = "将商人插件将要销毁的物品放入此集合。" ..
        "此过滤器必须具有非常高的优先级才能正常工作，因为它可以重新分类您库存中的任何物品。" ..
        "\n\n注意：此过滤器的启用状态在商人设置中控制",
    ADIBAGS_CATEGORY_VENDOR_DESTROY = "销毁（商人）",
    
    ADIBAGS_RULEFILTER_NAME_SELL = "商人：%s [出售]",
    ADIBAGS_RULEFILTER_NAME_KEEP = "商人：%s [保留]",
    ADIBAGS_RULEFILTER_NAME_DESTROY = "商人：%s [销毁]",
    
    ADIBAGS_RULEFILTER_CATEGORY_SELL = "出售：%s",
    ADIBAGS_RULEFILTER_CATEGORY_KEEP = "保留：%s",
    ADIBAGS_RULEFILTER_CATEGORY_DESTROY = "销毁：%s",
    
    ADIBAGS_RULEFILTER_DESCRIPTION_FMT = "%s\n\n注意：此过滤器的启用状态在商人设置中控制",
    ADIBAGS_RULEFILTER_NO_DESCRIPTION = "注意：此过滤器的启用状态在商人设置中控制。",
    
},

}