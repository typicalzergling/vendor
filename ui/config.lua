local L = Vendor:GetLocalizedStrings()

Vendor.defaults = {
	profile = {
		debug = false,
		showcopper = false,
		throttle_time = .5,
		autosell = true,
		autorepair = true,
		guildrepair = true,
		sellgreens = false,
		sellblues = false,
		sellgreensilvl = 190,
		sellbluesilvl = 190,
		sellartifactpower = true,
		sell_throttle = 3,
		sell_never = {},
		sell_always = {},
	},
}

Vendor.config = {
	name = L["ADDON_NAME"],
	handler = Vendor,
	type = 'group',
	args = {
		-- CORE
		titledesc = {
			name= L["OPTIONS_TITLE_ADDON"],
			type = 'description',
			order = 0,
		},
		debug = {
			name = L["OPTIONS_SETTINGNAME_DEBUG"],
			desc = L["OPTIONS_SETTINGDESC_DEBUG"],
			type = 'toggle',
			set = function(info,val) info.handler.db.profile.debug = val end,
			get = function(info) return info.handler.db.profile.debug end,
			order = 10,
		},
		showcopper = {
			name = L["OPTIONS_SETTINGNAME_SHOWCOPPER"],
			desc = L["OPTIONS_SETTINGDESC_SHOWCOPPER"],
			type = 'toggle',
			cmdHidden = true,
			set = function(info,val) info.handler.db.profile.showcopper = val end,
			get = function(info) return info.handler.db.profile.showcopper end,
			order = 20,
		},
		b1 = {
			name = "\n\n",
			type = 'description',
			order = 99,
		},
		
		-- SELLING
		h1 = {
			name = L["OPTIONS_HEADER_SELLING"],
			type = 'header',
			order = 100,
		},
		d1 = {
			name = L["OPTIONS_DESC_SELLING"],
			type = 'description',
			order = 110,
		},
		autosell = {
			name = L["OPTIONS_SETTINGNAME_AUTOSELL"],
			desc = L["OPTIONS_SETTINGDESC_AUTOSELL"],
			type = 'toggle',
			cmdHidden = true,
			order = 120,
			width = 'full',
			set = function(info,val) info.handler.db.profile.autosell = val end,
			get = function(info) return info.handler.db.profile.autosell end,
		},
		sellgreens = {
			name = L["OPTIONS_SETTINGNAME_SELLGREENS"],
			desc = L["OPTIONS_SETTINGDESC_SELLGREENS"],
			type = 'toggle',
			cmdHidden = true,
			order = 121,
			disabled = function(info) return (not info.handler.db.profile.autosell) end,
			set = function(info, val) info.handler.db.profile.sellgreens = val end,
			get = function(info) return info.handler.db.profile.sellgreens end,
		},
		sellgreensilvl = {
			name = L["OPTIONS_SETTINGNAME_SELLGREENSILVL"],
			desc = L["OPTIONS_SETTINGDESC_SELLGREENSILVL"],
			type = 'input',
			cmdHidden = true,
			order = 122,
			width = 'half',
			pattern = '%d+',
			disabled = function(info) return (not info.handler.db.profile.autosell or not info.handler.db.profile.sellgreens) end,
			validate = function(info, val) if not tonumber(val) or tonumber(val) < 1 then return L["OPTIONS_SETTINGINVALID_SELLGREENSILVL"] end return true end,
			set = function(info, val) info.handler.db.profile.sellgreensilvl = tonumber(val) end,
			get = function(info) return tostring(info.handler.db.profile.sellgreensilvl) end,
		},
		b12 = {
			name = "",
			type = 'description',
			order = 130,
		},
		sellblues = {
			name = L["OPTIONS_SETTINGNAME_SELLBLUES"],
			desc = L["OPTIONS_SETTINGDESC_SELLBLUES"],
			type = 'toggle',
			cmdHidden = true,
			order = 131,
			disabled = function(info) return (not info.handler.db.profile.autosell) end,
			set = function(info, val) info.handler.db.profile.sellblues = val end,
			get = function(info) return info.handler.db.profile.sellblues end,
		},
		sellbluesilvl = {
			name = L["OPTIONS_SETTINGNAME_SELLBLUESILVL"],
			desc = L["OPTIONS_SETTINGDESC_SELLBLUESILVL"],
			type = 'input',
			cmdHidden = true,
			order = 132,
			width = 'half',
			pattern = '%d+',
			disabled = function(info) return (not info.handler.db.profile.autosell or not info.handler.db.profile.sellblues) end,
			validate = function(info, val) if not tonumber(val) or tonumber(val) < 1 then return L["OPTIONS_SETTINGINVALID_SELLBLUESILVL"] end return true end,
			set = function(info, val) info.handler.db.profile.sellbluesilvl = tonumber(val) end,
			get = function(info) return tostring(info.handler.db.profile.sellbluesilvl) end,
		},
		b13 = {
			name = "",
			type = 'description',
			order = 140,
		},
		sellartifactpower = {
			name = L["OPTIONS_SETTINGNAME_SELLARTIFACTPOWER"],
			desc = L["OPTIONS_SETTINGDESC_SELLARTIFACTPOWER"],
			type = 'toggle',
			cmdHidden = true,
			order = 141,
			disabled = function(info) return (not info.handler.db.profile.autosell) end,
			set = function(info, val) info.handler.db.profile.sellartifactpower = val end,
			get = function(info) return info.handler.db.profile.sellartifactpower end,
		},
		
		-- REPAIR
		h2 = {
			name = L["OPTIONS_HEADER_REPAIR"],
			type = 'header',
			order = 200,
		},
		d2 = {
			name = L["OPTIONS_DESC_REPAIR"],
			type = 'description',
			order = 210,
		},
		autorepair = {
			name = L["OPTIONS_SETTINGNAME_AUTOREPAIR"],
			desc = L["OPTIONS_SETTINGDESC_AUTOREPAIR"],
			type = 'toggle',
			cmdHidden = true,
			order = 220,
			width = 'full',
			set = function(info,val) info.handler.db.profile.autorepair = val end,
			get = function(info) return info.handler.db.profile.autorepair end,
		},
		guildrepair = {
			name = L["OPTIONS_SETTINGNAME_GUILDREPAIR"],
			desc = L["OPTIONS_SETTINGDESC_GUILDREPAIR"],
			type = 'toggle',
			cmdHidden = true,
			order = 221,
			width = 'full',
			disabled = function(info) return (not info.handler.db.profile.autorepair) end,
			set = function(info, val) info.handler.db.profile.guildrepair = val end,
			get = function(info) return info.handler.db.profile.guildrepair end,
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
		--@do-not-package@
		link = {
			name = "Dump Link",
			guiHidden = true,
			cmdHidden = false,
			type = 'execute',		
			func = 'DumpLink_Cmd',
		},
		test = {
			name = 'Test Function',
			desc = "Runs the test function! It could do anything! Or nothing. Or break the addon. Use at own risk.",
			guiHidden = true,
			cmdHidden = false,
			type = 'execute',
			func = 'Test_Cmd',
		},
		--@end-do-not-package@
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
