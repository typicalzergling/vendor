local AddonName = select(1, ...);
local rulePackDefs =
{
    -- Vendor will check this source is loaded prior to registration.
    -- It will also be displayed in the Vendor UI.
    Source = "RulePack",
    Addon = AddonName,

    -- Rule IDs must be unique. The "Source" will be prefixed to the id.
    Rules =
    {
        {
            Id = "istabard",
            Type = "Keep",
            Name = "Tabards",
            Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
            Description = "Matches tabards, for example: |cff1eff00|Hitem:43154::::::::110:66::::::|h[Tabard of the Argent Crusade]|h|r",
            Script = "IsEquipment and EquipLoc == \"INVTYPE_TABARD\"",
            Order = 1600,
        },
        {
            Id = "craftingreagent",
            Type = "Keep",
            Name = "Crafting Reagents",
            Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
            Description = "Matches all crafting reagent items.",
            Script = "IsCraftingReagent",
            Order = 1500,
        },
        {
            Id = "sidegradeorbetter",
            Type = "Keep",
            Name = "Side-grade or Better",
            Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
            Description = "Matches equipment that is equal to or higher itemlevel than what you have currently equipped.",
            Script = "IsEquipment and (Level >= CurrentEquippedLevel())",
            Order = 1450,
        },
    },
}

-- Register this extension with Vendor.
-- For safety, you should make sure both Vendor and the RegisterExtension method exist before
-- calling, as done below. If not a clean LUA error will be thrown that can be reported back to players.
if (not Vendor.RegisterExtension(rulePackDefs)) then
    -- something went wrong
end
