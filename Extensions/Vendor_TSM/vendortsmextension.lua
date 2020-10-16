-- TSM Extension for Vendor
-- This also doubles as a sample for how to create a Vendor extension with both functions for evaluating, and for adding rules.
local AddonName = select(1, ...);


-- Function definition for the getCustomPriceValue from TSM
local function getCustomPriceValue(customPriceStr)
    assert(TSM_API and TSM_API.ToItemString and TSM_API.IsCustomPriceValid and TSM_API.GetCustomPriceValue)

    if not TSM_API.IsCustomPriceValid(customPriceStr) then
        error("Invalid custom price string for TSM")
    end
    
    -- Items with no data will return nil for a price. We'll convert them to 0 for rule matching.
    local value = TSM_API.GetCustomPriceValue(customPriceStr, TSM_API.ToItemString(Link))
    if not value then
        return 0
    end
    return value
end

-- We factor in the auction house cut here so you can do a simple comparison of value to the vendor price.
local function getMarketPriceValue()
    return getCustomPriceValue("dbmarket * .95")
end

-- Quick test if an item is on the AH
local function isAuctionItem()
    return getCustomPriceValue("dbmarket") > 0
end

-- Function definitions for the various TSM quantity functions
local function getTotalQuantity()
    assert(TSM_API and TSM_API.ToItemString and TSM_API.GetPlayerTotals)
    return TSM_API.GetPlayerTotals(TSM_API.ToItemString(Link))
end

local function getBagQuantity()
    assert(TSM_API and TSM_API.ToItemString and TSM_API.GetBagQuantity)
    return TSM_API.GetBagQuantity(TSM_API.ToItemString(Link))
end

local function getBankQuantity()
    assert(TSM_API and TSM_API.ToItemString and TSM_API.GetBankQuantity)
    return TSM_API.GetBankQuantity(TSM_API.ToItemString(Link))
end

local function getReagentBankQuantity()
    assert(TSM_API and TSM_API.ToItemString and TSM_API.GetReagentBankQuantity)
    return TSM_API.GetReagentBankQuantity(TSM_API.ToItemString(Link))
end

local function getMailQuantity()
    assert(TSM_API and TSM_API.ToItemString and TSM_API.GetMailQuantity)
    return TSM_API.GetMailQuantity(TSM_API.ToItemString(Link))
end

local function getAuctionQuantity()
    assert(TSM_API and TSM_API.ToItemString and TSM_API.GetAuctionQuantity)
    return TSM_API.GetAuctionQuantity(TSM_API.ToItemString(Link))
end

local function getGuildQuantity()
    assert(TSM_API and TSM_API.ToItemString and TSM_API.GetGuildQuantity)
    return TSM_API.GetGuildQuantity(TSM_API.ToItemString(Link))
end


-- This is the registration information for the Vendor addon. It's just a table with some required fields
-- which tell Vendor about the functions and/or rules present, and which Addon to ensure it is loaded.
local function registerTSMExtension()

    local TSMExtension =
    {
        -- Vendor will check this source is loaded prior to registration.
        -- It will also be displayed in the Vendor UI.
        Source = "TSM",
        Addon = AddonName,

        -- These are the set of functions that are being added that all Vendor rules can use.
        -- Players will have access to these functions for their own custom rules.
        -- Function names cannot overwrite built-in Vendor functions.
        -- This is what appears in the "Help" page for View/Edit rule for your functions that are
        -- added. You must add documentation for each function you add.
        -- The actual name of the function will be prefixed by the Source.
        Functions =
        {
            {
                Name="CustomValue",
                Function=getCustomPriceValue,
                Help="Gets the TSM specified custom price value specified. You can specify any TSM price string! See http://support.tradeskillmaster.com for how price strings work.",
            },
            {
                Name="MarketValue",
                Function=getMarketPriceValue,
                Help="This is just a convenient shorthand for the typical TSM 'dbmarket' price factoring in Auction House cut of 5%. In TSM price string terms, this is 'dbmarket * .95'. This is the value you would get if you sold the item at dbmarket on the AH.",
            },
            {
                Name="IsAuctionItem",
                Function=isAuctionItem,
                Help="Evaluates to true if the item has non-zero value to TSM and can therefore be auctioned.",
            },
            {
                Name="TotalQuantity",
                Function=getTotalQuantity,
                Help="Gets the total quantity of an item the player has.",
            },
            {
                Name="BagQuantity",
                Function=getBagQuantity,
                Help="Gets the quantity of an item the player has in their bags.",
            },
            {
                Name="BankQuantity",
                Function=getBankQuantity,
                Help="Gets the quantity of an item the player has in their bank.",
            },
            {
                Name="ReagentBankQuantity",
                Function=getReagentBankQuantity,
                Help="Gets the quantity of an item the player has in their reagent bank.",
            },
            {
                Name="MailQuantity",
                Function=getMailQuantity,
                Help="Gets the quantity of an item the player has in their mailbox.",
            },
            {
                Name="AuctionQuantity",
                Function=getAuctionQuantity,
                Help="Gets the quantity of an item the player has on the auction house.",
            },
            {
                Name="GuildQuantity",
                Function=getGuildQuantity,
                Help="Gets the quantity of an item the player's guild has.",
            },
        },

        -- Rule IDs must be unique. The "Source" will be prefixed to the id.
        Rules =
        {
            {
                Id = "worthauctionvalue",
                Type = "Keep",
                Name = "TSM - Items Worth Auctioning",
                Description = "Any items which have a (Market Value - Vendor Price) greater than the specified amount of Gold. Example: Specifying '10' will keep all items which have a net auction value greater than 10 gold.",
                Script = function()
                    --@do-not-package@
                    -- This will be shown if rules debug is enabled.
                    print("  Param: "..tostring(RULE_PARAMS.GOLDVALUE));
                    print("  Target Value: "..tostring(RULE_PARAMS.GOLDVALUE * 10000));
                    print("  Unit Value: "..tostring((TSM_MarketValue() - UnitValue)));
                    print("  Sale Rate: "..tostring(TSM_CustomValue("dbregionsalerate * 100")));
                    print("  Result: "..tostring((TSM_IsAuctionItem() and (TSM_CustomValue("dbregionsalerate * 100") > 30) and ((TSM_MarketValue() - UnitValue) > (RULE_PARAMS.GOLDVALUE * 10000)))));
                    --@end-do-not-package@
                    return TSM_IsAuctionItem() and (TSM_CustomValue("dbregionsalerate * 100") > 30) and ((TSM_MarketValue() - UnitValue) > (RULE_PARAMS.GOLDVALUE * 10000));
                end,
                ScriptText = "TSM_IsAuctionItem() and (TSM_CustomValue(\"dbregionsalerate * 100\") > 30) and ((TSM_MarketValue() - UnitValue) > ({gold} * 10000))",
                Params =     
                    {
                        {
                            Type="numeric",
                            Name="Gold",
                            Key="GOLDVALUE",
                        },
                    },
                Order = 1100,
            },
        },
    }

    -- Register this extension with Vendor.
    -- For safety, you should make sure both Vendor and the RegisterExtension method exist before
    -- calling, as done below. If not a clean LUA error will be thrown that can be reported back to players.
    assert(Vendor and Vendor.RegisterExtension, "Vendor RegisterExtension not found, cannot register extension: "..tostring(TSMExtension.Source))
    if (not Vendor.RegisterExtension(TSMExtension)) then
        -- something went wrong
    end
end

-- The only function call this addon does.
-- The TOC dependencies ensure this will be loaded after Vendor and TSM.
registerTSMExtension()

