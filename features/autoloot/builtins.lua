local _, Addon = ...
local CATEGORY_TAKE = Addon.SmartLoot.CATEGORY_TAKE
local CATEGORY_SKIP = Addon.SmartLoot.CATEGORY_SKIP

print("take:::", CATEGORY_TAKE)

Addon.SmartLoot.Category = {

    {
        Name = "Loot",
        Id = CATEGORY_TAKE,
        Description = " [tbd] ",
        Weight = 0
    },

    {
        Name = "Skip",
        Id = CATEGORY_SKIP,
        Description = " [tbd] ",
        Weight = 0
    }
}

Addon.SmartLoot.BuiltinRules = {

    {
        Id = "smartloot.skipjunk",
        Name = "Save 5 Empty",
        Script = function()
            return (FreeSpace <= 5) and (Quality == POOR)
        end,
        Weight = 1,
        Category = CATEGORY_SKIP
    },

    {
        Id = "smartloot.junk",
        Name = "Loot Junk",
        Script = function()
            return (Quality == 0)
        end,
        Weight = 1,
        Category = CATEGORY_TAKE,
    },

    {
        Id = "smartloot.common",
        Name = "Loot Common",
        Script = function()
            return (Quality == 1)
        end,
        Weight = 10,
        Category = CATEGORY_TAKE,
    },

    {
        Id = "smartloot.uncommon",
        Name = "Loot Uncommon",
        Script = function()
            return (Quality == 2)
        end,
        Weight = 100,
        Category = CATEGORY_TAKE,
    },

    {
        Id = "smartloot.rare",
        Name = "Loot Rare",
        Script = function()
            return (Quality == 3)
        end,
        Weight = 1000,
        Category = CATEGORY_TAKE,
    },

    {
        Id = "smartloot.epic",
        Name = "Loot Epic",
        Script = function()
            return (Quality == 4)
        end,
        Weight = 10000,
        Category = CATEGORY_TAKE,
    },

    {
        Id = "smartloot.betterthanepic",
        Name = "Loot Lego+",
        Script = function()
            return (Quality >= 4)
        end,
        Weight = 1000000,
        Category = CATEGORY_TAKE,
    }        
}

Addon.SmartLoot.Functions = {
    CanVendor = function()
        return false;
    end
}