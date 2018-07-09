local L = LibStub("AceLocale-3.0"):NewLocale("Vendor", "enUS", true) 
if not L then return end 

-- Core
L["ADDON_NAME"] = "Vendor"
L["ENABLED"] = "Enabled"
L["DISABLED"] = "Disabled"

-- Bindings
L["BINDING_HEADER_VENDORQUICKLIST"] = "Quick Add/Remove items from the sell lists when mousing over the item"
L["BINDING_NAME_VENDORALWAYSSELL"] = "Toggle Always-Sell Item"
L["BINDING_DESC_VENDORALWAYSSELL"] = "Adds the item currently in the game tooltip to the Always-sell list. Removes it if it is already in the list."
L["BINDING_NAME_VENDORNEVERSELL"] = "Toggle Never-Sell Item"
L["BINDING_DESC_VENDORNEVERSELL"] = "Adds the item currently in the game tooltip to the Never-sell list. Removes it if it is already in the list."

-- Merchant
L["MERCHANT_REPAIR_FROM_GUILD_BANK"] = "Repaired all equipment from the guild bank for %s"
L["MERCHANT_REPAIR_FROM_SELF"] = "Repaired all equipment for %s"
L["MERCHANT_SELLING_ITEM"] = "Selling %s for %s"
L["MERCHANT_SOLD_ITEMS"] = "Sold %s items for %s"

-- Tooltip
L["TOOLTIP_ADDITEM_ERROR_NOITEM"] = "Failed to add item to %s-sell list. The game tooltip is not over an item."
L["TOOLTIP_ITEM_IN_ALWAYS_SELL_LIST"] = "Vendor: Always Sell"
L["TOOLTIP_ITEM_IN_NEVER_SELL_LIST"] = "Vendor: Never Sell"
L["TOOLTIP_ITEM_WILL_BE_SOLD"] = "Item will be auto-sold by Vendor"

-- Options
L["OPTIONS_TITLE_ADDON"] = "These settings are for configuring Vendor behavior.\n\n"
L["OPTIONS_CATEGORY_PROFILES"] = "Profiles"
L["OPTIONS_SETTINGNAME_DEBUG"] = "Debug Mode"
L["OPTIONS_SETTINGDESC_DEBUG"] = "Toggles Debug Mode. This will output more messages to console."
L["OPTIONS_SETTINGNAME_SHOWCOPPER"] = "Show Copper"
L["OPTIONS_SETTINGDESC_SHOWCOPPER"] = "Toggles showing copper values in money strings."

L["OPTIONS_HEADER_SELLING"] = "Selling"
L["OPTIONS_DESC_SELLING"] = "What to sell at a vendor automatically. Soulbound gear, white quality items, level 1 items, uncollected transmog appearances, and epic quality gear is never sold unless it is on the always-sell list.\n"
L["OPTIONS_SETTINGNAME_AUTOSELL"] = "Auto-Sell"
L["OPTIONS_SETTINGDESC_AUTOSELL"] = "Automatically sell items per settings. By default this includes grey items and items marked to be always sold."
L["OPTIONS_SETTINGNAME_SELLGREENS"] = "Sell Green Gear"
L["OPTIONS_SETTINGDESC_SELLGREENS"] = "Automatically sell BOE green weapons and armor."
L["OPTIONS_SETTINGNAME_SELLGREENSILVL"] = "Itemlevel"
L["OPTIONS_SETTINGDESC_SELLGREENSILVL"] = "Sells all green equipment below the specified item level."
L["OPTIONS_SETTINGINVALID_SELLGREENSILVL"] = "Invalid ilvl; it must be a number greater than 0."
L["OPTIONS_SETTINGNAME_SELLBLUES"] = "Sell Blue Gear"
L["OPTIONS_SETTINGDESC_SELLBLUES"] = "Automatically sell BOE blue weapons and armor."
L["OPTIONS_SETTINGNAME_SELLBLUESILVL"] = "Itemlevel"
L["OPTIONS_SETTINGDESC_SELLBLUESILVL"] = "Sells all blue equipment below the specified item level."
L["OPTIONS_SETTINGINVALID_SELLBLUESILVL"] = "Invalid ilvl; it must be a number greater than 0."
L["OPTIONS_SETTINGNAME_SELLARTIFACTPOWER"] = "Sell Artifact Power"
L["OPTIONS_SETTINGDESC_SELLARTIFACTPOWER"] = "Automatically sell Legion artifact power items if player level is 110+"

L["OPTIONS_HEADER_REPAIR"] = "Repair"
L["OPTIONS_DESC_REPAIR"] = "Whether to auto-repair, and how to pay for it.\n"
L["OPTIONS_SETTINGNAME_AUTOREPAIR"] = "Auto-Repair"
L["OPTIONS_SETTINGDESC_AUTOREPAIR"] = "Automatically repair when visiting a repair-capable vendor."
L["OPTIONS_SETTINGNAME_GUILDREPAIR"] = "Use Guild Bank for Repairs"
L["OPTIONS_SETTINGDESC_GUILDREPAIR"] = "Uses guild bank for repairs if possible."

-- Performance Settings tab
L["OPTIONS_CATEGORY_PERFORMANCE"] = "Performance"
L["OPTIONS_TITLE_PERFORMANCE"] = "Vendor makes use of throttling and coroutines to avoid unresponsiveness in the interface and client disconnects. These settings control that behavior.\n\n"

L["OPTIONS_HEADER_THROTTLES"] = "Throttles"
L["OPTIONS_DESC_THROTTLES"] = "These values all set how many actions are taken per throttle cycle."
L["OPTIONS_SETTINGNAME_SELL_THROTTLE"] = "Items Vendored"
L["OPTIONS_SETTINGDESC_SELL_THROTTLE"] = "Used when auto-selling items to a vendor. Lower this value if items are inconsistently auto-selling.\n\nRecommended value: 1 to 5"
L["OPTIONS_SETTINGINVALID_SELL_THROTTLE"] = "Invalid throttle value; it must be an integer greater than 0."

L["OPTIONS_HEADER_FREQUENCY"] = "Frequency"
L["OPTIONS_DESC_FREQUENCY"] = "Sets how frequently a throttled task executes per second. Changing this affects all throttles."
L["OPTIONS_SETTINGNAME_CYCLE_RATE"] = "Cycle Rate"
L["OPTIONS_SETTINGDESC_CYCLE_RATE"] = "Interval in seconds between attempts to sell the throttled number of items.\n\nRecommended value: .5 to 2"
L["OPTIONS_SETTINGINVALID_CYCLE_RATE"] = "Invalid cycle rate; it must be greater than .1"

-- Commands
L["CMD_SETTINGS_NAME"] = "Open Settings"
L["CMD_SETTINGS_DESC"] = "Open the settings panel for Vendor."
L["CMD_SELLITEM_NAME"] = "Set never sell or always sell items."
L["CMD_SELLITEM_DESC"] = "Adds or removes items from the sell list: sell {always||never} [itemid]"
L["CMD_SELLITEM_INVALIDARG"] = "Must specify which list to which you want to query or edit an item: {always||never} [item]"
L["CMD_SELLITEM_ADDED"] = "Item: %s added to the %s-sell list."
L["CMD_SELLITEM_REMOVED"] = "Item: %s removed from the %s-sell list."

L["CMD_CLEARDATA_NAME"] = "Clear never-sell and always-sell lists"
L["CMD_CLEARDATA_DESC"] = "Clears data for all lists, or the list if specified. Usage: clear [always||never]"
L["CMD_CLEARDATA_INVALIDARG"] = "Invalid option: %s  Usage: clear [always||never]"
L["CMD_CLEARDATA_ALWAYS"] = "The always-sell list has been cleared."
L["CMD_CLEARDATA_NEVER"] = "The never-sell list has been cleared."

L["CMD_LISTDATA_NAME"] = "Print the never-sell and/or always-sell lists."
L["CMD_LISTDATA_DESC"] = "Prints the items for all lists, or the list if specified. Usage: list [always||never]"
L["CMD_LISTDATA_INVALIDARG"] = "Invalid option: %s  Usage: clear [always||never]"
L["CMD_LISTDATA_EMPTY"] = "The %s-sell list is empty."
L["CMD_LISTDATA_LISTHEADER"] = "Items in the %s-sell list:"
L["CMD_LISTDATA_LISTITEM"] = "  %s - %s"
L["CMD_LISTDATA_NOTINCACHE"] = "[Item not seen yet, re-run to see it.]"
