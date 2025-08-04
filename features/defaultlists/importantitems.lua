local _, Addon = ...

local LIST_ID = Addon.StaticListId.IMPORTANT_ITEMS

-- Definition for important items
local importantItems = {
    Version = 2,
    Name = "LIST_STATIC_IMPORTANT_NAME",      -- Key Name for loc
    Desc = "LIST_STATIC_IMPORTANT_DESC",      -- Key Name for loc
    Id = LIST_ID,
    Items = {
        [9149] = 1,		-- Philosopher's Stone (Alchemy Transmute)
        [13503] = 1,	-- Alchemist Stone (Alchemy Transmute)
        [32757] = 1, 	-- Blessed Medallion of Karabor (Teleport to Black Temple)
        [40110] = 1, 	-- Haunted Memento (creates a ghost, no longer obtainable)
        [44050] = 1,	-- Mastercraft Kalu'ak Fishing Pole (water breathing)
        [44935] = 1, 	-- Ring of the Kirin Tor (teleport to Dalaran)
        [45690] = 1, 	-- Inscribed Ring of the Kirin Tor (teleport to Dalaran)
        [46874] = 1, 	-- Argent Crusdader's Tabard (Teleport to Argent Tournament)
        [48956] = 1, 	-- Etched Ring of the Kirin Tor (teleport to Dalaran)
        [49040] = 1, 	-- Jeeves (Vendor/bank/repair)
        [49888] = 1,	-- Shadow's Edge (Shadowmourne precursor axe)
        [51559] = 1, 	-- Runed Ring of the Kirin Tor (teleport to Dalaran)
        [52251] = 1,	-- Jaina's Locket (Teleport to Dalaran)
        [63206] = 1, 	-- Wrap of Unity (Alliance) (Teleport to Main City)
        [63207] = 2,    -- Wrap of Unity (Horde) (Teleport to Main City)
        [63352] = 1,	-- Shroud of Cooperation (Alliance) (Teleport to Main City)
        [63353] = 2,    -- Shroud of Cooperation (Horde) (Teleport to Main City)
        [65274] = 2,    -- Cloak of Coordination (Horde) (Teleport to Main City)
        [65360] = 1,	-- Cloak of Coordination (Alliance) (Teleport to Main City)
        [109076] = 1,	-- Goblin Glider Kit
        [109262] = 1,	-- Draenic Philosopher's Stone (Required for alch transmute)
        [114943] = 1,	-- Ultimate Gnomish Army Knife (Many tradeskill items, sometimes a res)
        [116916] = 1,	-- Gorepetal's Gentel Grasp (Draenor treasure for improved herbalism)
        [116913] = 1,	-- Peon's Mining Pick (Draenor treasure for improving mining)
        [128353] = 1,	-- Admiral's Compass (Teleport to Garrison Port)
        [132514] = 1, 	-- Autohammer
        [132523] = 1,	-- Reeves Battery (repair)
        [139599] = 1, 	-- Empowered Ring of the Kirin Tor (teleport to Dalaran)	
        [141605] = 1,	-- Flight Master's Whistle (repair)
        [144341] = 1, 	-- Rechargeable Reeves Battery
        [172914] = 1,	-- Gravimetric Scrambler Cannon (Engineering device)
        [183616] = 1, 	-- Accursed Keepsake (creates a ghost, no longer obtainable)
        [188152] = 1, 	-- Gateway Control Shard
        [198247] = 1,	-- Neural Silencer Mk3
        [210816] = 1,	-- Algari Alchemist Stone
        [211495] = 1,	-- Dreambound Augment Rune (DF Reusable augment rune)
        [219222] = 1, 	-- Time Lost Artifact (Teleport to timeless isle)
        [224572] = 1, 	-- Crystallized Augment Rune (TWW Current augment rune)
    }
}

-- This must load after the defaultlists.lua
Addon.Features.DefaultLists:AddList(importantItems);
