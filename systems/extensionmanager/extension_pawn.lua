-- Pawn Extension for Vendor
-- This also doubles as a sample for how to create a Vendor extension with both functions for evaluating, and for adding rules.
local _, Addon = ...


-- Function definition for the Pawn upgrade query.
-- This could be inline in the registration table, but it's external here for better readability.
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


-- This is the registration information for the Vendor addon. It's just a table with some required fields
-- which tell Vendor about the functions and/or rules present, and which Addon to ensure it is loaded.
local function registerPawnExtension()
    local pawnExtension =
    {
        -- Vendor will check this source is loaded prior to registration.
        -- It will also be displayed in the Vendor UI.
        Source = "Pawn",
        Addon = "Pawn",
        Version = 1.0,

        -- These are the set of functions that are being added that all Vendor rules can use.
        -- Players will have access to these functions for their own custom rules.
        -- Function names cannot overwrite built-in Vendor functions.
        -- This is what appears in the "Help" page for View/Edit rule for your functions that are
        -- added. You must add documentation for each function you add.
        -- The actual name of the function will be prefixed by the Source.
        -- For example, this function will be called "Pawn_IsUpgrade()"
        Functions =
        {
            {
                Name="IsUpgrade",
                Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
                Function=isPawnUpgrade,
                Documentation="Checks if the item is an upgrade according to Pawn.",
            },
        },

        -- Rule IDs must be unique. The "Source" will be prefixed to the id.
        Rules =
        {
            {
                Id = "isupgrade",
                Type = "Keep",
                Name = "Pawn - Items that are upgrades",
                Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
                Description = "Any equipment items that the Pawn addon considers an upgrade.",
                Script = "IsEquipment and Pawn_IsUpgrade()",
                Order = 1000,
            },
            {
                Id = "isnotupgrade",
                Type = "Sell",
                Name = "Pawn - Items that are not upgrades",
                Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
                Description = "Any equipment items that are not considered upgrades by the Pawn addon.",
                Script = "IsEquipment and not Pawn_IsUpgrade() and not IsEquipped and not IsUnsellable",
                Order = 1000,
            },
        },
    }

    local extmgr = Addon.Systems.ExtensionManager
    extmgr:AddInternalExtension("Pawn", pawnExtension)
end

registerPawnExtension()

