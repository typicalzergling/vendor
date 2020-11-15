local AddonName, Addon = ...
local L = Addon:GetLocale()

local Package = select(2, ...);
Addon.Rules = Addon.Rules or {}
local Rules = Addon.Rules;
local SELL_RULE = Addon.c_RuleType_Sell;
local KEEP_RULE = Addon.c_RuleType_Keep;
local DESTROY_RULE = Addon.c_RuleType_Destroy;
local INTERFACE_VERSION = tonumber(select(4, GetBuildInfo()));
local SHADOWLANDS_VERSION = 90000;

local addon_Functions = {};
local addon_Definitions = {};

-- Define DebugRules if debug files are absent.
if not Addon.DebugRules then
    Addon.DebugRules = function () end
end

-- This is event is fired when our custom rule definitions have changed.
Rules.OnDefinitionsChanged = Addon.CreateEvent("Rules.OnDefinitionChanged");
Rules.OnFunctionsChanged = Addon.CreateEvent("Rules.OnFunctionsChanged");

local function DefaultItemLevel()
    local avg, equip = GetAverageItemLevel();
    return math.max(0, math.floor(math.min(avg, equip) * 0.8));
end

-- Param definition for our rules which use ITEMLEVEL
local ITEM_LEVEL_PARAMS =
{
    {
        Type="numeric",
        Name=L["RULEUI_LABEL_ITEMLEVEL"],
        Key="ITEMLEVEL",
    },
};

Rules.SystemRules =
{
    --*****************************************************************************
    -- Sell Rules
    --*****************************************************************************

    {
        Id = "sell.alwayssell",
        Type = SELL_RULE,
        Name = L["SYSRULE_SELL_ALWAYSSELL"],
        Description = L["SYSRULE_SELL_ALWAYSSELL_DESC"],
        ScriptText = "IsAlwaysSellItem()",
        Script = function() return IsAlwaysSellItem() end,
        Locked = true,
        Order = -2000,
    },

    {
        Id = "sell.poor",
        Type = SELL_RULE,
        Name = L["SYSRULE_SELL_POORITEMS"],
        Description = L["SYSRULE_SELL_POORITEMS_DESC"],
        ScriptText = "Quality == POOR",
        Script = function()
                return Quality == 0;
            end,
        Order = 1000,
    },

    {
        Id = "sell.oldfood",
        Type = SELL_RULE,
        Name = L["SYSRULE_SELL_OLDFOOD"],
        Description = L["SYSRULE_SELL_OLDFOOD_DESC"],
        ScriptText = "TypeId == 0 and SubTypeId == 5 and Level ~= 1 and Level <= (PlayerLevel() - 10)",
        Script = function()
            return (TypeId == 0) and (SubTypeId == 5) and (Level ~= 1) and (Level <= (PlayerLevel() - 10));
        end,
        Order = 1100,
    },

    --@retail@
    {
        Id = "sell.knowntoys",
        Type = SELL_RULE,
        Name = L["SYSRULE_SELL_KNOWNTOYS"],
        Description = L["SYSRULE_SELL_KNOWNTOYS_DESC"],
        ScriptText = "IsSoulbound and IsToy and IsAlreadyKnown",
        Script = function()
                return IsSoulbound and IsToy and IsAlreadyKnown;
            end,
        Order = 1300,
    },

    {
        Id = "sell.uncommongear",
        Type = SELL_RULE,
        Name = L["SYSRULE_SELL_UNCOMMONGEAR"],
        Description = L["SYSRULE_SELL_UNCOMMONGEAR_DESC"],
        ScriptText = "(not IsInEquipmentSet()) and IsEquipment and Quality == UNCOMMON and Level < {itemlevel}",
        Script = function()
                return (not IsInEquipmentSet()) and IsEquipment and (Quality == UNCOMMON) and (Level < RULE_PARAMS.ITEMLEVEL);
            end,
        Params = 
        {
            {
                Key = "ITEMLEVEL",
                Type = "numeric",
                Name = L.RULEUI_SELL_UNCOMMON_INFO,
                Default = DefaultItemLevel,
            }
        },
        Order = 1400,
    },

    {
        Id = "sell.raregear",
        Type = SELL_RULE,
        Name = L["SYSRULE_SELL_RAREGEAR"],
        Description = L["SYSRULE_SELL_RAREGEAR_DESC"],
        ScriptText = "(not IsInEquipmentSet()) and IsEquipment and Quality == RARE and Level < {itemlevel}",
        Script = function()
                return (not IsInEquipmentSet()) and IsEquipment and (Quality == RARE) and (Level < RULE_PARAMS.ITEMLEVEL);
            end,
        Params = 
        {
            {
                Type = "numeric",
                Name = L.RULEUI_SELL_RARE_INFO,
                Key = "ITEMLEVEL",
                Default = DefaultItemLevel,
            }
        },
        Order = 1500,
    },

    {
        Id = "sell.epicgear",
        Type = SELL_RULE,
        Name = L["SYSRULE_SELL_EPICGEAR"],
        Description = L["SYSRULE_SELL_EPICGEAR_DESC"],
        ScriptText = "(not IsInEquipmentSet()) and IsEquipment and IsSoulbound and Quality == EPIC and Level < {itemlevel}",
        Script = function()
                return (not IsInEquipmentSet()) and IsEquipment and IsSoulbound and (Quality == EPIC) and (Level < RULE_PARAMS.ITEMLEVEL);
            end,
        Params = 
        {
            {
                Type = "numeric",
                Key = "ITEMLEVEL",
                Name = L.RULEUI_SELL_EPIC_INFO,
                Default = DefaultItemLevel,
            }
        },
        Order = 1600,
    },
    --@end-retail@
    --[===[@non-retail@
    {
        Id = "sell.uncommongear_classic",
        Type = SELL_RULE,
        Name = L["SYSRULE_SELL_UNCOMMONGEAR"],
        Description = L["SYSRULE_SELL_UNCOMMONGEAR_DESC"],
        ScriptText = "IsEquipment and Quality == UNCOMMON and Level < {itemlevel}",
        Script = function()
                return IsEquipment and (Quality == UNCOMMON) and (Level < RULE_PARAMS.ITEMLEVEL);
            end,
        Params = ITEM_LEVEL_PARAMS,
        Order = 1401,
    },

    {
        Id = "sell.raregear_classic",
        Type = SELL_RULE,
        Name = L["SYSRULE_SELL_RAREGEAR"],
        Description = L["SYSRULE_SELL_RAREGEAR_DESC"],
        ScriptText = "IsEquipment and Quality == RARE and Level < {itemlevel}",
        Script = function()
                return IsEquipment and (Quality == RARE) and (Level < RULE_PARAMS.ITEMLEVEL);
            end,
        Params = ITEM_LEVEL_PARAMS,
        Order = 1501,
    },

    {
        Id = "sell.epicgear_classic",
        Type = SELL_RULE,
        Name = L["SYSRULE_SELL_EPICGEAR"],
        Description = L["SYSRULE_SELL_EPICGEAR_DESC"],
        ScriptText = "IsEquipment and IsSoulbound and Quality == EPIC and Level < {itemlevel}",
        Script = function()
                return IsEquipment and IsSoulbound and (Quality == EPIC) and (Level < RULE_PARAMS.ITEMLEVEL);
            end,
        Params = ITEM_LEVEL_PARAMS,
        Order = 1601,
    },
    --@end-non-retail@]===]

    --*****************************************************************************
    -- Keep Rules
    --*****************************************************************************

    -- Item is in the Never Sell list.
    {
        Id = "keep.neversell",
        Type = KEEP_RULE,
        Name = L["SYSRULE_KEEP_NEVERSELL"],
        Description = L["SYSRULE_KEEP_NEVERSELL_DESC"],
        ScriptText = "IsNeverSellItem()",
        Script = function() return IsNeverSellItem() end,
        Locked = true,
        Order = -3000,
    },

    -- Safeguard rule - Legendary and higher are very rare and should probably never be worthy of a sell rule, but just in case...
    {
        Id = "keep.legendaryandup",
        Type = KEEP_RULE,
        Name = L["SYSRULE_KEEP_LEGENDARYANDUP"],
        Description = L["SYSRULE_KEEP_LEGENDARYANDUP_DESC"],
        ScriptText = "Quality >= 5",
        Script = function() return Quality >= 5; end,
        Order = 1000,
    },

    -- Safeguard rule - Keep soulbound equipment.
    {
        Id = "keep.soulboundgear",
        Type = KEEP_RULE,
        Name = L["SYSRULE_KEEP_SOULBOUNDGEAR"],
        Description = L["SYSRULE_KEEP_SOULBOUNDGEAR_DESC"],
        ScriptText = "IsEquipment and Soulbound",
        Script = function()
                return IsEquipment and IsSoulbound;
            end,
        Order = 1100,
    },

    -- Safeguard rule - Keep BoE Equipment
    {
        Id = "keep.bindonequipgear",
        Type = KEEP_RULE,
        Name = L["SYSRULE_KEEP_BINDONEQUIPGEAR"],
        Description = L["SYSRULE_KEEP_BINDONEQUIPGEAR_DESC"],
        ScriptText = "IsEquipment and IsBindOnEquip",
        Script = function()
                return IsEquipment and IsBindOnEquip;
            end,
        Order = 1150,
    },

    -- Safeguard rule - Protect those transmogs!
    --@retail@
    {
        Id = "keep.unknownappearance",
        Type = KEEP_RULE,
        Name = L["SYSRULE_KEEP_UNKNOWNAPPEARANCE"],
        Description = L["SYSRULE_KEEP_UNKNOWNAPPEARANCE_DESC"],
        ScriptText = "IsUnknownAppearance",
        Script = function() return IsUnknownAppearance end,
        Order = 1200,
    },
    --@end-retail@

    -- Safeguard rule - Common items are usually important and useful.
    {
        Id = "keep.common",
        Type = KEEP_RULE,
        Name = L["SYSRULE_KEEP_COMMON"],
        Description = L["SYSRULE_KEEP_COMMON_DESC"],
        ScriptText = "Quality == 1",
        Script = function() return (Quality == 1) end,
        Order = 1300,
    },

    -- Optional Safeguard - Might be useful for leveling.
    {
        Id = "keep.uncommongear",
        Type = KEEP_RULE,
        Name = L["SYSRULE_KEEP_UNCOMMONGEAR"],
        Description = L["SYSRULE_KEEP_UNCOMMONGEAR_DESC"],
        ScriptText = "IsEquipment and Quality == 2",
        Script = function()
                return IsEquipment and (Quality == 2);
            end,
        Order = 1400,
    },

    -- Optional Safeguard - Might be useful for leveling or early max-level.
    {
        Id = "keep.raregear",
        Type = KEEP_RULE,
        Name = L["SYSRULE_KEEP_RAREGEAR"],
        Description = L["SYSRULE_KEEP_RAREGEAR_DESC"],
        ScriptText = "IsEquipment and Quality == 3",
        Script = function()
                return IsEquipment and (Quality == 3);
            end,
        Order = 1500,
    },

    -- Optional Safeguard - If you're a bit paranoid.
    {
        Id = "keep.epicgear",
        Type = KEEP_RULE,
        Name = L["SYSRULE_KEEP_EPICGEAR"],
        Description = L["SYSRULE_KEEP_EPICGEAR_DESC"],
        ScriptText = "IsEquipment and Quality == 4",
        Script = function()
                return IsEquipment and (Quality == 4);
            end,
        Order = 1600,
    },

    -- Safeguard against selling item sets, even if it matches some
    -- other rule, for example, a fishing or transmog set.
    --@retail@
    {
        Id = "keep.equipmentset",
        Type = KEEP_RULE,
        Name = L["SYSRULE_KEEP_EQUIPMENTSET_NAME"],
        Description = L["SYSRULE_KEEP_EQUIPMENTSET_DESC"],
        ScriptText = "IsInEquipmentSet()",
        Script = function() return IsInEquipmentSet() end,
        Order = 1050,
    },
    --@end-retail@

    --*****************************************************************************
    -- Destroy Rules
    --*****************************************************************************

    -- Item is in the Never Sell list.
    {
        Id = "destroy.alwaysdestroy",
        Type = DESTROY_RULE,
        Name = L["SYSRULE_DESTROYLIST"],
        Description = L["SYSRULE_DESTROYLIST_DESC"],
        ScriptText = "IsInList(\"Destroy\")",
        Script = function() return IsDestroyItem() end,
        Locked = true,
        Order = -1000,
    },
};

-- While creating this closure sort the rules table by order, this prevents us from
-- Having to do it each time we traverse the list.
table.sort(Rules.SystemRules,
    function (ruleA, ruleB)
        assert(tonumber(ruleA.Order), "All system rules must have an order field: " .. ruleA.Id);
        assert(tonumber(ruleB.Order), "All system rules must have an order field: " .. ruleB.Id);
        return (ruleA.Order < ruleB.Order);
    end);


--[[===========================================================================
    | findCustomDefinition (local)
    |   Simple local helper function which finds a custom rule definition
    |   or it returns nil meaning it doesn't exist.
    ========================================================================--]]
local function findCustomDefinition(ruleId)
    if (Vendor_CustomRuleDefinitions) then
        local id = string.lower(ruleId);
        for _, ruleDef in ipairs(Vendor_CustomRuleDefinitions) do
            if (string.lower(ruleDef.Id) == id) then
                return ruleDef;
            end
        end
    end
end

local function findExtensionDefinition(ruleId)
    local id = string.lower(ruleId);
    for _, ruleDef in ipairs(addon_Definitions) do
        if (string.lower(ruleDef.Id) == id) then
            return ruleDef;
        end
    end
end

--[[===========================================================================
    | DeleteDefinition:
    |   This will remove the custom rule definition from the list and fire
    |   the changed event. You can only delete custom definitions, trying
    |   to delete a non-existing rule is a no-op.
    ========================================================================--]]
function Rules.DeleteDefinition(ruleId)
    if (Vendor_CustomRuleDefinitions) then
        local id = string.lower(ruleId);

        for i,ruleDef in ipairs(Vendor_CustomRuleDefinitions) do
            if (string.lower(ruleDef.Id) == id) then
                table.remove(Vendor_CustomRuleDefinitions, i);
                Rules.OnDefinitionsChanged("DELETE", ruleDef.Id);
                break;
            end
        end
    end
end

--[[===========================================================================
    | UpdateDefinition:
    |   This will update the fields which change be changed by the user in
    |   the custom rule definitions, along with maintaining the edit field.
    |
    |   Updating a rule which doesn't yet exist will create a new custom
    |   rule with the specified parameters.
    ========================================================================--]]
function Rules.UpdateDefinition(ruleDef)
    local editedBy = string.format("%s / %s", UnitFullName("player"));
    local custom = findCustomDefinition(ruleDef.Id);
    if (custom) then
        custom.EditedBy = editedBy;
        custom.Name = ruleDef.Name;
        custom.Description = ruleDef.Description;
        custom.Script = ruleDef.Script;
        custom.Type = (ruleDef.Type or SELL_RULE);
        custom.needsMigration = nil;
        custom.interfaceversion = INTERFACE_VERSION;
        Rules.OnDefinitionsChanged("UPDATE", custom.Id);
    else
        Vendor_CustomRuleDefinitions = Vendor_CustomRuleDefinitions or {};
        table.insert(Vendor_CustomRuleDefinitions,
            {
                Id = string.lower(ruleDef.Id),
                Name = ruleDef.Name,
                Script = ruleDef.Script,
                Type = ruleDef.Type or SELL_RULE;
                Description = ruleDef.Description,
                EditedBy = editedBy,
                Custom = true,
                needsMigration = false,
                interfaceversion = INTERFACE_VERSION,
            });
        Rules.OnDefinitionsChanged("CREATE", ruleDef.Id);
    end
end

--[[===========================================================================
    | CheckMigration:
    ========================================================================--]]
function Rules.CheckMigration()
    Addon:Debug("rules", "%s+|r Checking for rule definition migration", YELLOW_FONT_COLOR_CODE);
    if (Vendor_CustomRuleDefinitions) then
        for _, ruleDef in ipairs(Vendor_CustomRuleDefinitions) do
            ruleDef.Locked = false;
            if (not ruleDef.needsMigration) then
                local riv = ruleDef.interfaceversion or 0;
                if ((INTERFACE_VERSION >=SHADOWLANDS_VERSION) and (riv < SHADOWLANDS_VERSION)) then
                    Addon:Debug("rules", "%s| |rrule '%s' needs migration (iv=%s)", GREEN_FONT_COLOR_CODE, ruleDef.Id, riv or "<none>");
                    ruleDef.needsMigration = true;
                end
            end
        end
    end
    Addon:Debug("rules", "+ Completed rule defintion migration");
end

--[[===========================================================================
    | CheckMigration:
    ========================================================================--]]
function Rules.IsExtension(target) 
    local ruleId = target;
    if (type(target) == "table") then
        ruleId = target.Id;
    end

    if (type(ruleId) ~= "string") then
        return false;
    end

    ruleId = string.lower(ruleId);
    if (Package.Extensions) then
        for _, ruleDef in ipairs(Package.Extensions:GetRules(typeFilter)) do
            if (string.lower(ruleDef.Id) == ruleId) then
                return true;
            end
        end
    end

    return false;
end

--[[===========================================================================
    | GetAllDefinitions:
    |   This returns the list of all rule definitions, order the way the
    |   should be presented the user. typeFilter is optional, and only
    |   needed to filter to a single type of rule.
    ========================================================================--]]
function Rules.GetDefinitions(typeFilter)
    local defs = {};

    -- Gather system rules
    for _, ruleDef in ipairs(Rules.SystemRules) do
        if (not ruleDef.Locked and ((not typeFilter) or (ruleDef.Type == typeFilter))) then
            table.insert(defs, ruleDef);
        end
    end

    -- Gather custom rules
    if (Vendor_CustomRuleDefinitions) then
        for _, ruleDef in ipairs(Vendor_CustomRuleDefinitions) do
            if (not typeFilter) or (ruleDef.Type == typeFilter) then
                table.insert(defs, ruleDef);
            end
        end
    end

    -- Gather extensions
    if (Package.Extensions) then
        for _, ruleDef in ipairs(Package.Extensions:GetRules(typeFilter)) do
            ruleDef.Locked = false;
            table.insert(defs, ruleDef);
        end
    end

    return defs;
end

--[[===========================================================================
    | GetDefinition:
    |   Given a rule ID this will return the definition of the rule, this
    |   does not search locked rules, and will also search for a custom rule.
    |
    |   Note: ruleType is optional and is not required.
    ========================================================================--]]
function Rules.GetDefinition(ruleId, ruleType)
    local id = string.lower(ruleId);

    -- Check the system rules.
    for _, ruleDef in ipairs(Rules.SystemRules) do
        if (not ruleDef.Locked) then
            if (string.lower(ruleDef.Id) == id) then
                if ((not ruleType) or (ruleType == ruleDef.Type)) then
                    return ruleDef;
                end
            end
        end
    end

    -- Check the custom rules.
    local custom = findCustomDefinition(id);
    if (custom) then
        if ((not ruleType) or (custom.Type == ruleType)) then
            return custom;
        end
    end

    -- Check for extensions
    if (Package.Extensions) then
        local ext = Package.Extensions:GetRule(id, ruleType);
        if (ext) then
            return ext;
        end
    end

    -- No match
    return nil;
end

--[[===========================================================================
    | GetLockedRules:
    |   This returns the list of locked rules, in priority order from our system
    |   table, users cannot build locked rules so we don't also need to traverse
    |   the custom definitions here.
    ========================================================================--]]
function Rules.GetLockedRules()
    lockedRules = {}
    for _, ruleDef in ipairs(Rules.SystemRules) do
        if (ruleDef.Locked) then
            table.insert(lockedRules, ruleDef);
        end
    end
    return lockedRules
end

--[[===========================================================================
    | GetCustomDefinitions
    |   Returns all of the custom definitions, optionally filtering for
    |   specified type.
    ========================================================================--]]
function Rules.GetCustomDefinitions(filter)
    local defs = {};
    if (Vendor_CustomRuleDefinitions) then
        for _, ruleDef in ipairs(Vendor_CustomRuleDefinitions) do
            if (not filter or (filter == ruleDef.Type)) then
                table.insert(defs, ruleDef);
            end
        end
    end
    return defs;
end
