local AddonName, Addon = ...

local testCategory = "TSM"

-- TSM has no data for an item and TSM_CustomValue reports that as 0, so a rule
-- cannot tell no data apart from a real zero. TSM_HasCustomValue can.

local saved_tsm_api
local item_link = "|cff1eff00|Hitem:15250::::::::80:72::::::|h[Test Item]|h|r"

-- What TSM reports for the item. Nil means TSM has no data for it.
local tsm_result

local function testSetup()
    saved_tsm_api = _G.TSM_API
    _G.Link = item_link

    _G.TSM_API =
    {
        IsCustomPriceValid = function(str) return type(str) == "string" and string.len(str) > 0 end,
        ToItemString = function() return "i:15250::1705" end,
        GetCustomPriceValue = function() return tsm_result end,
    }

    tsm_result = nil
end

local function testCleanup()
    _G.TSM_API = saved_tsm_api
    tsm_result = nil
end

local function getFunctions()
    return Addon:GetRuleFunctions()
end

local function evaluateRule(script)
    local engine = Addon:CreateRulesEngine()
    engine:RemoveCategory(1)
    engine:CreateCategory(1, "<test>")
    engine:AddRule(1, { Id = "tsmvaluetest", Name = "tsmvaluetest", Script = script })
    return engine:Evaluate({ Name = "Test Item", Link = item_link })
end

local guardedRule = 'TSM_HasCustomValue("dbregionsalerate") and TSM_CustomValue("dbregionsalerate") < 0.05'
local unguardedRule = 'TSM_CustomValue("dbregionsalerate") < 0.05'

Addon:AddTest(
    "Missing Value Is Zero",
    testCategory,
    testSetup,
    function ()
        local functions = getFunctions()
        tsm_result = nil
        assert(functions.TSM_CustomValue("dbregionsalerate") == 0, "Missing value must stay zero")
        assert(functions.TSM_HasCustomValue("dbregionsalerate") == false, "Missing value must report no data")
    end,
    testCleanup)

Addon:AddTest(
    "Zero Value Has Data",
    testCategory,
    testSetup,
    function ()
        local functions = getFunctions()
        tsm_result = 0
        assert(functions.TSM_CustomValue("dbregionsalerate") == 0, "Zero value must be zero")
        assert(functions.TSM_HasCustomValue("dbregionsalerate") == true, "Zero value must report data")
    end,
    testCleanup)

Addon:AddTest(
    "Positive Value Has Data",
    testCategory,
    testSetup,
    function ()
        local functions = getFunctions()
        tsm_result = 6711
        assert(functions.TSM_CustomValue("dbregionsaleavg") == 6711, "Positive value must pass through")
        assert(functions.TSM_HasCustomValue("dbregionsaleavg") == true, "Positive value must report data")
    end,
    testCleanup)

Addon:AddTest(
    "Negative Value Has Data",
    testCategory,
    testSetup,
    function ()
        local functions = getFunctions()
        tsm_result = -2289
        assert(functions.TSM_CustomValue("dbregionsaleavg") == -2289, "Negative value must pass through")
        assert(functions.TSM_HasCustomValue("dbregionsaleavg") == true, "Negative value must report data")
    end,
    testCleanup)

Addon:AddTest(
    "Invalid Price String Raises",
    testCategory,
    testSetup,
    function ()
        local functions = getFunctions()
        assert(not pcall(functions.TSM_CustomValue, ""), "Invalid price string must raise")
        assert(not pcall(functions.TSM_HasCustomValue, ""), "Invalid price string must raise")
    end,
    testCleanup)

Addon:AddTest(
    "Guarded Rule Needs Data",
    testCategory,
    testSetup,
    function ()
        local cases =
        {
            { result = nil, expected = false },
            { result = 0, expected = true },
            { result = 0.017, expected = true },
            { result = 0.05, expected = false },
            { result = 0.445, expected = false },
        }

        for _, case in ipairs(cases) do
            tsm_result = case.result
            assert(evaluateRule(guardedRule) == case.expected,
                "Guarded rule was wrong for a value of " .. tostring(case.result))
        end
    end,
    testCleanup)

Addon:AddTest(
    "Unguarded Rule Matches Missing Data",
    testCategory,
    testSetup,
    function ()
        tsm_result = nil
        assert(evaluateRule(unguardedRule) == true, "Unguarded rule behaviour must not change")
    end,
    testCleanup)