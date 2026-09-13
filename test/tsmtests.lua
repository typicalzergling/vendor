-- Standalone regression tests. Run from the repository root with Lua 5.1:
-- lua test/tsmtests.lua
-- These mocks model TSM's public API: custom results are rounded to whole
-- copper, and a rounded zero (or missing data) is returned as nil.
local functions = {}
local addon = {
    Systems = {
        ExtensionManager = {
            AddInternalExtension = function(_, name, extension)
                assert(name == "TradeSkillMaster")
                for _, entry in ipairs(extension.Functions) do
                    functions[entry.Name] = entry.Function
                end
            end,
        },
    },
}
assert(loadfile("systems/extensionmanager/extension_tsm.lua"))("Vendor", addon)

local itemString = "i:15250::1705"
local itemLink = "|cff1eff00|Hitem:15250::::::::80:72::::::|h[Boneslasher]|h|r"
local sources = {}
local priceCalls = 0
local valid = true
Link = itemLink
TSM_API = {
    IsCustomPriceValid = function()
        return valid
    end,
    ToItemString = function(link)
        assert(link == itemLink, "Must convert the item's full link")
        return itemString
    end,
    GetCustomPriceValue = function(expression, item)
        assert(item == itemString, "Must retain the item's specific variant")
        priceCalls = priceCalls + 1
        -- The cases below use the arithmetic subset shared by Lua and TSM.
        -- A missing source invalidates the expression, as it does in TSM.
        local evaluate = assert(loadstring("return " .. expression))
        setfenv(evaluate, sources)
        local success, value = pcall(evaluate)
        if not success or value == nil then
            return nil
        end
        value = math.floor(value + 0.5)
        return value > 0 and value or nil
    end,
}

local cases = {
    { name = "small sale rate", expression = "dbregionsalerate", rate = 0.003, expected = 0.003 },
    { name = "sale rate as percent", expression = "dbregionsalerate * 100", rate = 0.003, expected = 0.3 },
    { name = "rate above rounding midpoint", expression = "dbregionsalerate", rate = 0.6, expected = 0.6 },
    { name = "four decimal places", expression = "dbregionsalerate", rate = 0.0001, expected = 0.0001 },
    { name = "fraction above one", expression = "dbregionsalerate * 100", rate = 0.1234, expected = 12.34 },
    { name = "zero rate", expression = "dbregionsalerate", rate = 0, expected = 0 },
    { name = "missing rate", expression = "dbregionsalerate", expected = 0 },
    { name = "missing rate in expression", expression = "dbregionsalerate * 100", expected = 0 },
    { name = "market value retains copper units", expression = "dbregionmarketavg", market = 1490000000, expected = 1490000000 },
    { name = "large market value", expression = "dbregionmarketavg", market = 99999999999, expected = 99999999999 },
    { name = "scale entire sum", expression = "dbregionsalerate + 1", rate = 0.003, expected = 1.003 },
    { name = "scale entire difference", expression = "1 - dbregionsalerate", rate = 0.003, expected = 0.997 },
    { name = "mixed price and rate", expression = "dbregionmarketavg * dbregionsalerate", market = 1490000000, rate = 0.003, expected = 4470000 },
}

local passed = 0
for _, case in ipairs(cases) do
    sources = { dbregionsalerate = case.rate, dbregionmarketavg = case.market }
    priceCalls = 0
    local actual = functions.CustomValue(case.expression)
    assert(math.abs(actual - case.expected) < 0.0000001,
        case.name .. ": expected " .. case.expected .. ", got " .. actual)
    assert(priceCalls == 1, case.name .. ": expected one lookup")
    passed = passed + 1
end

-- Invalid user expressions must still fail validation before a price lookup.
valid = false
priceCalls = 0
local success, message = pcall(functions.CustomValue, "invalid(")
assert(not success and string.find(message, "Invalid custom price string for TSM", 1, true))
assert(priceCalls == 0)
valid = true
passed = passed + 1

-- Convenience functions share this evaluator and must keep their documented units.
sources = { dbmarket = 20000 }
assert(functions.MarketValue() == 19000)
assert(functions.IsAuctionItem() == true)
sources = {}
assert(functions.MarketValue() == 0)
assert(functions.IsAuctionItem() == false)
passed = passed + 1

print("Passed " .. passed .. " TSM regression tests")
