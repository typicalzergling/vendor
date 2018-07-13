-- enUS Localization

Vendor = Vendor or {}
Vendor.Locales = Vendor.Locales or {}
Vendor.Locales["enUS"] =
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
["OPTIONS_CATEGORY_PROFILES"] = "Profiles",


["OPTIONS_HEADER_REPAIR"] = "Repair",
["OPTIONS_DESC_REPAIR"] = "Whether to auto-repair, and how to pay for it.\n",
["OPTIONS_SETTINGNAME_AUTOREPAIR"] = "Auto-Repair",
["OPTIONS_SETTINGDESC_AUTOREPAIR"] = "Automatically repair when visiting a repair-capable vendor.",
["OPTIONS_SETTINGNAME_GUILDREPAIR"] = "Use Guild Bank for Repairs",
["OPTIONS_SETTINGDESC_GUILDREPAIR"] = "Uses guild bank for repairs if possible.",

["OPTIONS_HEADER_SELLING"] = "Selling",
["OPTIONS_DESC_SELLING"] = "What to sell at a vendor automatically. Keep rules are always processed first, then Sell rules run on items that remain. By default we have several safeguard Keep rules enabled so you don't accidentally sell something you want. Before disabling any Keep rules, you should definitely take a look at the sell rules that are enabled first.\n",
["OPTIONS_SETTINGNAME_AUTOSELL"] = "Auto-Sell",
["OPTIONS_SETTINGDESC_AUTOSELL"] = "Automatically sell items per the sell and keep rules.\n\nDisabling this will also hide Vendor tooltip lines.",
["OPTIONS_SETTINGNAME_CONFIG"] = "Open Rule Config",
["OPTIONS_SETTINGDESC_CONFIG"] = "Shows the Rule Configuration Dialog, allowing you to toggle rules and create your own rules.",

-- Performance Settings tab
["OPTIONS_CATEGORY_PERFORMANCE"] = "Performance",
["OPTIONS_TITLE_PERFORMANCE"] = "Vendor makes use of throttling and coroutines to avoid unresponsiveness in the interface and client disconnects. These settings control that behavior.\n\n",

["OPTIONS_HEADER_THROTTLES"] = "Throttles",
["OPTIONS_DESC_THROTTLES"] = "These values all set how many actions are taken per throttle cycle.",
["OPTIONS_SETTINGNAME_SELL_THROTTLE"] = "Items Vendored",
["OPTIONS_SETTINGDESC_SELL_THROTTLE"] = "Used when auto-selling items to a vendor. Lower this value if items are inconsistently auto-selling.\n\nRecommended value: 1 to 5",
["OPTIONS_SETTINGINVALID_SELL_THROTTLE"] = "Invalid throttle value; it must be an integer greater than 0.",

["OPTIONS_HEADER_FREQUENCY"] = "Frequency",
["OPTIONS_DESC_FREQUENCY"] = "Sets how frequently a throttled task executes per second. Changing this affects all throttles.",
["OPTIONS_SETTINGNAME_CYCLE_RATE"] = "Cycle Rate",
["OPTIONS_SETTINGDESC_CYCLE_RATE"] = "Interval in seconds between attempts to sell the throttled number of items.\n\nRecommended value: .5 to 2",
["OPTIONS_SETTINGINVALID_CYCLE_RATE"] = "Invalid cycle rate; it must be greater than .1",

-- Commands
["CMD_SETTINGS_NAME"] = "Open Settings",
["CMD_SETTINGS_DESC"] = "Open the settings panel for Vendor.",
["CMD_SELLITEM_NAME"] = "Set never sell or always sell items.",
["CMD_SELLITEM_DESC"] = "Adds or removes items from the sell list: sell {always||never} [itemid]",
["CMD_SELLITEM_INVALIDARG"] = "Must specify which list to which you want to query or edit an item: {always||never} [item]",
["CMD_SELLITEM_ADDED"] = "Item: %s added to the %s-sell list.",
["CMD_SELLITEM_REMOVED"] = "Item: %s removed from the %s-sell list.",

["CMD_CLEARDATA_NAME"] = "Clear never-sell and always-sell lists",
["CMD_CLEARDATA_DESC"] = "Clears data for all lists, or the list if specified. Usage: clear [always||never]",
["CMD_CLEARDATA_INVALIDARG"] = "Invalid option: %s  Usage: clear [always||never]",
["CMD_CLEARDATA_ALWAYS"] = "The always-sell list has been cleared.",
["CMD_CLEARDATA_NEVER"] = "The never-sell list has been cleared.",

["CMD_LISTDATA_NAME"] = "Print the never-sell and/or always-sell lists.",
["CMD_LISTDATA_DESC"] = "Prints the items for all lists, or the list if specified. Usage: list [always||never]",
["CMD_LISTDATA_INVALIDARG"] = "Invalid option: %s  Usage: clear [always||never]",
["CMD_LISTDATA_EMPTY"] = "The %s-sell list is empty.",
["CMD_LISTDATA_LISTHEADER"] = "Items in the %s-sell list:",
["CMD_LISTDATA_LISTITEM"] = "  %s - %s",
["CMD_LISTDATA_NOTINCACHE"] = "[Item not seen yet, re-run to see it]",

-- Rules
["RULEMATCH_TOOLTIP"] = "Vendor Rule: \"%s\"",
["RULEUI_LABEL_ITEMLEVEL"] = "Level:",
["CONFIG_DIALOG_CAPTION"] = "Vendor Setting",
["CONFIG_DIALOG_KEEPRULES_TAB"] = "Keep Rules",
["CONFIG_DIALOG_KEEPRULES_TEXT"] = "These are the built-in rules which Vendor uses to determine if hte item should be kept or sold",
["CONFIG_DIALOG_SELLRULES_TAB"] = "Sell Rules",
["CONFIG_DIALOG_SELLRULES_TEXT"] = "These are the built-in rules which Vendor using for selling your items",
["CONFIG_DIALOG_CUSTOMRULES_TAB"] = "Custom Rules",
["CONFIG_DIALOG_CUSTOMRULES_TEXT"] = "Custom rules are not yet implemented but are coming Soon(TM)",

-- System rules

-- Sell Rules
["SYSRULE_SELL_ALWAYSSELL"] = "Items in Always Sell List",
["SYSRULE_SELL_ALWAYSSELL_DESC"] = "Items that are in the Always Sell list are always sold. You can view the full list with '/vendor list always'",
["SYSRULE_SELL_POORITEMS"] = "Poor (Gray) Items",
["SYSRULE_SELL_POORITEMS_DESC"] = "Matches all gray quality items, which is the majority of the junk you will pick up.",
["SYSRULE_SELL_ARTIFACTPOWER"] = "Artifact Power (Legion)",
["SYSRULE_SELL_ARTIFACTPOWER_DESC"] =  "Matches any Artifact Power items from the Legion expansion if you are level 110+. We assume you have done the quest and no longer need it.",
["SYSRULE_SELL_UNCOMMONGEAR"] = "Uncommon (Green) Gear",
["SYSRULE_SELL_UNCOMMONGEAR_DESC"] = "Matches Any Uncommon equipment with an item level less than specified item level.",
["SYSRULE_SELL_RAREGEAR"] = "Rare (Blue) Gear",
["SYSRULE_SELL_RAREGEAR_DESC"] = "Matches Any Rare equipment with an item level less than specified item level.",
["SYSRULE_SELL_EPICGEAR"] = "Epic (Purple) Gear",
["SYSRULE_SELL_EPICGEAR_DESC"] = "Matches Soulbound Epic equipment with an item level less than specified item level. We assume you will want to sell BoE Epics on the auction house, so BoEs are excluded.",
["SYSRULE_SELL_KNOWNTOYS"] = "Already-Known Toys",
["SYSRULE_SELL_KNOWNTOYS_DESC"] = "Matches any already-known toys that are Soulbound. You can't AH them and you can't learn them, so help them home to the vendor.",
["SYSRULE_SELL_OLDFOOD"] = "Low-Level Food",
["SYSRULE_SELL_OLDFOOD_DESC"] = "Matches food and drink that is 10 or more levels below you. This will cover food from previous expansions, and old food while leveling.",

-- Keep Rules
["SYSRULE_KEEP_NEVERSELL"] = "Items in Never Sell List",
["SYSRULE_KEEP_NEVERSELL_DESC"] = "Items that are in the Never Sell list are never sold. You can view the full list with '/vendor list never'",
["SYSRULE_KEEP_UNSELLABLE"] = "Unsellable Items",
["SYSRULE_KEEP_UNSELLABLE_DESC"] = "These items have no value and cannot be sold to a merchant. If you don't like it, take it up with Blizzard.",
["SYSRULE_KEEP_SOULBOUNDGEAR"] = "Soulbound Gear",
["SYSRULE_KEEP_SOULBOUNDGEAR_DESC"] = "Keeps any equipment item that is Soulbound to you, even items your class cannot wear. This is a safeguard rule meant to protect you from accidentally vendoring your gear. Take care when disabling this rule.",
["SYSRULE_KEEP_COMMON"] = "Common (White) Items",
["SYSRULE_KEEP_COMMON_DESC"] = "Matches any Common quality item. These are typically valuable consumables or crafting materials. This is a safeguard rule meant to protect you from vendoring your consumables and crafting materials.",
["SYSRULE_KEEP_UNKNOWNAPPEARANCE"] = "Uncollected Transmog Apperances",
["SYSRULE_KEEP_UNKNOWNAPPEARANCE_DESC"] = "Matches any gear that is an Uncollected Appearance. This is a Safeguard for your transmog hunting.",
["SYSRULE_KEEP_LEGENDARYANDUP"] = "Legendary or Better Items",
["SYSRULE_KEEP_LEGENDARYANDUP_DESC"] = "Always keeps any items of Legendary quality or higher. This includes Legendaries, Artifacts, Heirlooms, and Blizzard items (WoW Tokens). This just a paranoid Safeguard Rule that we don't recommend disabling.",
["SYSRULE_KEEP_UNCOMMONGEAR"] = "Uncommon (Green) Gear|r",
["SYSRULE_KEEP_UNCOMMONGEAR_DESC"] = "Matches any Uncommon quality equipment. Does not include non-equipment of Uncommon quality.",
["SYSRULE_KEEP_RAREGEAR"] = "Rare (Blue) Gear",
["SYSRULE_KEEP_RAREGEAR_DESC"] = "Matches any Rare quality equipment. Does not include non-equipment of Rare quality.",
["SYSRULE_KEEP_EPICGEAR"] = "Epic (Purple) Gear",
["SYSRULE_KEEP_EPICGEAR_DESC"] = "Matches any Epic quality equipment. Does not include non-equipment of Epic quality.",

} -- END OF LOCALIZATION TABLE
