
local function isPawnUpgrade()
    -- Make sure Pawn API hasn't changed
    if not PawnGetItemData or not PawnIsItemAnUpgrade then return false end

    -- Use Pawn as they do in the tooltip handler.
    local Item = PawnGetItemData(Link)
    if not Item then return false end

    -- Get Upgrade Info
    local UpgradeInfo = PawnIsItemAnUpgrade(Item)
    return not not UpgradeInfo
end

local function registerPawnExtension()
    if (not IsAddOnLoaded("Pawn")) then
        return;
    end

    local pawnExtension =
    {
        Source = "Pawn",
       
        Functions = 
        {
            IsPawnUpgrade=isPawnUpgrade,
        },

        Documentation = 
        {
            IsPawnUpgrade = "Checks if the item is an upgraded according the Pawn",
        },

        Rules =
        {
            {
                Id = "pawn.isupgrade",
                Type = "Keep",
                Name = "Pawn Upgrades",
                Description = "Any equipment items that the Pawn addon considers an upgrade.",
                Script = "IsEquipment and IsPawnUpgrade()",
                Order = 1000,
            },        
        },
    }

    Vendor:RegisterExtension(pawnExtension);
end

Vendor:RegisterEvent("PLAYER_ENTERING_WORLD", registerPawnExtension);
