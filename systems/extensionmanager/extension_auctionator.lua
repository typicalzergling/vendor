-- Auctionator Extension for Vendor
-- This also doubles as a sample for how to create a Vendor extension with both functions for evaluating, and for adding rules.
local AddonName, Addon = ...
local L = Addon:GetLocale()
local COPPER_PER_GOLD = 10000

local function getAuctionValue()
    -- This accounts for nil (no auction value) and the Auction House Cut of 5%.
    -- This is the value you will get for selling this item.
    assert(Auctionator and Auctionator.API and Auctionator.API.v1 and Auctionator.API.v1.GetAuctionPriceByItemLink)
    return (Auctionator.API.v1.GetAuctionPriceByItemLink(AddonName, Link) or 0) * .95
end

local function isAuctionItem()
    -- This accounts for nil (no auction value) and the Auction House Cut of 5%.
    -- This is the value you will get for selling this item.
    return getAuctionValue() > 0
end

local function getAuctionProfit()
    -- This is the total profit gained over auctioning the item instead of vendoring it.
    -- Does not account for relisting fees!
    -- Deposit is 15% vendor price per 12 hours.
    return math.max(0, (getAuctionValue() - UnitValue ) / COPPER_PER_GOLD)
end

local function getAuctionRatio()
    -- This is the ratio of auction value - unit price / unit price.
    return (getAuctionValue() - UnitValue) / UnitValue
end

-- This is the registration information for the Vendor addon. It's just a table with some required fields
-- which tell Vendor about the functions and/or rules present, and which Addon to ensure it is loaded.
local function registerAuctionatorExtension()

    local AuctionatorExtension =
    {
        -- Vendor will check this source is loaded prior to registration.
        -- It will also be displayed in the Vendor UI.
        Source = "Auc",
        Addon = "Auctionator",
        Version = 1.0,

        -- These are the set of functions that are being added that all Vendor rules can use.
        -- Players will have access to these functions for their own custom rules.
        -- Function names cannot overwrite built-in Vendor functions.
        -- This is what appears in the "Help" page for View/Edit rule for your functions that are
        -- added. You must add documentation for each function you add.
        -- The actual name of the function will be prefixed by the Source.
        Functions =
        {
            {
                Name="IsAuctionItem",
                Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
                Function=isAuctionItem,
                Documentation=L.EXT_AUCTIONATOR_FUNC_ISAUCTIONITEM,
            },
            {
                Name="AuctionValue",
                Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
                Function=getAuctionValue,
                Documentation=L.EXT_AUCTIONATOR_FUNC_AUCTIONVALUE,
            },
            {
                Name="AuctionProfit",
                Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
                Function=getAuctionProfit,
                Documentation=L.EXT_AUCTIONATOR_FUNC_AUCTIONPROFIT,
            },
            {
                Name="AuctionRatio",
                Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
                Function=getAuctionRatio,
                Documentation=L.EXT_AUCTIONATOR_FUNC_AUCTIONRATIO,
            },
        },

        Rules =
        {
            -- Keep Rule for items that are more valuable and worth the time/effort to auction instead of vendor.
            {
                Id = "keepforauction",
                Type = "Keep",
                Name = L.EXT_AUCTIONATOR_RULENAME_KEEPFORAUCTION,
                Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
                Description = L.EXT_AUCTIONATOR_RULEDESC_KEEPFORAUCTION,
                Script = function()
                    return not IsSoulbound and not IsWarbound and (Auc_AuctionProfit() > MIN_AUCTIONPROFIT) and (Auc_AuctionRatio() > MIN_AUCTIONRATIO)
                end,
                ScriptText = "not IsSoulbound and not IsWarbound and (Auc_AuctionProfit() > MIN_AUCTIONPROFIT) and (Auc_AuctionRatio() > MIN_AUCTIONRATIO)",
                Params = {
                        {
                            Type="numeric",
                            Name=L.EXT_AUCTIONATOR_RULEPARAM_MINAUCTIONPROFIT,
                            Key="MIN_AUCTIONPROFIT",
                            Default = 10,
                        },
                        {
                            Type="numeric",
                            Name=L.EXT_AUCTIONATOR_RULEPARAM_MINAUCTIONRATIO,
                            Key="MIN_AUCTIONRATIO",
                            Default = 5,
                        },
                    },
                Order = 5000,
            },
        },
    }

    local extmgr = Addon.Systems.ExtensionManager
    extmgr:AddInternalExtension("Auctionator", AuctionatorExtension)
end

-- The only function call this addon does.
-- The TOC dependencies ensure this will be loaded after Vendor and TSM.
registerAuctionatorExtension()

