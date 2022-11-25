-- enUS Localization
-- If the loading order of the files is incorrect, this will fail when trying to use AddonLocales.
-- Locales should be loaded AFTER Init and before anything that uses them.
-- So basically make sure they are all loaded together in the TOC right after Init (constants is OK too).
local _, Addon = ...
Addon:AddLocale("enUS",
{
-- Core
ADDON_NAME = "Vendor",
ADDON_LOADED = "is loaded. Type '/vendor help' for usage.",
VENDOR_URL = "https://www.curseforge.com/wow/addons/vendor",
VENDOR_TUTORIAL = "https://youtu.be/j93Orw3vPKQ",
ABOUT_PROJECT_LABEL = "Project:",
ABOUT_TUTORIAL_LABEL = "Tutorial:",
ABOUT_RELEASES_LABEL = "Releases:",
ABOUT_VERSION_LABEL = "Version:",
DEFAULT_PROFILE_NAME = "Default",
ABOUT_COPY = "Copy",

-- Date Formats - For cultures who may wish to change these.
CMD_HISTORY_DATEFORMAT = "%c",
OPTIONS_AUDIT_TT_DATESTR = "%A, %B %d, %I:%M:%S %p",

-- Rule types
RULE_TYPE_KEEP_NAME = "Keep",
RULE_TYPE_KEEP_DESCR = "These rules are safeguards to prevent selling things you don't want sold.|n|nAll Keep Rules are checked before Sell Rules. However, anything you add to the 'Sell' list will ignore Keep Rules.",
RULE_TYPE_SELL_NAME = "Sell",
RULE_TYPE_SELL_DESCR = "Anything you add to the 'Keep' list will ignore Sell Rules and always be kept.|n|nKeep Rules are always processed before Sell Rules, so if the Sell Rule you enable doesn't seem to work check the Keep Rules to see if something is preventing it.",
RULE_TYPE_DELETE_NAME = "Destroy",
RULE_TYPE_DELETE_DESCR = "Anything you add to the 'Keep' list or rules or 'Sell' list or rules will supercede Destroy rules.|n|nDestroy can only happen on a hardware event, so you must"..
    " use a keybinding, macro, or Titan plugin button press to trigger it.",

-- Bindings
BINDING_HEADER_VENDORQUICKLIST = "Quick Add/Remove items from the sell lists when mousing over the item",
BINDING_NAME_VENDORALWAYSSELL = "Vendor: Toggle Sell Item",
BINDING_DESC_VENDORALWAYSSELL = "Adds the item currently in the game tooltip to the Sell list. Removes it if it is already in the list.",
BINDING_NAME_VENDORNEVERSELL = "Vendor: Toggle Keep Item",
BINDING_DESC_VENDORNEVERSELL = "Adds the item currently in the game tooltip to the Keep list. Removes it if it is already in the list.",
BINDING_NAME_VENDORTOGGLEDESTROY = "Vendor: Toggle Destroy Item",
BINDING_DESC_VENDORTOGGLEDESTROY = "Adds the item currently in the game tooltip to the Destroy list. Removes it if it is already in the list.",
BINDING_NAME_VENDORRUNAUTOSELL = "Vendor: Autosell at Merchant",
BINDING_DESC_VENDORRUNAUTOSELL = "Manually trigger an autoselling run while at a merchant.",
BINDING_NAME_VENDORRUNDESTROY = "Vendor: Destroy Next Item",
BINDING_DESC_VENDORRUNDESTROY = "Destroy items vendor has identified for destruction. This must be done via hardware event due to a Blizzard restriction.",
BINDING_NAME_VENDORRULES = "Vendor: Open Menu",
BINDING_DESC_VENDORRULES = "Toggles the visibility of the main Vendor Rules menu.",

-- Merchant
MERCHANT_REPAIR_FROM_GUILD_BANK = "Repaired all equipment from the guild bank for %s",
MERCHANT_REPAIR_FROM_SELF = "Repaired all equipment for %s",
MERCHANT_SELLING_ITEM = "Sold %s for %s (%s)",
MERCHANT_WITHDRAW_ITEM = "Withdrawing %s to sell.",
MERCHANT_SOLD_ITEMS = "Sold %s items for %s",
MERCHANT_WITHDRAWN_ITEMS = "Withdrew %s items.",
MERCHANT_SELL_LIMIT_REACHED = "Reached the sell limit (%s), stopping auto-sell.",
MERCHANT_AUTO_CONFIRM_SELL_TRADE_REMOVAL = "Auto-accepted confirmation of making %s non-tradeable.",
MERCHANT_SELL_ITEMS = "Sell [%d]",
MERCHANT_DESTROY_ITEMS = "Destroy [%d]",

-- Destroy
ITEM_DESTROY_SUMMARY = "Destroyed %s items.",
ITEM_DESTROY_CURRENT = "Destroying %s (%s)",
ITEM_DESTROY_CANCELLED_CURSORITEM = "Cancelling item destroy due to an item being held.",
ITEM_DESTROY_STARTED = "Starting destruction of items matching Destroy rules or list...",
ITEM_DESTROY_MORE_ITEMS = "There are %s more items remaining for destruction.",
ITEM_DESTROY_NONE_REMAIN = "There are no items identified for destruction.",

-- Tooltip
TOOLTIP_ADDITEM_ERROR_NOITEM = "Failed to add item to %s-sell list. The game tooltip is not over an item.",
TOOLTIP_ITEM_IN_ALWAYS_SELL_LIST = "Vendor: Sell",
TOOLTIP_ITEM_IN_NEVER_SELL_LIST = "Vendor: Keep",
TOOLTIP_ITEM_IN_DESTROY_LIST = "Vendor: Destroy",
TOOLTIP_ITEM_WILL_BE_SOLD = "Will be sold by Vendor",
TOOLTIP_ITEM_WILL_BE_DELETED = "Will be DESTROYED by Vendor",
TOOLTIP_RULEMATCH_SELL = "Sell: %s",
TOOLTIP_RULEMATCH_KEEP = "Keep: %s",
TOOLTIP_RULEMATCH_DESTROY = "Destroy: %s",

-- Options
OPTIONS_TITLE_ADDON = "These settings are for configuring Vendor behavior.\n\n",
OPTIONS_SHOW_BINDINGS = "Key Bindings",
OPTIONS_OPEN_RULES = "Open Rules",
OPTIONS_OPEN_SETTINGS = "Open Settings",

OPTIONS_AUDIT_INTRO_TEXT = "Records of all recent actions Vendor has taken for this character up to the last 30 days.",
OPTIONS_AUDIT_SEARCH_LABEL = "Search:",
OPTIONS_AUDIT_FILTER_LABEL = "Filter:",
OPTIONS_AUDIT_EMPTY = "No records match the filters and/or search terms specified.",
OPTIONS_AUDIT_SEARCH_PLACEHOLDER = "Enter terms to search",
OPTIONS_AUDIT_FILTER_SOLD = "Sold",
OPTIONS_AUDIT_FILTER_SOLD_DESC = "Include all items which were sold",
OPTIONS_AUDIT_FILTER_DESTROYED = "Destroyed",
OPTIONS_AUDIT_FILTER_DESTROYED_DESC = "Include all items which were destroyed",
OPTIONS_AUDIT_FILTER_EPIC = "Epic Items",
OPTIONS_AUDIT_FILTER_EPIC_DESC = "Include Epic quality items",
OPTIONS_AUDIT_FILTER_RARE = "Rare Items",
OPTIONS_AUDIT_FILTER_RARE_DESC = "Include Rare quality items",
OPTIONS_AUDIT_FILTER_UNCOMMON = "Uncommon Items",
OPTIONS_AUDIT_FILTER_UNCOMMON_DESC = "Include Uncommon quality items",
OPTIONS_AUDIT_FILTER_LEGENDARY = "Legendary or Better",
OPTIONS_AUDIT_FILTER_LEGENDARY_DESC = "Include Legendary quality or better items",
OPTIONS_AUDIT_FILTER_COMMON = "Common or Less",
OPTIONS_AUDIT_FILTER_COMMON_DESC = "Include Common quality or worse items.",
OPTIONS_AUDIT_FILTER_EXTENSION = "Extension Rule",
OPTIONS_AUDIT_FILTER_EXTENSION_DESC = "Include items sold or destroyed from a Vendor extension rule.",
OPTIONS_AUDIT_FILTER_ALL = "All",
OPTIONS_VENDOR_AUDIT = "Vendor Audit:",
OPTIONS_AUDIT_TT_PROFILE = "Profile:",
OPTIONS_AUDIT_TT_RULE = "Rule:",
OPTIONS_AUDIT_TT_SOLD = "Sold:",
OPTIONS_AUDIT_TT_DESTROYED = "Destroyed:",

RULES_DIALOG_CONFIG_TAB = "Settings",
SETTINGS_CATEGORY_LABEL = "Category",

-- Setting categories and descriptions.
OPTIONS_CATEGORY_GENERAL = "General",
OPTIONS_CATEGORY_QUICK = "Common",
OPTIONS_DESC_GENERAL = "These are the quick high-level set of common settings to govern overall Vendor behavior. Use the drop-down menu for more refined setting adjustment.",
OPTIONS_CATEGORY_SELLING = "Selling",
OPTIONS_DESC_SELLING = "Controls what Vendor does when you are selling at a merchant. ",
OPTIONS_CATEGORY_REPAIR = "Repairing",
OPTIONS_DESC_REPAIR = "Whether to auto-repair, and how to pay for it.\n",
OPTIONS_CATEGORY_TOOLTIP = "Tooltips",
OPTIONS_DESC_TOOLTIP = "Tooltip settings when mousing over your items.",
OPTIONS_CATEGORY_DEBUG = "Debug",
OPTIONS_DESC_DEBUG = "Debug settings.",
OPTIONS_CATEGORY_ADVANCED = "Advanced",
OPTIONS_DESC_ADVANCED = "Advanced settings. Changing these is not recommended unless you have a problem.",
OPTIONS_CATEGORY_PERFORMANCE = "Performance",
OPTIONS_DESC_PERFORMANCE = "Vendor makes use of throttling and coroutines to avoid unresponsiveness in the interface and client disconnects. These settings control that behavior.\n\n",

-- Individual settings
OPTIONS_SETTINGNAME_AUTOSELL = "Auto-Sell",
OPTIONS_SETTINGDESC_AUTOSELL = "Automatically sell items when interacting with a merchant. If this is disabled you can still manually sell by setting a hotkey or by adding a button.",
OPTIONS_SETTINGNAME_BUYBACK = "Limit number sold to 12",
OPTIONS_SETTINGDESC_BUYBACK = "Limits the number of items sold each time an autosell is triggered to 12, which is the buyback limit. This allows you to always buy back any items that were sold. It is recommended to disable this setting once you are comfortable with Vendor rules and lists and trust that it is doing what you want.",
OPTIONS_SETTINGNAME_CONFIG = "Open Rule Config",
OPTIONS_SETTINGDESC_CONFIG = "Shows the Rule Configuration Dialog, allowing you to toggle rules and create your own rules.",
OPTIONS_SETTINGNAME_TOOLTIP = "Enable ToolTip",
OPTIONS_SETTINGDESC_TOOLTIP = "Vendor will add a line to the tooltip indicating when the item will be sold. ",
OPTIONS_SETTINGNAME_EXTRARULEINFO = "Extra rule information",
OPTIONS_SETTINGDESC_EXTRARULEINFO = "Include information about the rule that causes the item to be sold or kept. An item may match multiple rules; this will only display the first one that matches.",
OPTIONS_SETTINGNAME_MAXITEMS = "Limit number of items to sell",
OPTIONS_SETTINGDESC_MAXITEMS = "Controls the maximum number items vendor will auto-sell at each visit. If you want to be able to buy-back all items sold, set this to 12.",
OPTIONS_SETTINGNAME_AUTOREPAIR = "Auto-Repair",
OPTIONS_SETTINGDESC_AUTOREPAIR = "Automatically repair when visiting a repair-capable vendor.",
OPTIONS_SETTINGNAME_GUILDREPAIR = "Use Guild Bank",
OPTIONS_SETTINGDESC_GUILDREPAIR = "Uses guild bank for repairs if possible.",
OPTIONS_SETTINGNAME_SELL_THROTTLE = "Items Vendored Per Cycle",
OPTIONS_SETTINGDESC_SELL_THROTTLE = "This is the number of items vendored per sell cycle. Increase this if you want to sell items more in bulk, but lower this to lower the risk Blizzard will throttle you.",
OPTIONS_SETTINGNAME_CYCLE_RATE = "Cycle Rate",
OPTIONS_SETTINGDESC_CYCLE_RATE = "Interval in seconds between attempts to sell the throttled number of items specified above. Lower is faster. Increase this to slow down sell rate if you notice throttling from Blizzard.",
OPTIONS_SETTINGNAME_MINIMAP = "Show Minimap Button",
OPTIONS_SETTINGDESC_MINIMAP = "Vendor will show a minimap button for quickly accessing rules and profiles, and mousing over it shows a summary of matching items.\n\nThis is an account-wide setting.",
OPTIONS_SETTINGNAME_SELLBUTTON = "Show Auto-Sell Button on Merchant Window",
OPTIONS_SETTINGDESC_SELLBUTTON = "Add an 'Auto-Sell' button to the merchant's sell window to run the Vendor Auto-sell.",

QUICK_SELL_SETTING = "Auto-Sell items at merchant",
QUICK_SELL_SETTING_HELP = "Automatically sell items when interacting with a merchant. If this is disabled you can still manually trigger an autosell by setting a hotkey.\n\nThis also enables the 12-item limit on selling, which is the buyback limit for safety.",
QUICK_REPAIR_SETTING = "Auto-Repair at repair merchants",
QUICK_REPAIR_SETTING_HELP = "Automatically repair when visiting a repair-capable vendor.\n\nThis also enables using guild repair when available.",
QUICK_MINIMAP_SETTING = "Show Minimap Button",
QUICK_MINIMAP_SETTING_HELP = "Enable the Vendor Minimap button on the minimap. On mouseover the button displays items that will be sold/destroyed. Left click brings up the rules configuration page, while right-click brings up profiles.\n\nThis is an account-wide setting.",

-- Profiles Page
OPTIONS_PROFILE_TITLE = "Profiles",
OPTIONS_PROFILE_HELPTEXT = "All rules settings, addon settings, and Sell / Keep / Destroy list contents are stored per-profile. "..
    "Profiles are stored globally across all servers and characters, and selected per-character.",
OPTIONS_PROFILE_COPY = "Copy",
OPTIONS_PROFILE_CREATE = "New",
OPTIONS_PROFILE_RENAME = "Rename",
OPTIONS_PROFILE_SET = "Set",
OPTIONS_PROFILE_NAME_PLACEHOLDER = "type the name of the profile to create or copy here",
OPTIONS_PROFILE_CREATETEXT = "You can create a new profile from scratch (starts with the vendor defaults) or you can copy an existing profile in the list. A blank name defaults to 'PlayerName - Realm'",
OPTIONS_CONFIRM_PROFILE_DELETE_CAPTION = "Delete Profile",
OPTIONS_CONFIRM_PROFILE_DELETE_CONFIRM = "Confirm",
OPTIONS_CONFIRM_PROFILE_DELETE_FMT1 = [[
# Delete Profile

Are you sure you want to delete profile '%s'?"
]],
OPTIONS_PROFILE_DUPLICATE_NAME_CAPTION = "Duplicate Name",
OPTIONS_PROFILE_DUPLICATE_NAME_FMT1 = [[
# Duplicate Profile Name

A profile already exists with the name '%s' please choose another.
]],
OPTIONS_PROFILE_CREATE_LABEL = "Create Profile",
OPTIONS_PROFILE_DEFAULT_COPY_NAME = "%s (Copy)",

OPTIONS_RULES_SHOW_HIDDEN = "Show Hidden",
OPTIONS_RULES_ONE_HIDDEN = " (1 rule)",
OPTIONS_RULES_N_HIDDEN = " (%s rules)",

SETTINGS_HIDDENRULES_HELP = "[revisit] The list below contains the list of hidden rules, you can select on an unhide the rule to restore it.",
SETTINGS_HIDDENRULES_EMPTY = "[revisit] There are currently no hidden rules",
SETTINGS_HIDDENRULES_UNHIDE = "Unhide Rule",

RULE_TOOLTIP_SOURCE = "Source: %s",
RULE_TOOLTIP_HIDDEN = "This rule is currently hidden from the view",
RULE_TOOLTIP_CUSTOM_RULE = "Custom Rule",
RULE_TOOLTIP_SYSTEM_RULE = "Built-In",
RULE_LIST_EMPTY = "There are no rules for this category. Create one!",

RULE_CMENU_ENABLE = "Enable",
RULE_CMENU_DISABLE = "Disable",
RULE_CMENU_HIDE = "Hide",
RULE_CMENU_SHOW = "Show",
RULE_CMENU_VIEW = "View",
RULE_CMENU_EDIT = "Edit",
RULE_CMENU_DELETE = "Delete",
RULE_CMENU_CLOSE = "Close",

-- Console Commands
CMD_HELP_HEADER = "Command Reference: ",
CMD_HELP_HELP = "Show this command list reference.",

CMD_SETTINGS_HELP = "Open the settings in the interface options.",
CMD_RULES_HELP = "Open the Sell/Keep Rules configuration panel.",
CMD_KEYS_HELP = "Open keybindings. Working with blocklists is much easier with keybinds!",
CMD_WITHDRAW_HELP = "Withdraws any items from you bank which vendor would sell, requires your bank to be open",
CMD_API_HELP = "Prints the public API for Vendor",

CMD_LISTTOGGLE_HELP = "Adds or removes items from a list: list {sell||keep||destroy} [itemid]",
CMD_LISTTOGGLE_INVALIDARG = "Must specify which list to which you want to query or edit an item: {sell||keep||destroy} [item]",
CMD_LISTTOGGLE_ADDED = "Item: %s added to the %s list.",
CMD_LISTTOGGLE_REMOVED = "Item: %s removed from the %s list.",

CMD_LISTDATA_INVALIDARG = "Invalid option: %s  Valid lists: [sell||keep||destroy]",
CMD_LISTDATA_EMPTY = "The %s list is empty.",
CMD_LISTDATA_LISTHEADER = "Items in the %s list:",
CMD_LISTDATA_LISTITEM = "  %s - %s",
CMD_LISTDATA_NOTINCACHE = "[Item not seen yet, re-run to see it]",
CMD_LISTTOGGLE_UNSELLABLE = "%s is unsellable, therefore changing toggle to Destroy list instead.",

CMD_AUTOSELL_MERCHANTNOTOPEN = "Merchant window is not open. You must be at a merchant to auto-sell.",
CMD_AUTOSELL_INPROGRESS = "Already auto-selling. Please wait for completion before re-running.",
CMD_AUTOSELL_EXECUTING = "Running auto-sell.",

CMD_CLEAR_ALL_HISTORY = "Clearing all history.",
CMD_CLEAR_CHAR_HISTORY = "Clearing history for %s",
CMD_PRINT_HISTORY_HEADER = "History for %s",
CMD_PRINT_HISTORY_SUMMARY = "History for %s contains %s entries totalling %s",
CMD_PRINT_HISTORY_SUMMARY_ALL = "Entire history contains %s entries worth a total %s",
CMD_PRUNE_CHAR_HISTORY = "Pruning %s history of entries over %s hours.",
CMD_PRUNE_ALL_HISTORY = "Pruning all character histories of entries over %s hours.",
CMD_PRUNE_HISTORY_ARG = "Invalid argument to history pruning, please specify number of hours to prune.",
CMD_PRUNE_SUMMARY = "Removed %s entries from the history.",
CMD_HISTORY_HELP = "View, clear, or prune history. Usage: history [clear||prune hours] [all]",

CMD_RUNDESTROY = "Destroying all items matching Destroy rules or in the Destory list.",
CMD_DESTROY_HELP = "Destroys all items matching Destroy rules or in the Destroy list.",

-- API
API_REGISTEREXTENSION_TITLE = "Register Extension",
API_REGISTEREXTENSION_DOCS = "Registers a Vendor extension with Vendor. See CurseForge documentation for details.",
API_EVALUATEITEM_TITLE = "Evaluate Item",
API_EVALUATEITEM_DOCS = "Evaluates an item for selling. Input is a Bag and Slot.",
API_ADDTOALWAYSSELL_TITLE = "Add Tooltip Item To Always Sell List",
API_ADDTOALWAYSSELL_DOCS = "Toggles the item that has a tooltip showing on or off the Always Sell list.",
API_ADDTONEVERSELL_TITLE = "Add Tooltip Item To Never Sell List",
API_ADDTONEVERSELL_DOCS = "Toggles the item that has a tooltip showing on or off the Never Sell list.",
API_AUTOSELL_TITLE = "Run Autosell",
API_AUTOSELL_DOCS = "Runs the autosell routine if at a merchant.",
API_OPENSETTINGS_TITLE = "Open Settings",
API_OPENSETTINGS_DOCS = "Opens the Vendor Settings page.",
API_OPENKEYBINDINGS_TITLE = "Open Keybindings",
API_OPENKEYBINDINGS_DOCS = "Opens the Vendor Keybindings page.",
API_OPENRULES_TITLE = "Open Rules",
API_OPENRULES_DOCS = "Opens the Vendor interface to the Rules tab.",
API_OPENPROFILES_TITLE = "Open Profiles",
API_OPENPROFILES_DOCS = "Opens the Vendor interface to the Profiles tab.",
API_GETEVALUATIONSTATUS_TITLE = "Get Evaluation Status",
API_GETEVALUATIONSTATUS_DOCS = "Returns current number of slots Vendor will take action, sell, delete, and their value.",
API_GETPRICESTRING_TITLE = "Get Price String",
API_GETPRICESTRING_DOCS = "Converts passed in integer to a color coded and icon embedded price string.",
API_SETPROFILE_TITLE = "Set Profile",
API_SETPROFILE_DOCS = "Sets the currently selected profile to the specified profile.",
API_GETPROFILES_TITLE = "Get Profiles",
API_GETPROFILES_DOCS = "Gets the available list of profiles which can be set.",
API_DESTROYITEMS_TITLE = "Destroy Items",
API_DESTROYITEMS_DOCS = "Runs the item destroyer, which will destroy all items matching Destroy rules or the Destroy list.",

-- Rules
RULEUI_LABEL_ITEMLEVEL = "Item Level:",
RULEUI_SELL_EPIC_INFO = "Any " ..ITEM_QUALITY_COLORS[4].hex .. "Epic|r gear below this item level will be sold",
RULEUI_SELL_RARE_INFO = "Any " ..ITEM_QUALITY_COLORS[3].hex .. "Rare|r gear below this item level will be sold",
RULEUI_SELL_UNCOMMON_INFO = "Any " ..ITEM_QUALITY_COLORS[2].hex .. "Uncommon|r gear below this item level will be sold",
RULEUI_KEEP_EPIC_INFO = "Any " ..ITEM_QUALITY_COLORS[4].hex .. "Epic|r gear at or above this item level will be kept",
RULEUI_KEEP_RARE_INFO = "Any " ..ITEM_QUALITY_COLORS[3].hex .. "Rare|r gear at or above this item level will be kept",
RULEUI_KEEP_UNCOMMON_INFO = "Any " ..ITEM_QUALITY_COLORS[2].hex .. "Uncommon|r gear at or above this item level will be kept",

CONFIG_DIALOG_CAPTION = "Vendor",
CONFIG_DIALOG_KEEPRULES_TAB = "Keep Rules",
CONFIG_DIALOG_RULES_TAB = "Rules",
CONFIG_DIALOG_CONFIRM_DELETE_FMT1 = "Deleting '%s' will make it unavailable to all of your characters you sure you want to delete this rule?",
CONFIG_DIALOG_SHARE_TOOLTIP = "Share",
CONFIG_DIALOG_MOVEUP_TOOLTIP = "Click to move the rule sooner in evaluation order",
CONFIG_DIALOG_MOVEDOWN_TOOLTIP = "Click to move the rule later in the evaluation order",
CONFIG_DIALOG_LISTS_TAB = "Lists",
CONFIG_DIALOG_AUDIT_TAB = "Audit",
CONFIG_DIALOG_LISTS_TEXT = "Items in the associated lists will always be Kept, Sold, or Destroyed.|n"..
    "Drag items onto the list area to add it to that list.|n"..
    "You can drag an item from one list to another.",
ALWAYS_SELL_LIST_NAME = "Sell",
ALWAYS_SELL_LIST_TOOLTIP = "Items that will always be sold whenever you visit a merchant.",
NEVER_SELL_LIST_NAME = "Keep",
NEVER_SELL_LIST_TOOLTIP = "Items that will always be kept and never sold or destroyed.",
ALWAYS_DESTROY_LIST_NAME = "Destroy",
ALWAYS_DESTROY_LIST_TOOLTIP = "Items that will be destroyed whenever the Destroy is run, provided they are not also matching a Sell or Keep rule.",
RULES_DIALOG_HELP_TAB = "Help",
RULES_DIALOG_EMPTY_LIST = "There are no items in this list. Drag an item onto this area to add it to this list.",
CONFIG_DIALOG_CREATE_LIST = "Create",

RULES_DIALOG_RULES_TAB = "Rules",
RULES_TAB_HELPTEXT = "Rules are processed in the following order: Keep -> Sell -> Destroy|n"..
    "The first match found stops further evaluation.|n"..
    "Items in Keep/Sell/Destroy lists supercede rules.",

-- Sell Rules
SYSRULE_SELL_ALWAYSSELL = "Items in Sell list",
SYSRULE_SELL_ALWAYSSELL_DESC = "Items that are in the Always Sell list are always sold. You can view the full list with '/vendor list always'",
SYSRULE_SELL_POORITEMS = "Poor Items",
SYSRULE_SELL_POORITEMS_DESC = "Matches all "..ITEM_QUALITY_COLORS[0].hex.."Poor"..FONT_COLOR_CODE_CLOSE.." quality items which are the majority of the junk you will pick up.",
SYSRULE_SELL_UNCOMMONGEAR = "Uncommon Gear",
SYSRULE_SELL_UNCOMMONGEAR_DESC = "Matches Any "..ITEM_QUALITY_COLORS[2].hex.."Uncommon"..FONT_COLOR_CODE_CLOSE.." equipment with an item level less than the specified item level.",
SYSRULE_SELL_RAREGEAR = "Rare Gear",
SYSRULE_SELL_RAREGEAR_DESC = "Matches Any "..ITEM_QUALITY_COLORS[3].hex.."Rare"..FONT_COLOR_CODE_CLOSE.." equipment with an item level less than the specified item level.",
SYSRULE_SELL_EPICGEAR = "Epic Gear",
SYSRULE_SELL_EPICGEAR_DESC = "Matches Soulbound "..ITEM_QUALITY_COLORS[4].hex.."Epic"..FONT_COLOR_CODE_CLOSE.." equipment with an item level less than the specified item level. We assume you will want to sell BoE Epics on the auction house so BoEs are excluded.",
SYSRULE_SELL_KNOWNTOYS = "Known Toys",
SYSRULE_SELL_KNOWNTOYS_DESC = "Matches any already-known toys that are Soulbound.",
SYSRULE_DESTROY_KNOWNTOYS = "Known Toys (Unsellable)",
SYSRULE_DESTROY_KNOWNTOYS_DESC = "Matches any already-known toys that are Soulbound which have no value",
SYSRULE_SELL_OLDFOOD = "Low-Level Food",
SYSRULE_SELL_OLDFOOD_DESC = "Matches Food and Drink that is 10 or more levels below you. This will cover food from previous expansions and old food while leveling.",

-- Keep Rules
SYSRULE_KEEP_NEVERSELL = "Items in Keep list",
SYSRULE_KEEP_NEVERSELL_DESC = "Items that are in the Never Sell list are never sold. You can view the full list with '/vendor list never'",
SYSRULE_KEEP_SOULBOUNDGEAR = "Soulbound Gear",
SYSRULE_KEEP_SOULBOUNDGEAR_DESC = "Keeps any equipment item that is "..ITEM_QUALITY_COLORS[1].hex.."Soulbound"..FONT_COLOR_CODE_CLOSE.." to you even items your class cannot wear. A good safeguard if you are unsure about some rules.",
SYSRULE_KEEP_BINDONEQUIPGEAR = "Bind-on-Equip Gear",
SYSRULE_KEEP_BINDONEQUIPGEAR_DESC = "Keeps any equipment item that is "..ITEM_QUALITY_COLORS[1].hex.."Binds when equipped"..FONT_COLOR_CODE_CLOSE..".",
SYSRULE_KEEP_COMMON = "Common Items",
SYSRULE_KEEP_COMMON_DESC = "Matches any "..ITEM_QUALITY_COLORS[1].hex.."Common"..FONT_COLOR_CODE_CLOSE.." quality item. These are typically valuable consumables or crafting materials.",
SYSRULE_KEEP_UNKNOWNAPPEARANCE = "Uncollected Appearances",
SYSRULE_KEEP_UNKNOWNAPPEARANCE_DESC = "Matches any gear that is an Uncollected Appearance so you don't have to worry about missing a transmog.",
SYSRULE_KEEP_COSMETIC = "Cosmetic Gear",
SYSRULE_KEEP_COSMETIC_DESC = "Any gear which is considered cosmetic, for example: |cff1eff00|Hitem:21525:::::::2010962816:110:66::::::|h[Green Winter Hat]|h|r",
SYSRULE_KEEP_LEGENDARYANDUP = "Legendary or Better Items",
SYSRULE_KEEP_LEGENDARYANDUP_DESC = "Always keeps any items of "..ITEM_QUALITY_COLORS[5].hex.."Legendary"..FONT_COLOR_CODE_CLOSE.." quality or higher. This includes "..ITEM_QUALITY_COLORS[5].hex.."Legendaries"..FONT_COLOR_CODE_CLOSE..", "..ITEM_QUALITY_COLORS[6].hex.."Artifacts"..FONT_COLOR_CODE_CLOSE..", "..ITEM_QUALITY_COLORS[7].hex.."Heirlooms"..FONT_COLOR_CODE_CLOSE..", and "..ITEM_QUALITY_COLORS[8].hex.."Blizzard"..FONT_COLOR_CODE_CLOSE.." items (WoW Tokens).",
SYSRULE_KEEP_UNCOMMONGEAR = "Uncommon Gear|r",
SYSRULE_KEEP_UNCOMMONGEAR_DESC = "Matches any "..ITEM_QUALITY_COLORS[2].hex.."Uncommon"..FONT_COLOR_CODE_CLOSE.." quality equipment at or above the specified item level. Does not include non-equipment of Uncommon quality.",
SYSRULE_KEEP_RAREGEAR = "Rare Gear",
SYSRULE_KEEP_RAREGEAR_DESC = "Matches any "..ITEM_QUALITY_COLORS[3].hex.."Rare"..FONT_COLOR_CODE_CLOSE.." quality equipment at or above the specified item level. Does not include non-equipment of Rare quality.",
SYSRULE_KEEP_EPICGEAR = "Epic Gear",
SYSRULE_KEEP_EPICGEAR_DESC = "Matches any "..ITEM_QUALITY_COLORS[4].hex.."Epic"..FONT_COLOR_CODE_CLOSE.." quality equipment at or above the specified item level. Does not include non-equipment of Epic quality.",
SYSRULE_KEEP_EQUIPMENTSET = "Equipment Sets",
SYSRULE_KEEP_EQUIPMENTSET_DESC = "Matches any item that is a member of an equipment set created by the built-in "..ITEM_QUALITY_COLORS[8].hex.."Blizzard"..FONT_COLOR_CODE_CLOSE.." equipment manager",
SYSRULE_KEEP_POTENTIALUPGRADES = "Potential Upgrades",
SYSRULE_KEEP_POTENTIALUPGRADES_DESC = "Matches any gear that is within 5 item levels or 95% of your average item level (whichever is lower). This safeguards potential upgrades, side-grades, or gear for other specs.",

-- Destroy Rules
SYSRULE_DESTROYLIST = "Items in Destroy list",

-- Tooltip Scan Overrides - Note for folks of non-English languages. If these scans don't work properly, create a new locale and override them. They have been confirmed to be correct in several languages, so probably dont need to be changed.
TOOLTIP_SCAN_UNKNOWNAPPEARANCE = _G["TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN"],
TOOLTIP_SCAN_ARTIFACTPOWER = _G["ARTIFACT_POWER"],
TOOLTIP_SCAN_TOY = _G["TOY"],
TOOLTIP_SCAN_ALREADYKNOWN = _G["ITEM_SPELL_KNOWN"],
TOOLTIP_SCAN_CRAFTINGREAGENT = _G["PROFESSIONS_USED_IN_COOKING"],
TOOLTIP_SCAN_BLIZZARDACCOUNTBOUND = _G["ITEM_BNETACCOUNTBOUND"],
TOOLTIP_SCAN_COSMETIC = _G["ITEM_COSMETIC"],

-- Data Migration
DATA_MIGRATION_SL_NOTICE = YELLOW_FONT_COLOR_CODE.. "Detected migration to Shadowlands! The settings for Vendor have been reset and custom rules require verification before they will be active!" ..FONT_COLOR_CODE_CLOSE,
DATA_MIGRATION_ERROR = YELLOW_FONT_COLOR_CODE.. "Data migration error. Migration was detected, but no action taken. Please notify the addon authors here: https://www.curseforge.com/wow/addons/vendor/issues" ..FONT_COLOR_CODE_CLOSE,

-- Edit Rule Dialog
EDITRULE_CAPTION = "Edit Rule",
CREATERULE_CAPTION = "Create Rule",
VIEWRULE_CAPTION = "View Rule",
CREATE_BUTTON = "Create",
EDITRULE_DEFAULT_NAME = "New Rule",
EDITRULE_DEFAULT_COPY_NAME_FMT1 = "%s (Copy)",
EDITRULE_NAME_LABEL = "Name:",
EDITRULE_TYPE_LABEL = "Type:",
EDITFULE_PARAMETERS_LABEL = "Parameters",
EDITRULE_ADDPARAM_LABEL = "Add",
EDITRULE_DELPARAM_LABEL = "Remove",
EDITRULE_EDITPARAM_LABEL = "Edit",
EDITRULE_VIEWPARAM_LABEL = "View",
EDITRULE_NOPARAMS_TEXT = "This rule currently has no parameters",
EDITRULE_NAME_HELPTEXT = "type the name of your rule here",
EDITRULE_FILTER_LABEL = "Filter:",
EDITRULE_FILTER_HELPTEXT = "click here to filter the help",
EDITRULE_DESCR_LABEL = "Description:",
EDITRULE_DESCR_HELPTEXT = "type the description of your rule here",
EDITRULE_SCRIPT_LABEL = "Script:",
EDITRULE_SCRIPT_HELPTEXT = "enter the script for your rule here, see 'Help' for a list of available functions along with relational operators: and, or, >, >=, <, <=, ==, ~=",
EDITRULE_HELP_TAB_NAME = "Help",
EDITRULE_MATCHES_TAB_NAME = "Matches",
EDITRULE_MATCHES_TAB_TEXT = "Below you can see all of the items currently in your inventory which would be matched by this rule.",
EDITRULE_ITEMINFO_TAB_NAME = "Item Info",
EDITRULE_ITEMINFO_TAB_TEXT = "<Place Itemlink Here>",
EDITRULE_ITEM_PROPERTIES_EMPTY = "Drag an item into this panel to view the properties of that item. Properties with quotes (\") around them are strings, and the quotes are required for matching.",
EDITRULE_SELLRULE_LABEL = "Sell Rule",
EDITRULE_SELLRULE_TEXT = "A sell rule determines if Vendor will sell the item when the rule evaluates to true.",
EDITRULE_KEEPRULE_LABEL = "Keep Rule",
EDITRULE_KEEPRULE_TEXT = "A keep rule determines if Vendor will keep the item when the rule evaluates to true.",
EDITRULE_DELETERULE_TEXT = "A destroy rule allows you to matches items which Vendor will destroy when the rule evaluates to true.",
EDITRULE_DELETERULE_LABEL = "Destroy Rule",

EDITRULE_UNHEALTHY_RULE = "Unhealthy Rule",
EDITRULE_ERROR_RULE = "Validation Error",
EDITRULE_OK_TEXT = "Rule Ok",
EDITRULE_RULEOK_TEXT = "Your rule passed validation; check the matches tab to be sure it does what you expect.",
EDITRULE_SCRIPT_ERROR = "The following error was found validating your rule:|n%s",
EDITRULE_NO_MATCHES = "This rule does not match anything in your inventory.",
EDITRULE_MATCHES_HEADER_FMT = "<h1>This rule matched %s items in your inventory</h1>",
EDITRULE_RULE_SOURCE_FMT = "Source: %s",
EDITRULE_MIGRATE_RULE_TITLE ="Verify Rule",
EDITRULE_MIGRATE_RULE_TEXT ="Rule requires review before it can be used. Please verify that it matches what you expect and save.",
EDITRULE_UNHEALTHY_TEXT = "The following error occured while trying to evaulate this rule:|n%s",
EDITRULE_EXTENSION_RULE = "Extension Rule",
EDITRULE_EXTENSION_RULE_TEXT = "This rule comes from '%s' extension and cannot be edited or deleted. ",
EDITRULE_SYSTEM_RULE = "Built-In Rule",
EDITRULE_SYSTEM_RULE_TEXT = "This rules is a built-in Vendor rule and cannot be edited or deleted.",

RDITPARAM_NAME_LABEL = "Name:",
EDITPARAM_KEY_LABEL = "Script Name:",
EDITPARAM_TYPE_LABEL = "Type:",
EDITPARAM_DEFAULT_LABEL = "Default Value:",
EDITPARAM_CURRENT_LABEL = "Current Value:",
EDITPARAM_BOOLEAN_LABEL = "Boolean",
EDITPARAM_BOOLEAN_HELP = "",
EDITPARAM_NUMBER_LABEL = "Number",
EDITPARAM_NUMBER_HELP = "",
EDITPARAM_STRING_LABEL = "String",
EDITPARAM_STRING_HELP = "",
EDITPARAM_CREATE_LABEL = "Create",
EDITPARAM_SAVE_LABEL = SAVE,
EDITPARAM_CANCEL_LABEL = CANCEL,
EDITPARAM_CLOSE_LABEL = "Close",
EDITPARAM_DEFAULT_NAME = "New Paraemter",
EDITPARAM_DEFAULT_SCRIPTNAME = "NEW_PARAM",

EDITRULE_ITEM_LABEL = "Item:",
EDITRULE_NO_ITEM = "<none>",

RULEHELP_NO_MATCHES = "There are no items which match the specified filter",
RULEHELP_SOURCE = "Source: %s",
RULEHELP_NOTES = "Notes:",
RULEHELP_MAP = "Possible Values:",
RULEHELP_EXAMPLES = "Examples:",

RULEITEM_UNHEALTHY_WARNING = "This rule has an invalid script and must be fixed before it will work.",
RULEITEM_MIGRATE_WARNING = "This rule was created before an expansion itemlevel squish. For safety this rule has been disabled until it is reviewed by you. Right-click to open the context menu and select \"Edit\" to review.",
RULEITEM_SOURCE = HIGHLIGHT_FONT_COLOR_CODE .. "Source: |r",

EXPORT_HELP_TEXT = "[revisit] Copy the text below",
EXPORT_LIST_CAPTION = "Export List",
EXPORT_CLOSE_BUTTON = "Close",
IMPORTLIST_UNIQUE_NAME0 = "%s (Imported)",
IMPORTLIST_UNIQUE_NAME1 = "%s (Imported %d)",
IMPORTLIST_MARKDOWN_FMT = [[
# Import List

%s

> %s

You are importing a list from %s-%s which contains %d item%s are you sure you
want to continue?
]],

-- List Pane / Dialog
EDIT_LIST = "Edit",
NEW_LIST = "Create",
COPY_LIST = "Copy",
COPY_LIST_FMT1 = "%s (Copy)",
LISTOOLTIP_LISTTYPE = "Type:",
TOOLTIP_SYTEMLIST = "Built-In (profile specific)",
TOOLTIP_CUSTOMLIST = "Custom",
LISTDIALOG_CREATE_CAPTION = "New List",
LISTDIALOG_EDIT_CAPTION = "Edit List",
LISTDIALOG_NAME_LABEL = "Name:",
LISTDIALOG_DESCR_LABEL = "Description:",
LISTDIALOG_CONTENTS_LABEL = "Items:",
LISTDIALOG_NAME_HELPTEXT = "type the name of your list here",
LISTDIALOG_DESCR_HELPTEXT = "type the description of your list here",
LISTDIALOG_ADDBYID_LABEL = "Enter Item ID to add directly, or drag item into the list.",
LISTDIALOG_ADDBYID = "Add",
LISTDIALOG_SYSTEM_INFO = "This is a built-in list and saved in the current profile, you can add and remove items bit you cannot modify the name or description",
LISTDIALOG_ADDBYID_HELP = "Type the ID an item",
EDITLIST_DUPLICATE_NAME_CAPTION = "Name already exists",
EDITLIST_DUPLICATE_NAME_FMT1 = [[
# Duplicate List Name

A list already exists with the name '%s' please choose another.
]],
DELETE_LIST_CAPTION = "Delete List",
DELETE_LIST_FMT1 = [[
# Delete list %s?

Deleting this list will remove it from all of your characters, and may affect any rules configured to use 
the list. THIS ACTION CANNOT BE UNDONE!

Are you sure?
]],
CONFIRM_DELETE_LIST = "Yes, DELETE",
CANCEL_DELETE_LIST = "Cancel",

DELETE_RULE_CAPTION = "Delete Rule",
DELETE_RULE_FMT1 = [[
# Delete rule %s?

Deleting this rule will remove it from all of your characters. THIS ACTION CANNOT BE UNDONE!

Are you sure?
]],
CONFIRM_DELETE_RULE = "Yes, DELETE",
CANCEL_DELETE_RULE = "Cancel",
HIDE_RULE_CAPTION = "Hide Rule",
HIDE_RULE_FMT1 = [[
# Hide rule %s?

[revisit] If you hide this rule it will no longer show up in the rules list, and will not be used
to compute sell, keep, destroy

You can unhide the rule by going into the settings tab.

Are you sure?
]],
CONFIRM_HIDE_RULE = "Yes, HIDE",
CANCEL_HIDE_RULE = "Cancel",
DUPLICATE_RULE_NAME_CAPTION = "Existing Name",
DUPLICATE_RULE_FMT1 = [[
# Duplicate Rule Name

There is already a rule with the name '%s' plase select another 
and save the rule again.
]],
DUPLICATE_RULE_OK = "Close",

-- ItemLists
ITEMLIST_LOADING = "Loading...",
ITEMLIST_INVALID_ITEM = "Invalid Item",
ITEMLIST_INVALID_ITEM_TOOLTIP = "Blizzard has removed this item and it is no longer valid. Click to remove it from the list.",
ITEMLIST_LOADING_TOOLTIP = "The item information is currently being retrieved from the server",
ITEMLIST_EMPTY_SELL_LIST = "Your always sell list is current empty you can drag and drop items into this list to add them.",
ITEMLIST_EMPTY_KEEP_LIST = "Your never sell list is current empty you can drag and drop items into this list to add them.",
ITEMLIST_REMOVE_TOOLTIP = "Remove from list",
ITEMLIST_UNSELLABLE = "%s is unsellable, adding to Destroy list instead.",
ITEMLIST_EMPTY = "There are no items in this list yet. You can drag and drop items here to populate the list.",

-- LDB Object
LDB_BUTTON_BUTTON_LABEL = "Vendor: ",
LDB_BUTTON_MENU_TEXT = "Vendor",
LDB_BUTTON_TOOLTIP_TITLE = "Vendor",
LDB_BUTTON_TOOLTIP_TOSELL = "To Sell",
LDB_BUTTON_TOOLTIP_TODESTROY = "To Destroy",
LDB_BUTTON_TOOLTIP_VALUE = "Value",
LDB_BUTTON_MENU_NEW_RULE = "New Rule",
LDB_BUTTON_MENU_SETTINGS = "Settings",
LDB_BUTTON_MENU_KEYBINDINGS = "Keybindings",
LDB_BUTTON_MENU_SHOWVALUETEXT = "Show Value Text",
LDB_BUTTON_MENU_HIDE = "Hide",
LDB_BUTTON_MENU_CHANGE_PROFILES = "Set Profile",
LDB_BUTTON_MENU_PROFILES = "Profiles",
LDB_BUTTON_MENU_RUNDESTROY = "Run Destroy",


-- ITEM PROPERTIES HELP

HELP_NAME_TEXT = [[The item name, as it appears in the tooltip. This is a localized string.]],
HELP_LINK_TEXT = [[The item link, including all color codes and the item string. This may be useful if you want to string.find specific ids in the item string.]],
HELP_ID_TEXT =[[The item ID, as a number.]],
HELP_COUNT_TEXT = [[The quantity of the item, as a number.]],
HELP_COUNT_NOTES = "This will always be 1 for links to items. When we scan items in your bag it will be the actual quantity " ..
    "for the slot. This means if you make a rule that sells based on quantity then the tooltip for Vendor " ..
    "selling it will not be accurate when mousing over an item since that uses its tootip link, not " ..
    "the bag slot information. The matches tab uses items in your bag so it will be correct for what Vendor will sell.",
HELP_QUALITY_TEXT = [[The quality of the item:

0 = Poor 
1 = Common
2 = Uncommon
3 = Rare
4 = Epic
5 = Legendary
6 = Artifact
7 = Heirloom
8 = Wow Token

You can also use the following constants in your scripts: POOR, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, ARTIFACT, HEIRLOOM]],
HELP_LEVEL_TEXT = [[The item level (iLvl) of the item.]],
HELP_LEVEL_TEXT = "This will be the item's effective item level if it is Equipment, otherwise it will be the base item level if it does not have an effective item level.",
HELP_MINLEVEL_TEXT = [[The required character level for equipping the item.]],
HELP_TYPE_TEXT = [[The name of the item's Type. This is a localized string. You can use this in conjunction with SubType to zero in on specific types of items.]],
HELP_TYPEID_TEXT = [[The numeric ID of the item's Type.]],
HELP_TYPEID_NOTES ="This is not localized so it will be portable to players using other locales. " ..
    "It's also faster than a string compare, so you should use this over Type() if possible.",
HELP_SUBTYPE_TEXT = [[The name of the item's SubType. This is a localized string. You can use this in conjunction with Type to zero in on specific types of items.]],
HELP_SUBTYPEID_TEXT = [[The numeric ID of the item's SubType.]],
HELP_SUBTYPEID_NOTES  = "This is not localized so it will be portable to players using other locales. It's also faster than a string compare, so you should use this over SubType() if possible.",
HELP_EQUIPLOC_TEXT = [[The equip location of this item. This will be nil if the item is not equipment.]],
HELP_BINDTYPE_TEXT = [[The binding behavior for the item.

0 = None
1 = On Pickup
2 = On Equip
3 = On Use
4 = Quest]],
HELP_BINDTYPE_NOTES = "This is the base behavior of the item itself, not the current bind state of the item. This does NOT " ..
    "accurately tell you if the item is SoulBound or Bind-on-Equip by itself. " ..
    "If you want to know if an item is BoE or Soulbound, use IsBindOnEquip() and IsSoulbound()",
HELP_STACKSIZE_TEXT = [[The max stack size of this item.]],
HELP_UNITVALUE_TEXT = [[The vendor price in copper for one of these items.]],
HELP_UNITVALUE_NOTES = "Items with UnitValue == 0 cannot be sold to a vendor. Such items will never match any rules because you cannot possibly sell them.",
HELP_NETVALUE_TEXT = [[The vendor price in copper for this stack. This is equivalent to Count() * UnitValue()]],
HELP_EXPANSIONPACKID_TEXT = [[The expansion pack ID to which this item belongs.

0 = Default / None (this matches many items)
1 = BC
2 = WoTLK
3 = Cata
4 = MoP
5 = WoD
6 = Legion
7 = BFA
8 = SL]],
HELP_EXPANSIONPACKID_NOTES = "Use caution when using this to identify items of previous expansions. Not every item is tagged with an " ..
    "expansion ID. It appears that generally only wearable equipment is tagged. Zero is the default for " .. 
    "everything, including many items from Expansion packs (like reagants and Dalaran Hearthstones).|n|n" ..
    "We recommend that you only use this for rules involving wearable equipment. Checking ExpansionPackId() == 0 " ..
    "intending to match Vanilla will not do what you want, as it will include non-Vanilla things. Likewise, " ..
    "ExpansionPackId() < 7 will match a great many items. If you want to be safe, use this in conjunction with " ..
    "IsEquipment(), and have some items from Vanilla and several expansion packs to verify.",

HELP_ISAZERITEITEM_TEXT = [[True if the item is Azerite gear.]],
HELP_ISEQUIPMENT_TEXT = [[True if the item is wearable equipment. This is equivalent to EquipLoc() ~= nil]],
HELP_ISEQUIPMENT_NOTES = [[This does NOT tell you if your character can equip the item. This tells you whether the item is equippable gear.]],
HELP_ISSOULBOUND_TEXT = [[True if this specific item is currently "Soulbound" to you.]],
HELP_ISSOULBOUND_NOTES = "If the item's bind type is Bind-on-pickup then this will always report true, even for items you have not " ..
    "yet picked up if you are mousing over them. This is because the item will be Soulbound if you were to pick it up, " ..
    "so we are accurately representing the resulting behavior of the item. If an item is Binds-when-equipped or on use, " ..
    "then IsSoulbound() will return false unless you actually have the item in your possession and we can",
HELP_ISBINDONEQUIP_TEXT = [[True if this specific item is currently "Binds-when-equipped".]],
HELP_ISBINDONEQUIP_NOTES = 
    "If the item's bind type is Bind-on-pickup then this will always report false, even for items you have not " ..
    "yet picked up if you are mousing over them. This is becuase the item cannot possibly be Binds-when-equipped. " ..
    "If the item has yet to be picked up and it has a bind type of On-Equip, then we will always report it as true. If it is in your possession and Soulbound to you, then this will return false.",
HELP_ISBINDONUSE_TEXT = [[True if this specific item is currently "Binds-when-used".]],
HELP_ISBINDONUSE_NOTES = [[If the item is not yet in your possession, then it will always return true if its bind type is On-Use. If it is in your possession and Soulbound to you then this will return false.]],
HELP_ISTOY_TEXT = "True if the item is a toy.",
HELP_ISCRAFTINGREAGENT_TEXT = "True if this specific item is a crafting reagent.",
HELP_ISCRAFTINGREAGENT_NOTES = [[This is determined by the tooltip text. Note that if you drag a crafting reagent to the item box in a custom rule definition to read its properties, that item may incorrectly report as "false" but it will evaluate correctly with this property.]],
HELP_ISALREADYKNOWN_TEXT = [[True if the item is "Already known", such as a Toy or Recipe you have already learned.]],
HELP_ISUSABLE_TEXT = [[True if the item can be used, such as if it has a "Use:" effect described in its tooltip."]],
HELP_ISUNSELLABLE_TEXT = [[True if the item has 0 value.]],
HELP_ISUNSELLABLE_NOTES = [[There are a few very rare exceptions where items may have value but are unsellable and so you may get an occasional false negative here. This appears to be an item data error on Blizzard's end.]],
HELP_ISBAGANDSLOT_TEXT = [[True if the item has a defined bag and slot.]],
HELP_BAG_TEXT = [[The bag ID of the item, or -1 if it is not in a bag and slot.]],
HELP_SLOT_TEXT = [[The slot ID of the item, or -1 if it is not in a bag and slot.]],
HELP_CRAFTEDQUALITY_TEXT = [[
The Dragonflight Profession Crafted Quality of an item or reagent.

   0 = No Quality
   1 = 1 gem (bronze)
   2 = 2 gems (silver)
   3 = 3 gems, etc
]],

-- FUNCTION HELP

HELP_ISEQUIPPED_TEXT = "True if the item is currently equipped. Will never be true for items in inventory.",

HELP_ISINEQUIPMENTSET_ARGS = "[setName0 .. setNameN]",
HELP_ISINEQUIPMENTSET_TEXT = [[
Checks if the item is a memmber of a Blizzard equipment set and returns true if found.
If no arguments are provied then all of the chracters equipment sets are check, otherwise
this checks only the specified sets.

## Examples

Any equpment set:

> IsInEquipmentSet()

In your "Tank" equipment set.

> IsInEquipmentSet("Tank")

### Notes

Equipment set matches by item ID, which means it can match different ilvl versions of the same item and all will be considered part of the equipment set. We use what Blizzard gives us.
]],

HELP_HASSTAT_TEXT = [[
Checks if the item has a specific 'stat' or Attribute. These are attributes of the items specifically and not any random text.

## Examples

> HasStat("Speed")
> HasStat("Mastery")
]],

HELP_TOOLTIPCONTAINS_TEXT = [[
Usage: TooltipContains(text [, side, line])

Checks if specified text is in the item's tooltip.

## Side & Line

Which side of the tooltip (left or right), and a specific line to check are optional.
If no line or side is specified, the entire tooltip will be checked.

## Examples

> TooltipContains("Rogue")
> TooltipContains("Fated Mythic")

Check left side of tooltip, line 1 for "Vanq"

> TooltipContains("Vanq", "left", 1)
]],

HELP_PLAYERLEVEL = [[
Returns the current level of the player. This is so you can make rules that only work while leveling or at max level.
]],

HELP_PLAYERCLASS = [[
Returns the English classname in all caps of the current player to make class-based rules.
Names will be fully capitalized english class name with no spaces, such as "MAGE", "DEATHKNIGHT", "DEMONHUNTER", etc

Example: PlayerClass() == "DEMONHUNTER"

]],

HELP_PLAYERITEMLEVEL = [[
Returns the average item level of the player as it appears in the character panel, rounded down to nearest integer.
]],

HELP_PLAYERCLASSID = [[
Returns the index of the current player's class to make class-based rules. Index
is a faster and shorter lookup than name. Class Indexes:

> 1 = Warrior
> 2 = Paladin
> 3 = Hunter
> 4 = Rogue
> 5 = Priest
> 6 = Death Knight
> 7 = Shaman
> 8 = Mage
> 9 = Warlock
>10 = Monk
>11 = Druid
>12 = Demon Hunter
>13 = Evoker

]],

HELP_PLAYERSPECIALIZATION = [[
Returns the localized name of the player's current specialization. Ex: "Balance" for a Balance druid.
]],

HELP_PLAYERSPECIALIZATIONID = [[
Returns the specialization ID of the player's current specialization.

Spec ID Reference:

> Death Knight: 250 = Blood, 251 = Frost, 252 = Unholy
> Demon Hunter: 577 = Havoc, 581 = Vengeance
> Druid: 102 = Balance, 103 = Feral, 104 = Guardian, 105 = Restoration
> Evoker: 1467 = Devastation, 1468 = Preservation
> Hunter: 253 = Beast Mastery, 254 = Marksmanship, 255 = Survival
> Mage: 62 = Arcane, 63 = Fire, 64 = Frost
> Monk: 268 = Brewmaster, 270 = Mistweaver, 269 = Windwalker
> Paladin: 65 = Holy, 66 = Protection, 70 = Retribution
> Priest: 256 = Discipline, 257 = Holy, 258 = Shadow
> Rogue: 259 = Assassination, 260 = Outlaw, 261 = Subtlety
> Shaman: 262 = Elemental, 263 = Enhancement, 264 = Restoration
> Warlock: 265 = Affliction, 266 = Demonology, 267 = Destruction
> Warrior: 71 = Arms, 72 = Fury, 73 = Protection

## Examples

True if the player is currently a Fury Warrior

> PlayerSpecializationId() == 72

]],

HELP_TOTALITEMCOUNT_TEXT = [[
Usage: TotalItemCount([includeBank, includeUses])

Returns the total number of the item the player has in their bags.
Parameters:
  includeBank - set to 'true' if you want to include bank and reagent bank.
  includeUses - set to 'true' if you want to count items with multiple uses multiple times.

"includeUses" is for items with multiple charges per item on them, like Healthstones.

## Examples

More than 100 of this item in bags

> TotalItemCount() > 100

More than 100 of this item in bags and bank

> TotalItemCount(true) > 500

More than 50 uses of this item in bags only

> TotalItemCount(false, true)

More than 50 uses of this item across all bags and bank

> TotalItemCount(true, true) > 50
]],


HELP_CURRENTEQUIPPEDLEVEL_TEXT = [[
Usage: CurrentEquippedLevel()

Returns the current item level of the equipped item in the same slot, or 0 if the item being evaluated is not an equippable item or doesn't have a meaningful equipment slot.
This rule is for determining how an item compares to your currently equipped item in the same slot. For example, it can tell you
if the item being evaluated is an item level upgrade over the current item you have equipped in that slot.

For equipment that can be in multiple slots (such as rings) the number returned is the lower item level among the two items equipped.

For dual wielding characters, one-handed weapons will check both weapons.

For Fury warriors, two-handed weapons will check both weapons (to factor in Titan Grip).

## Examples

True if the item is equal to or higher item level than your current equipped item in that slot.

> CurrentEquippedLevel() <= Level

True if the item is within 13 item levels of your currently equipped ger (within one tier)

> CurrentEquippedLevel() <= (Level + 13)

]],

}) -- END OF LOCALIZATION TABLE

-- Help strings for documentation of rules. These are separate due to the multi-line strings, which doesn't play nice with tables.


