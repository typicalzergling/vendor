
Vendor_CustomRuleDefinitions = {
	{
		["Type"] = "Keep",
		["Script"] = "HasStat(\"speed\")",
		["interfaceversion"] = 90002,
		["Id"] = "cr.malvir.lightbringer.1601961838",
		["Custom"] = true,
		["EditedBy"] = "Malvir / Lightbringer",
		["Locked"] = false,
		["Name"] = "Has Speed",
		["Description"] = "Has Speed",
	}, -- [1]
	{
		["Type"] = "Sell",
		["Script"] = "SubType == \"Artifact Relic\"",
		["interfaceversion"] = 90001,
		["Id"] = "cr.malvir.lightbringer.1602290239",
		["Custom"] = true,
		["EditedBy"] = "Malvir / Lightbringer",
		["Locked"] = false,
		["Name"] = "Artifacts",
		["Description"] = "Vendors old artifact relics",
	}, -- [2]
	{
		["Type"] = "Sell",
		["Script"] = "TypeId == 15 and SubTypeId == 4 and IsAlreadyKnown and TooltipContains(\"Garrison Blueprint\")",
		["interfaceversion"] = 90001,
		["Id"] = "cr.szarekh.lightbringer.1605511839",
		["Name"] = "Known Garrison Blueprints",
		["EditedBy"] = "Szarekh / Lightbringer",
		["Locked"] = false,
		["Description"] = "Sell Known Garrison Blueprints",
		["Custom"] = true,
		["needsMigration"] = false,
	}, -- [3]
	{
		["Type"] = "Sell",
		["Script"] = "(Id ==  163569) and (NumKeep() >= 1)",
		["interfaceversion"] = 90002,
		["Id"] = "cr.thoekh.lightbringer.1605999007",
		["Name"] = "Destroy all but 1 scourgestone stack",
		["EditedBy"] = "Thoekh / Lightbringer",
		["Locked"] = false,
		["Custom"] = true,
		["Description"] = "Keep 1 scourgestone stack, destroy the rest.",
	}, -- [4]
	{
		["Type"] = "Keep",
		["Script"] = "string.find(Name, 'Selfless Bearer')",
		["interfaceversion"] = 90005,
		["Id"] = "cr.szarekh.lightbringer.1618358047",
		["Name"] = "Selfless Bearer Gear",
		["EditedBy"] = "Szarekh / Lightbringer",
		["Locked"] = false,
		["needsMigration"] = false,
		["Custom"] = true,
		["Description"] = "Keeps Kyrian Covenant Gear",
	}, -- [5]
	{
		["Type"] = "Sell",
		["Script"] = "(not IsEquipment) and (SubTypeId == 0) and (TypeId == 15) and (ExpansionPackId == 0) and (IsUsable) and (not IsUnsellable) and (Quality == 4) and (not TooltipContains(PlayerClass()))",
		["interfaceversion"] = 90005,
		["Id"] = "cr.szarekh.lightbringer.1623817524",
		["Name"] = "Unusable TBC Equipment Tokens",
		["EditedBy"] = "Szarekh / Lightbringer",
		["Locked"] = false,
		["Description"] = "Sells unusable TBC equipment tokens.",
		["Custom"] = true,
		["needsMigration"] = false,
	}, -- [6]
	{
		["Type"] = "Sell",
		["Script"] = "IsCraftingReagent and (ExpansionPackId == 0)",
		["interfaceversion"] = 90005,
		["Id"] = "cr.szarekh.lightbringer.1623817952",
		["Name"] = "Old Crafting Materials",
		["EditedBy"] = "Szarekh / Lightbringer",
		["Locked"] = false,
		["Description"] = "Old crafting materials not worth selling.",
		["Custom"] = true,
		["needsMigration"] = false,
	}, -- [7]
	["cr.Severin.Windrunner.1532721676"] = {
		["Script"] = "TypeId == 0\nand\nSubTypeId() == 8\nand\nTooltipContains(\"Champion Equipment\")",
		["EditedBy"] = "Severin - Windrunner",
		["Id"] = "cr.Severin.Windrunner.1532721676",
		["Name"] = "Champion Equipment",
		["Description"] = "Sells Champion equipment",
	},
	["cr.Severin.Windrunner.1532503831"] = {
		["Script"] = "TypeId() == 3\nand\nSubTypeId() == 11\nand\nLevel() < 225\nand\nExpansionPackId() == 6\n",
		["EditedBy"] = "Severin - Windrunner",
		["Id"] = "cr.Severin.Windrunner.1532503831",
		["Name"] = "Relics < 225",
		["Description"] = "Relics under item level 225",
	},
	["cr.Severin.Windrunner.1532501893"] = {
		["Script"] = "ExpansionPackId() == 6  -- Legion\nand\nSubTypeId() == 11  -- Artifact Relic\nand\nTypeId() == 3 -- Gem\n\n",
		["EditedBy"] = "Severin - Windrunner",
		["Id"] = "cr.Severin.Windrunner.1532501893",
		["Name"] = "Relics < 200",
		["Description"] = "Sells Legion Relics under Item Level 200",
	},
}
Vendor_Settings = nil
Vendor_debug = {
	["settings"] = {
		["simulate"] = false,
	},
	["channel"] = {
		["blocklists"] = false,
		["ruleconfig"] = true,
		["itemerrors"] = false,
		["autosell"] = false,
		["rulesdialog"] = false,
		["historystats"] = true,
		["destroy"] = false,
		["delete"] = true,
		["rulesengine"] = false,
		["tooltiperrors"] = false,
		["profile"] = false,
		["tooltip"] = false,
		["extensions"] = false,
		["config"] = false,
		["items"] = false,
		["history"] = false,
		["events"] = false,
		["test"] = false,
		["databroker"] = true,
		["itemproperties"] = false,
		["threads"] = false,
		["rules"] = false,
	},
}
Vendor_Profiles = {
	["Vendor:16234502990475"] = {
		["rules:sell"] = {
			"sell.poor", -- [1]
			"sell.oldfood", -- [2]
			"sell.knowntoys", -- [3]
			"cr.malvir.lightbringer.1602290239", -- [4]
			"e[pawn.isnotupgrade])", -- [5]
		},
		["profile:interface"] = 90001,
		["list:sell"] = {
			[71617] = true,
			[14227] = true,
			[163051] = true,
			[139813] = true,
			[163060] = true,
			[13446] = true,
			[152442] = true,
			[163054] = true,
			[12208] = true,
			[143681] = true,
			[168144] = true,
			[152927] = true,
			[40772] = true,
			[163103] = true,
			[139795] = true,
			[3928] = true,
			[163053] = true,
			[139792] = true,
			[159868] = true,
			[159867] = true,
			[152033] = true,
			[41119] = true,
			[159848] = true,
			[133848] = true,
			[12203] = true,
			[13444] = true,
		},
		["max_items_to_sell"] = 1,
		["tooltip_basic"] = true,
		["sell_throttle"] = 1,
		["autorepair"] = true,
		["throttle_time"] = 0,
		["autosell"] = true,
		["rules:destroy"] = {
			"destroy.knowntoys", -- [1]
		},
		["id"] = "Vendor:16234502990475",
		["guildrepair"] = true,
		["list:keep"] = {
			[71781] = true,
			[49040] = true,
			[33292] = true,
			[178157] = true,
			[116913] = true,
			[133576] = true,
			[178851] = true,
			[118897] = true,
			[178156] = true,
			[178158] = true,
			[165629] = true,
			[183663] = true,
			[124387] = true,
			[169489] = true,
			[132523] = true,
			[183687] = true,
			[179774] = true,
			[173245] = true,
			[178754] = true,
			[178868] = true,
			[184105] = true,
			[124360] = true,
			[178829] = true,
			[178160] = true,
			[178782] = true,
			[173246] = true,
			[178861] = true,
			[178704] = true,
			[124388] = true,
			[65360] = true,
			[173349] = true,
			[178153] = true,
			[77217] = true,
			[178161] = true,
			[178159] = true,
			[177799] = true,
			[177870] = true,
			[183021] = true,
			[178831] = true,
			[180792] = true,
			[178824] = true,
			[178753] = true,
			[32757] = true,
			[178871] = true,
			[124389] = true,
			[114943] = true,
			[124375] = true,
			[42997] = true,
			[178029] = true,
			[173249] = true,
			[116916] = true,
			[178809] = true,
			[139946] = true,
			[44050] = true,
			[174108] = true,
			[178715] = true,
			[40586] = true,
			[180117] = true,
			[144341] = true,
			[165628] = true,
		},
		["version"] = 2,
		["profile:default"] = false,
		["profile:name"] = "Malvir - Lightbringer - Copy",
		["profile:version"] = 1,
		["tooltip_addrule"] = true,
		["autosell_limit"] = false,
		["list:destroy"] = {
			[20411] = true,
			[169329] = true,
			[169470] = true,
			[174767] = true,
			[154174] = true,
			[174287] = true,
			[174758] = true,
			[29282] = true,
			[117391] = true,
			[174764] = true,
			[12534] = true,
			[174766] = true,
			[169694] = true,
			[34068] = true,
		},
		["rules:keep"] = {
			"keep.legendaryandup", -- [1]
			"keep.unknownappearance", -- [2]
			"keep.potentialupgrades", -- [3]
			"cr.malvir.lightbringer.1601961838", -- [4]
			"keep.equipmentset", -- [5]
			{
				["ITEMLEVEL"] = 170,
				["rule"] = "keep.raregear",
			}, -- [6]
			{
				["ITEMLEVEL"] = 110,
				["rule"] = "keep.epicgear",
			}, -- [7]
		},
		["profile:timestamp"] = 1623450319,
	},
	["Vendor:16055962520042"] = {
		["rules:sell"] = {
			"sell.poor", -- [1]
			"sell.oldfood", -- [2]
			"sell.knowntoys", -- [3]
			"cr.malvir.lightbringer.1602290239", -- [4]
			"cr.thoekh.lightbringer.1605999007", -- [5]
		},
		["profile:interface"] = 90001,
		["list:sell"] = {
			[71617] = true,
			[163051] = true,
			[139813] = true,
			[152442] = true,
			[143681] = true,
			[163060] = true,
			[152927] = true,
			[159848] = true,
			[139795] = true,
			[163053] = true,
			[159868] = true,
			[20410] = true,
			[152033] = true,
			[139792] = true,
			[159867] = true,
			[133848] = true,
			[163054] = true,
			[163103] = true,
		},
		["max_items_to_sell"] = 1,
		["tooltip_basic"] = true,
		["sell_throttle"] = 1,
		["autorepair"] = true,
		["throttle_time"] = 0,
		["autosell"] = true,
		["rules:destroy"] = {
			"cr.thoekh.lightbringer.1605650640", -- [1]
			"cr.thoekh.lightbringer.1605999007", -- [2]
			"destroy.knowntoys", -- [3]
		},
		["id"] = "Vendor:16055962520042",
		["guildrepair"] = true,
		["list:keep"] = {
			[132523] = true,
			[124375] = true,
			[179349] = true,
			[124387] = true,
			[124389] = true,
			[124360] = true,
			[49040] = true,
			[77217] = true,
			[169489] = true,
			[116913] = true,
			[124388] = true,
			[133576] = true,
			[144341] = true,
			[65360] = true,
			[180929] = true,
			[114943] = true,
			[71781] = true,
			[33292] = true,
			[179350] = true,
		},
		["version"] = 2,
		["profile:default"] = false,
		["profile:name"] = "Thoekh - Lightbringer",
		["profile:version"] = 1,
		["tooltip_addrule"] = true,
		["autosell_limit"] = false,
		["list:destroy"] = {
			[163852] = true,
			[20397] = true,
			[128644] = true,
			[163853] = true,
			[143903] = true,
			[34068] = true,
			[43348] = true,
			[87399] = true,
			[174288] = true,
			[20398] = true,
			[180720] = true,
		},
		["rules:keep"] = {
			"keep.equipmentset", -- [1]
			"keep.legendaryandup", -- [2]
			"keep.unknownappearance", -- [3]
			"keep.potentialupgrades", -- [4]
		},
		["profile:timestamp"] = 1620193510,
	},
	["Vendor:16238360270086"] = {
		["rules:sell"] = {
			"sell.poor", -- [1]
			"sell.oldfood", -- [2]
			"sell.knowntoys", -- [3]
			"cr.malvir.lightbringer.1602290239", -- [4]
			"cr.szarekh.lightbringer.1605511839", -- [5]
			"e[pawn.isnotupgrade])", -- [6]
			"cr.szarekh.lightbringer.1623817524", -- [7]
			"cr.szarekh.lightbringer.1623817952", -- [8]
		},
		["profile:interface"] = 90001,
		["merchantbutton"] = true,
		["list:sell"] = {
			[40772] = true,
			[132510] = true,
			[109253] = true,
		},
		["max_items_to_sell"] = 1,
		["tooltip_basic"] = true,
		["sell_throttle"] = 1,
		["showminimap"] = true,
		["autorepair"] = true,
		["autosell"] = true,
		["guildrepair"] = true,
		["rules:destroy"] = {
			"destroy.knowntoys", -- [1]
		},
		["id"] = "Vendor:16238360270086",
		["throttle_time"] = 0.15,
		["list:keep"] = {
			[132523] = true,
			[7005] = true,
			[172320] = true,
			[116916] = true,
			[177846] = true,
			[63206] = true,
			[49040] = true,
			[172321] = true,
			[2901] = true,
			[118897] = true,
			[124118] = true,
			[133576] = true,
			[90146] = true,
			[144341] = true,
			[65360] = true,
			[178927] = true,
			[114943] = true,
			[5956] = true,
			[33292] = true,
			[116913] = true,
		},
		["profile:version"] = 2,
		["profile:default"] = false,
		["profile:name"] = "Thoekh - Sargeras",
		["version"] = 2,
		["tooltip_addrule"] = true,
		["autosell_limit"] = false,
		["list:destroy"] = {
			[42780] = true,
			[118099] = true,
		},
		["rules:keep"] = {
			"keep.equipmentset", -- [1]
			"keep.legendaryandup", -- [2]
			"keep.unknownappearance", -- [3]
			"keep.potentialupgrades", -- [4]
			"cr.szarekh.lightbringer.1618358047", -- [5]
			"cr.malvir.lightbringer.1601961838", -- [6]
			"keep.cosmetic", -- [7]
		},
		["profile:timestamp"] = 1667708173,
	},
	["Vendor:16054699890112"] = {
		["rules:sell"] = {
			"sell.poor", -- [1]
			"sell.oldfood", -- [2]
			"sell.knowntoys", -- [3]
			"cr.malvir.lightbringer.1602290239", -- [4]
			"cr.szarekh.lightbringer.1605511839", -- [5]
			"e[pawn.isnotupgrade])", -- [6]
			"cr.szarekh.lightbringer.1623817524", -- [7]
			"cr.szarekh.lightbringer.1623817952", -- [8]
		},
		["autosell"] = true,
		["list:sell"] = {
			[40772] = true,
			[132510] = true,
			[109253] = true,
		},
		["max_items_to_sell"] = 1,
		["tooltip_basic"] = true,
		["sell_throttle"] = 1,
		["autosell_limit"] = false,
		["list:keep"] = {
			[5956] = true,
			[33292] = true,
			[144341] = true,
			[132523] = true,
			[114943] = true,
			[116913] = true,
			[177846] = true,
			[118897] = true,
			[116916] = true,
			[2901] = true,
			[133576] = true,
			[65360] = true,
			[49040] = true,
			[7005] = true,
			[63206] = true,
		},
		["profile:timestamp"] = 1623818112,
		["rules:destroy"] = {
			"destroy.knowntoys", -- [1]
		},
		["id"] = "Vendor:16054699890112",
		["guildrepair"] = true,
		["throttle_time"] = 0.15,
		["profile:version"] = 1,
		["profile:default"] = false,
		["profile:name"] = "Szarekh - Lightbringer",
		["version"] = 2,
		["tooltip_addrule"] = true,
		["autorepair"] = true,
		["list:destroy"] = {
			[42780] = true,
			[118099] = true,
		},
		["rules:keep"] = {
			"keep.equipmentset", -- [1]
			"keep.legendaryandup", -- [2]
			"keep.unknownappearance", -- [3]
			"keep.potentialupgrades", -- [4]
			"cr.szarekh.lightbringer.1618358047", -- [5]
			"cr.malvir.lightbringer.1601961838", -- [6]
			{
				["ITEMLEVEL"] = 150,
				["rule"] = "keep.epicgear",
			}, -- [7]
		},
		["profile:interface"] = 90001,
	},
	["Vendor:16054697530399"] = {
		["rules:keep"] = {
			"keep.legendaryandup", -- [1]
			"keep.unknownappearance", -- [2]
			"keep.potentialupgrades", -- [3]
			"cr.malvir.lightbringer.1601961838", -- [4]
			{
				["ITEMLEVEL"] = 110,
				["rule"] = "keep.epicgear",
			}, -- [5]
			{
				["ITEMLEVEL"] = 170,
				["rule"] = "keep.raregear",
			}, -- [6]
			"keep.equipmentset", -- [7]
		},
		["profile:interface"] = 90001,
		["list:sell"] = {
			[71617] = true,
			[14227] = true,
			[163051] = true,
			[139813] = true,
			[13444] = true,
			[13446] = true,
			[152442] = true,
			[163054] = true,
			[159848] = true,
			[143681] = true,
			[168144] = true,
			[152927] = true,
			[3928] = true,
			[12208] = true,
			[139795] = true,
			[40772] = true,
			[163053] = true,
			[139792] = true,
			[159868] = true,
			[159867] = true,
			[152033] = true,
			[41119] = true,
			[163103] = true,
			[133848] = true,
			[12203] = true,
			[163060] = true,
		},
		["max_items_to_sell"] = 1,
		["tooltip_basic"] = true,
		["sell_throttle"] = 1,
		["autosell_limit"] = false,
		["list:keep"] = {
			[71781] = true,
			[49040] = true,
			[33292] = true,
			[178157] = true,
			[116913] = true,
			[133576] = true,
			[178851] = true,
			[118897] = true,
			[178158] = true,
			[165629] = true,
			[178156] = true,
			[183663] = true,
			[124387] = true,
			[132523] = true,
			[183687] = true,
			[169489] = true,
			[173245] = true,
			[44050] = true,
			[178868] = true,
			[184105] = true,
			[124360] = true,
			[178829] = true,
			[178754] = true,
			[178782] = true,
			[178160] = true,
			[178861] = true,
			[178704] = true,
			[124388] = true,
			[178153] = true,
			[173349] = true,
			[65360] = true,
			[77217] = true,
			[178161] = true,
			[178159] = true,
			[177799] = true,
			[177870] = true,
			[183021] = true,
			[178831] = true,
			[180792] = true,
			[178753] = true,
			[178824] = true,
			[32757] = true,
			[178871] = true,
			[124389] = true,
			[114943] = true,
			[124375] = true,
			[42997] = true,
			[178029] = true,
			[173249] = true,
			[116916] = true,
			[178809] = true,
			[139946] = true,
			[179774] = true,
			[174108] = true,
			[178715] = true,
			[40586] = true,
			[180117] = true,
			[144341] = true,
			[165628] = true,
		},
		["autosell"] = true,
		["rules:destroy"] = {
			"destroy.knowntoys", -- [1]
		},
		["id"] = "Vendor:16054697530399",
		["guildrepair"] = true,
		["throttle_time"] = 0,
		["version"] = 2,
		["profile:default"] = false,
		["profile:name"] = "Malvir - Lightbringer",
		["profile:version"] = 1,
		["tooltip_addrule"] = true,
		["autorepair"] = true,
		["list:destroy"] = {
			[20411] = true,
			[169329] = true,
			[169470] = true,
			[174767] = true,
			[154174] = true,
			[174287] = true,
			[34068] = true,
			[29282] = true,
			[117391] = true,
			[169694] = true,
			[12534] = true,
			[174766] = true,
			[174764] = true,
			[174758] = true,
		},
		["rules:sell"] = {
			"sell.poor", -- [1]
			"sell.oldfood", -- [2]
			"sell.knowntoys", -- [3]
			"cr.malvir.lightbringer.1602290239", -- [4]
			"e[pawn.isnotupgrade])", -- [5]
		},
		["profile:timestamp"] = 1623451457,
	},
	["Vendor:16055979470961"] = {
		["rules:sell"] = {
			"sell.poor", -- [1]
			"sell.oldfood", -- [2]
			"sell.knowntoys", -- [3]
			{
				["rule"] = "sell.uncommongear",
				["ITEMLEVEL"] = 81,
				["GOLDVALUE"] = 0,
			}, -- [4]
			{
				["ITEMLEVEL"] = 81,
				["rule"] = "sell.raregear",
			}, -- [5]
			{
				["ITEMLEVEL"] = 81,
				["rule"] = "sell.epicgear",
			}, -- [6]
		},
		["profile:timestamp"] = 1605662694,
		["list:sell"] = {
		},
		["max_items_to_sell"] = false,
		["tooltip_basic"] = true,
		["sell_throttle"] = 1,
		["autorepair"] = true,
		["profile:interface"] = 90001,
		["rules:destroy"] = {
		},
		["guildrepair"] = true,
		["autosell_limit"] = true,
		["throttle_time"] = 0.15,
		["list:keep"] = {
			[65360] = true,
		},
		["profile:default"] = true,
		["profile:name"] = "Default",
		["profile:version"] = 1,
		["tooltip_addrule"] = false,
		["version"] = 2,
		["list:destroy"] = {
			[154891] = true,
		},
		["rules:keep"] = {
			"keep.legendaryandup", -- [1]
			"keep.equipmentset", -- [2]
			"keep.unknownappearance", -- [3]
		},
		["autosell"] = true,
	},
	["Vendor:16055961930542"] = {
		["rules:sell"] = {
		},
		["autosell"] = true,
		["list:sell"] = {
		},
		["max_items_to_sell"] = false,
		["tooltip_basic"] = true,
		["sell_throttle"] = 1,
		["autosell_limit"] = true,
		["rules:destroy"] = {
		},
		["guildrepair"] = true,
		["list:keep"] = {
		},
		["throttle_time"] = 0.15,
		["rules:keep"] = {
			{
				["ITEMLEVEL"] = 0,
				["rule"] = "keep.raregear",
			}, -- [1]
			"e[rulepack.istabard])", -- [2]
			{
				["ITEMLEVEL"] = 0,
				["rule"] = "keep.epicgear",
			}, -- [3]
		},
		["autorepair"] = true,
		["profile:name"] = "Testing Empty",
		["version"] = 2,
		["tooltip_addrule"] = false,
		["profile:version"] = 1,
		["list:destroy"] = {
		},
		["profile:interface"] = 90001,
		["profile:timestamp"] = 1623450706,
	},
}
Vendor_CustomLists = {
	["uid:thoekh:sargeras:1624250099878"] = {
		["Items"] = {
			[181468] = true,
			[33292] = true,
		},
		["Name"] = "Keeper Stuff",
		["Description"] = "Stuff to keep",
	},
}
Vendor_History = {
	["Characters"] = {
		["Khyrek - Lightbringer"] = {
			["Window"] = 1665283066,
			["Entries"] = {
			},
		},
		["Thoekh - Lightbringer"] = {
			["Window"] = 1665283066,
			["Entries"] = {
			},
		},
		["Thoekh - Sargeras"] = {
			["Window"] = 1665283066,
			["Entries"] = {
				{
					["Profile"] = 1,
					["Action"] = 1,
					["TimeStamp"] = 1667874782,
					["Id"] = 62413,
					["Count"] = 1,
					["Rule"] = 1,
					["Value"] = 2121,
				}, -- [1]
				{
					["Profile"] = 1,
					["Action"] = 1,
					["TimeStamp"] = 1667874782,
					["Id"] = 5465,
					["Count"] = 1,
					["Rule"] = 2,
					["Value"] = 3,
				}, -- [2]
				{
					["Profile"] = 1,
					["Action"] = 1,
					["TimeStamp"] = 1667874813,
					["Id"] = 5465,
					["Count"] = 1,
					["Rule"] = 2,
					["Value"] = 3,
				}, -- [3]
				{
					["Profile"] = 1,
					["Action"] = 1,
					["TimeStamp"] = 1667874814,
					["Id"] = 62413,
					["Count"] = 1,
					["Rule"] = 1,
					["Value"] = 2121,
				}, -- [4]
			},
		},
		["Sevirin - Lightbringer"] = {
			["Window"] = 1665283066,
			["Entries"] = {
			},
		},
		["Szarekh - Lightbringer"] = {
			["Window"] = 1665283066,
			["Entries"] = {
			},
		},
		["Malvir - Lightbringer"] = {
			["Window"] = 1665283066,
			["Entries"] = {
			},
		},
	},
	["Rules"] = {
		{
			["Id"] = "sell.poor",
			["Name"] = "Poor Items",
		}, -- [1]
		{
			["Id"] = "cr.szarekh.lightbringer.1623817952",
			["Name"] = "Old Crafting Materials",
		}, -- [2]
	},
	["Version"] = 1,
	["Profiles"] = {
		{
			["Id"] = "Vendor:16238360270086",
			["Name"] = "Thoekh - Sargeras",
		}, -- [1]
	},
}
