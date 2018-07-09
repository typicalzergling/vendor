-- enUS Localization

Vendor = Vendor or {}
Vendor.Locales = Vendor.Locales or {}
Vendor.Locales["enUS"] = 
{
-- Core
["ADDON_NAME"] = "Vendor",
["ENABLED"] = "Enabled",
["DISABLED"] = "Disabled",

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
["TOOLTIP_ITEM_WILL_BE_SOLD"] = "Item will be auto-sold by Vendor",

-- Options
["OPTIONS_TITLE_ADDON"] = "These settings are for configuring Vendor behavior.\n\n",
["OPTIONS_CATEGORY_PROFILES"] = "Profiles",
["OPTIONS_SETTINGNAME_DEBUG"] = "Debug Mode",
["OPTIONS_SETTINGDESC_DEBUG"] = "Toggles Debug Mode. This will output more messages to console.",
["OPTIONS_SETTINGNAME_SHOWCOPPER"] = "Show Copper",
["OPTIONS_SETTINGDESC_SHOWCOPPER"] = "Toggles showing copper values in money strings.",

["OPTIONS_HEADER_SELLING"] = "Selling",
["OPTIONS_DESC_SELLING"] = "What to sell at a vendor automatically. Soulbound gear, white quality items, level 1 items, uncollected transmog appearances, and epic quality gear is never sold unless it is on the always-sell list.\n",
["OPTIONS_SETTINGNAME_AUTOSELL"] = "Auto-Sell",
["OPTIONS_SETTINGDESC_AUTOSELL"] = "Automatically sell items per settings. By default this includes grey items and items marked to be always sold.",
["OPTIONS_SETTINGNAME_SELLGREENS"] = "Sell Green Gear",
["OPTIONS_SETTINGDESC_SELLGREENS"] = "Automatically sell BOE green weapons and armor.",
["OPTIONS_SETTINGNAME_SELLGREENSILVL"] = "Itemlevel",
["OPTIONS_SETTINGDESC_SELLGREENSILVL"] = "Sells all green equipment below the specified item level.",
["OPTIONS_SETTINGINVALID_SELLGREENSILVL"] = "Invalid ilvl; it must be a number greater than 0.",
["OPTIONS_SETTINGNAME_SELLBLUES"] = "Sell Blue Gear",
["OPTIONS_SETTINGDESC_SELLBLUES"] = "Automatically sell BOE blue weapons and armor.",
["OPTIONS_SETTINGNAME_SELLBLUESILVL"] = "Itemlevel",
["OPTIONS_SETTINGDESC_SELLBLUESILVL"] = "Sells all blue equipment below the specified item level.",
["OPTIONS_SETTINGINVALID_SELLBLUESILVL"] = "Invalid ilvl; it must be a number greater than 0.",
["OPTIONS_SETTINGNAME_SELLARTIFACTPOWER"] = "Sell Artifact Power",
["OPTIONS_SETTINGDESC_SELLARTIFACTPOWER"] = "Automatically sell Legion artifact power items if player level is 110+",

["OPTIONS_HEADER_REPAIR"] = "Repair",
["OPTIONS_DESC_REPAIR"] = "Whether to auto-repair, and how to pay for it.\n",
["OPTIONS_SETTINGNAME_AUTOREPAIR"] = "Auto-Repair",
["OPTIONS_SETTINGDESC_AUTOREPAIR"] = "Automatically repair when visiting a repair-capable vendor.",
["OPTIONS_SETTINGNAME_GUILDREPAIR"] = "Use Guild Bank for Repairs",
["OPTIONS_SETTINGDESC_GUILDREPAIR"] = "Uses guild bank for repairs if possible.",

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

} -- END OF LOCALIZATION TABLE
