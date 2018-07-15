-- enUS Localization
-- If the loading order of the files is incorrect, this will fail when trying to use AddonLocales.
-- Locales should be loaded AFTER Init and before anything that uses them.
-- So basically make sure they are all loaded together in the TOC right after Init (constants is OK too).
local AddonLocales = _G[select(1,...).."_LOC"]()
AddonLocales["enUS"] =
{
-- Core
["ADDON_NAME"] = "Vendor",

-- Bindings
["BINDING_HEADER_VENDORQUICKLIST"] = "Quick Add/Remove items from the sell lists when mousing over the item",
["BINDING_NAME_VENDORALWAYSSELL"] = "Toggle Always-Sell Item",
["BINDING_DESC_VENDORALWAYSSELL"] = "Adds the item currently in the game tooltip to the Always-sell list. Removes it if it is already in the list.",
["BINDING_NAME_VENDORNEVERSELL"] = "Toggle Never-Sell Item",
["BINDING_DESC_VENDORNEVERSELL"] = "Adds the item currently in the game tooltip to the Never-sell list. Removes it if it is already in the list.",

-- Merchant
["MERCHANT_REPAIR_FROM_GUILD_BANK"] = "Repaired all equipment from the guild bank for %s",
["MERCHANT_REPAIR_FROM_SELF"] = "Repaired all equipment for %s",
["MERCHANT_SELLING_ITEM"] = "Selling %s for %s",
["MERCHANT_SOLD_ITEMS"] = "Sold %s items for %s",

-- Tooltip
["TOOLTIP_ADDITEM_ERROR_NOITEM"] = "Failed to add item to %s-sell list. The game tooltip is not over an item.",
["TOOLTIP_ITEM_IN_ALWAYS_SELL_LIST"] = "Vendor: Always Sell",
["TOOLTIP_ITEM_IN_NEVER_SELL_LIST"] = "Vendor: Never Sell",
["TOOLTIP_ITEM_WILL_BE_SOLD"] = "Will be auto-sold by Vendor",

-- Options
["OPTIONS_TITLE_ADDON"] = "These settings are for configuring Vendor behavior.\n\n",
["OPTIONS_SHOW_BINDINGS"] = "Key Bindings",
["OPTIONS_OPEN_RULES"] = "Open Rules",


["OPTIONS_HEADER_REPAIR"] = "Repair",
["OPTIONS_DESC_REPAIR"] = "Whether to auto-repair, and how to pay for it.\n",
["OPTIONS_SETTINGNAME_AUTOREPAIR"] = "Auto-Repair",
["OPTIONS_SETTINGDESC_AUTOREPAIR"] = "Automatically repair when visiting a repair-capable vendor.",
["OPTIONS_SETTINGNAME_GUILDREPAIR"] = "Use Guild Bank for Repairs",
["OPTIONS_SETTINGDESC_GUILDREPAIR"] = "Uses guild bank for repairs if possible.",

-- Main Config Panel (aka Selling)
["OPTIONS_HEADER_SELLING"] = "General",
["OPTIONS_DESC_SELLING"] = "What to sell at a vendor automatically. Keep rules are always processed first, then Sell rules run on items that remain. By default we have several safeguard Keep rules enabled so you don't accidentally sell something you want. Before disabling any Keep rules, you should definitely take a look at the sell rules that are enabled first.\n",
["OPTIONS_SETTINGNAME_AUTOSELL"] = "Auto-Sell",
["OPTIONS_SETTINGDESC_AUTOSELL"] = "Automatically sell items per the sell and keep rules.",
["OPTIONS_SETTINGNAME_CONFIG"] = "Open Rule Config",
["OPTIONS_SETTINGDESC_CONFIG"] = "Shows the Rule Configuration Dialog, allowing you to toggle rules and create your own rules.",
["OPTIONS_SETTINGNAME_TOOLTIP"] = "Enable ToolTip",
["OPTIONS_SETTINGDESC_TOOLTIP"] = "Vendor will add a line to the tooltip indicating the item will be sold. In addition you can choose have the tooltip also include the rule which will cause the item to be sold or kept",
["OPTIONS_SETTINGNAME_RULE_ON_TOOLTIP"] = "Enable rule information",


-- Performance Settings tab
["OPTIONS_CATEGORY_PERFORMANCE"] = "Performance",
["OPTIONS_TITLE_PERFORMANCE"] = "Vendor makes use of throttling and coroutines to avoid unresponsiveness in the interface and client disconnects. These settings control that behavior.\n\n",

["OPTIONS_HEADER_THROTTLES"] = "Throttles",
["OPTIONS_DESC_THROTTLES"] = "These values all set how many actions are taken per throttle cycle.",
["OPTIONS_SETTINGNAME_SELL_THROTTLE"] = "Items Vendored Per Cycle",
["OPTIONS_SETTINGDESC_SELL_THROTTLE"] = "This is the number of items vendored per sell cycle. Increase this if you want to sell items more in bulk, but lower this to lower the risk Blizzard will throttle you.",

["OPTIONS_HEADER_FREQUENCY"] = "Frequency",
["OPTIONS_DESC_FREQUENCY"] = "Sets how frequently a throttled task executes per second. Changing this affects all throttles.",
["OPTIONS_SETTINGNAME_CYCLE_RATE"] = "Cycle Rate",
["OPTIONS_SETTINGDESC_CYCLE_RATE"] = "Interval in seconds between attempts to sell the throttled number of items specified above. Lower is faster. Increase this to slow down sell rate if you notice throttling from Blizzard.",

-- Console Commands
["CMD_HELP_HEADER"] = "Command Reference: ",
["CMD_HELP_HELP"] = "Show this command list reference.",

["CMD_SETTINGS_HELP"] = "Open the settings in the interface options.",
["CMD_RULES_HELP"] = "Open the Sell/Keep Rules configuration panel.",
["CMD_KEYS_HELP"] = "Open keybindings. Working with blocklists is much easier with keybinds!",

["CMD_SELLITEM_HELP"] = "Adds or removes items from the sell list: sell {always||never} [itemid]",
["CMD_SELLITEM_INVALIDARG"] = "Must specify which list to which you want to query or edit an item: {always||never} [item]",
["CMD_SELLITEM_ADDED"] = "Item: %s added to the %s-sell list.",
["CMD_SELLITEM_REMOVED"] = "Item: %s removed from the %s-sell list.",

["CMD_CLEARDATA_HELP"] = "Clears data for all lists, or the list if specified. Usage: clear [always||never]",
["CMD_CLEARDATA_INVALIDARG"] = "Invalid option: %s  Usage: clear [always||never]",
["CMD_CLEARDATA_ALWAYS"] = "The always-sell list has been cleared.",
["CMD_CLEARDATA_NEVER"] = "The never-sell list has been cleared.",

["CMD_LISTDATA_HELP"] = "Prints the items for all lists, or the list if specified. Usage: list [always||never]",
["CMD_LISTDATA_INVALIDARG"] = "Invalid option: %s  Usage: clear [always||never]",
["CMD_LISTDATA_EMPTY"] = "The %s-sell list is empty.",
["CMD_LISTDATA_LISTHEADER"] = "Items in the %s-sell list:",
["CMD_LISTDATA_LISTITEM"] = "  %s - %s",
["CMD_LISTDATA_NOTINCACHE"] = "[Item not seen yet, re-run to see it]",

-- Rules
["RULEMATCH_TOOLTIP"] = "Rule: %s",
["RULEUI_LABEL_ITEMLEVEL"] = "Level:",
["CONFIG_DIALOG_CAPTION"] = "Vendor Rules",
["CONFIG_DIALOG_KEEPRULES_TAB"] = "Keep Rules",
["CONFIG_DIALOG_KEEPRULES_TEXT"] = "These rules are safeguards to prevent selling things you don't ever want sold. All Keep Rules are checked before Sell Rules; However, anything you mark as 'Always Sell' will ignore Keep Rules.",
["CONFIG_DIALOG_SELLRULES_TAB"] = "Sell Rules",
["CONFIG_DIALOG_SELLRULES_TEXT"] = "These rules govern what will be auto-sold to the merchant. Anything you mark as 'Never Sell' will ignore Sell Rules and always be kept. Keep Rules are always processed before Sell Rules, so if the Sell Rule you enable doesn't seem to work, check the Keep Rules to see if something is preventing it.",
["CONFIG_DIALOG_CUSTOMRULES_TAB"] = "Custom Rules",
["CONFIG_DIALOG_CUSTOMRULES_TEXT"] = "Custom rules are not yet implemented but are coming Soon(TM)",

-- Sell Rules
["SYSRULE_SELL_ALWAYSSELL"] = "Items in Always Sell List",
["SYSRULE_SELL_ALWAYSSELL_DESC"] = "Items that are in the Always Sell list are always sold. You can view the full list with '/vendor list always'",
["SYSRULE_SELL_POORITEMS"] = "Poor Items",
["SYSRULE_SELL_POORITEMS_DESC"] = "Matches all "..ITEM_QUALITY_COLORS[0].hex.."Poor"..FONT_COLOR_CODE_CLOSE.." quality items which are the majority of the junk you will pick up.",
["SYSRULE_SELL_ARTIFACTPOWER"] = "Artifact Power (Legion)",
["SYSRULE_SELL_ARTIFACTPOWER_DESC"] =  "Matches any "..ITEM_QUALITY_COLORS[6].hex.."Artifact Power"..FONT_COLOR_CODE_CLOSE.." items from the Legion expansion if you are level 110+. We assume you have done the quest and no longer need it.",
["SYSRULE_SELL_UNCOMMONGEAR"] = "Uncommon Gear",
["SYSRULE_SELL_UNCOMMONGEAR_DESC"] = "Matches Any "..ITEM_QUALITY_COLORS[2].hex.."Uncommon"..FONT_COLOR_CODE_CLOSE.." equipment with an item level less than specified item level.",
["SYSRULE_SELL_RAREGEAR"] = "Rare Gear",
["SYSRULE_SELL_RAREGEAR_DESC"] = "Matches Any "..ITEM_QUALITY_COLORS[3].hex.."Rare"..FONT_COLOR_CODE_CLOSE.." equipment with an item level less than specified item level.",
["SYSRULE_SELL_EPICGEAR"] = "Epic Gear",
["SYSRULE_SELL_EPICGEAR_DESC"] = "Matches Soulbound "..ITEM_QUALITY_COLORS[4].hex.."Epic"..FONT_COLOR_CODE_CLOSE.." equipment with an item level less than specified item level. We assume you will want to sell BoE Epics on the auction house so BoEs are excluded.",
["SYSRULE_SELL_KNOWNTOYS"] = "Known Toys",
["SYSRULE_SELL_KNOWNTOYS_DESC"] = "Matches any already-known toys that are Soulbound. You can't sell them to the Auction House  and you can't learn them, so rehome them to the vendor.",
["SYSRULE_SELL_OLDFOOD"] = "Low-Level Food",
["SYSRULE_SELL_OLDFOOD_DESC"] = "Matches Food and Drink that is 10 or more levels below you. This will cover food from previous expansions and old food while leveling.",

-- Keep Rules
["SYSRULE_KEEP_NEVERSELL"] = "Items in Never Sell List",
["SYSRULE_KEEP_NEVERSELL_DESC"] = "Items that are in the Never Sell list are never sold. You can view the full list with '/vendor list never'",
["SYSRULE_KEEP_UNSELLABLE"] = "Unsellable Items",
["SYSRULE_KEEP_UNSELLABLE_DESC"] = "These items have no value and cannot be sold to a merchant. If you don't like it, take it up with Blizzard.",
["SYSRULE_KEEP_SOULBOUNDGEAR"] = "Soulbound Gear",
["SYSRULE_KEEP_SOULBOUNDGEAR_DESC"] = "Keeps any equipment item that is "..ITEM_QUALITY_COLORS[1].hex.."Soulbound"..FONT_COLOR_CODE_CLOSE.." to you even items your class cannot wear. This is a safeguard rule meant to protect you from accidentally vendoring your valuables. In order to fully take advantage of many of the Sell Rules, you will need to disable this rule but think carefully before you do.",
["SYSRULE_KEEP_COMMON"] = "Common Items",
["SYSRULE_KEEP_COMMON_DESC"] = "Matches any "..ITEM_QUALITY_COLORS[1].hex.."Common"..FONT_COLOR_CODE_CLOSE.." quality item. These are typically valuable consumables or crafting materials. This is a safeguard rule meant to protect you from vendoring your consumables and crafting materials.",
["SYSRULE_KEEP_UNKNOWNAPPEARANCE"] = "Uncollected Appearances",
["SYSRULE_KEEP_UNKNOWNAPPEARANCE_DESC"] = "Matches any gear that is an Uncollected Appearance so you don't have to worry about missing a transmog.",
["SYSRULE_KEEP_LEGENDARYANDUP"] = "Legendary or Better Items",
["SYSRULE_KEEP_LEGENDARYANDUP_DESC"] = "Always keeps any items of "..ITEM_QUALITY_COLORS[5].hex.."Legendary"..FONT_COLOR_CODE_CLOSE.." quality or higher. This includes "..ITEM_QUALITY_COLORS[5].hex.."Legendaries"..FONT_COLOR_CODE_CLOSE..", "..ITEM_QUALITY_COLORS[6].hex.."Artifacts"..FONT_COLOR_CODE_CLOSE..", "..ITEM_QUALITY_COLORS[7].hex.."Heirlooms"..FONT_COLOR_CODE_CLOSE..", and "..ITEM_QUALITY_COLORS[8].hex.."Blizzard"..FONT_COLOR_CODE_CLOSE.." items (WoW Tokens). This just a paranoid Safeguard Rule that we don't recommend disabling.",
["SYSRULE_KEEP_UNCOMMONGEAR"] = "Uncommon Gear|r",
["SYSRULE_KEEP_UNCOMMONGEAR_DESC"] = "Matches any "..ITEM_QUALITY_COLORS[2].hex.."Uncommon"..FONT_COLOR_CODE_CLOSE.." quality equipment. Does not include non-equipment of Uncommon quality.",
["SYSRULE_KEEP_RAREGEAR"] = "Rare Gear",
["SYSRULE_KEEP_RAREGEAR_DESC"] = "Matches any "..ITEM_QUALITY_COLORS[3].hex.."Rare"..FONT_COLOR_CODE_CLOSE.." quality equipment. Does not include non-equipment of Rare quality.",
["SYSRULE_KEEP_EPICGEAR"] = "Epic Gear",
["SYSRULE_KEEP_EPICGEAR_DESC"] = "Matches any "..ITEM_QUALITY_COLORS[4].hex.."Epic"..FONT_COLOR_CODE_CLOSE.." quality equipment. Does not include non-equipment of Epic quality.",

-- Data Migration
["DATA_MIGRATION_BFA_NOTICE"] = "Detected migration to BFA. We have reset Vendor rules settings to default to protect against unintended selling due to the item level squish. Sorry for the inconvenience!"

} -- END OF LOCALIZATION TABLE
