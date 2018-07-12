local L = Vendor:GetLocalizedStrings()

Vendor.DefaultRulesConfig = 
{
	version = 2,
	
    -- The default rules to enable which cause items to be kept
    keep = {
        "neversell",
        "unsellable",
        "common",
        "soulboundgear",
        "unknownappearance",
        "legendaryandup",
    },

    -- The default rules to enable which cause items to be sold.
    sell = 
    {
        "artifactpower",
        "poor",
        "knowntoys",
        { rule = "uncommongear", itemlevel = 190 }, -- green gear < ilvl
        { rule = "raregear", itemlevel = 190 }, -- blue gear < ilvl
    },

    -- Custom rules provied by the user
    custom = {},
    customDefinitions = {},
}

Vendor.defaults = {
    profile = {
        throttle_time = .5,
        autosell = true,
        autorepair = true,
        guildrepair = true,
        sell_throttle = 3,
        sell_never = {},
        sell_always = {},

        -- Rules configuration
        rules =
        {
        	version = 2,
        	
            -- The default rules to enable which cause items to be kept
            keep = {
                "neversell",
                "unsellable",
                "common",
                "soulboundgear",
                "unknownappearance",
                "legendaryandup",
            },

            -- The default rules to enable which cause items to be sold.
            sell = 
            {
                "artifactpower",
                "poor",
                "knowntoys",
                { rule = "uncommongear", itemlevel = 190 }, -- green gear < ilvl
                { rule = "raregear", itemlevel = 190 }, -- blue gear < ilvl
            },

            -- Custom rules provied by the user
            custom = {},
            customDefinitions = {},
        },
    },
}

Vendor.config = {
    name = L["ADDON_NAME"],
    handler = Vendor,
    type = 'group',
    args = {
        -- CORE
        --[[ Removing for now until we have something meaningful to put here.
        titledesc = {
            name= L["OPTIONS_TITLE_ADDON"],
            type = 'description',
            order = 0,
        },]]
        
        -- REPAIR
        repairheader = {
            name = L["OPTIONS_HEADER_REPAIR"],
            type = 'header',
            order = 100,
        },
        repairdesc = {
            name = L["OPTIONS_DESC_REPAIR"],
            type = 'description',
            order = 110,
        },
        autorepair = {
            name = L["OPTIONS_SETTINGNAME_AUTOREPAIR"],
            desc = L["OPTIONS_SETTINGDESC_AUTOREPAIR"],
            type = 'toggle',
            cmdHidden = true,
            order = 120,
            width = 'full',
            set = function(info,val) info.handler.db.profile.autorepair = val end,
            get = function(info) return info.handler.db.profile.autorepair end,
        },
        guildrepair = {
            name = L["OPTIONS_SETTINGNAME_GUILDREPAIR"],
            desc = L["OPTIONS_SETTINGDESC_GUILDREPAIR"],
            type = 'toggle',
            cmdHidden = true,
            order = 121,
            width = 'full',
            disabled = function(info) return (not info.handler.db.profile.autorepair) end,
            set = function(info, val) info.handler.db.profile.guildrepair = val end,
            get = function(info) return info.handler.db.profile.guildrepair end,
        },
        
        -- SELLING
        sellheader = {
            name = L["OPTIONS_HEADER_SELLING"],
            type = 'header',
            order = 200,
        },
        selldesc = {
            name = L["OPTIONS_DESC_SELLING"],
            type = 'description',
            order = 210,
        },

        autosell = {
            name = L["OPTIONS_SETTINGNAME_AUTOSELL"],
            desc = L["OPTIONS_SETTINGDESC_AUTOSELL"],
            type = 'toggle',
            cmdHidden = true,
            order = 220,
            width = 'full',
            set = function(info,val) info.handler.db.profile.autosell = val end,
            get = function(info) return info.handler.db.profile.autosell end,
        },
        sellrules = {
            name = L["OPTIONS_SETTINGNAME_SELLRULES"],
            desc = L["OPTIONS_SETTINGDESC_SELLRULES"],
            type = 'execute',
            order = 230,
            confirm = false,
            func = 'ShowSystemRuleSellDialog',
        },

        keeprules = {
            name = L["OPTIONS_SETTINGNAME_KEEPRULES"],
            desc = L["OPTIONS_SETTINGDESC_KEEPRULES"],
            type = 'execute',
            order = 240,
            confirm = false,
            func = 'ShowSystemRuleKeepDialog',
        },

        -- Console only commands
        sell = {
            name = L["CMD_SELLITEM_NAME"],
            desc = L["CMD_SELLITEM_DESC"],
            guiHidden = true,
            type = 'execute',
            func = 'SellItem_Cmd',  
        },
        list = {
            name = L["CMD_LISTDATA_NAME"],
            desc = L["CMD_LISTDATA_DESC"],
            guiHidden = true,
            type = 'execute',
            func = 'ListData_Cmd',
        },  
        clear = {
            name = L["CMD_CLEARDATA_NAME"],
            desc = L["CMD_CLEARDATA_DESC"],
            guiHidden = true,
            type = 'execute',
            func = 'ClearData_Cmd',
        },  
        settings = {
            name = L["CMD_SETTINGS_NAME"],
            desc = L["CMD_SETTINGS_DESC"],
            guiHidden = true,
            type = 'execute',
            func = 'OpenSettings_Cmd',
        },
    },
}

Vendor.perfconfig = {
    name = L["OPTIONS_CATEGORY_PERFORMANCE"],
    handler = Vendor,
    type = 'group',
    args = {
        titledesc = {
            name= L["OPTIONS_TITLE_PERFORMANCE"],
            type = 'description',
            order = 0,
        },
        h1 = {
            name = L["OPTIONS_HEADER_THROTTLES"],
            type = 'header',
            order = 100,
        },
        d1 = {
            name = L["OPTIONS_DESC_THROTTLES"],
            type = 'description',
            order = 110,
        },
        sell_throttle = {
            name = L["OPTIONS_SETTINGNAME_SELL_THROTTLE"],
            desc = L["OPTIONS_SETTINGDESC_SELL_THROTTLE"],
            type = 'input',
            order = 150,
            cmdHidden = true,
            pattern = '%d+',
            validate = function(info, val) if not tonumber(val) or math.floor(tonumber(val)) < 1 or math.floor(tonumber(val)) ~= tonumber(val) then return L["OPTIONS_SETTINGINVALID_SELL_THROTTLE"] end return true end,
            set = function(info, val) info.handler.db.profile.sell_throttle = tonumber(val) end,
            get = function(info) return tostring(info.handler.db.profile.sell_throttle) end,
        },
        b1 = {
            name = "\n\n",
            type = 'description',
            order = 199,
        },
        h2 = {
            name = L["OPTIONS_HEADER_FREQUENCY"],
            type = 'header',
            order = 200,
        },
        d2 = {
            name = L["OPTIONS_DESC_FREQUENCY"],
            type = 'description',
            order = 210,
        },
        throttle_time = {
            name = L["OPTIONS_SETTINGNAME_CYCLE_RATE"],
            desc = L["OPTIONS_SETTINGDESC_CYCLE_RATE"],
            type = 'input',
            order = 220,
            pattern = '%d+',
            cmdHidden = true,
            validate = function(info, val) if not tonumber(val) or tonumber(val) < .1 then return L["OPTIONS_SETTINGINVALID_CYCLE_RATE"] end return true end,
            set = function(info, val) info.handler.db.profile.throttle_time = tonumber(val) end,
            get = function(info) return tostring(info.handler.db.profile.throttle_time) end,
        },
    },
}
