-- Sets up running functional tests.

local AddonName, Addon = ...

local testCategory = "Blocklists"

-- Should copy existing blocklist out, clear it, and then restore when test is done.

local always_sell_original = {}
local never_sell_original = {}
local function testSetup()
    
    -- Copy out existing blocklist entries
    always_sell_original = {}
    never_sell_original = {}
    
    --always_sell_original = Addon.DeepTableCopy



    -- Clear the blocklist
end

local function testCleanup()

end

local function testInvalidEntry()
    assert(Addon:GetList(Addon.c_AlwaysSellList))
end

