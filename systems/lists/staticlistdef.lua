local _, Addon = ...
local L = Addon:GetLocale()
local function debugp(...) Addon:Debug("staticlists", ...) end

local SystemImportantItemsListDefault =
{
	[9149] = true,		-- Philosopher's Stone (Alchemy Transmute)
	[13503] = true,		-- Alchemist Stone (Alchemy Transmute)
	[32757] = true, 	-- Blessed Medallion of Karabor (Teleport to Black Temple)
	[40110] = true, 	-- Haunted Memento (creates a ghost, no longer obtainable)
	[44935] = true, 	-- Ring of the Kirin Tor (teleport to Dalaran)
	[45690] = true, 	-- Inscribed Ring of the Kirin Tor (teleport to Dalaran)
	[46874] = true, 	-- Argent Crusdader's Tabard (Teleport to Argent Tournament)
    [48956] = true, 	-- Etched Ring of the Kirin Tor (teleport to Dalaran)
	[49040] = true, 	-- Jeeves (Vendor/bank/repair)
	[49888] = true,		-- Shadow's Edge (Shadowmourne precursor axe)
    [51559] = true, 	-- Runed Ring of the Kirin Tor (teleport to Dalaran)
	[52251] = true,		-- Jaina's Locket (Teleport to Dalaran)
	[63206] = true, 	-- Wrap of Unity (Teleport to Main City)
	[63352] = true,		-- Shroud of Cooperation (Teleport to Main City)
	[65360] = true,		-- Cloak of Coordination (Teleport to Main City)
	[109076] = true,	-- Goblin Glider Kit
	[109262] = true,	-- Draenic Philosopher's Stone (Required for alch transmute)
	[114943] = true,	-- Ultimate Gnomish Army Knife (Many tradeskill items, sometimes a res)
	[116916] = true,	-- Gorepetal's Gentel Grasp (Draenor treasure for improved herbalism)
	[116913] = true,	-- Peon's Mining Pick (Draenor treasure for improving mining)
	[128353] = true,	-- Admiral's Compass (Teleport to Garrison Port)
	[132514] = true, 	-- Autohammer
	[132523] = true,	-- Reeves Battery (repair)
    [139599] = true, 	-- Empowered Ring of the Kirin Tor (teleport to Dalaran)	
	[141605] = true,	-- Flight Master's Whistle (repair)
	[144341] = true, 	-- Rechargeable Reeves Battery
	[172914] = true,	-- Gravimetric Scrambler Cannon (Engineering device)
	[183616] = true, 	-- Accursed Keepsake (creates a ghost, no longer obtainable)
	[188152] = true, 	-- Gateway Control Shard
	[198247] = true,	-- Neural Silencer Mk3
	[210816] = true,	-- Algari Alchemist Stone
	[211495] = true,	-- Dreambound Augment Rune (DF Reusable augment rune)
	[224572] = true, 	-- Crystallized Augment Rune (TWW Current augment rune)
}

function Addon:SetupImportantItemsList()
	local existing = Addon:GetList(Addon.StaticListId.IMPORTANT_ITEMS)
	if existing then
		debugp("Important Items list already exists, skipping")
		return
	end

	local list = Addon:CreateListStatic(L.LIST_STATIC_IMPORTANT_NAME,
						   				Addon.StaticListId.IMPORTANT_ITEMS,
						   				L.LIST_STATIC_IMPORTANT_DESC)

	-- Items may not exist on the version of the game, so validate each one before adding.
	for itemId, v in pairs(SystemImportantItemsListDefault) do
		list:Add(itemId)
	end

	debugp("Important Items list created.")
end

function Addon:ResetImportantItemsList()
	local existing = Addon:GetList(Addon.StaticListId.IMPORTANT_ITEMS)
	if existing then
		Addon:DeleteList(Addon.StaticListId.IMPORTANT_ITEMS)
		debugp("Important Items list deleted")
	end

	Addon:SetupImportantItemsList();
end


