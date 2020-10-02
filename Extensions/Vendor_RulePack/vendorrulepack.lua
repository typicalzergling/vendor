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
            Description = "Matches tabards, for example: |cff1eff00|Hitem:43154::::::::110:66::::::|h[Tabard of the Argent Crusade]|h|r",
            Script = "IsEquipment and EquipLoc == \"INVTYPE_TABARD\"",
            Order = 1600,
        },
        {
            Id = "craftingreagent",
            Type = "Keep",
            Name = "Crafting Reagents",
            Description = "Matches all crafting reagent items.",
            Script = "IsCraftingReagent",
            Order = 1500,
        },
        {
            Id = "cosmetic",
            Type = "Keep",
            Name = "Keep cosmetic gear ",
            Description = "And gear which is considered cosmetic, for example: |cff1eff00|Hitem:21525:::::::2010962816:110:66::::::|h[Green Winter Hat]|h|r",
            Script = "IsEquipment and SubTypeId == 5",
            Order = 1700,
        },
    },
}

-- Register this extension with Vendor.
-- For safety, you should make sure both Vendor and the RegisterExtension method exist before
-- calling, as done below. If not a clean LUA error will be thrown that can be reported back to players.
if (not Vendor:RegisterExtension(rulePackDefs)) then
    -- something went wrong
end
