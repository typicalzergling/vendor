local _, Addon = ...

local function isTransmogable()
    if not CanIMogIt or not CanIMogIt.IsTransmogable then error("CanIMogIt IsTransmogable Not Found") end
    return not not CanIMogIt:IsTransmogable(Link)
end

local function playerKnowsTransmogFromItem()
    if not CanIMogIt or not CanIMogIt.PlayerKnowsTransmogFromItem then error("CanIMogIt PlayerKnowsTransmogFromItem Not Found") end
    return not not CanIMogIt:PlayerKnowsTransmogFromItem(Link)
end

local function playerKnowsTransmog()
    if not CanIMogIt or not CanIMogIt.PlayerKnowsTransmog then error("CanIMogIt PlayerKnowsTransmog Not Found") end
    return not not CanIMogIt:PlayerKnowsTransmog(Link)
end

local function isValidAppearanceForCharacter()
    if not CanIMogIt or not CanIMogIt.IsValidAppearanceForCharacter then error("CanIMogIt IsValidAppearanceForCharacter Not Found") end
    return not not CanIMogIt:IsValidAppearanceForCharacter(Link)
end

local function characterCanLearnTransmog()
    if not CanIMogIt or not CanIMogIt.CharacterCanLearnTransmog then error("CanIMogIt CharacterCanLearnTransmog Not Found") end
    return not not CanIMogIt:CharacterCanLearnTransmog(Link)
end



-- This is the registration information for the Vendor addon. It's just a table with some required fields
-- which tell Vendor about the functions and/or rules present, and which Addon to ensure it is loaded.
local function registerCIMIExtension()
    local canIMogItExtension =
    {
        -- Vendor will check this source is loaded prior to registration.
        -- It will also be displayed in the Vendor UI.
        Source = "CIMI",
        Addon = "CanIMogIt",
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
                Name="IsTransmogable",
                Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
                Function=isTransmogable,
                Documentation="Returns true if CanIMogIt determines it is Transmogable.",
            },
            {
                Name="PlayerKnowsTransmogFromItem",
                Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
                Function=playerKnowsTransmogFromItem,
                Documentation="Returns true if CanIMogIt determines the player knows the transmog from this specific item.",
            },
            {
                Name="PlayerKnowsTransmog",
                Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
                Function=playerKnowsTransmog,
                Documentation="Returns true if CanIMogIt determines the player knows the transmog. This is likely the most useful function to use for Transmog collecting.",
            },
            {
                Name="CharacterCanLearnTransmog",
                Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
                Function=characterCanLearnTransmog,
                Documentation="Returns true if CanIMogIt determines the character can learn the transmog.",
            },
        },

        -- Rule IDs must be unique. The "Source" will be prefixed to the id.
        Rules =
        {
            {
                Id = "unknowntransmog",
                Type = "Keep",
                Name = "CanIMogIt - Unknown Transmogs",
                Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
                Description = "Non-soulbound gear that is transmogable and has a transmog which the player does not know. Uses CanIMogIt APIs for determining transmog status.",
                Script = "not IsSoulbound and CIMI_IsTransmogable() and not CIMI_PlayerKnowsTransmog()",
                Order = 1000,
            },
        },
    }

    local extmgr = Addon.Systems.ExtensionManager
    extmgr:AddInternalExtension("CanIMogIt", canIMogItExtension)
end

registerCIMIExtension()

