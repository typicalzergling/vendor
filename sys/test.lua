-- Sets up running functional tests.

local AddonName, Addon = ...

local testlist = {}

-- Test Format:
-- {
--      Name,
--      Category,
--      Func,
-- }
function Addon:AddTest(name, category, setup, exec, cleanup)
    assert(type(name == "string"))
    assert(type(category == "string"))
    assert(not setup or type(exec == "function"))
    assert(not cleanup or type(cleanup == "function"))
    assert(type(exec == "function"))
    local test = {}
    test.Name = name
    test.Category = category
    test.Exec = exec
    test.Setup = setup
    test.Cleanup = cleanup
    table.insert(testlist, test)
    self:Debug("default", "Added Test: %s", test.Name)
end

-- Persisted list of failures
local failures = {}
local function addFailure(name, category, step, msg)
    assert(type(name == "string"))
    assert(type(category == "string"))
    assert(type(step == "string") and (step == "Setup" or step == "Cleanup" or step == "Execution"))
    assert(type(msg == "string"))
    failure = {}
    failure.Name = name
    failure.Category = category
    failure.Step = step
    failure.Error = msg
    table.insert(failures, failure)
end

local function printFailedTests()
    if #failures == 0 then
        Addon:Print("All tests passed!")
        return
    end

    Addon:Print("Failed Tests:")
    for _, fail in pairs(failures) do
        Addon:Print("  [%s][%s] %s: %s", fail.Category, fail.Step, fail.Name, fail.Error)
    end
end

-- Runs a test function, logs failures, and returns success state.
local function runTestFunction(test, step)
    assert(test and type(test) == "table" and step)

    local func = nil
    if step == "Setup" then
        func = test.Setup
    elseif step == "Cleanup" then
        func = test.Cleanup
    else
        func = test.Exec
    end

    -- Setup and Cleanup can be nil
    if not func then return true end

    -- pcall the function
    local success, msg = pcall(func)
    if success then return true end
    addFailure(test.Name, test.Category, step, msg)
    return false
end

local function runTest(test)
    Addon:Print("Running [%s] %s...", test.Category, test.Name)

    -- Run test setup (if this fails we will abort the entire test run but still run cleanup.
    local setupSuccess = runTestFunction(test, "Setup")
    if not setupSuccess then
        Addon:Print("[%s] %s Setup failed! Not executing remainder of test.", test.Category, test.Name)        
    end

    -- Run main execution if setup succeeded.
    local execStatus = false
    if setupSuccess then
        execSuccess = runTestFunction(test, "Execution")
    end
    if setupSuccess and not execSuccess then
        Addon:Print("[%s] %s failed!", test.Category, test.Name)
    end

    -- Always run cleanup
    if not runTestFunction(test, "Cleanup") then
        Addon:Print("[%s] %s Cleanup failed! Addon may be in a bad state!", test.Category, test.Name)
        return false
    end

    return not not execSuccess
end

local function runTests()
    local testCount = 0
    local failCount = 0
    failures = {}

    -- Sort the tests by category
    table.sort(testlist, function (a, b) return a.Category < b.Category end)

    Addon:Print("Beginning running tests...")
    for _, test in pairs(testlist) do
        testCount = testCount + 1
        local success = runTest(test)
        if not success then
            failCount = failCount + 1
        end
    end

    -- Sort the failures by category
    table.sort(failures, function (a, b) return a.Category < b.Category end)

    Addon:Print("Finished running %s tests. %s Passed, %s Failed.", tostring(testCount), tostring(testCount - failCount), tostring(failCount))
    printFailedTests()
end

function Addon:SetupTestConsoleCommands()
    self:AddConsoleCommand("test", "It is a mystery!", "Test_Cmd")
    self:AddConsoleCommand("runtests", "Runs all functional tests.", "RunTests_Cmd")
    self:AddConsoleCommand("testfailures", "Re-prints test failures from the last test run.", "TestFailures_Cmd")
end

function Addon:RunTests_Cmd()
    runTests()
end

function Addon:TestFailures_Cmd()
    printFailedTests()
end

function Addon:Test_Cmd(...)
    Addon:RemoveInvalidEntriesFromAllBlocklists()
end

-- Basic test harness tests.
Addon:AddTest(
    "Add Tests",
    "Test", 
    function () Addon:Debug("default", "In Setup") end,
    function () Addon:Debug("default", "In Execution") end,
    function () Addon:Debug("default", "In Cleanup") end) 

Addon:AddTest(
    "Fail Setup",
    "Test", 
    function () error("Setup failed") end,
    function () Addon:Debug("default", "In Execution") end,
    function () Addon:Debug("default", "In Cleanup") end) 

Addon:AddTest(
    "Fail Execution",
    "Test", 
    function () Addon:Debug("default", "In Setup") end,
    function () error("Execution failed") end,
    function () Addon:Debug("default", "In Cleanup") end) 

Addon:AddTest(
    "Fail Cleanup",
    "Test", 
    function () Addon:Debug("default", "In Setup") end,
    function () Addon:Debug("default", "In Execution") end,
    function () error("Cleanup failed") end) 

Addon:AddTest(
    "Fail Execution & Cleanup",
    "Test", 
    function () Addon:Debug("default", "In Setup") end,
    function () error("Execution failed") end,
    function () error("Cleanup failed") end) 

Addon:AddTest(
    "Test Nil Cleanup",
    "Test", 
    nil,
    Addon:Debug("default", "In Execution"),
    nil) 