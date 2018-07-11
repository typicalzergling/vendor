
Vendor = Vendor or {}
local L = Vendor:GetLocalizedStrings()

Vendor.SystemRules = 
{
    --*****************************************************************************
    -- 
    -- 
    --*****************************************************************************
    Sell = 
    {
        junk = 
        {
            Name = L["SYSRULE_SELL_JUNK"],
            Description = L["SYSRULE_SELL_JUNK_DESC"],
            Script = "Quality() == 0",
        },

        alwayssell = 
        {
            Name = L["SYSRULE_SELL_ALWAYSSELL"],
            Description = L["SYSRULE_SELL_ALWAYSSELL_DESC"],
            Script = "IsAlwaysSellItem()",
            Locked = true,
        },

        artifactpower =
        {
            Name = L["SYSRULE_SELL_ARTIFACTPOWER"],
            Description = L["SYSRULE_SELL_ARTIFACTPOWER_DESC"],
            Script = "IsArtifactPower() and IsFromExpansion(6) and (PlayerLevel() >= 110)",
        },      
                
        uncommon =
        {
            Name = L["SYSRULE_SELL_UNCOMMON_ITEMS"],
            Description = L["SYSRULE_SELL_UNCOMMON_ITEMS_DESC"],
            Script = "IsSoulbound() and ItemType(2, 4) and Quality() == 2 and Level() < {itemlevel}",
            InsetsNeeded = { "itemlevel" },
        },
        
        rare =
        {
            Name = L["SYSRULE_SELL_RARE_ITEMS"],
            Description = L["SYSRULE_SELL_RARE_ITEMS_DESC"],
            Script = "IsSoulbound() and ItemType(2, 4) and Quality() == 3 and Level() < {itemlevel}",
            InsetsNeeded = { "itemlevel" },
        },

        epic =
        {
            Name = L["SYSRULE_SELL_EPIC_ITEMS"],
            Description = L["SYSRULE_SELL_EPIC_ITEMS_DESC"],
            Script = "IsSoulbound() and ItemType(2, 4) and Quality() == 4 and Level() < {itemlevel}",
            InsetsNeeded = { "itemlevel" },
        },
    },

    --*****************************************************************************
    -- 
    -- 
    --*****************************************************************************
    Keep =
    {
        neversell =
        {
            Name = L["SYSRULE_KEEP_NEVERSELL"],
            Description = L["SYSRULE_KEEP_NEVERSELL_DESC"],
            Script = "IsNeverSellItem()",
            Locked = true,
        },  

        common =
        {
            Name = L["SYSRULE_KEEP_COMMON"],
            Description = L["SYSRULE_KEEP_COMMON_DESC"],
            Script = "Quality() == 1",
        },

        uncommon =
        {
            Name = L["SYSRULE_KEEP_UNCOMMON"],
            Description = L["SYSRULE_KEEP_UNCOMMON_DESC"],
            Script = "Quality() == 2",
        },

        rare =
        {
            Name = L["SYSRULE_KEEP_RARE"],
            Description = L["SYSRULE_KEEP_RARE_DESC"],
            Script = "Quality() == 3",
        },

        epic =
        {
            Name = L["SYSRULE_KEEP_EPIC"],
            Description = L["SYSRULE_KEEP_EPIC_DESC"],
            Script = "Quality() == 4",
        },

        legendary =
        {
            Name = L["SYSRULE_KEEP_LEGENDARY"],
            Description = L["SYSRULE_KEEP_LEGENDARY_DESC"],
            Script = "Quality() == 5",
        },

        artifact =
        {
            Name = L["SYSRULE_KEEP_ARTIFACT"],
            Description = L["SYSRULE_KEEP_ARTIFACT_DESC"],
            Script = "Quality() == 6",
        },

        heirloom =
        {
            Name = L["SYSRULE_KEEP_HEIRLOOM"],
            Description = L["SYSRULE_KEEP_HEIRLOOM_DESC"],
            Script = "Quality() == 7",
        },

        token =
        {
            Name = L["SYSRULE_KEEP_TOKEN"],
            Description = L["SYSRULE_KEEP_TOKEN_DESC"],         
            Script = "Quality() == 8",
        },

        unknownapperence =
        {
            Name = L["SYSRULE_KEEP_UNKNOWNAPPERANCE"],
            Description = L["SYSRULE_KEEP_UNKNOWNAPPERANCE_DESC"],
            Script = "IsBindOnEquip() and IsUnknownAppearance()",   
        },
    }
}

--*****************************************************************************
-- Gets the rule definitions of the specified type,or returns an empty 
-- table if there aren't any available.
--*****************************************************************************
local function getSystemRuleDefinitons(ruleType)
    return Vendor.SystemRules[ruleType] or {}
end

--*****************************************************************************
-- Subsitutes every instance of "{inset}" with the value specified by 
-- insetValue as a string.
--*****************************************************************************
local function replaceInset(source, inset, insetValue)
    local searchTerm = string.format("{%s}", string.lower(inset))
    local replaceValue = tostring(insetValue)
    return string.gsub(source, searchTerm, replaceValue)
end

--*****************************************************************************
-- Executes a subsitution on all the values within the "insets" table, this table
-- can be null or empty.
--*****************************************************************************
local function replaceInsets(source, insets)
    if (Vendor:TableSize(insets) ~= 0) then
        for inset, value in pairs(insets) do
            source = replaceInset(source, inset, value)
        end
    end
    return source
end

--*****************************************************************************
-- Creates a new id using the rule type and id which is uniuqe for the 
-- given set of insets.  
--
-- Example: makeRuleId("Sell", "Epic", { itemlevel=700 })
--           creates the following "sell.epic(itemlevel:700)"
--*****************************************************************************
local function makeRuleId(ruleType, ruleId, insets)
    local id = string.format("%s.%s", string.lower(ruleType), string.lower(ruleId))
    if (Vendor:TableSize(insets) ~= 0) then
        for inset, value in pairs(insets) do
            if (string.lower(ruleId) ~= string.lower(value)) then
                id  = (id .. string.format("(%s:%s)", string.lower(inset), tostring(value)))
            end
        end
    end
    return id
end

--*****************************************************************************
-- Creates an instance of the rule from the specified definition
--*****************************************************************************
local function createRuleFromDefinition(ruleType, ruleId, ruleDef, insets)
    return {
                Id = makeRuleId(ruleType, ruleId, insets),
                Name =  ruleDef.Name,
                Description = ruleDef.Description,
                Script = replaceInsets(ruleDef.Script, insets),
                InsetsNeeded = ruleDef.InsetsNeeded,
                Locked = ruleDef.Locked,
            }
end

--*****************************************************************************
-- Gets the definition of the specified rule checking the tables of rules 
-- returns the id and the script of the rule. this will format the item level
-- into the rule of needed.
--
-- insets is an optional parameter which is a table of items which shuold
-- be formated into both the ruleId and script.
--*****************************************************************************
function Vendor:GetSystemRuleDefinition(ruleType, ruleId, insets)
    local ruleDef = getSystemRuleDefinitons(ruleType)[string.lower(ruleId)]
    if (ruleDef ~= nil) then
        return createRuleFromDefinition(ruleType, ruleId, ruleDef, insets)
    end
    return nil
end

--*****************************************************************************
--  Gets the list of system rules which are considered locked, meaning they
-- cannot be added/removed by the user as part of the config.
--*****************************************************************************
function Vendor:GetLockedSystemRules(ruleType, insets)
    lockedRules = {}
    for ruleId, ruleDef in pairs(getSystemRuleDefinitons(ruleType)) do
        if (ruleDef.Locked) then
            table.insert(lockedRules, createRuleFromDefinition(ruleType, ruleId, ruleDef, insets))
        end
    end
    return lockedRules
end
