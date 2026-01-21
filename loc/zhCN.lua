-- zhCN Localization by Sanxy09
-- If the loading order of the files is incorrect, this will fail when trying to use AddonLocales.
-- Locales should be loaded AFTER Init and before anything that uses them.
-- So basically make sure they are all loaded together in the TOC right after Init (constants is OK too).
local _, Addon = ...
Addon:AddLocale("zhCN",
{
-- Core
ADDON_NAME = "Vendor",
ADDON_LOADED = "已加载，输入“/vendor help”查看指令",
VENDOR_URL = "https://www.curseforge.com/wow/addons/vendor",
VENDOR_TUTORIAL = "https://youtu.be/j93Orw3vPKQ",
VENDOR_DISCORD  = "https://discord.gg/BtqVg8KVDg",
ABOUT_PROJECT_LABEL = "项目: ",
ABOUT_TUTORIAL_LABEL = "教程: ",
ABOUT_DISCORD_LABEL = "Discord: ",
ABOUT_RELEASES_LABEL = "发布: ",
ABOUT_VERSION_LABEL = "版本: ",
DEFAULT_PROFILE_NAME = "默认",
ABOUT_COPY = "复制",

-- Date Formats - For cultures who may wish to change these.
CMD_HISTORY_DATEFORMAT = "%c",
OPTIONS_AUDIT_TT_DATESTR = "%A, %B %d, %I:%M:%S %p",

-- Rule types
RULE_TYPE_KEEP_NAME = "保留",
RULE_TYPE_KEEP_DESCR = "这些规则是用于防止需要保留物品的被出售|n|n“保留规则”总是优先于“出售规则”，“出售列表”中的物品将忽略“保留规则”",
RULE_TYPE_SELL_NAME = "出售",
RULE_TYPE_SELL_DESCR = "所有添加至“保留列表”的物品将忽略“出售规则”|n|n“保留规则”总是优先于“出售规则”，“出售规则”对物品不生效时可以检查是否受“保留规则”影响",
RULE_TYPE_DELETE_NAME = "摧毁",
RULE_TYPE_DELETE_DESCR = "所有添加至“保留规则/列表”或“出售规则/列表”的物品将忽略“摧毁规则”|n|n摧毁只能由物理按键触发，"..
    "必须使用快捷键、宏或Titan插件按钮触发",

-- Bindings
BINDING_HEADER_VENDORQUICKLIST = "快速添加/移除鼠标指向的物品至“出售列表”",
BINDING_NAME_VENDORALWAYSSELL = "Vendor: 添加/移除物品至出售",
BINDING_DESC_VENDORALWAYSSELL = "将鼠标指向的物品添加至“出售列表”，如果列表中已存在将会移除",
BINDING_NAME_VENDORNEVERSELL = "Vendor: 添加/移除物品至保留",
BINDING_DESC_VENDORNEVERSELL = "将鼠标指向的物品添加至“保留列表”，如果列表中已存在将会移除",
BINDING_NAME_VENDORTOGGLEDESTROY = "Vendor: 添加/移除物品至摧毁",
BINDING_DESC_VENDORTOGGLEDESTROY = "将鼠标指向的物品添加至“摧毁列表”，如果列表中已存在将会移除",
BINDING_NAME_VENDORRUNAUTOSELL = "Vendor: 自动出售",
BINDING_DESC_VENDORRUNAUTOSELL = "在商人处手动触发一次自动出售",
BINDING_NAME_VENDORRUNDESTROY = "Vendor: 摧毁下个物品",
BINDING_DESC_VENDORRUNDESTROY = "摧毁Vendor标记为摧毁的物品，由于暴雪限制只能由物理按键触发",
BINDING_NAME_VENDORRULES = "Vendor: 打开菜单",
BINDING_DESC_VENDORRULES = "打开Vendor规则菜单界面",

-- Merchant
MERCHANT_REPAIR_FROM_GUILD_BANK = "已修理所有装备，花费公会银行%s",
MERCHANT_REPAIR_FROM_SELF = "已修理所有装备，花费%s",
MERCHANT_SELLING_ITEM = "出售%s，获得%s（%s）",
MERCHANT_WITHDRAW_ITEM = "提取%s出售",
MERCHANT_SOLD_ITEMS = "出售%s个物品，获得%s",
MERCHANT_WITHDRAWN_ITEMS = "提取%s个物品",
MERCHANT_SELL_LIMIT_REACHED = "已到达出售上限（%s），停止自动出售",
MERCHANT_AUTO_CONFIRM_SELL_TRADE_REMOVAL = "已自动确认使%s不可交易",
MERCHANT_SELL_ITEMS = "出售 [%s]",
MERCHANT_DESTROY_ITEMS = "摧毁 [%s]",
MERCHANT_SELL_BUTTON_TOOLTIP_TITLE = "出售",
MERCHANT_DESTROY_BUTTON_TOOLTIP_TITLE = "摧毁下个物品",
MERCHANT_DESTROY_BUTTON_TOOLTIP_NEXT = "摧毁: \n  ",
MERCHANT_DESTROY_BUTTON_TOOLTIP_REMAINING = "剩余: ",

-- Destroy
ITEM_DESTROY_SUMMARY = "已摧毁%s个物品",
ITEM_DESTROY_CURRENT = "正在摧毁%s（%s）",
ITEM_DESTROY_CANCELLED_CURSORITEM = "鼠标正在持有物品，取消摧毁",
ITEM_DESTROY_STARTED = "开始摧毁匹配“摧毁规则/列表”的物品",
ITEM_DESTROY_MORE_ITEMS = "剩余%s个物品待摧毁",
ITEM_DESTROY_NONE_REMAIN = "未找到标记为摧毁的物品",

-- Tooltip
TOOLTIP_ADDITEM_ERROR_NOITEM = "添加物品至%s-出售列表失败，未指向物品",
TOOLTIP_ITEM_IN_ALWAYS_SELL_LIST = "Vendor: 出售",
TOOLTIP_ITEM_IN_NEVER_SELL_LIST = "Vendor: 保留",
TOOLTIP_ITEM_IN_DESTROY_LIST = "Vendor: 摧毁",
TOOLTIP_ITEM_WILL_BE_SOLD = "Vendor将出售该物品",
TOOLTIP_ITEM_WILL_BE_DELETED = "Vendor将摧毁该物品",
TOOLTIP_RULEMATCH_SELL = "出售: %s",
TOOLTIP_RULEMATCH_KEEP = "保留: %s",
TOOLTIP_RULEMATCH_DESTROY = "摧毁: %s",

-- Options
OPTIONS_TITLE_ADDON = "这些设置用于配置Vendor行为\n\n",
OPTIONS_SHOW_BINDINGS = "快捷键",
OPTIONS_OPEN_RULES = "打开规则",
OPTIONS_OPEN_SETTINGS = "打开设置",

OPTIONS_AUDIT_INTRO_TEXT = "记录30天内该角色在Vendor进行过的所有操作",
OPTIONS_AUDIT_SEARCH_LABEL = "搜索: ",
OPTIONS_AUDIT_FILTER_LABEL = "过滤: ",
OPTIONS_AUDIT_EMPTY = "未找到与关键字/过滤匹配的记录",
OPTIONS_AUDIT_SEARCH_PLACEHOLDER = "输入关键字进行搜索",
OPTIONS_AUDIT_FILTER_SOLD = "出售",
OPTIONS_AUDIT_FILTER_SOLD_DESC = "包含所有已出售的物品",
OPTIONS_AUDIT_FILTER_DESTROYED = "摧毁",
OPTIONS_AUDIT_FILTER_DESTROYED_DESC = "包含所有已摧毁的物品",
OPTIONS_AUDIT_FILTER_EPIC = "史诗",
OPTIONS_AUDIT_FILTER_EPIC_DESC = "包含所有史诗品质的物品",
OPTIONS_AUDIT_FILTER_RARE = "精良",
OPTIONS_AUDIT_FILTER_RARE_DESC = "包含所有精良品质的物品",
OPTIONS_AUDIT_FILTER_UNCOMMON = "优秀",
OPTIONS_AUDIT_FILTER_UNCOMMON_DESC = "包含所有优秀品质的物品",
OPTIONS_AUDIT_FILTER_LEGENDARY = "传说及以上",
OPTIONS_AUDIT_FILTER_LEGENDARY_DESC = "包含所有传说及更高品质的物品",
OPTIONS_AUDIT_FILTER_COMMON = "普通及以下",
OPTIONS_AUDIT_FILTER_COMMON_DESC = "包含所有普通及更低品质的物品",
OPTIONS_AUDIT_FILTER_EXTENSION = "自定义规则",
OPTIONS_AUDIT_FILTER_EXTENSION_DESC = "包含所有Vendor自定义规则中出售/摧毁的物品",
OPTIONS_AUDIT_FILTER_ALL = "所有",
OPTIONS_VENDOR_AUDIT = "Vendor统计: ",
OPTIONS_AUDIT_TT_PROFILE = "配置: ",
OPTIONS_AUDIT_TT_RULE = "规则: ",
OPTIONS_AUDIT_TT_SOLD = "出售: ",
OPTIONS_AUDIT_TT_DESTROYED = "摧毁: ",

RULES_DIALOG_CONFIG_TAB = "设置",
SETTINGS_CATEGORY_LABEL = "类别",

-- Setting categories and descriptions.
OPTIONS_CATEGORY_QUICK = "快速",
OPTIONS_DESC_QUICK = "快速进行常用功能设置",
OPTIONS_CATEGORY_GENERAL = "一般",
OPTIONS_DESC_GENERAL = "所有Vendor的一般设置",
OPTIONS_CATEGORY_HIDDENRULES = "隐藏规则",
OPTIONS_DESC_HIDDENRULES = "管理隐藏规则",
OPTIONS_CATEGORY_PROTECT = "保护",
OPTIONS_DESC_PROTECT = "设置是否开启Vendor保护防止意外出售/删除“保留”物品",
OPTIONS_CATEGORY_SELLING = "出售",
OPTIONS_DESC_SELLING = "设置在商人处出售时的操作",
OPTIONS_CATEGORY_REPAIR = "修理",
OPTIONS_DESC_REPAIR = "设置是否开启自动修理以及如何支付修理费\n",
OPTIONS_CATEGORY_LOOTING = "拾取",
OPTIONS_DESC_LOOTING = "设置拾取相关选项，例如快速拾取\n",
OPTIONS_CATEGORY_TOOLTIP = "鼠标提示",
OPTIONS_DESC_TOOLTIP = "设置指向物品时的鼠标提示",
OPTIONS_CATEGORY_DEBUG = "调试",
OPTIONS_DESC_DEBUG = "调试设置",
OPTIONS_CATEGORY_ADVANCED = "高级",
OPTIONS_DESC_ADVANCED = "高级设置，不推荐自行调整",
OPTIONS_CATEGORY_PERFORMANCE = "性能",
OPTIONS_DESC_PERFORMANCE = "Vendor使用限流和协程以避免客户端无响应和掉线，这些设置用于控制该行为\n\n",

-- Individual settings
OPTIONS_SETTINGNAME_AUTOSELL = "自动出售",
OPTIONS_SETTINGDESC_AUTOSELL = "访问商人时自动出售物品，禁用后仍可设置快捷键/添加按钮手动出售",
OPTIONS_SETTINGNAME_BUYBACK = "限制单次出售上限为12",
OPTIONS_SETTINGDESC_BUYBACK = "设置每次触发自动出售时的出售上限为12（购回上限），避免出现无法购回的情况。建议在适应并信任Vendor的规则和列表后禁用",
OPTIONS_SETTINGNAME_CONFIG = "打开规则配置",
OPTIONS_SETTINGDESC_CONFIG = "显示规则配置界面，可以启用/禁用规则以及创建新的规则",
OPTIONS_SETTINGNAME_TOOLTIP = "启用鼠标提示",
OPTIONS_SETTINGDESC_TOOLTIP = "标记为出售的物品添加鼠标提示信息",
OPTIONS_SETTINGNAME_EXTRARULEINFO = "额外的规则信息",
OPTIONS_SETTINGDESC_EXTRARULEINFO = "显示物品所匹配的“保留/出售规则”信息，仅显示所有匹配规则的第一条",
OPTIONS_SETTINGNAME_MAXITEMS = "限制出售上限",
OPTIONS_SETTINGDESC_MAXITEMS = "设置每次触发自动出售时的出售上限，设置为12可以避免出现无法购回的情况",
OPTIONS_SETTINGNAME_AUTOREPAIR = "自动修理",
OPTIONS_SETTINGDESC_AUTOREPAIR = "访问可修理的商人时自动修理",
OPTIONS_SETTINGNAME_GUILDREPAIR = "使用公会银行",
OPTIONS_SETTINGDESC_GUILDREPAIR = "公会银行可用时，使用公会银行修理",
OPTIONS_SETTINGNAME_SELL_THROTTLE = "每周期出售物品数",
OPTIONS_SETTINGDESC_SELL_THROTTLE = "设置每周期出售物品的数量，增加数值可以大批量出售，可能被暴雪限流",
OPTIONS_SETTINGNAME_CYCLE_RATE = "周期速律",
OPTIONS_SETTINGDESC_CYCLE_RATE = "尝试出售上方设置数量物品的时间间隔（秒），数值越低越快，增加数值可以降低出售速率，避免被暴雪限流",
OPTIONS_SETTINGNAME_MINIMAP = "显示小地图按钮",
OPTIONS_SETTINGDESC_MINIMAP = "在小地图添加Vendor按钮，可以快速访问规则和配置，鼠标指向时显示匹配物品的信息\n\n该设置账户通用",
OPTIONS_SETTINGNAME_MERCHANT = "显示商人按钮",
OPTIONS_SETTINGDESC_MERCHANT = "在商人界面添加按钮，可以手动触发自动出售/摧毁操作\n\n该设置账户通用",
OPTIONS_SETTINGNAME_PROTECTION = "保护“保留”物品",
OPTIONS_SETTINGDESC_PROTECTION = "尝试删除保留物品时自动取消\n\n保留物品被出售时Vendor将尝试回购",
OPTIONS_SETTINGNAME_FASTLOOT = "快速拾取",
OPTIONS_SETTINGDESC_FASTLOOT = "提升拾取速度，当拾取界面出现时会立即拾取所有可获得物品，比普通拾取速度快三倍。未开启自动拾取时不生效\n\n该设置账户通用",

QUICK_SELL_SETTING = "自动出售",
QUICK_SELL_SETTING_HELP = "访问商人时自动出售物品，禁用后仍可设置快捷键/添加按钮手动出售\n\n同时设置出售上限为12（购回上限），避免出现无法购回的情况",
QUICK_REPAIR_SETTING = "自动修理",
QUICK_REPAIR_SETTING_HELP = "访问可修理的商人时自动修理\n\n同时启用公会银行修理",
QUICK_PROTECT_SETTING = "保护“保留”物品被出售/删除",
QUICK_PROTECT_SETTING_HELP = "自动回购被出售的保留物品，自动取消删除保留物品",
QUICK_MINIMAP_SETTING = "显示小地图按钮",
QUICK_MINIMAP_SETTING_HELP = "在小地图添加Vendor按钮，可以快速访问规则和配置，鼠标指向时显示匹配物品的信息\n\n该设置账户通用",
QUICK_MERCHANT_SETTING = "显示商人按钮",
QUICK_MERCHANT_SETTING_HELP = "在商人界面添加按钮，可以进行手动触发自动出售/摧毁操作\n\n该设置账户通用",

-- Profiles Page
OPTIONS_PROFILE_TITLE = "配置",
OPTIONS_PROFILE_HELPTEXT = "所有规则设置，插件设置和保留/出售/摧毁列表内容都储存在单独配置\n"..
    "配置文件全局储存所有服务器和角色，并按角色选择",
OPTIONS_PROFILE_COPY = "复制",
OPTIONS_PROFILE_CREATE = "新建",
OPTIONS_PROFILE_RENAME = "重命名",
OPTIONS_PROFILE_SET = "设置",
OPTIONS_PROFILE_NAME_PLACEHOLDER = "在此处输入配置名称进行创建/复制",
OPTIONS_PROFILE_CREATETEXT = "可以创建一个新配置（Vendor默认配置）或从列表中复制一个已有配置\n不输入名称则默认为“角色名字 - 服务器”",
OPTIONS_CONFIRM_PROFILE_DELETE_CAPTION = "删除配置",
OPTIONS_CONFIRM_PROFILE_DELETE_CONFIRM = "确认",
OPTIONS_CONFIRM_PROFILE_DELETE_FMT1 = [[
# 删除配置


是否确认删除配置“%s”？"
]],
OPTIONS_PROFILE_DUPLICATE_NAME_CAPTION = "名称重复",
OPTIONS_PROFILE_DUPLICATE_NAME_FMT1 = [[
# 配置名称重复

配置“%s”已存在，请重新命名
]],
OPTIONS_PROFILE_CREATE_LABEL = "创建配置",
OPTIONS_PROFILE_DEFAULT_COPY_NAME = "%s（副本）",

OPTIONS_RULES_SHOW_HIDDEN = "显示隐藏",
OPTIONS_RULES_ONE_HIDDEN = "（1条规则）",
OPTIONS_RULES_N_HIDDEN = " （%s条规则）",

SETTINGS_HIDDENRULES_HELP = "所有已隐藏的规则，可以选中并点击下方按钮取消隐藏",
SETTINGS_HIDDENRULES_EMPTY = "未找到已隐藏的规则",
SETTINGS_HIDDENRULES_UNHIDE = "取消隐藏",
SETTINGS_HIDDENRULES_TYPE_FMT = "（%s）",

RULE_TOOLTIP_SOURCE = "来源: %s",
RULE_TOOLTIP_HIDDEN = "该规则已在查看中隐藏",
RULE_TOOLTIP_CUSTOM_RULE = "自定义规则",
RULE_TOOLTIP_SYSTEM_RULE = "内置",
RULE_LIST_EMPTY = "该类别中未找到规则，请创建新规则！",

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

-- Console Commands
CMD_HELP_HEADER = "命令参考: ",
CMD_HELP_HELP = "显示命令列表参考",

CMD_SETTINGS_HELP = "打开设置界面",
CMD_RULES_HELP = "打开规则界面",
CMD_KEYS_HELP = "打开快捷键绑定",
CMD_WITHDRAW_HELP = "提取所有银行中的待出售物品，需要打开银行",
CMD_API_HELP = "列出Vendor公共API",

CMD_LISTTOGGLE_HELP = "添加/移除物品至列表: list {sell||keep||destroy} [itemid]",
CMD_LISTTOGGLE_INVALIDARG = "必须指定物品要查询/编辑的列表: {sell||keep||destroy} [item]",
CMD_LISTTOGGLE_ADDED = "物品: %s添加至“%s”列表",
CMD_LISTTOGGLE_REMOVED = "物品: %s移除出“%s”列表",

CMD_LISTDATA_INVALIDARG = "无效选项: %s  可用列表: [sell||keep||destroy]",
CMD_LISTDATA_EMPTY = "“%s”列表为空",
CMD_LISTDATA_LISTHEADER = "“%s”列表中的物品: ",
CMD_LISTDATA_LISTITEM = "  %s - %s",
CMD_LISTDATA_NOTINCACHE = "[未找到物品，请重新执行]",
CMD_LISTTOGGLE_UNSELLABLE = "%s无法出售，移动至摧毁列表",

CMD_AUTOSELL_MERCHANTNOTOPEN = "未打开商人界面，必须在商人处自动出售",
CMD_AUTOSELL_INPROGRESS = "正在自动出售，请等待完成后再尝试重新执行",
CMD_AUTOSELL_EXECUTING = "自动出售",

CMD_CLEAR_ALL_HISTORY = "清除所有记录",
CMD_CLEAR_CHAR_HISTORY = "清除“%s”记录",
CMD_PRINT_HISTORY_HEADER = "“%s”记录",
CMD_PRINT_HISTORY_SUMMARY = "“%s”记录包含%s个条目总计%s",
CMD_PRINT_HISTORY_SUMMARY_ALL = "所有记录包含%s个条目总计%s",
CMD_PRUNE_CHAR_HISTORY = "删减“%s”记录中超过%s小时的条目",
CMD_PRUNE_ALL_HISTORY = "删减所有记录中超过%s小时的条目",
CMD_PRUNE_HISTORY_ARG = "无效的删减参数，请指定需要删减的小时数",
CMD_PRUNE_SUMMARY = "已从记录中移除%s个条目",
CMD_HISTORY_HELP = "查看、清除或删减记录，用法: history [clear||prune 小时] [all]",

CMD_RUNDESTROY = "摧毁下个摧毁规则/列表中的物品",
CMD_DESTROY_HELP = "摧毁一个匹配摧毁规则/列表的物品，每次命令仅摧毁一个物品",

CMD_DEFAULTLIST_HELP = "列举并重置内置物品列表",
CMD_LIST_HEADER = "默认物品列表: ",
CMD_LIST_USAGE = "用法: list <all||reset>",
CMD_LIST_ENUM = "  %s - 版本: %s",
CMD_LIST_RESET_COMPLETE = "“%s”列表已重置为默认",

-- API
API_REGISTEREXTENSION_TITLE = "注册扩展",
API_REGISTEREXTENSION_DOCS = "注册一个Vendor扩展，详情请参阅CurseForge文档",
API_EVALUATEITEM_TITLE = "评估物品",
API_EVALUATEITEM_DOCS = "评估物品是否可出售，输入参数为背包栏位和格位",
API_ADDTOALWAYSSELL_TITLE = "将鼠标指向的物品添加至“出售列表”",
API_ADDTOALWAYSSELL_DOCS = "在“出售列表”中添加/移除鼠标指向的物品",
API_ADDTONEVERSELL_TITLE = "将鼠标指向的物品添加至“保留列表”",
API_ADDTONEVERSELL_DOCS = "在“保留列表”中添加/移除鼠标指向的物品",
API_ADDTODESTROY_TITLE = "将鼠标指向的物品添加至“摧毁列表”",
API_ADDTODESTROY_DOCS = "在“摧毁列表”中添加/移除鼠标指向的物品",
API_AUTOSELL_TITLE = "自动出售",
API_AUTOSELL_DOCS = "在商人处时执行一次自动出售",
API_OPENSETTINGS_TITLE = "打开设置",
API_OPENSETTINGS_DOCS = "打开Vendor设置界面",
API_OPENKEYBINDINGS_TITLE = "打开快捷键",
API_OPENKEYBINDINGS_DOCS = "打开Vendor快捷键界面",
API_OPENRULES_TITLE = "打开规则",
API_OPENRULES_DOCS = "打开Vendor界面的规则标签页",
API_OPENPROFILES_TITLE = "打开配置",
API_OPENPROFILES_DOCS = "打开Vendor界面的配置标签页",
API_GETEVALUATIONSTATUS_TITLE = "获取评估状态",
API_GETEVALUATIONSTATUS_DOCS = "返回Vendor将要处理的物品格位中，出售/摧毁物品的数量和总价值",
API_GETPRICESTRING_TITLE = "获取价格字符串",
API_GETPRICESTRING_DOCS = "将整数型转换为带颜色代码和硬币图标的价格字符串",
API_SETPROFILE_TITLE = "设置配置",
API_SETPROFILE_DOCS = "将当前配置切换为指定配置",
API_GETPROFILES_TITLE = "获取配置",
API_GETPROFILES_DOCS = "获取所有可用的配置列表",
API_DESTROYITEMS_TITLE = "摧毁物品",
API_DESTROYITEMS_DOCS = "执行摧毁物品，摧毁下一个匹配摧毁规则/列表的物品，由于暴雪限制一次只能摧毁一个物品",

-- Rules
RULEUI_LABEL_ITEMLEVEL_PARAM = "物品升级最高等级",

CONFIG_DIALOG_CAPTION = "Vendor",
CONFIG_DIALOG_KEEPRULES_TAB = "保留规则",
CONFIG_DIALOG_RULES_TAB = "规则",
CONFIG_DIALOG_CONFIRM_DELETE_FMT1 = "删除规则“%s”将影响所有角色，是否确认删除？",
CONFIG_DIALOG_SHARE_TOOLTIP = "分享",
CONFIG_DIALOG_MOVEUP_TOOLTIP = "点击提高规则优先级",
CONFIG_DIALOG_MOVEDOWN_TOOLTIP = "点击降低规则优先级",
CONFIG_DIALOG_LISTS_TAB = "列表",
CONFIG_DIALOG_AUDIT_TAB = "统计",
CONFIG_DIALOG_LISTS_TEXT = "列表中的物品总是被保留/出售/摧毁|n"..
    "将物品拖动至列表区域进行添加|n"..
    "可以创建自定义列表并使用自定义规则",
ALWAYS_SELL_LIST_NAME = "出售",
ALWAYS_SELL_LIST_TOOLTIP = "物品总是被出售，忽略“保留/摧毁规则”",
NEVER_SELL_LIST_NAME = "保留",
NEVER_SELL_LIST_TOOLTIP = "物品总是被保留，忽略“出售/摧毁规则”",
ALWAYS_DESTROY_LIST_NAME = "摧毁",
ALWAYS_DESTROY_LIST_TOOLTIP = "物品总是被摧毁，忽略“保留/出售规则”",
RULES_DIALOG_HELP_TAB = "帮助",
RULES_DIALOG_EMPTY_LIST = "该列表中未找到物品，将物品拖动至该区域进行添加",
CONFIG_DIALOG_CREATE_LIST = "创建",

RULES_DIALOG_RULES_TAB = "规则",
RULES_TAB_HELPTEXT = "规则处理的优先级为: 保留->出售->摧毁|n"..
    "成功匹配一条规则后将停止继续匹配|n"..
    "“保留/出售/摧毁列表”中的物品忽略规则",

-- Sell Rules
SYSRULE_SELL_ALWAYSSELL = "出售列表",
SYSRULE_SELL_ALWAYSSELL_DESC = "“出售列表”中的物品总是出售，输入“/vendor list always”查看完整列表",
SYSRULE_SELL_POORITEMS = "粗糙物品",
SYSRULE_SELL_POORITEMS_DESC = "匹配所有"..ITEM_QUALITY_COLORS[0].hex.."粗糙"..FONT_COLOR_CODE_CLOSE.."品质物品，主要是拾取的垃圾",
SYSRULE_SELL_UNCOMMONGEAR = "优秀装备",
SYSRULE_SELL_UNCOMMONGEAR_DESC = "匹配所有低于指定装等的"..ITEM_QUALITY_COLORS[2].hex.."优秀"..FONT_COLOR_CODE_CLOSE.."品质装备",
SYSRULE_SELL_RAREGEAR = "精良装备",
SYSRULE_SELL_RAREGEAR_DESC = "匹配所有低于指定装等的"..ITEM_QUALITY_COLORS[3].hex.."精良"..FONT_COLOR_CODE_CLOSE.."品质装备",
SYSRULE_SELL_EPICGEAR = "史诗装备",
SYSRULE_SELL_EPICGEAR_DESC = "匹配所有低于指定装等的"..ITEM_QUALITY_COLORS[4].hex.."史诗"..FONT_COLOR_CODE_CLOSE.."品质装备，可能会需要在拍卖行出售这些装备",
SYSRULE_SELL_KNOWNTOYS = "已经学会的玩具",
SYSRULE_SELL_KNOWNTOYS_DESC = "匹配所有灵魂绑定且已经学会的玩具",
SYSRULE_DESTROY_KNOWNTOYS = "已经学会的玩具（无法出售）",
SYSRULE_DESTROY_KNOWNTOYS_DESC = "匹配所有灵魂绑定、已经学会且无法出售的玩具",
SYSRULE_SELL_OLDFOOD = "低等级食物",
SYSRULE_SELL_OLDFOOD_DESC = "匹配所有低于角色等级10以上的食物和饮水，将会包含所有旧资料片和升级过程中的食物",

-- Keep Rules
SYSRULE_KEEP_NEVERSELL = "保留列表",
SYSRULE_KEEP_NEVERSELL_DESC = "“保留列表”中的物品永不出售，输入“/vendor list never”查看完整列表",
SYSRULE_KEEP_SOULBOUNDGEAR = "灵魂绑定装备",
SYSRULE_KEEP_SOULBOUNDGEAR_DESC = "保留所有"..ITEM_QUALITY_COLORS[1].hex.."灵魂绑定"..FONT_COLOR_CODE_CLOSE.."装备（包含非本职业），为某些不确定的规则提供保障",
SYSRULE_KEEP_BINDONEQUIPGEAR = "装备后绑定装备",
SYSRULE_KEEP_BINDONEQUIPGEAR_DESC = "保留所有"..ITEM_QUALITY_COLORS[1].hex.."装备后绑定"..FONT_COLOR_CODE_CLOSE.."装备",
SYSRULE_KEEP_COMMON = "普通物品",
SYSRULE_KEEP_COMMON_DESC = "匹配所有"..ITEM_QUALITY_COLORS[1].hex.."普通"..FONT_COLOR_CODE_CLOSE.."品质物品，通常是消耗品/制作材料",
SYSRULE_KEEP_UNKNOWNAPPEARANCE = "未收集的外观",
SYSRULE_KEEP_UNKNOWNAPPEARANCE_DESC = "匹配所有未收集外观的装备，防止错过幻化",
SYSRULE_KEEP_COSMETIC = "装饰品",
SYSRULE_KEEP_COSMETIC_DESC = "匹配所有装饰品，例如|cff1eff00|Hitem:21525:::::::2010962816:110:66::::::|h[绿色冬帽]|h|r",
SYSRULE_KEEP_LEGENDARYANDUP = "传说及以上物品",
SYSRULE_KEEP_LEGENDARYANDUP_DESC = "保留所有"..ITEM_QUALITY_COLORS[5].hex.."传说"..FONT_COLOR_CODE_CLOSE.."及更高品质物品，包含"..ITEM_QUALITY_COLORS[5].hex.."传说"..FONT_COLOR_CODE_CLOSE.."、"..ITEM_QUALITY_COLORS[6].hex.."神器"..FONT_COLOR_CODE_CLOSE.."、"..ITEM_QUALITY_COLORS[7].hex.."传家宝"..FONT_COLOR_CODE_CLOSE.."和"..ITEM_QUALITY_COLORS[8].hex.."暴雪"..FONT_COLOR_CODE_CLOSE.."物品（魔兽世界时光徽章）",
SYSRULE_KEEP_UNCOMMONGEAR = "优秀装备",
SYSRULE_KEEP_UNCOMMONGEAR_DESC = "匹配所有高于指定装等的"..ITEM_QUALITY_COLORS[2].hex.."优秀"..FONT_COLOR_CODE_CLOSE.."品质装备，不包含优秀品质非装备",
SYSRULE_KEEP_RAREGEAR = "精良装备",
SYSRULE_KEEP_RAREGEAR_DESC = "匹配所有高于指定装等的"..ITEM_QUALITY_COLORS[3].hex.."精良"..FONT_COLOR_CODE_CLOSE.."品质装备，不包含精良品质非装备",
SYSRULE_KEEP_EPICGEAR = "史诗装备",
SYSRULE_KEEP_EPICGEAR_DESC = "匹配所有高于指定装等的"..ITEM_QUALITY_COLORS[4].hex.."史诗"..FONT_COLOR_CODE_CLOSE.."品质装备，不包含史诗品质非装备",
SYSRULE_KEEP_EQUIPMENTSET = "装备方案",
SYSRULE_KEEP_EQUIPMENTSET_DESC = "匹配所有"..ITEM_QUALITY_COLORS[8].hex.."暴雪"..FONT_COLOR_CODE_CLOSE.."内置装备管理方案中的装备",
SYSRULE_KEEP_POTENTIALUPGRADES = "升级潜力",
SYSRULE_KEEP_POTENTIALUPGRADES_DESC = "匹配所有物品等级低于平均物品等级5以内或95%的装备，为有升级潜力/同级别/其他专精的装备提供保障",
SYSRULE_KEEP_CRAFTINGREAGENT = "制作材料",
SYSRULE_KEEP_CRAFTINGREAGENT_DESC = "匹配所有制作材料",
SYSRULE_KEEP_SIDEGRADEORBETTER = "同级别及以上",
SYSRULE_KEEP_SIDEGRADEORBETTER_DESC = "匹配所有物品等级等于或高于当前栏位的装备",
SYSRULE_KEEP_CRAFTEDGEAR = "制造的史诗装备",
SYSRULE_KEEP_CRAFTEDGEAR_DESC = "匹配所有制造的史诗及更高品质装备，保护所有制造的毕业装备（火花装备等）",
SYSRULE_KEEP_LEVELINGGEAR = "高等级装备",
SYSRULE_KEEP_LEVELINGGEAR_DESC = "匹配所有使用等级高于玩家当前等级的装备，升级后可能会用到",
SYSRULE_KEEP_IMPORTANTITEMS = "重要物品",
SYSRULE_KEEP_IMPORTANTITEMS_DESC = "匹配所有“重要物品”列表中的物品，该列表包含过资料片中常见的重要物品",
SYSRULE_KEEP_PROFESSIONGEAR = "专业装备",
SYSRULE_KEEP_PROFESSIONGEAR_DESC = "匹配所有可装备于专业栏位的装备，对角色专业技能至关重要",

LIST_STATIC_IMPORTANT_NAME = "重要物品",
LIST_STATIC_IMPORTANT_DESC = "关联“重要物品”保留规则的物品，对账号中的所有角色生效",

-- Destroy Rules
SYSRULE_DESTROYLIST = "摧毁列表",

-- Tooltip Scan Overrides - Note for folks of non-English languages. If these scans don't work properly, create a new locale and override them. They have been confirmed to be correct in several languages, so probably dont need to be changed.
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

-- Data Migration
DATA_MIGRATION_SL_NOTICE = YELLOW_FONT_COLOR_CODE.. "已检测到转移至暗影国度！Vendor设置已重置，自定义规则需要验证后才能生效！" ..FONT_COLOR_CODE_CLOSE,
DATA_MIGRATION_ERROR = YELLOW_FONT_COLOR_CODE.. "数据转移出错，已检测到转移，但无事发生，请通知插件作者: https://www.curseforge.com/wow/addons/vendor/issues" ..FONT_COLOR_CODE_CLOSE,

-- Extensions Loc

-- Edit Rule Dialog
EDITRULE_CAPTION = "编辑规则",
CREATERULE_CAPTION = "创建规则",
VIEWRULE_CAPTION = "查看规则",
CREATE_BUTTON = "创建",
EDITRULE_DEFAULT_NAME = "新规则",
EDITRULE_DEFAULT_COPY_NAME_FMT1 = "%s（副本）",
EDITRULE_NAME_LABEL = "名称: ",
EDITRULE_TYPE_LABEL = "类型: ",
EDITFULE_PARAMETERS_LABEL = "参数",
EDITRULE_ADDPARAM_LABEL = "添加",
EDITRULE_DELPARAM_LABEL = "移除",
EDITRULE_EDITPARAM_LABEL = "编辑",
EDITRULE_VIEWPARAM_LABEL = "查看",
EDITRULE_NOPARAMS_TEXT = "该规则当前没有参数",
EDITRULE_NAME_HELPTEXT = "在此处输入规则名称",
EDITRULE_FILTER_LABEL = "过滤: ",
EDITRULE_FILTER_HELPTEXT = "点击此处过滤帮助",
EDITRULE_DESCR_LABEL = "描述: ",
EDITRULE_DESCR_HELPTEXT = "在此处输入规则描述",
EDITRULE_SCRIPT_LABEL = "脚本: ",
EDITRULE_SCRIPT_HELPTEXT = "在此处输入规则脚本，查看“帮助”了解可用函数列表及关系操作符: and, or, >, >=, <, <=, ==, ~=",
EDITRULE_HELP_TAB_NAME = "帮助",
EDITRULE_MATCHES_TAB_NAME = "匹配",
EDITRULE_MATCHES_TAB_TEXT = "下方可以看到背包中所有匹配规则的物品",
EDITRULE_ITEMINFO_TAB_NAME = "物品信息",
EDITRULE_ITEMINFO_TAB_TEXT = "<在此处放置物品链接>",
EDITRULE_ITEM_PROPERTIES_EMPTY = "拖动物品至该面板查看物品属性，带有引号（\"）的属性是字符串，匹配时也需要引号",
EDITRULE_SELLRULE_LABEL = "出售规则",
EDITRULE_SELLRULE_TEXT = "规则评估为真时，出售规则决定Vendor是否出售物品",
EDITRULE_KEEPRULE_LABEL = "保留规则",
EDITRULE_KEEPRULE_TEXT = "规则评估为真时，保留规则决定Vendor是否保留物品",
EDITRULE_DELETERULE_TEXT = "规则评估为真时，摧毁规则决定Vendor是否摧毁物品",
EDITRULE_DELETERULE_LABEL = "摧毁规则",

EDITRULE_UNHEALTHY_RULE = "不健康规则",
EDITRULE_ERROR_RULE = "验证错误",
EDITRULE_OK_TEXT = "规则通过",
EDITRULE_RULEOK_TEXT = "验证规则通过: 检查匹配标签，确保符合预期",
EDITRULE_SCRIPT_ERROR = "验证规则时发现以下错误: |n%s",
EDITRULE_NO_MATCHES = "背包中没有物品匹配该规则",
EDITRULE_MATCHES_HEADER_FMT = "<h1>背包中有%s个物品匹配该规则</h1>",
EDITRULE_RULE_SOURCE_FMT = "使用: %s",
EDITRULE_MIGRATE_RULE_TITLE ="验证规则",
EDITRULE_MIGRATE_RULE_TEXT ="规则在使用前需要审核，请验证匹配是否符合预期并保存",
EDITRULE_UNHEALTHY_TEXT = "评估规则时发现以下错误: |n%s",
EDITRULE_EXTENSION_RULE = "扩展规则",
EDITRULE_EXTENSION_RULE_TEXT = "该规则是“%s”扩展内置规则，无法编辑/删除",
EDITRULE_SYSTEM_RULE = "内置规则",
EDITRULE_SYSTEM_RULE_TEXT = "该规则是Vendor内置规则，无法编辑/删除",


DIALOG_TEXT_CONFIRM="确认",
IMPORT_HELP_TEXT="在下方粘贴Vendor编码文本字符串，导入其他玩家的规则/列表",
IMPORT_DIALOG_CAPTION="导入规则/列表",
IMPORT_HELP_TEXT_PASTE_HERE="在此处粘贴Vendor导出的规则/列表字符串",
IMPORT_INVALID_STRING = "字符串不是有效的导入字符串",
IMPORT_ERROR_CAPTION="导入错误",
IMPORT_PAYLOAD_ERROR = [[
# 导入错误

无效的导入数据
]],
IMPORT_UNKNOWN_CONTENT = [[
# 导入错误

导入数据不是Vendor字符串
]],
IMPORT_MISMATCH_RELEASE = [[
# 导入错误

导入数据是其他版本的魔兽世界
]],
IMPORT_OUTDATED_VERSION = [[
# 导入错误

导入数据来源是旧版Vendor，当前版本不支持
]],

EDITPARAM_NAME_LABEL = "名称: ",
EDITPARAM_KEY_LABEL = "脚本命名: ",
EDITPARAM_TYPE_LABEL = "类型: ",
EDITPARAM_DEFAULT_LABEL = "默认值: ",
EDITPARAM_CURRENT_LABEL = "当前值: ",
EDITPARAM_BOOLEAN_LABEL = "布尔",
EDITPARAM_BOOLEAN_HELP = "",
EDITPARAM_NUMBER_LABEL = "数值",
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

默认值“%s”对于参数类型无效
]],
EDITPARAM_ERROR_CREATE_GENERAL = [[
# 创建错误

创建规则参数时出错
请检查值并重试
]],
EDITPARAM_ERROR_UPDATE_GENERAL = [[
# 保存错误

保存规则参数时出错
请检查值并重试
]],
EDITPARAM_ERROR_DUPLICATE_KEY = [[
# 脚本命名重复

脚本名为“%s”的参数已存在，请重新命名或编辑重名参数

]],
EDITPARM_REMOVE_PARAM_CAPTION = "移除参数",
EDITPARAM_REMOVE_PARAM = [[
# 移除参数

是否确认移除参数“%s” [%s]？"
]],
EDITPARAM_CONFIRM_REMOVE = "是，移除",
EDITPARAM_KEEP_PARAM = "保留",
EDIT_RULE_PARAMETER = "参数",
EDITRULE_ITEM_LABEL = "物品: ",
EDITRULE_NO_ITEM = "<无>",

RULEHELP_NO_MATCHES = "没有匹配指定过滤的物品",
RULEHELP_SOURCE = "来源: %s",
RULEHELP_NOTES = "备注: ",
RULEHELP_MAP = "可能值: ",
RULEHELP_EXAMPLES = "示例: ",

RULEITEM_UNHEALTHY_WARNING = "该规则中有无效脚本，必须修复后才能生效",
RULEITEM_MIGRATE_WARNING = "该规则在资料片压缩物品等级前创建，安全起见在重新审核前已禁用。右键打开菜单并选择“编辑”进行审核",
RULEITEM_SOURCE = HIGHLIGHT_FONT_COLOR_CODE .. "来源: |r",

EXPORT_HELP_TEXT = "复制下方文本，与其他玩家分享Vendor内容！",
EXPORT_LIST_CAPTION = "导出列表",
EXPORT_RULE_CAPTION = "导出规则",
EXPORT_CLOSE_BUTTON = "关闭",
IMPORTLIST_UNIQUE_NAME0 = "%s（导入）",
IMPORTLIST_UNIQUE_NAME1 = "%s（导入%d）",
IMPORTLIST_MARKDOWN_FMT = [[
# 导入列表

%s

> %s

正在导入“%s-%s”的列表，包含%d个物品，是否继续？

]],
IMPORTRULE_MARKDOWN_FMT = [[
# 导入规则

%s

> %s

正在导入“%s-%s”的规则，是否继续？
]],

-- List Pane / Dialog
EDIT_LIST = "编辑",
NEW_LIST = "创建",
COPY_LIST = "复制",
COPY_LIST_FMT1 = "%s（副本）",
LISTOOLTIP_LISTTYPE = "类型: ",
TOOLTIP_SYSTEMLIST = "内置（指定配置）",
TOOLTIP_STATICLIST = "内置（账号）",
TOOLTIP_CUSTOMLIST = "自定义",
LISTDIALOG_CREATE_CAPTION = "新列表",
LISTDIALOG_EDIT_CAPTION = "编辑列表",
LISTDIALOG_NAME_LABEL = "名称: ",
LISTDIALOG_DESCR_LABEL = "描述: ",
LISTDIALOG_CONTENTS_LABEL = "物品: ",
LISTDIALOG_NAME_HELPTEXT = "在此输入列表名称",
LISTDIALOG_DESCR_HELPTEXT = "在此输入列表描述",
LISTDIALOG_ADDBYID_LABEL = "输入物品ID直接添加，或拖动物品至列表",
LISTDIALOG_ADDBYID = "添加",
LISTDIALOG_SYSTEM_INFO = "该列表是保存在当前配置的内置列表，可以添加/移除物品但无法修改名称/描述",
LISTDIALOG_STATIC_INFO = "该列表是保存在账号的内置列表，可以添加/移除物品但无法修改名称/描述",
LISTDIALOG_ADDBYID_HELP = "在此输入物品ID",
EDITLIST_DUPLICATE_NAME_CAPTION = "名称重复",
EDITLIST_DUPLICATE_NAME_FMT1 = [[
# 列表名称重复

列表“%s”已存在，请重新命名
]],
DELETE_LIST_CAPTION = "删除列表",
DELETE_LIST_FMT1 = [[
# 删除列表“%s”？

删除该列表将从所有角色中移除，并影响所有使用该列表的规则|n
|cffff0000此操作无法撤销！|r

是否确认删除？
]],
CONFIRM_DELETE_LIST = "是，删除",
CANCEL_DELETE_LIST = "取消",

DELETE_RULE_CAPTION = "删除规则",
DELETE_RULE_FMT1 = [[
# 删除规则“%s”？

删除该规则将从所有角色中移除，|cffff0000此操作无法撤销！|r

是否确认删除？
]],
CONFIRM_DELETE_RULE = "是，删除",
CANCEL_DELETE_RULE = "取消",
HIDE_RULE_CAPTION = "隐藏规则",
HIDE_RULE_FMT1 = [[
# 隐藏规则“%s”?

隐藏该规则将禁用并不在规则列表中显示|n
可以在“设置->隐藏规则”中取消隐藏

是否确认隐藏？
]],
CONFIRM_HIDE_RULE = "是，隐藏",
CANCEL_HIDE_RULE = "取消",
DUPLICATE_RULE_NAME_CAPTION = "名称重复",
DUPLICATE_RULE_FMT1 = [[
# 规则名称重复

规则“%s”已存在，请重新命名并保存

]],
DUPLICATE_RULE_OK = "关闭",

-- ItemLists
ITEMLIST_LOADING = "加载……",
ITEMLIST_INVALID_ITEM = "无效物品",
ITEMLIST_INVALID_ITEM_TOOLTIP = "该物品不再有效，暴雪已将其移除，点击从列表中移除",
ITEMLIST_LOADING_TOOLTIP = "正在从服务器检索物品信息",
ITEMLIST_EMPTY_SELL_LIST = "出售列表为空，拖动物品到此处进行添加",
ITEMLIST_EMPTY_KEEP_LIST = "保留列表为空，拖动物品到此处进行添加",
ITEMLIST_REMOVE_TOOLTIP = "从列表中移除",
ITEMLIST_UNSELLABLE = "%s无法出售，添加至摧毁列表",
ITEMLIST_EMPTY = "该列表中没有物品，拖动物品到此处进行添加",

-- LDB Object
LDB_BUTTON_BUTTON_LABEL = "Vendor: ",
LDB_BUTTON_MENU_TEXT = "Vendor",
LDB_BUTTON_TOOLTIP_TITLE = "Vendor",
LDB_BUTTON_TOOLTIP_TOSELL = "待出售",
LDB_BUTTON_TOOLTIP_TODESTROY = "待摧毁",
LDB_BUTTON_TOOLTIP_VALUE = "价值",
LDB_BUTTON_TOOLTIP_TITLEREFRESH = "Vendor",
LDB_BUTTON_TOOLTIP_PROTECTIONSTATUS_ON = "物品保护"..GREEN_FONT_COLOR_CODE.."启用"..FONT_COLOR_CODE_CLOSE,
LDB_BUTTON_TOOLTIP_PROTECTIONSTATUS_OFF = "物品保护"..RED_FONT_COLOR_CODE.."禁用"..FONT_COLOR_CODE_CLOSE,
LDB_BUTTON_TOOLTIP_HOWTOSHOWHELP = "（按住Alt显示额外操作）",
LDB_BUTTON_TOOLTIP_HELP_TITLE = "点击选项: ",
LDB_BUTTON_TOOLTIP_HELP_RULES = "  左键 = 打开规则",
LDB_BUTTON_TOOLTIP_HELP_PROFILES = "  右键 = 打开配置",
LDB_BUTTON_TOOLTIP_HELP_DESTROY = "  Shift + 左键 = 摧毁下个物品",
LDB_BUTTON_TOOLTIP_HELP_PROTECTION = "  Shift + 右键 = 启用/禁用保护",
LDB_BUTTON_MENU_NEW_RULE = "新规则",
LDB_BUTTON_MENU_SETTINGS = "设置",
LDB_BUTTON_MENU_KEYBINDINGS = "快捷键绑定",
LDB_BUTTON_MENU_SHOWVALUETEXT = "显示价值文本",
LDB_BUTTON_MENU_HIDE = "隐藏",
LDB_BUTTON_MENU_CHANGE_PROFILES = "设置配置",
LDB_BUTTON_MENU_PROFILES = "配置",
LDB_BUTTON_MENU_RUNDESTROY = "开始摧毁",

-- ITEM PROPERTIES HELP

HELP_NAME_TEXT = [[物品名称（本地化字符串），鼠标提示中显示的名称]],
HELP_LINK_TEXT = [[物品链接，包含颜色代码和物品字符串，可用于在物品字符串中匹配指定ID]],
HELP_ID_TEXT =[[物品ID（数值）]],
HELP_COUNT_TEXT = [[物品数量（数值）]],
HELP_COUNT_NOTES = "物品链接的数量始终为1，背包扫描时显示该格位实际堆叠数量。" ..
    "基于物品数量的出售规则并不准确，" ..
    "鼠标提示中的数量来自物品链接而非背包格位信息。" ..
    "使用背包中的物品匹配将会准确出售",
HELP_QUALITY_TEXT = [[物品品质: 

0 = 粗糙
1 = 普通
2 = 优秀
3 = 精良
4 = 史诗
5 = 传说
6 = 神器
7 = 传家宝
8 = 魔兽世界时光徽章

脚本中也可以使用常量: POOR, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, ARTIFACT, HEIRLOOM]],
HELP_LEVEL_TEXT = "装备显示实际物品等级，非装备显示基础物品等级",
HELP_MINLEVEL_TEXT = [[装备所需的角色等级]],
HELP_TYPE_TEXT = [[物品类型名称（本地化字符串），可结合子类型精确查找指定类型的物品]],
HELP_TYPEID_TEXT = [[物品类型ID]],
HELP_TYPEID_NOTES ="非本地化数据，跨语言通用。" ..
    "性能优于Type()，建议优先使用",
HELP_SUBTYPE_TEXT = [[物品子类型名称（本地化字符串），可结合类型精确查找指定类型的物品]],
HELP_SUBTYPEID_TEXT = [[物品子类型ID]],
HELP_SUBTYPEID_NOTES  = "非本地化数据，跨语言通用。性能优于Subtype()，建议优先使用",
HELP_EQUIPLOC_TEXT = [[物品装备栏位，非装备为nil]],
HELP_BINDTYPE_TEXT = [[物品绑定类型: 

0 = 无
1 = 拾取后绑定
2 = 装备后绑定
3 = 使用后绑定
4 = 任务]],
HELP_BINDTYPE_NOTES = "这是物品的基础绑定类型，而非当前绑定状态！" ..
    "不会判断物品是灵魂绑定还是装备后绑定，" ..
    "查询灵魂绑定使用IsSoulbound()，装备后绑定使用IsBindOnEquip()",
HELP_STACKSIZE_TEXT = [[物品最大堆叠数量]],
HELP_UNITVALUE_TEXT = [[单个物品售价（铜）]],
HELP_UNITVALUE_NOTES = "UnitValue == 0的物品无法出售，也不会匹配任何出售规则",
HELP_NETVALUE_TEXT = [[堆叠物品售价（铜），等同于"Count() * UnitValue()""]],
HELP_EXPANSIONPACKID_TEXT = [[物品所属资料片ID: 

0 = 默认/无（包含大量物品）
1 = 燃烧的远征
2 = 巫妖王之怒
3 = 大地的裂变
4 = 熊猫人之谜
5 = 德拉诺之王
6 = 军团再临
7 = 争霸艾泽拉斯
8 = 暗影国度
9 = 巨龙时代
10 = 地心之战
254 = 怀旧服探索赛季]],
HELP_EXPANSIONPACKID_NOTES = "过往资料片中一般只有装备标记了资料片ID，" ..
    "未标记的物品默认为0，" .. 
    "例如材料和达拉然炉石|n|n" ..
    "推荐仅用于查找装备。使用ExpansionPackId() == 0" ..
    "查找经典旧世将包含大量其他资料片的物品，" ..
    "同样ExpansionPackId() < 7也将匹配大量物品，" ..
    "建议结合IsEquipment()使用。"..
    "怀旧服探索赛季的资料片ID是254",

HELP_ISAZERITEITEM_TEXT = [[物品是否为艾泽里特装备]],
HELP_ISEQUIPMENT_TEXT = [[物品是否为装备, 等同于"EquipLoc() ~= nil"]],
HELP_ISEQUIPMENT_NOTES = [[不会判断角色是否可装备，仅识别物品是否为装备]],
HELP_ISSOULBOUND_TEXT = [[物品当前是否为“灵魂绑定”]],
HELP_ISSOULBOUND_NOTES = "物品的绑定类型为拾取后绑定则总是返回true，" ..
    "包含鼠标指向但未拾取的物品，" ..
    "因为已识别出拾取后将变为灵魂绑定。" ..
    "装备/使用后绑定的物品在绑定前，IsSoulbound()将返回false",
HELP_ISBINDONEQUIP_TEXT = [[物品当前是否为“装备后绑定”]],
HELP_ISBINDONEQUIP_NOTES = 
    "物品的绑定类型为拾取后绑定则总是返回false，" ..
    "包含鼠标指向但未拾取的物品，因为已识别出不可能是装备后绑定。" ..
    "鼠标指向但未拾取的物品类型为装备后绑定则总是返回true，绑定后将返回false",
HELP_ISBINDONUSE_TEXT = [[物品当前是否为“使用后绑定”]],
HELP_ISBINDONUSE_NOTES = [[物品的绑定类型为使用后绑定时，绑定前总是返回true，绑定后将返回false]],
HELP_ISTOY_TEXT = "物品是否为玩具",
HELP_ISCRAFTINGREAGENT_TEXT = "物品是否为制作材料",
HELP_ISCRAFTINGREAGENT_NOTES = [[根据鼠标提示文本判断，注意自定义规则时将制作材料拖入物品信息查询时可能错误显示为false，不影响实际功能]],
HELP_ISALREADYKNOWN_TEXT = [[物品是否已经学会，例如玩具/配方]],
HELP_ISUSABLE_TEXT = [[物品是否可使用，鼠标提示中包含“使用:”描述]],
HELP_ISUNSELLABLE_TEXT = [[物品售价是否为0（是否无法出售）]],
HELP_ISUNSELLABLE_NOTES = [[极少数无法出售的物品售价不为0，可能导致返回false，是暴雪物品数据的问题]],
HELP_ISBAGANDSLOT_TEXT = [[物品是否在背包栏位和格位中]],
HELP_BAG_TEXT = [[物品的背包栏位ID，不在背包中返回-1]],
HELP_SLOT_TEXT = [[物品的背包格位ID，不在背包中返回-1]],
HELP_CRAFTEDQUALITY_TEXT = [[
巨龙时代专业制作物品/材料的品质:

   0 = 无
   1 = 1宝石（铜）
   2 = 2宝石（银）
   3 = 3宝石（金及更高）
]],

-- FUNCTION HELP

HELP_ISEQUIPPED_TEXT = "物品是否正在装备，背包中总是返回false",

HELP_ISINEQUIPMENTSET_ARGS = "[setName0 .. setNameN]",
HELP_ISINEQUIPMENTSET_TEXT = [[
检查物品是否属于暴雪装备方案，
无参数时检查所有装备方案，
反之检查指定装备方案

## 示例

任意装备方案: 

> IsInEquipmentSet()

在“坦克”装备方案: 

> IsInEquipmentSet("坦克")

### 注意

装备方案仅匹配物品ID，会包含不同物品等级的同ID装备
]],

HELP_HASSTAT_TEXT = [[
检查物品是否包含指定属性（非任意文本）

## 示例

> HasStat("Speed")
> HasStat("Mastery")
]],

HELP_TOOLTIPCONTAINS_TEXT = [[
用法: TooltipContains(文本 [, 侧, 行])

检查物品鼠标提示中是否包含指定文本

## 侧 & 行

指定鼠标提示的左侧（left）/右侧（right）和指定的行（可选），
未指定侧或行时检查整个鼠标提示

## 示例

> TooltipContains("潜行者")
> TooltipContains("史诗宿命")

检查左侧、第1行是否包含"胜": 

> TooltipContains("胜", "left", 1)
]],

HELP_PLAYERLEVEL = [[
返回当前角色等级，可用于创建升级/满级相关规则
]],

HELP_PLAYERCLASS = [[
返回当前角色职业名称（全大写英文），可用于创建职业相关规则。
名称为全大写英文无空格，例如: "MAGE"（法师），"DEATHKNIGHT"（死亡骑士），"DEMONHUNTER"（恶魔猎手）等

示例: PlayerClass() == "DEMONHUNTER"

]],

HELP_HASPROFESSION = [[
玩家是否拥有指定专业，
可使用本地化名称或下列非本地化环境变量，
仅支持主专业

可用的专业环境变量:
ALCHEMY（炼金术）
* BLACKSMITHING（锻造）
* ENCHANTING（附魔）
* ENGINEERING（工程学）
* HERBALISM（草药学）
* INSCRIPTION（铭文）
* JEWELCRAFTING（珠宝加工）
* LEATHERWORKING（制皮）
* MINING（采矿）
* SKINNING（剥皮）
* TAILORING（裁缝）

## 示例:
> HasProfession(ENCHANTING)
> HasProfession("附魔")

]],

HELP_PLAYERITEMLEVEL = [[
返回角色界面显示的平均物品等级（向下取整）
]],

HELP_PLAYERCLASSID = [[
返回当前角色职业索引，用于创建职业相关规则。
索引性能优于名称，职业索引:

> 1 = 战士
> 2 = 圣骑士
> 3 = 猎人
> 4 = 潜行者
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
返回角色当前专精的本地化名称，例如: 平衡德鲁伊返回"平衡"
]],

HELP_PLAYERSPECIALIZATIONID = [[
返回角色当前专精的ID

专精ID: 

> 死亡骑士: 250 = 鲜血, 251 = 冰霜, 252 = 邪恶
> 恶魔猎手: 577 = 浩劫, 581 = 复仇
> 德鲁伊: 102 = 平衡, 103 = 野性, 104 = 守护, 105 = 恢复
> 唤魔师: 1467 = 湮灭, 1468 = 恩护, 1473 = 增辉
> 猎人: 253 = 野兽控制, 254 = 射击, 255 = 生存
> 法师: 62 = 奥术, 63 = 火焰, 64 = 冰霜
> 武僧: 268 = 酒仙, 270 = 踏风, 269 = 织雾
> 圣骑士: 65 = 神圣, 66 = 保护, 70 = 惩戒
> 牧师: 256 = 戒律, 257 = 神圣, 258 = 暗影
> 潜行者: 259 = 奇袭, 260 = 狂徒, 261 = 敏锐
> 萨满祭司: 262 = 元素, 263 = 增强, 264 = 恢复
> 术士: 265 = 痛苦, 266 = 恶魔学识, 267 = 毁灭
> 战士: 71 = 武器, 72 = 狂怒, 73 = 防护

## 示例

角色当前专精是狂怒战士则返回true

> PlayerSpecializationId() == 72

]],

HELP_PLAYERNAME_TEXT = "当前角色的名称",

HELP_WATERMARKLEVEL_TEXT = [[返回相同栏位装备过的最高物品等级，
例如头部装备过的最高装等为500，装备其他头部时也返回500。

用于判断装备有提升或是同级别

## 示例
MaxLevel >= WatermarkLevel()
]],
HELP_PLAYERREALM_TEXT = "当前角色的服务器",

HELP_TOTALITEMCOUNT_TEXT = [[
用法: TotalItemCount([包含银行, 计算使用次数])

返回背包中物品的总数量
参数: 
  包含银行 - 设置为true将包含银行和材料银行中的物品
  计算使用次数 - 设置为true将按使用次数计算物品数量

“计算使用次数”用于可多次使用的物品，例如治疗石

## 示例

背包中有超过100个该物品: 

> TotalItemCount() > 100

背包和银行中总共有超过500个该物品: 

> TotalItemCount(true) > 500

背包中该物品可使用次数超过50次: 

> TotalItemCount(false, true) > 50

背包和银行中该物品总使用次数超过50次: 

> TotalItemCount(true, true) > 50
]],


HELP_CURRENTEQUIPPEDLEVEL_TEXT = [[
用法: CurrentEquippedLevel()

返回相同栏位当前装备的物品等级，
非装备返回0。
用于比较装备升级价值

戒指/饰品将返回其中较低的物品等级

双持单手武器将检查两把武器

狂怒战士将检查两把双手武器

## 示例

物品大于等于当前装备的物品等级时返回true

> CurrentEquippedLevel() <= Level

物品提升13个等级后大于等于当前装备的物品等级时返回true

> CurrentEquippedLevel() <= (Level + 13)

]],
EXT_AUCTIONATOR_FUNC_ISAUCTIONITEM = [[
需要Auctionator

返回物品是否有拍卖数据，表明是可拍卖物品，
等同于"Auc_AuctionValuce() > 0"
]],

EXT_AUCTIONATOR_FUNC_AUCTIONVALUE = [[
需要Auctionator

返回物品的拍卖价格（铜），没有拍卖数据时返回0。 

该数值已扣除拍卖行手续费（5%），与实际卖出后获得的金额相同
]],
EXT_AUCTIONATOR_FUNC_AUCTIONPROFIT = [[
需要Auctionator

返回拍卖减商人价格后的利润（金）。

该数值已扣除拍卖行手续费（5%），以金币计算。
没有拍卖数据或亏损时返回0，不为负数。

可用于创建一个最低利润的规则，
判断物品是否值得花时间和耐心去拍卖，还是直接卖给商人。
低利润物品可能不值得花时间去拍卖，除非数量巨大
]],
EXT_AUCTIONATOR_FUNC_AUCTIONRATIO = [[
需要Auctionator

返回拍卖和商人价格的比率。
比率越高，拍卖的价值越高。
例如物品价格比率为2，表示拍卖是商人的2倍利润

该数值已扣除拍卖行手续费（5%），
反应了实际拍卖对比商人的价格，负数表示亏损。

可用于判断物品值得拍卖还是卖给商人，
低比率表示物品拍卖反而可能损失金钱和时间
]],
EXT_AUCTIONATOR_RULENAME_KEEPFORAUCTION = "Auctionator - 拍卖保留",
EXT_AUCTIONATOR_RULEDESC_KEEPFORAUCTION = [[
匹配所有达到指定最低利润（金）和最低拍卖/商人价格比率的物品，在参数中调整数保留值得拍卖的物品
]],
EXT_AUCTIONATOR_RULEPARAM_MINAUCTIONPROFIT = "最低利润（金）",
EXT_AUCTIONATOR_RULEPARAM_MINAUCTIONRATIO = "最低价格比率",

}) -- END OF LOCALIZATION TABLE

-- Help strings for documentation of rules. These are separate due to the multi-line strings, which doesn't play nice with tables.


