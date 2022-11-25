-- Oribos Exchange Extension for Vendor
local AddonName = select(1, ...);

local function baseMarketInfo(item, key)
    assert(item and key, string.format("Invalid input to baseMarketInfo. Item: %s  Key: %s", tostring(item), tostring(key)))
    assert(OEMarketInfo, "OEMarketInfo is missing, should have detected that before now")
    local result = OEMarketInfo(item)
    if not result or type(result) ~= "table" then return -1 end
    if not result['input'] == item then return -1 end
    if not result[key] then return -1 end
    return result[key]
end

local function market()
    return baseMarketInfo(Link, "market")
end

local function region()
    return baseMarketInfo(Link, "region")
end

local function days()
    return baseMarketInfo(Link, "days")
end

local function age()
    return baseMarketInfo(Link, "age")
end

local function registerOEExtension()
    local oeExtension =
    {
        -- Vendor will check this source is loaded prior to registration.
        -- It will also be displayed in the Vendor UI.
        Source = "OE",
        Addon = AddonName,

        Functions =
        {
            {
                Name="Market",
                Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
                Function=market,
                Documentation="Oribos Exchange Market (usually Realm) price for the item, in copper",
            },
            {
                Name="Region",
                Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
                Function=region,
                Documentation="Oribos Exchange Region price for the item, in copper",
            },
            {
                Name="Days",
                Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
                Function=days,
                Documentation="Oribos Exchange number of days since the item was last seen in the AH. 0-250 are days. 251 is > 250 days. 252 is unlimited quantity by vendors.",
            },
            {
                Name="Age",
                Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
                Function=age,
                Documentation=[[Oribos Exchange number of seconds since the data was compiled.
                                Useful if you want to add a stale-data safeguard in a rule.
                                
                                # Example

                                > OE_Age() < 72*60*60]],
            },
        },

        -- Rule IDs must be unique. The "Source" will be prefixed to the id.
        Rules =
        {
        },
    }

    -- Register this extension with Vendor.
    -- For safety, you should make sure both Vendor and the RegisterExtension method exist before
    -- calling, as done below. If not a clean LUA error will be thrown that can be reported back to players.
    assert(Vendor and Vendor.RegisterExtension, "Vendor RegisterExtension not found, cannot register extension: "..tostring(oeExtension.Source))
    if (not Vendor.RegisterExtension(oeExtension)) then
        -- something went wrong
    end
end

-- The TOC dependencies ensure this will be loaded after Vendor and OribosExchange.
registerOEExtension()

