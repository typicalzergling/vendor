-- enUS Localization
-- If the loading order of the files is incorrect, this will fail when trying to use AddonLocales.
-- Locales should be loaded AFTER Init and before anything that uses them.
-- So basically make sure they are all loaded together in the TOC right after Init (constants is OK too).
local _, Addon = ...
Addon:AddLocale("zhCN",
{
-- Core
ADDON_NAME = "Vendor",
ADDON_LOADED = "已加载。输入 '/vendor help' 获取使用帮助。",
VENDOR_URL = "https://www.curseforge.com/wow/addons/vendor",
VENDOR_TUTORIAL = "https://youtu.be/j93Orw3vPKQ",
VENDOR_DISCORD  = "https://discord.gg/BtqVg8KVDg",
ABOUT_PROJECT_LABEL = "项目：",
ABOUT_TUTORIAL_LABEL = "教程：",
ABOUT_DISCORD_LABEL = "Discord：",
ABOUT_RELEASES_LABEL = "发布：",
ABOUT_VERSION_LABEL = "版本：",
DEFAULT_PROFILE_NAME = "默认",
ABOUT_COPY = "复制",

-- Date Formats - For cultures who may wish to change these.
CMD_HISTORY_DATEFORMAT = "%c",
OPTIONS_AUDIT_TT_DATESTR = "%A, %B %d, %I:%M:%S %p",

-- Rule types
RULE_TYPE_KEEP_NAME = "保留",
RULE_TYPE_KEEP_DESCR = "这些规则是为了防止出售你不想出售的物品的保障措施。|n|n所有保留规则都会在出售规则之前检查。但是，任何你添加到“出售”列表中的物品都会忽略保留规则。",
RULE_TYPE_SELL_NAME = "出售",
RULE_TYPE_SELL_DESCR = "任何你添加到“保留”列表中的物品都会忽略出售规则并始终保留。|n|n保留规则总是在出售规则之前处理，所以如果你启用的出售规则似乎不起作用，请检查保留规则以查看是否有任何阻止它的因素。",
RULE_TYPE_DELETE_NAME = "销毁",
RULE_TYPE_DELETE_DESCR = "任何你添加到“保留”列表或规则或“出售”列表或规则中的物品都会优先于销毁规则。|n|n销毁只能在硬件事件上发生，所以你必须使用键绑定、宏或Titan插件按钮按下以触发它。",

-- 绑定
BINDING_HEADER_VENDORQUICKLIST = "鼠标悬停在物品上时快速添加/移除出售列表中的物品",
BINDING_NAME_VENDORALWAYSSELL = "商人：切换出售物品",
BINDING_DESC_VENDORALWAYSSELL = "将当前游戏工具提示中的物品添加到出售列表。如果它已经在列表中，则将其移除。",
BINDING_NAME_VENDORNEVERSELL = "商人：切换保留物品",
BINDING_DESC_VENDORNEVERSELL = "将当前游戏工具提示中的物品添加到保留列表。如果它已经在列表中，则将其移除。",
BINDING_NAME_VENDORTOGGLEDESTROY = "商人：切换销毁物品",
BINDING_DESC_VENDORTOGGLEDESTROY = "将当前游戏工具提示中的物品添加到销毁列表。如果它已经在列表中，则将其移除。",
BINDING_NAME_VENDORRUNAUTOSELL = "商人：在商人处自动出售",
BINDING_DESC_VENDORRUNAUTOSELL = "在商人处手动触发自动出售。",
BINDING_NAME_VENDORRUNDESTROY = "商人：销毁下一个物品",
BINDING_DESC_VENDORRUNDESTROY = "销毁商人已标识为销毁的物品。由于暴雪的限制，这必须通过硬件事件完成。",
BINDING_NAME_VENDORRULES = "商人：打开菜单",
BINDING_DESC_VENDORRULES = "切换主商人规则菜单的可见性。",

-- 商人
MERCHANT_REPAIR_FROM_GUILD_BANK = "从公会银行修理了所有装备，花费 %s",
MERCHANT_REPAIR_FROM_SELF = "修理了所有装备，花费 %s",
MERCHANT_SELLING_ITEM = "出售了 %s，获得 %s (%s)",
MERCHANT_WITHDRAW_ITEM = "提取 %s 以出售。",
MERCHANT_SOLD_ITEMS = "出售了 %s 件物品，获得 %s",
MERCHANT_WITHDRAWN_ITEMS = "提取了 %s 件物品。",
MERCHANT_SELL_LIMIT_REACHED = "达到出售限制 (%s)，停止自动出售。",
MERCHANT_AUTO_CONFIRM_SELL_TRADE_REMOVAL = "自动接受确认使 %s 无法交易。",
MERCHANT_SELL_ITEMS = "出售 [%s]",
MERCHANT_DESTROY_ITEMS = "销毁 [%s]",
MERCHANT_SELL_BUTTON_TOOLTIP_TITLE = "出售",
MERCHANT_DESTROY_BUTTON_TOOLTIP_TITLE = "销毁下一个物品",
MERCHANT_DESTROY_BUTTON_TOOLTIP_NEXT = "将被销毁：\n  ",
MERCHANT_DESTROY_BUTTON_TOOLTIP_REMAINING = "剩余：",

-- 销毁
ITEM_DESTROY_SUMMARY = "销毁了 %s 件物品。",
ITEM_DESTROY_CURRENT = "正在销毁 %s (%s)",
ITEM_DESTROY_CANCELLED_CURSORITEM = "由于持有物品，取消销毁。",
ITEM_DESTROY_STARTED = "开始销毁符合销毁规则或列表的物品...",
ITEM_DESTROY_MORE_ITEMS = "还有 %s 件物品待销毁。",
ITEM_DESTROY_NONE_REMAIN = "没有标识为销毁的物品。",

-- 工具提示
TOOLTIP_ADDITEM_ERROR_NOITEM = "无法将物品添加到 %s 出售列表。游戏工具提示未悬停在物品上。",
TOOLTIP_ITEM_IN_ALWAYS_SELL_LIST = "商人：出售",
TOOLTIP_ITEM_IN_NEVER_SELL_LIST = "商人：保留",
TOOLTIP_ITEM_IN_DESTROY_LIST = "商人：销毁",
TOOLTIP_ITEM_WILL_BE_SOLD = "将由商人出售",
TOOLTIP_ITEM_WILL_BE_DELETED = "将由商人销毁",
TOOLTIP_RULEMATCH_SELL = "出售：%s",
TOOLTIP_RULEMATCH_KEEP = "保留：%s",
TOOLTIP_RULEMATCH_DESTROY = "销毁：%s",

-- 选项
OPTIONS_TITLE_ADDON = "这些设置用于配置商人的行为。\n\n",
OPTIONS_SHOW_BINDINGS = "按键绑定",
OPTIONS_OPEN_RULES = "打开规则",
OPTIONS_OPEN_SETTINGS = "打开设置",

OPTIONS_AUDIT_INTRO_TEXT = "记录商人在过去 30 天内为该角色执行的所有最近操作。",
OPTIONS_AUDIT_SEARCH_LABEL = "搜索：",
OPTIONS_AUDIT_FILTER_LABEL = "过滤：",
OPTIONS_AUDIT_EMPTY = "没有符合指定过滤器和/或搜索词的记录。",
OPTIONS_AUDIT_SEARCH_PLACEHOLDER = "输入搜索词",
OPTIONS_AUDIT_FILTER_SOLD = "已出售",
OPTIONS_AUDIT_FILTER_SOLD_DESC = "包括所有已出售的物品",
OPTIONS_AUDIT_FILTER_DESTROYED = "已销毁",
OPTIONS_AUDIT_FILTER_DESTROYED_DESC = "包括所有已销毁的物品",
OPTIONS_AUDIT_FILTER_EPIC = "史诗物品",
OPTIONS_AUDIT_FILTER_EPIC_DESC = "包括史诗品质的物品",
OPTIONS_AUDIT_FILTER_RARE = "稀有物品",
OPTIONS_AUDIT_FILTER_RARE_DESC = "包括稀有品质的物品",
OPTIONS_AUDIT_FILTER_UNCOMMON = "优秀物品",
OPTIONS_AUDIT_FILTER_UNCOMMON_DESC = "包括优秀品质的物品",
OPTIONS_AUDIT_FILTER_LEGENDARY = "传奇或更好",
OPTIONS_AUDIT_FILTER_LEGENDARY_DESC = "包括传奇品质或更好的物品",
OPTIONS_AUDIT_FILTER_COMMON = "普通或更差",
OPTIONS_AUDIT_FILTER_COMMON_DESC = "包括普通品质或更差的物品。",
OPTIONS_AUDIT_FILTER_EXTENSION = "扩展规则",
OPTIONS_AUDIT_FILTER_EXTENSION_DESC = "包括从商人扩展规则中出售或销毁的物品。",
OPTIONS_AUDIT_FILTER_ALL = "全部",
OPTIONS_VENDOR_AUDIT = "商人审计：",
OPTIONS_AUDIT_TT_PROFILE = "配置文件：",
OPTIONS_AUDIT_TT_RULE = "规则：",
OPTIONS_AUDIT_TT_SOLD = "已出售：",
OPTIONS_AUDIT_TT_DESTROYED = "已销毁：",

RULES_DIALOG_CONFIG_TAB = "设置",
SETTINGS_CATEGORY_LABEL = "类别",

-- 设置类别和描述
OPTIONS_CATEGORY_QUICK = "快速",
OPTIONS_DESC_QUICK = "快速访问常用设置",
OPTIONS_CATEGORY_GENERAL = "常规",
OPTIONS_DESC_GENERAL = "商人的所有常规设置",
OPTIONS_CATEGORY_HIDDENRULES = "隐藏规则",
OPTIONS_DESC_HIDDENRULES = "隐藏规则的管理",
OPTIONS_CATEGORY_SELLING = "出售",
OPTIONS_DESC_SELLING = "控制你在商人处出售时商人的行为。",
OPTIONS_CATEGORY_REPAIR = "修理",
OPTIONS_DESC_REPAIR = "是否自动修理，以及如何支付修理费用。\n",
OPTIONS_CATEGORY_TOOLTIP = "工具提示",
OPTIONS_DESC_TOOLTIP = "鼠标悬停在物品上时的工具提示设置。",
OPTIONS_CATEGORY_DEBUG = "调试",
OPTIONS_DESC_DEBUG = "调试设置。",
OPTIONS_CATEGORY_ADVANCED = "高级",
OPTIONS_DESC_ADVANCED = "高级设置。除非你遇到问题，否则不建议更改这些设置。",
OPTIONS_CATEGORY_PERFORMANCE = "性能",
OPTIONS_DESC_PERFORMANCE = "商人使用节流和协程来避免界面无响应和客户端断开连接。这些设置控制这种行为。\n\n",

-- 单独设置
OPTIONS_SETTINGNAME_AUTOSELL = "自动出售",
OPTIONS_SETTINGDESC_AUTOSELL = "与商人互动时自动出售物品。如果禁用此功能，您仍然可以通过设置热键或添加按钮手动出售。",
OPTIONS_SETTINGNAME_BUYBACK = "限制出售数量为12",
OPTIONS_SETTINGDESC_BUYBACK = "每次触发自动出售时限制出售的物品数量为12，这是回购限制。这允许您始终回购任何已出售的物品。建议在您熟悉商人规则和列表并信任其执行您想要的操作后禁用此设置。",
OPTIONS_SETTINGNAME_CONFIG = "打开规则配置",
OPTIONS_SETTINGDESC_CONFIG = "显示规则配置对话框，允许您切换规则并创建自己的规则。",
OPTIONS_SETTINGNAME_TOOLTIP = "启用工具提示",
OPTIONS_SETTINGDESC_TOOLTIP = "商人将在工具提示中添加一行，指示何时出售该物品。",
OPTIONS_SETTINGNAME_EXTRARULEINFO = "额外规则信息",
OPTIONS_SETTINGDESC_EXTRARULEINFO = "包括导致物品被出售或保留的规则信息。一个物品可能匹配多个规则；这只会显示第一个匹配的规则。",
OPTIONS_SETTINGNAME_MAXITEMS = "限制出售物品数量",
OPTIONS_SETTINGDESC_MAXITEMS = "控制每次访问时商人自动出售的最大物品数量。如果您希望能够回购所有已出售的物品，请将此设置为12。",
OPTIONS_SETTINGNAME_AUTOREPAIR = "自动修理",
OPTIONS_SETTINGDESC_AUTOREPAIR = "访问可修理的商人时自动修理。",
OPTIONS_SETTINGNAME_GUILDREPAIR = "使用公会银行",
OPTIONS_SETTINGDESC_GUILDREPAIR = "如果可能，使用公会银行进行修理。",
OPTIONS_SETTINGNAME_SELL_THROTTLE = "每周期出售的物品数量",
OPTIONS_SETTINGDESC_SELL_THROTTLE = "这是每个出售周期出售的物品数量。如果您想批量出售物品，请增加此数量，但降低此数量以降低暴雪限制您的风险。",
OPTIONS_SETTINGNAME_CYCLE_RATE = "周期速率",
OPTIONS_SETTINGDESC_CYCLE_RATE = "尝试出售上述指定数量的物品之间的间隔时间（以秒为单位）。时间越短越快。如果您注意到暴雪的限制，请增加此时间以减慢出售速率。",
OPTIONS_SETTINGNAME_MINIMAP = "显示小地图按钮",
OPTIONS_SETTINGDESC_MINIMAP = "商人将在小地图上显示一个按钮，以便快速访问规则和配置文件，并在鼠标悬停时显示匹配物品的摘要。\n\n这是一个全账户设置。",
OPTIONS_SETTINGNAME_MERCHANT = "显示商人按钮",
OPTIONS_SETTINGDESC_MERCHANT = "与商人互动时添加按钮以触发自动出售和销毁商人已识别为出售和/或销毁的物品。\n\n这是一个全账户设置。",

QUICK_SELL_SETTING = "在商人处自动出售物品",
QUICK_SELL_SETTING_HELP = "与商人互动时自动出售物品。如果禁用此功能，您仍然可以通过设置热键手动触发自动出售。\n\n这也启用了12件物品的出售限制，这是为了安全的回购限制。",
QUICK_REPAIR_SETTING = "在修理商人处自动修理",
QUICK_REPAIR_SETTING_HELP = "访问可修理的商人时自动修理。\n\n这也启用了在可用时使用公会修理。",
QUICK_MINIMAP_SETTING = "显示小地图按钮",
QUICK_MINIMAP_SETTING_HELP = "在小地图上启用商人小地图按钮。鼠标悬停时按钮显示将被出售/销毁的物品。左键单击打开规则配置页面，右键单击打开配置文件。\n\n这是一个全账户设置。",
QUICK_MERCHANT_SETTING = "显示商人按钮",
QUICK_MERCHANT_SETTING_HELP = "在与商人互动时启用商人出售和销毁按钮。这使得触发商人出售和销毁规则变得容易。如果您禁用自动出售，这是手动触发出售的便捷方式。\n\n这是一个全账户设置。",

-- 配置文件页面
OPTIONS_PROFILE_TITLE = "配置文件",
OPTIONS_PROFILE_HELPTEXT = "所有规则设置、插件设置和出售/保留/销毁列表内容都存储在每个配置文件中。"..
    "配置文件在所有服务器和角色之间全局存储，并且每个角色选择一个配置文件。",
OPTIONS_PROFILE_COPY = "复制",
OPTIONS_PROFILE_CREATE = "新建",
OPTIONS_PROFILE_RENAME = "重命名",
OPTIONS_PROFILE_SET = "设置",
OPTIONS_PROFILE_NAME_PLACEHOLDER = "在此处输入要创建或复制的配置文件名称",
OPTIONS_PROFILE_CREATETEXT = "您可以从头开始创建一个新配置文件（从商人默认值开始），或者您可以复制列表中的现有配置文件。空白名称默认为“PlayerName - Realm”",
OPTIONS_CONFIRM_PROFILE_DELETE_CAPTION = "删除配置文件",
OPTIONS_CONFIRM_PROFILE_DELETE_CONFIRM = "确认",
OPTIONS_CONFIRM_PROFILE_DELETE_FMT1 = [[
# 删除配置文件


您确定要删除配置文件 '%s' 吗？"
]],
OPTIONS_PROFILE_DUPLICATE_NAME_CAPTION = "重复名称",
OPTIONS_PROFILE_DUPLICATE_NAME_FMT1 = [[
# 重复的配置文件名称

名称为 '%s' 的配置文件已存在，请选择另一个名称。
]],
OPTIONS_PROFILE_CREATE_LABEL = "创建配置文件",
OPTIONS_PROFILE_DEFAULT_COPY_NAME = "%s（复制）",

OPTIONS_RULES_SHOW_HIDDEN = "显示隐藏",
OPTIONS_RULES_ONE_HIDDEN = "（1条规则）",
OPTIONS_RULES_N_HIDDEN = "（%s条规则）",

SETTINGS_HIDDENRULES_HELP = "这些是您隐藏的所有规则。可以通过使用下面的选择和按钮取消隐藏它们。",
SETTINGS_HIDDENRULES_EMPTY = "当前没有隐藏的规则。",
SETTINGS_HIDDENRULES_UNHIDE = "取消隐藏规则",
SETTINGS_HIDDENRULES_TYPE_FMT = "（%s）",

RULE_TOOLTIP_SOURCE = "来源：%s",
RULE_TOOLTIP_HIDDEN = "此规则当前在视图中隐藏",
RULE_TOOLTIP_CUSTOM_RULE = "自定义规则",
RULE_TOOLTIP_SYSTEM_RULE = "内置规则",
RULE_LIST_EMPTY = "此类别没有规则。创建一个！",

RULE_CMENU_ENABLE = "启用",
RULE_CMENU_DISABLE = "禁用",
RULE_CMENU_HIDE = "隐藏",
RULE_CMENU_SHOW = "显示",
RULE_CMENU_VIEW = "查看",
RULE_CMENU_EDIT = "编辑",
RULE_CMENU_DELETE = "删除",
RULE_CMENU_CLOSE = "关闭",
RULE_CMENU_COPY = "复制",
RULE_CMENU_EXPORT = "导出",

-- 控制台命令
CMD_HELP_HEADER = "命令参考：",
CMD_HELP_HELP = "显示此命令列表参考。",

CMD_SETTINGS_HELP = "在界面选项中打开设置。",
CMD_RULES_HELP = "打开出售/保留规则配置面板。",
CMD_KEYS_HELP = "打开键绑定。使用黑名单更容易与键绑定一起工作！",
CMD_WITHDRAW_HELP = "从银行提取商人将出售的任何物品，需要打开银行",
CMD_API_HELP = "打印商人的公共API",

CMD_LISTTOGGLE_HELP = "从列表中添加或删除物品：list {sell||keep||destroy} [itemid]",
CMD_LISTTOGGLE_INVALIDARG = "必须指定要查询或编辑物品的列表：{sell||keep||destroy} [item]",
CMD_LISTTOGGLE_ADDED = "物品：%s 已添加到 %s 列表。",
CMD_LISTTOGGLE_REMOVED = "物品：%s 已从 %s 列表中移除。",

CMD_LISTDATA_INVALIDARG = "无效选项：%s 有效列表：[sell||keep||destroy]",
CMD_LISTDATA_EMPTY = "%s 列表为空。",
CMD_LISTDATA_LISTHEADER = "%s 列表中的物品：",
CMD_LISTDATA_LISTITEM = "  %s - %s",
CMD_LISTDATA_NOTINCACHE = "[物品尚未见过，请重新运行以查看]",
CMD_LISTTOGGLE_UNSELLABLE = "%s 无法出售，因此将切换到销毁列表。",

CMD_AUTOSELL_MERCHANTNOTOPEN = "商人窗口未打开。您必须在商人处才能自动出售。",
CMD_AUTOSELL_INPROGRESS = "已经在自动出售。请等待完成后再重新运行。",
CMD_AUTOSELL_EXECUTING = "正在运行自动出售。",

CMD_CLEAR_ALL_HISTORY = "清除所有历史记录。",
CMD_CLEAR_CHAR_HISTORY = "清除 %s 的历史记录",
CMD_PRINT_HISTORY_HEADER = "%s 的历史记录",
CMD_PRINT_HISTORY_SUMMARY = "%s 的历史记录包含 %s 条目，总计 %s",
CMD_PRINT_HISTORY_SUMMARY_ALL = "整个历史记录包含 %s 条目，总计 %s",
CMD_PRUNE_CHAR_HISTORY = "修剪 %s 历史记录中超过 %s 小时的条目。",
CMD_PRUNE_ALL_HISTORY = "修剪所有角色历史记录中超过 %s 小时的条目。",
CMD_PRUNE_HISTORY_ARG = "历史修剪的无效参数，请指定要修剪的小时数。",
CMD_PRUNE_SUMMARY = "从历史记录中删除了 %s 条目。",
CMD_HISTORY_HELP = "查看、清除或修剪历史记录。用法：history [clear||prune hours] [all]",

CMD_RUNDESTROY = "销毁销毁规则或销毁列表中的下一个物品。",
CMD_DESTROY_HELP = "销毁匹配销毁规则或销毁列表的单个物品。每次执行此命令只能销毁一个物品。",

-- API
API_REGISTEREXTENSION_TITLE = "注册扩展",
API_REGISTEREXTENSION_DOCS = "向商人注册一个扩展。有关详细信息，请参阅CurseForge文档。",
API_EVALUATEITEM_TITLE = "评估物品",
API_EVALUATEITEM_DOCS = "评估物品以进行出售。输入是一个包和插槽。",
API_ADDTOALWAYSSELL_TITLE = "将工具提示物品添加到始终出售列表",
API_ADDTOALWAYSSELL_DOCS = "将显示工具提示的物品切换到始终出售列表或从中移除。",
API_ADDTONEVERSELL_TITLE = "将工具提示物品添加到从不出售列表",
API_ADDTONEVERSELL_DOCS = "将显示工具提示的物品切换到从不出售列表或从中移除。",
API_ADDTODESTROY_TITLE = "将工具提示物品添加到销毁列表",
API_ADDTODESTROY_DOCS = "将显示工具提示的物品切换到销毁列表或从中移除。",
API_AUTOSELL_TITLE = "运行自动出售",
API_AUTOSELL_DOCS = "如果在商人处，运行自动出售例程。",
API_OPENSETTINGS_TITLE = "打开设置",
API_OPENSETTINGS_DOCS = "打开商人设置页面。",
API_OPENKEYBINDINGS_TITLE = "打开键绑定",
API_OPENKEYBINDINGS_DOCS = "打开商人键绑定页面。",
API_OPENRULES_TITLE = "打开规则",
API_OPENRULES_DOCS = "打开商人界面的规则选项卡。",
API_OPENPROFILES_TITLE = "打开配置文件",
API_OPENPROFILES_DOCS = "打开商人界面的配置文件选项卡。",
API_GETEVALUATIONSTATUS_TITLE = "获取评估状态",
API_GETEVALUATIONSTATUS_DOCS = "返回商人将采取行动、出售、删除的当前插槽数量及其价值。",
API_GETPRICESTRING_TITLE = "获取价格字符串",
API_GETPRICESTRING_DOCS = "将传入的整数转换为颜色编码和图标嵌入的价格字符串。",
API_SETPROFILE_TITLE = "设置配置文件",
API_SETPROFILE_DOCS = "将当前选择的配置文件设置为指定的配置文件。",
API_GETPROFILES_TITLE = "获取配置文件",
API_GETPROFILES_DOCS = "获取可设置的配置文件列表。",
API_DESTROYITEMS_TITLE = "销毁物品",
API_DESTROYITEMS_DOCS = "运行物品销毁器，将销毁匹配销毁规则或销毁列表的下一个物品。暴雪每次只允许销毁一个物品。",
-- 规则
RULEUI_LABEL_ITEMLEVEL = "物品等级：",
RULEUI_SELL_EPIC_INFO = "任何低于此物品等级的" ..ITEM_QUALITY_COLORS[4].hex .. "史诗|r装备将被出售",
RULEUI_SELL_RARE_INFO = "任何低于此物品等级的" ..ITEM_QUALITY_COLORS[3].hex .. "稀有|r装备将被出售",
RULEUI_SELL_UNCOMMON_INFO = "任何低于此物品等级的" ..ITEM_QUALITY_COLORS[2].hex .. "优秀|r装备将被出售",
RULEUI_KEEP_EPIC_INFO = "任何等于或高于此物品等级的" ..ITEM_QUALITY_COLORS[4].hex .. "史诗|r装备将被保留",
RULEUI_KEEP_RARE_INFO = "任何等于或高于此物品等级的" ..ITEM_QUALITY_COLORS[3].hex .. "稀有|r装备将被保留",
RULEUI_KEEP_UNCOMMON_INFO = "任何等于或高于此物品等级的" ..ITEM_QUALITY_COLORS[2].hex .. "优秀|r装备将被保留",

CONFIG_DIALOG_CAPTION = "商人",
CONFIG_DIALOG_KEEPRULES_TAB = "保留规则",
CONFIG_DIALOG_RULES_TAB = "规则",
CONFIG_DIALOG_CONFIRM_DELETE_FMT1 = "删除 '%s' 将使其对所有角色不可用，确定要删除此规则吗？",
CONFIG_DIALOG_SHARE_TOOLTIP = "分享",
CONFIG_DIALOG_MOVEUP_TOOLTIP = "点击以在评估顺序中提前规则",
CONFIG_DIALOG_MOVEDOWN_TOOLTIP = "点击以在评估顺序中推迟规则",
CONFIG_DIALOG_LISTS_TAB = "列表",
CONFIG_DIALOG_AUDIT_TAB = "审计",
CONFIG_DIALOG_LISTS_TEXT = "关联列表中的物品将始终被保留、出售或销毁。|n"..
    "将物品拖到列表区域以将其添加到该列表。|n"..
    "您可以创建自定义列表，并在自定义规则中引用它们。",
ALWAYS_SELL_LIST_NAME = "出售",
ALWAYS_SELL_LIST_TOOLTIP = "每次访问商人时将始终出售的物品。",
NEVER_SELL_LIST_NAME = "保留",
NEVER_SELL_LIST_TOOLTIP = "将始终保留且不会出售或销毁的物品。",
ALWAYS_DESTROY_LIST_NAME = "销毁",
ALWAYS_DESTROY_LIST_TOOLTIP = "每次运行销毁时将被销毁的物品，前提是它们不符合出售或保留规则。",
RULES_DIALOG_HELP_TAB = "帮助",
RULES_DIALOG_EMPTY_LIST = "此列表中没有物品。将物品拖到此区域以将其添加到列表中。",
CONFIG_DIALOG_CREATE_LIST = "创建",

RULES_DIALOG_RULES_TAB = "规则",
RULES_TAB_HELPTEXT = "规则按以下顺序处理：保留 -> 出售 -> 销毁|n"..
    "找到的第一个匹配项将停止进一步评估。|n"..
    "保留/出售/销毁列表中的物品优先于规则。",

-- 出售规则
SYSRULE_SELL_ALWAYSSELL = "出售列表中的物品",
SYSRULE_SELL_ALWAYSSELL_DESC = "始终出售在始终出售列表中的物品。您可以使用 '/vendor list always' 查看完整列表",
SYSRULE_SELL_POORITEMS = "低劣物品",
SYSRULE_SELL_POORITEMS_DESC = "匹配所有 "..ITEM_QUALITY_COLORS[0].hex.."低劣"..FONT_COLOR_CODE_CLOSE.." 品质的物品，这些物品是您捡到的大多数垃圾。",
SYSRULE_SELL_UNCOMMONGEAR = "优秀装备",
SYSRULE_SELL_UNCOMMONGEAR_DESC = "匹配任何 "..ITEM_QUALITY_COLORS[2].hex.."优秀"..FONT_COLOR_CODE_CLOSE.." 装备，其物品等级低于指定的物品等级。",
SYSRULE_SELL_RAREGEAR = "稀有装备",
SYSRULE_SELL_RAREGEAR_DESC = "匹配任何 "..ITEM_QUALITY_COLORS[3].hex.."稀有"..FONT_COLOR_CODE_CLOSE.." 装备，其物品等级低于指定的物品等级。",
SYSRULE_SELL_EPICGEAR = "史诗装备",
SYSRULE_SELL_EPICGEAR_DESC = "匹配灵魂绑定的 "..ITEM_QUALITY_COLORS[4].hex.."史诗"..FONT_COLOR_CODE_CLOSE.." 装备，其物品等级低于指定的物品等级。我们假设您会在拍卖行出售 BoE 史诗装备，因此不包括 BoE。",
SYSRULE_SELL_KNOWNTOYS = "已知玩具",
SYSRULE_SELL_KNOWNTOYS_DESC = "匹配任何已知的灵魂绑定玩具。",
SYSRULE_DESTROY_KNOWNTOYS = "已知玩具（不可出售）",
SYSRULE_DESTROY_KNOWNTOYS_DESC = "匹配任何已知的灵魂绑定且无价值的玩具",
SYSRULE_SELL_OLDFOOD = "低级食物",
SYSRULE_SELL_OLDFOOD_DESC = "匹配低于您10级或更多的食物和饮料。这将涵盖以前扩展包的食物和升级时的旧食物。",

-- 保留规则
SYSRULE_KEEP_NEVERSELL = "保留列表中的物品",
SYSRULE_KEEP_NEVERSELL_DESC = "从不出售在从不出售列表中的物品。您可以使用 '/vendor list never' 查看完整列表",
SYSRULE_KEEP_SOULBOUNDGEAR = "灵魂绑定装备",
SYSRULE_KEEP_SOULBOUNDGEAR_DESC = "保留任何 "..ITEM_QUALITY_COLORS[1].hex.."灵魂绑定"..FONT_COLOR_CODE_CLOSE.." 的装备，即使是您职业无法穿戴的物品。如果您对某些规则不确定，这是一个很好的保障措施。",
SYSRULE_KEEP_BINDONEQUIPGEAR = "装备绑定装备",
SYSRULE_KEEP_BINDONEQUIPGEAR_DESC = "保留任何 "..ITEM_QUALITY_COLORS[1].hex.."装备绑定"..FONT_COLOR_CODE_CLOSE.." 的装备。",
SYSRULE_KEEP_COMMON = "普通物品",
SYSRULE_KEEP_COMMON_DESC = "匹配任何 "..ITEM_QUALITY_COLORS[1].hex.."普通"..FONT_COLOR_CODE_CLOSE.." 品质的物品。这些通常是有价值的消耗品或制作材料。",
SYSRULE_KEEP_UNKNOWNAPPEARANCE = "未收集的外观",
SYSRULE_KEEP_UNKNOWNAPPEARANCE_DESC = "匹配任何未收集外观的装备，这样您就不必担心错过幻化。",
SYSRULE_KEEP_COSMETIC = "装饰性装备",
SYSRULE_KEEP_COSMETIC_DESC = "任何被认为是装饰性的装备，例如：|cff1eff00|Hitem:21525:::::::2010962816:110:66::::::|h[绿色冬帽]|h|r",
SYSRULE_KEEP_LEGENDARYANDUP = "传奇或更好的物品",
SYSRULE_KEEP_LEGENDARYANDUP_DESC = "始终保留任何 "..ITEM_QUALITY_COLORS[5].hex.."传奇"..FONT_COLOR_CODE_CLOSE.." 品质或更高的物品。这包括 "..ITEM_QUALITY_COLORS[5].hex.."传奇"..FONT_COLOR_CODE_CLOSE..", "..ITEM_QUALITY_COLORS[6].hex.."神器"..FONT_COLOR_CODE_CLOSE..", "..ITEM_QUALITY_COLORS[7].hex.."传家宝"..FONT_COLOR_CODE_CLOSE..", 和 "..ITEM_QUALITY_COLORS[8].hex.."暴雪"..FONT_COLOR_CODE_CLOSE.." 物品（魔兽世界代币）。",
SYSRULE_KEEP_UNCOMMONGEAR = "优秀装备|r",
SYSRULE_KEEP_UNCOMMONGEAR_DESC = "匹配任何 "..ITEM_QUALITY_COLORS[2].hex.."优秀"..FONT_COLOR_CODE_CLOSE.." 品质的装备，其物品等级等于或高于指定的物品等级。不包括非装备的优秀品质物品。",
SYSRULE_KEEP_RAREGEAR = "稀有装备",
SYSRULE_KEEP_RAREGEAR_DESC = "匹配任何 "..ITEM_QUALITY_COLORS[3].hex.."稀有"..FONT_COLOR_CODE_CLOSE.." 品质的装备，其物品等级等于或高于指定的物品等级。不包括非装备的稀有品质物品。",
SYSRULE_KEEP_EPICGEAR = "史诗装备",
SYSRULE_KEEP_EPICGEAR_DESC = "匹配任何 "..ITEM_QUALITY_COLORS[4].hex.."史诗"..FONT_COLOR_CODE_CLOSE.." 品质的装备，其物品等级等于或高于指定的物品等级。不包括非装备的史诗品质物品。",
SYSRULE_KEEP_EQUIPMENTSET = "装备套装",
SYSRULE_KEEP_EQUIPMENTSET_DESC = "匹配任何属于内置 "..ITEM_QUALITY_COLORS[8].hex.."暴雪"..FONT_COLOR_CODE_CLOSE.." 装备管理器创建的装备套装的物品",
SYSRULE_KEEP_POTENTIALUPGRADES = "潜在升级",
SYSRULE_KEEP_POTENTIALUPGRADES_DESC = "匹配任何物品等级在您平均物品等级的5级以内或95%以内的装备（以较低者为准）。这可以保护潜在的升级、侧级或其他专精的装备。",
SYSRULE_KEEP_CRAFTINGREAGENT = "制作材料",
SYSRULE_KEEP_CRAFTINGREAGENT_DESC = "匹配所有被认为是制作材料的物品。",
SYSRULE_KEEP_SIDEGRADEORBETTER = "侧级或更好的装备",
SYSRULE_KEEP_SIDEGRADEORBETTER_DESC = "匹配任何物品等级等于或高于您当前装备在该槽位或槽位的装备。",

-- 销毁规则
SYSRULE_DESTROYLIST = "销毁列表中的物品",

-- 工具提示扫描覆盖 - 注意非英语语言的用户。如果这些扫描无法正常工作，请创建一个新的本地化并覆盖它们。它们已在多种语言中确认正确，因此可能不需要更改。
TOOLTIP_SCAN_UNKNOWNAPPEARANCE = _G["TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN"],
TOOLTIP_SCAN_ARTIFACTPOWER = _G["ARTIFACT_POWER"],
TOOLTIP_SCAN_TOY = _G["TOY"],
TOOLTIP_SCAN_ALREADYKNOWN = _G["ITEM_SPELL_KNOWN"],
TOOLTIP_SCAN_CRAFTINGREAGENT = _G["PROFESSIONS_USED_IN_COOKING"],
TOOLTIP_SCAN_BLIZZARDACCOUNTBOUND = _G["ITEM_BNETACCOUNTBOUND"],
TOOLTIP_SCAN_ACCOUNTBOUND = _G["ITEM_ACCOUNTBOUND"],
TOOLTIP_SCAN_ACCOUNTBOUND_UNTILEQUIP = _G["ITEM_ACCOUNTBOUND_UNTIL_EQUIP"],
TOOLTIP_SCAN_COSMETIC = _G["ITEM_COSMETIC"],
TOOLTIP_SCAN_SOULBOUND = _G["ITEM_SOULBOUND"],

-- 数据迁移
DATA_MIGRATION_SL_NOTICE = YELLOW_FONT_COLOR_CODE.. "检测到迁移到暗影国度！商人的设置已重置，自定义规则需要验证后才能激活！" ..FONT_COLOR_CODE_CLOSE,
DATA_MIGRATION_ERROR = YELLOW_FONT_COLOR_CODE.. "数据迁移错误。检测到迁移，但未采取任何行动。请在此通知插件作者：https://www.curseforge.com/wow/addons/vendor/issues" ..FONT_COLOR_CODE_CLOSE,

-- 扩展本地化

-- 编辑规则对话框
EDITRULE_CAPTION = "编辑规则",
CREATERULE_CAPTION = "创建规则",
VIEWRULE_CAPTION = "查看规则",
CREATE_BUTTON = "创建",
EDITRULE_DEFAULT_NAME = "新规则",
EDITRULE_DEFAULT_COPY_NAME_FMT1 = "%s（副本）",
EDITRULE_NAME_LABEL = "名称：",
EDITRULE_TYPE_LABEL = "类型：",
EDITFULE_PARAMETERS_LABEL = "参数",
EDITRULE_ADDPARAM_LABEL = "添加",
EDITRULE_DELPARAM_LABEL = "删除",
EDITRULE_EDITPARAM_LABEL = "编辑",
EDITRULE_VIEWPARAM_LABEL = "查看",
EDITRULE_NOPARAMS_TEXT = "此规则当前没有参数",
EDITRULE_NAME_HELPTEXT = "在此输入您的规则名称",
EDITRULE_FILTER_LABEL = "过滤器：",
EDITRULE_FILTER_HELPTEXT = "点击此处过滤帮助",
EDITRULE_DESCR_LABEL = "描述：",
EDITRULE_DESCR_HELPTEXT = "在此输入您的规则描述",
EDITRULE_SCRIPT_LABEL = "脚本：",
EDITRULE_SCRIPT_HELPTEXT = "在此输入您的规则脚本，请参阅“帮助”以获取可用函数列表以及关系运算符：and, or, >, >=, <, <=, ==, ~=",
EDITRULE_HELP_TAB_NAME = "帮助",
EDITRULE_MATCHES_TAB_NAME = "匹配项",
EDITRULE_MATCHES_TAB_TEXT = "在下方您可以看到当前库存中所有与此规则匹配的物品。",
EDITRULE_ITEMINFO_TAB_NAME = "物品信息",
EDITRULE_ITEMINFO_TAB_TEXT = "<在此放置物品链接>",
EDITRULE_ITEM_PROPERTIES_EMPTY = "将物品拖到此面板以查看该物品的属性。带引号（\"）的属性是字符串，匹配时需要引号。",
EDITRULE_SELLRULE_LABEL = "出售规则",
EDITRULE_SELLRULE_TEXT = "出售规则确定当规则评估为真时商人是否会出售该物品。",
EDITRULE_KEEPRULE_LABEL = "保留规则",
EDITRULE_KEEPRULE_TEXT = "保留规则确定当规则评估为真时商人是否会保留该物品。",
EDITRULE_DELETERULE_TEXT = "销毁规则允许您匹配当规则评估为真时商人将销毁的物品。",
EDITRULE_DELETERULE_LABEL = "销毁规则",

EDITRULE_UNHEALTHY_RULE = "不健康的规则",
EDITRULE_ERROR_RULE = "验证错误",
EDITRULE_OK_TEXT = "规则正常",
EDITRULE_RULEOK_TEXT = "您的规则通过了验证；请检查匹配项选项卡以确保它符合您的预期。",
EDITRULE_SCRIPT_ERROR = "验证您的规则时发现以下错误：|n%s",
EDITRULE_NO_MATCHES = "此规则与您的库存中的任何物品都不匹配。",
EDITRULE_MATCHES_HEADER_FMT = "<h1>此规则匹配了您库存中的 %s 件物品</h1>",
EDITRULE_RULE_SOURCE_FMT = "使用：%s",
EDITRULE_MIGRATE_RULE_TITLE ="验证规则",
EDITRULE_MIGRATE_RULE_TEXT ="规则需要在使用前进行审核。请验证它是否符合您的预期并保存。",
EDITRULE_UNHEALTHY_TEXT = "尝试评估此规则时发生以下错误：|n%s",
EDITRULE_EXTENSION_RULE = "扩展规则",
EDITRULE_EXTENSION_RULE_TEXT = "此规则是使用 '%s' 的内置扩展，无法编辑或删除。",
EDITRULE_SYSTEM_RULE = "内置规则",
EDITRULE_SYSTEM_RULE_TEXT = "此规则是内置的商人规则，无法编辑或删除。",

DIALOG_TEXT_CONFIRM="确认",
IMPORT_HELP_TEXT="在下方粘贴编码的文本字符串以导入其他玩家的商人规则或列表。",
IMPORT_DIALOG_CAPTION="导入规则和列表",
IMPORT_HELP_TEXT_PASTE_HERE="在此处粘贴商人导出字符串以导入规则或列表。",
IMPORT_INVALID_STRING = "指定的字符串不是有效的导入字符串。",
IMPORT_ERROR_CAPTION="导入错误",
IMPORT_PAYLOAD_ERROR = [[
# 导入错误

无效的导入数据。
]],
IMPORT_UNKNOWN_CONTENT = [[
# 导入错误

导入数据不是商人识别的字符串。
]],
IMPORT_MISMATCH_RELEASE = [[
# 导入错误

导入数据适用于不同版本的魔兽世界。
]],
IMPORT_OUTDATED_VERSION = [[
# 导入错误

导入数据来自旧版本的商人，不支持此版本。
]],
IMPORT_BUTTON_TEXT="导入",

EDITPARAM_NAME_LABEL = "名称：",
EDITPARAM_KEY_LABEL = "脚本名称：",
EDITPARAM_TYPE_LABEL = "类型：",
EDITPARAM_DEFAULT_LABEL = "默认值：",
EDITPARAM_CURRENT_LABEL = "当前值：",
EDITPARAM_BOOLEAN_LABEL = "布尔值",
EDITPARAM_BOOLEAN_HELP = "",
EDITPARAM_NUMBER_LABEL = "数字",
EDITPARAM_NUMBER_HELP = "",
EDITPARAM_STRING_LABEL = "字符串",
EDITPARAM_STRING_HELP = "",
EDITPARAM_CREATE_LABEL = "创建",
EDITPARAM_SAVE_LABEL = SAVE,
EDITPARAM_CANCEL_LABEL = CANCEL,
EDITPARAM_CLOSE_LABEL = "关闭",
EDITPARAM_DEFAULT_NAME = "新参数",
EDITPARAM_DEFAULT_SCRIPTNAME = "PARAM",
EEDITPARAM_ERROR_CAPTION = "参数错误",
EDITPARAM_ERROR_CONVERT_DEFAULT = [[
# 无效的默认值

默认值 '%s' 对于参数类型无效
]],
EDITPARAM_ERROR_CREATE_GENERAL = [[
# 创建错误

尝试创建规则参数时发生错误，请检查您的值并重试
]],
EDITPARAM_ERROR_UPDATE_GENERAL = [[
# 保存错误

尝试保存规则参数时发生错误，请检查您的值并重试
]],
EDITPARAM_ERROR_DUPLICATE_KEY = [[
# 重复的脚本名称

脚本名称为 '%s' 的参数已存在，请使用其他名称，或编辑现有的。
]],
EDITPARM_REMOVE_PARAM_CAPTION = "删除参数",
EDITPARAM_REMOVE_PARAM = [[
# 删除参数

您确定要删除参数 '%s' [%s] 吗？
]],
EDITPARAM_CONFIRM_REMOVE = "是的，删除",
EDITPARAM_KEEP_PARAM = "保留",
EDIT_RULE_PARAMETER = "参数",
EDITRULE_ITEM_LABEL = "物品：",
EDITRULE_NO_ITEM = "<无>",
RULEHELP_NO_MATCHES = "没有符合指定过滤条件的物品",
RULEHELP_SOURCE = "来源：%s",
RULEHELP_NOTES = "备注：",
RULEHELP_MAP = "可能的值：",
RULEHELP_EXAMPLES = "示例：",

RULEITEM_UNHEALTHY_WARNING = "此规则的脚本无效，必须修复后才能使用。",
RULEITEM_MIGRATE_WARNING = "此规则是在扩展物品等级压缩之前创建的。为了安全起见，此规则已被禁用，直到您进行审核。右键单击以打开上下文菜单并选择“编辑”进行审核。",
RULEITEM_SOURCE = HIGHLIGHT_FONT_COLOR_CODE .. "来源：|r",

EXPORT_HELP_TEXT = "复制下面的文本以与他人分享此商人创建的内容！",
EXPORT_LIST_CAPTION = "导出列表",
EXPORT_RULE_CAPTION = "导出规则",
EXPORT_CLOSE_BUTTON = "关闭",
IMPORTLIST_UNIQUE_NAME0 = "%s（已导入）",
IMPORTLIST_UNIQUE_NAME1 = "%s（已导入 %d）",
IMPORTLIST_MARKDOWN_FMT = [[
# 导入列表

%s

> %s

您正在从 %s-%s 导入一个包含 %d 个物品的列表，确定要继续吗？
]],
IMPORTRULE_MARKDOWN_FMT = [[
# 导入规则

%s

> %s

您正在导入由 %s-%s 共享的规则，确定要继续吗？
]],

-- 列表面板 / 对话框
EDIT_LIST = "编辑",
NEW_LIST = "创建",
COPY_LIST = "复制",
COPY_LIST_FMT1 = "%s（副本）",
LISTOOLTIP_LISTTYPE = "类型：",
TOOLTIP_SYTEMLIST = "内置（特定配置文件）",
TOOLTIP_CUSTOMLIST = "自定义",
LISTDIALOG_CREATE_CAPTION = "新建列表",
LISTDIALOG_EDIT_CAPTION = "编辑列表",
LISTDIALOG_NAME_LABEL = "名称：",
LISTDIALOG_DESCR_LABEL = "描述：",
LISTDIALOG_CONTENTS_LABEL = "物品：",
LISTDIALOG_NAME_HELPTEXT = "在此输入您的列表名称",
LISTDIALOG_DESCR_HELPTEXT = "在此输入您的列表描述",
LISTDIALOG_ADDBYID_LABEL = "输入物品ID以直接添加，或将物品拖入列表。",
LISTDIALOG_ADDBYID = "添加",
LISTDIALOG_SYSTEM_INFO = "这是一个内置列表，保存在当前配置文件中，您可以添加和删除物品，但不能修改名称或描述",
LISTDIALOG_ADDBYID_HELP = "输入物品ID",
EDITLIST_DUPLICATE_NAME_CAPTION = "名称已存在",
EDITLIST_DUPLICATE_NAME_FMT1 = [[
# 重复的列表名称

名称为 '%s' 的列表已存在，请选择另一个名称。
]],
DELETE_LIST_CAPTION = "删除列表",
DELETE_LIST_FMT1 = [[
# 删除列表 %s？

删除此列表将从所有角色中移除，并可能影响任何配置为使用该列表的规则。此操作无法撤销！

您确定吗？
]],
CONFIRM_DELETE_LIST = "是的，删除",
CANCEL_DELETE_LIST = "取消",

DELETE_RULE_CAPTION = "删除规则",
DELETE_RULE_FMT1 = [[
# 删除规则 %s？

删除此规则将从所有角色中移除。此操作无法撤销！

您确定吗？
]],
CONFIRM_DELETE_RULE = "是的，删除",
CANCEL_DELETE_RULE = "取消",
HIDE_RULE_CAPTION = "隐藏规则",
HIDE_RULE_FMT1 = [[
# 隐藏规则：%s？

如果您隐藏此规则，它将被禁用并且不再显示在规则列表中。您可以随时通过进入“隐藏规则”类别下的设置选项卡取消隐藏它。

您确定要隐藏此规则吗？
]],
CONFIRM_HIDE_RULE = "是的，隐藏",
CANCEL_HIDE_RULE = "取消",
DUPLICATE_RULE_NAME_CAPTION = "现有名称",
DUPLICATE_RULE_FMT1 = [[
# 重复的规则名称

名称为 '%s' 的规则已存在，请选择另一个名称并重新保存规则。
]],
DUPLICATE_RULE_OK = "关闭",

-- 物品列表
ITEMLIST_LOADING = "加载中...",
ITEMLIST_INVALID_ITEM = "无效物品",
ITEMLIST_INVALID_ITEM_TOOLTIP = "暴雪已移除此物品，它不再有效。点击以将其从列表中移除。",
ITEMLIST_LOADING_TOOLTIP = "物品信息正在从服务器检索",
ITEMLIST_EMPTY_SELL_LIST = "您的始终出售列表当前为空，您可以将物品拖放到此列表中以添加它们。",
ITEMLIST_EMPTY_KEEP_LIST = "您的从不出售列表当前为空，您可以将物品拖放到此列表中以添加它们。",
ITEMLIST_REMOVE_TOOLTIP = "从列表中移除",
ITEMLIST_UNSELLABLE = "%s 无法出售，已添加到销毁列表。",
ITEMLIST_EMPTY = "此列表中尚无物品。您可以将物品拖放到此处以填充列表。",

-- LDB 对象
LDB_BUTTON_BUTTON_LABEL = "商人：",
LDB_BUTTON_MENU_TEXT = "商人",
LDB_BUTTON_TOOLTIP_TITLE = "商人",
LDB_BUTTON_TOOLTIP_TOSELL = "出售",
LDB_BUTTON_TOOLTIP_TODESTROY = "销毁",
LDB_BUTTON_TOOLTIP_VALUE = "价值",
LDB_BUTTON_TOOLTIP_TITLEREFRESH = "商人（更新进行中）",
LDB_BUTTON_MENU_NEW_RULE = "新规则",
LDB_BUTTON_MENU_SETTINGS = "设置",
LDB_BUTTON_MENU_KEYBINDINGS = "键绑定",
LDB_BUTTON_MENU_SHOWVALUETEXT = "显示价值文本",
LDB_BUTTON_MENU_HIDE = "隐藏",
LDB_BUTTON_MENU_CHANGE_PROFILES = "设置配置文件",
LDB_BUTTON_MENU_PROFILES = "配置文件",
LDB_BUTTON_MENU_RUNDESTROY = "运行销毁",

-- 物品属性帮助
HELP_NAME_TEXT = [[物品名称，如工具提示中所示。这是一个本地化字符串。]],
HELP_LINK_TEXT = [[物品链接，包括所有颜色代码和物品字符串。如果您想在物品字符串中查找特定ID，这可能很有用。]],
HELP_ID_TEXT =[[物品ID，作为一个数字。]],
HELP_COUNT_TEXT = [[物品数量，作为一个数字。]],
HELP_COUNT_NOTES = "对于物品链接，这将始终为1。当我们扫描您包中的物品时，它将是该槽位的实际数量。" ..
    "这意味着如果您根据数量创建一个出售规则，那么当鼠标悬停在物品上时，商人的工具提示将不准确，因为它使用的是工具提示链接，而不是" ..
    "包槽信息。匹配选项卡使用您包中的物品，因此它将正确显示商人将出售的内容。",
HELP_QUALITY_TEXT = [[物品的品质：

0 = 劣质 
1 = 普通
2 = 优秀
3 = 稀有
4 = 史诗
5 = 传奇
6 = 神器
7 = 传家宝
8 = 魔兽世界代币

您还可以在脚本中使用以下常量：POOR, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, ARTIFACT, HEIRLOOM]],
HELP_LEVEL_TEXT = "如果是装备，这将是物品的有效物品等级，否则如果没有有效物品等级，它将是基础物品等级。",
HELP_MINLEVEL_TEXT = [[装备物品所需的角色等级。]],
HELP_TYPE_TEXT = [[物品类型的名称。这是一个本地化字符串。您可以将其与子类型结合使用，以精确定位特定类型的物品。]],
HELP_TYPEID_TEXT = [[物品类型的数字ID。]],
HELP_TYPEID_NOTES ="这不是本地化的，因此可以移植到使用其他语言环境的玩家。" ..
    "它也比字符串比较更快，因此如果可能，您应该使用它而不是 Type()。",
HELP_SUBTYPE_TEXT = [[物品子类型的名称。这是一个本地化字符串。您可以将其与类型结合使用，以精确定位特定类型的物品。]],
HELP_SUBTYPEID_TEXT = [[物品子类型的数字ID。]],
HELP_SUBTYPEID_NOTES  = "这不是本地化的，因此可以移植到使用其他语言环境的玩家。它也比字符串比较更快，因此如果可能，您应该使用它而不是 SubType()。",
HELP_EQUIPLOC_TEXT = [[物品的装备位置。如果物品不是装备，则为nil。]],
HELP_BINDTYPE_TEXT = [[物品的绑定行为。

0 = 无
1 = 拾取绑定
2 = 装备绑定
3 = 使用绑定
4 = 任务]],
HELP_BINDTYPE_NOTES = "这是物品本身的基本行为，而不是物品的当前绑定状态。这并不能准确告诉您物品是灵魂绑定还是装备绑定。" ..
    "如果您想知道物品是 BoE 还是灵魂绑定，请使用 IsBindOnEquip() 和 IsSoulbound()",
HELP_STACKSIZE_TEXT = [[物品的最大堆叠大小。]],
HELP_UNITVALUE_TEXT = [[单个物品的商人价格（以铜币为单位）。]],
HELP_UNITVALUE_NOTES = "UnitValue == 0 的物品不能出售给商人。此类物品永远不会匹配任何规则，因为您无法出售它们。",
HELP_NETVALUE_TEXT = [[此堆叠的商人价格（以铜币为单位）。这相当于 Count() * UnitValue()]],
HELP_EXPANSIONPACKID_TEXT = [[物品所属的扩展包ID。

0 = 默认 / 无（这匹配许多物品）
1 = 燃烧的远征
2 = 巫妖王之怒
3 = 大地的裂变
4 = 熊猫人之谜
5 = 德拉诺之王
6 = 军团再临
7 = 争霸艾泽拉斯
8 = 暗影国度]],
HELP_EXPANSIONPACKID_NOTES = "在使用此方法识别以前扩展包的物品时要谨慎。并非每个物品都标有扩展ID。通常只有可穿戴装备被标记。零是" ..
    "所有物品的默认值，包括许多扩展包中的物品（如材料和达拉然炉石）。|n|n" ..
    "我们建议您仅将此方法用于涉及可穿戴装备的规则。检查 ExpansionPackId() == 0 " ..
    "意图匹配经典旧世将不会达到您的预期，因为它将包括非经典旧世的物品。同样，" ..
    "ExpansionPackId() < 7 将匹配许多物品。如果您想安全起见，请将此方法与" ..
    "IsEquipment() 结合使用，并拥有一些来自经典旧世和多个扩展包的物品进行验证。",

HELP_ISAZERITEITEM_TEXT = [[如果物品是艾泽里特装备，则为真。]],
HELP_ISEQUIPMENT_TEXT = [[如果物品是可穿戴装备，则为真。这相当于 EquipLoc() ~= nil]],
HELP_ISEQUIPMENT_NOTES = [[这并不能告诉您您的角色是否可以装备该物品。这告诉您物品是否是可装备的装备。]],
HELP_ISSOULBOUND_TEXT = [[如果此特定物品当前是“灵魂绑定”的，则为真。]],
HELP_ISSOULBOUND_NOTES = "如果物品的绑定类型是拾取绑定，那么即使是您尚未拾取的物品，当您将鼠标悬停在它们上面时，这也将始终报告为真。这是因为如果您拾取了该物品，它将是灵魂绑定的，" ..
    "因此我们准确地表示了物品的结果行为。如果物品是装备绑定或使用绑定，那么 IsSoulbound() 将返回假，除非您实际拥有该物品并且我们可以",
HELP_ISBINDONEQUIP_TEXT = [[如果此特定物品当前是“装备绑定”的，则为真。]],
HELP_ISBINDONEQUIP_NOTES = 
    "如果物品的绑定类型是拾取绑定，那么即使是您尚未拾取的物品，当您将鼠标悬停在它们上面时，这也将始终报告为假。这是因为该物品不可能是装备绑定的。" ..
    "如果物品尚未被拾取并且其绑定类型是装备绑定，那么我们将始终报告为真。如果它在您的拥有中并且灵魂绑定给您，那么这将返回假。",
HELP_ISBINDONUSE_TEXT = [[如果此特定物品当前是“使用绑定”的，则为真。]],
HELP_ISBINDONUSE_NOTES = [[如果物品尚未在您的拥有中，那么如果其绑定类型是使用绑定，它将始终返回真。如果它在您的拥有中并且灵魂绑定给您，那么这将返回假。]],
HELP_ISTOY_TEXT = "如果物品是玩具，则为真。",
HELP_ISCRAFTINGREAGENT_TEXT = "如果此特定物品是制作材料，则为真。",
HELP_ISCRAFTINGREAGENT_NOTES = [[这是由工具提示文本确定的。请注意，如果您将制作材料拖到自定义规则定义中的物品框以读取其属性，该物品可能会错误地报告为“假”，但使用此属性进行评估时将正确。]],
HELP_ISALREADYKNOWN_TEXT = [[如果物品是“已知的”，例如您已经学会的玩具或配方，则为真。]],
HELP_ISUSABLE_TEXT = [[如果物品可以使用，例如如果它的工具提示中描述了“使用：”效果，则为真。]],
HELP_ISUNSELLABLE_TEXT = [[如果物品没有价值，则为真。]],
HELP_ISUNSELLABLE_NOTES = [[有一些非常罕见的例外情况，物品可能有价值但无法出售，因此您可能会在这里偶尔得到一个假阴性。这似乎是暴雪端的物品数据错误。]],
HELP_ISBAGANDSLOT_TEXT = [[如果物品有定义的包和槽，则为真。]],
HELP_BAG_TEXT = [[物品的包ID，如果不在包和槽中，则为-1。]],
HELP_SLOT_TEXT = [[物品的槽ID，如果不在包和槽中，则为-1。]],
HELP_CRAFTEDQUALITY_TEXT = [[
巨龙时代专业制作物品或材料的质量。

   0 = 无质量
   1 = 1颗宝石（青铜）
   2 = 2颗宝石（银）
   3 = 3颗宝石，等等
]],

-- FUNCTION HELP

HELP_ISEQUIPPED_TEXT = "如果物品当前已装备，则为真。对于库存中的物品，将永远为假。",

HELP_ISINEQUIPMENTSET_ARGS = "[setName0 .. setNameN]",
HELP_ISINEQUIPMENTSET_TEXT = [[
检查物品是否属于暴雪装备套装，如果找到则返回真。
如果没有提供参数，则检查所有角色的装备套装，否则
仅检查指定的套装。

## 示例

任何装备套装：

> IsInEquipmentSet()

在你的“坦克”装备套装中：

> IsInEquipmentSet("Tank")

### 注意

装备套装通过物品ID匹配，这意味着它可以匹配同一物品的不同物品等级版本，所有这些都将被视为装备套装的一部分。我们使用暴雪提供的数据。
]],

HELP_HASSTAT_TEXT = [[
检查物品是否具有特定的“属性”或属性。这些是物品的属性，而不是任何随机文本。

## 示例

> HasStat("Speed")
> HasStat("Mastery")
]],

HELP_TOOLTIPCONTAINS_TEXT = [[
用法: TooltipContains(text [, side, line])

检查指定文本是否在物品的工具提示中。

## 侧边和行

工具提示的哪一侧（左或右），以及要检查的特定行是可选的。
如果没有指定行或侧边，将检查整个工具提示。

## 示例

> TooltipContains("Rogue")
> TooltipContains("Fated Mythic")

检查工具提示左侧，第1行是否包含“Vanq”

> TooltipContains("Vanq", "left", 1)
]],

HELP_PLAYERLEVEL = [[
返回玩家的当前等级。这使您可以制定仅在升级或达到最高等级时有效的规则。
]],

HELP_PLAYERCLASS = [[
返回当前玩家的英文职业名称（全大写）以制定基于职业的规则。
名称将是全大写的英文职业名称，没有空格，例如“MAGE”、“DEATHKNIGHT”、“DEMONHUNTER”等。

示例: PlayerClass() == "DEMONHUNTER"

]],

HELP_PLAYERITEMLEVEL = [[
返回玩家在角色面板中显示的平均物品等级，向下取整到最接近的整数。
]],

HELP_PLAYERCLASSID = [[
返回当前玩家职业的索引以制定基于职业的规则。索引
比名称查找更快且更短。职业索引：

> 1 = 战士
> 2 = 圣骑士
> 3 = 猎人
> 4 = 盗贼
> 5 = 牧师
> 6 = 死亡骑士
> 7 = 萨满祭司
> 8 = 法师
> 9 = 术士
>10 = 武僧
>11 = 德鲁伊
>12 = 恶魔猎手
>13 = 唤魔师

]],

HELP_PLAYERSPECIALIZATION = [[
返回玩家当前专精的本地化名称。例如：“平衡”对于平衡德鲁伊。
]],

HELP_PLAYERSPECIALIZATIONID = [[
返回玩家当前专精的专精ID。

专精ID参考：

> 死亡骑士: 250 = 血, 251 = 冰霜, 252 = 邪恶
> 恶魔猎手: 577 = 浩劫, 581 = 复仇
> 德鲁伊: 102 = 平衡, 103 = 野性, 104 = 守护, 105 = 恢复
> 唤魔师: 1467 = 毁灭, 1468 = 保护
> 猎人: 253 = 野兽控制, 254 = 射击, 255 = 生存
> 法师: 62 = 奥术, 63 = 火焰, 64 = 冰霜
> 武僧: 268 = 酒仙, 270 = 织雾, 269 = 踏风
> 圣骑士: 65 = 神圣, 66 = 防护, 70 = 惩戒
> 牧师: 256 = 戒律, 257 = 神圣, 258 = 暗影
> 盗贼: 259 = 刺杀, 260 = 狂徒, 261 = 敏锐
> 萨满祭司: 262 = 元素, 263 = 增强, 264 = 恢复
> 术士: 265 = 痛苦, 266 = 恶魔学识, 267 = 毁灭
> 战士: 71 = 武器, 72 = 狂怒, 73 = 防护

## 示例

如果玩家当前是狂怒战士，则为真

> PlayerSpecializationId() == 72

]],

HELP_PLAYERNAME_TEXT = "当前登录角色的名称",

HELP_PLAYERREALM_TEXT = "当前登录角色所在的服务器",

HELP_TOTALITEMCOUNT_TEXT = [[
用法: TotalItemCount([includeBank, includeUses])

返回玩家背包中该物品的总数量。
参数：
  includeBank - 如果要包括银行和材料银行，请设置为“true”。
  includeUses - 如果要多次计算具有多个用途的物品，请设置为“true”。

“includeUses”适用于每个物品有多个充能的物品，例如治疗石。

## 示例

背包中此物品超过100个

> TotalItemCount() > 100

背包和银行中此物品超过100个

> TotalItemCount(true) > 500

仅背包中此物品的用途超过50次

> TotalItemCount(false, true)

所有背包和银行中此物品的用途超过50次

> TotalItemCount(true, true) > 50
]],

HELP_CURRENTEQUIPPEDLEVEL_TEXT = [[
用法: CurrentEquippedLevel()

返回同一槽位中已装备物品的当前物品等级，如果正在评估的物品不是可装备物品或没有有意义的装备槽，则返回0。
此规则用于确定物品与您当前装备的同一槽位物品的比较。例如，它可以告诉您
正在评估的物品是否比您当前装备的物品在物品等级上有所提升。

对于可以在多个槽位中的装备（例如戒指），返回的数字是两个装备中较低的物品等级。

对于双持角色，单手武器将检查两把武器。

对于狂怒战士，两手武器将检查两把武器（考虑到泰坦之握）。

## 示例

如果物品的物品等级等于或高于您当前装备的物品，则为真。

> CurrentEquippedLevel() <= Level

如果物品的物品等级在您当前装备的物品等级以内13级（在一个等级范围内），则为真

> CurrentEquippedLevel() <= (Level + 13)

]],

}) -- END OF LOCALIZATION TABLE

-- Help strings for documentation of rules. These are separate due to the multi-line strings, which doesn't play nice with tables.


