local AddonName, Addon = ...
local L = Addon:GetLocale()

local Package = select(2, ...);
Addon.Rules = Addon.Rules or {}
local Rules = Addon.Rules;
local SELL_RULE = Addon.RuleType.SELL;
local KEEP_RULE = Addon.RuleType.KEEP;
local DESTROY_RULE = Addon.RuleType.DESTROY;
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
    local avg = UnitLevel("player")
    local equip = avg
    if (_G["GetAverageItemLevel"]) then
        avg, equip = GetAverageItemLevel()
    end
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
    {
        Type="boolean",
        Name="i am a boolean param",
        Key="bbITEMLEVEL",
    },    {
        Type="numeric",
        Name=L["RULEUI_LABEL_ITEMLEVEL"],
        Key="ITEMLEVEL",
    },    {
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
        Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
        Name = L["SYSRULE_SELL_ALWAYSSELL"],
        Description = L["SYSRULE_SELL_ALWAYSSELL_DESC"],
        ScriptText = "IsAlwaysSellItem()",
        Script = function() 
            return IsInList(SELL_LIST)
        end,
        Locked = true,
        Order = -2000,
    },

    {
        Id = "sell.poor",
        Type = SELL_RULE,
        Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
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
        Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
        Name = L["SYSRULE_SELL_OLDFOOD"],
        Description = L["SYSRULE_SELL_OLDFOOD_DESC"],
        ScriptText = "TypeId == 0 and SubTypeId == 5 and (not NO_LEVEL_ONE or Level ~= 1) and Level <= (PlayerLevel() - FOOD_LEVEL)",
        Script = function()
            return (TypeId == 0) and 
                    (SubTypeId == 5) and 
                    (not NO_LEVEL_ONE or (Level ~= 1)) and
                    (Level <= (PlayerLevel() - FOOD_LEVEL));
        end,
        Order = 1100,
        Params = {
            {
                Type = "number",
                Name = "Level",
                Key = "FOOD_LEVEL",
                Default = 10,
            },
            {
                Type ="boolean",
                Name = "Exclude level 1",
                Key = "NO_LEVEL_ONE",
                Default = true,
            },
        }
    },

    --@retail@
    {
        Id = "sell.knowntoys",
        Type = SELL_RULE,
        Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
        Name = L["SYSRULE_SELL_KNOWNTOYS"],
        Description = L["SYSRULE_SELL_KNOWNTOYS_DESC"],
        ScriptText = "IsSoulbound and IsToy and IsAlreadyKnown and not IsUnsellable",
        Script = function()
                return IsSoulbound and IsToy and IsAlreadyKnown and not IsUnsellable;
            end,
        Order = 1300,
    },

    {
        Id = "sell.uncommongear",
        Type = SELL_RULE,
        Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
        Name = L["SYSRULE_SELL_UNCOMMONGEAR"],
        Description = L["SYSRULE_SELL_UNCOMMONGEAR_DESC"],
        ScriptText = "(not IsInEquipmentSet()) and IsEquipment and Quality == UNCOMMON and (not IsUnsellable) and Level < ITEMLEVEL",
        Script = function()
                return (not IsInEquipmentSet()) and IsEquipment and (Quality == UNCOMMON) and (not IsUnsellable) and (Level < ITEMLEVEL);
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
        Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
        Name = L["SYSRULE_SELL_RAREGEAR"],
        Description = L["SYSRULE_SELL_RAREGEAR_DESC"],
        ScriptText = "(not IsInEquipmentSet()) and IsEquipment and Quality == RARE and (not IsUnsellable) and Level < ITEMLEVEL",
        Script = function()
                return (not IsInEquipmentSet()) and IsEquipment and (Quality == RARE) and (not IsUnsellable) and (Level < ITEMLEVEL);
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
        Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
        Name = L["SYSRULE_SELL_EPICGEAR"],
        Description = L["SYSRULE_SELL_EPICGEAR_DESC"],
        ScriptText = "(not IsInEquipmentSet()) and IsEquipment and IsSoulbound and Quality == EPIC and (not IsUnsellable) and Level < ITEMLEVEL",
        Script = function()
                return (not IsInEquipmentSet()) and IsEquipment and IsSoulbound and (Quality == EPIC) and (not IsUnsellable) and (Level < ITEMLEVEL);
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

    --*****************************************************************************
    -- Keep Rules
    --*****************************************************************************

    -- Item is in the Never Sell list.
    {
        Id = "keep.neversell",
        Type = KEEP_RULE,
        Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
        Name = L["SYSRULE_KEEP_NEVERSELL"],
        Description = L["SYSRULE_KEEP_NEVERSELL_DESC"],
        ScriptText = "IsNeverSellItem()",
        Script = function() 
            return IsInList(KEEP_LIST)
        end,
        Locked = true,
        Order = -3000,
    },

    -- Safeguard rule - Legendary and higher are very rare and should probably never be worthy of a sell rule, but just in case...
    {
        Id = "keep.legendaryandup",
        Type = KEEP_RULE,
        Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
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
        Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
        Name = L["SYSRULE_KEEP_SOULBOUNDGEAR"],
        Description = L["SYSRULE_KEEP_SOULBOUNDGEAR_DESC"],
        ScriptText = "IsEquipment and IsSoulbound",
        Script = function()
                return IsEquipment and IsSoulbound;
            end,
        Order = 1100,
    },

    -- Safeguard rule - Keep BoE Equipment
    {
        Id = "keep.bindonequipgear",
        Type = KEEP_RULE,
        Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
        Name = L["SYSRULE_KEEP_BINDONEQUIPGEAR"],
        Description = L["SYSRULE_KEEP_BINDONEQUIPGEAR_DESC"],
        ScriptText = "IsEquipment and IsBindOnEquip",
        Script = function()
                return IsEquipment and IsBindOnEquip;
            end,
        Order = 1150,
    },

    -- Safeguard rule - Protect those transmogs!
    {
        Id = "keep.unknownappearance",
        Type = KEEP_RULE,
        Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
        Name = L["SYSRULE_KEEP_UNKNOWNAPPEARANCE"],
        Description = L["SYSRULE_KEEP_UNKNOWNAPPEARANCE_DESC"],
        ScriptText = "IsCollectable",
        Script = function() return IsCollectable end,
        Order = 1200,
    },
    {
        Id = "keep.cosmetic",
        Type = KEEP_RULE,
        Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
        Name = L["SYSRULE_KEEP_COSMETIC"],
        Description = L["SYSRULE_KEEP_COSMETIC_DESC"],
        ScriptText = "IsCosmetic and (IsBindOnEquip or IsBindOnAccount)",
        Script = function() return IsCosmetic and (IsBindOnEquip or IsAccountBound) end,
        Order = 1250,
    },

    -- Safeguard Rule
    {
        Id = "keep.potentialupgrades",
        Type = KEEP_RULE,
        Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
        Name = L["SYSRULE_KEEP_POTENTIALUPGRADES"],
        Description = L["SYSRULE_KEEP_POTENTIALUPGRADES_DESC"],
        ScriptText = "IsEquippable and (Level >= math.min(PlayerItemLevel() * .95, PlayerItemLevel() - 5))",
        Script = function() return IsEquippable and (Level >= math.min(PlayerItemLevel() * .95, PlayerItemLevel() - 5)) end,
        Order = 1275,
    },

    -- Safeguard rule - Common items are usually important and useful.
    {
        Id = "keep.common",
        Type = KEEP_RULE,
        Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
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
        Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
        Name = L["SYSRULE_KEEP_UNCOMMONGEAR"],
        Description = L["SYSRULE_KEEP_UNCOMMONGEAR_DESC"],
        ScriptText = "IsEquipment and Quality == 2 and (Level >= ITEMLEVEL)",
        Script = function()
                return IsEquipment and (Quality == 2) and (Level >= ITEMLEVEL);
            end,
        Params = 
            {
                {
                    Type = "numeric",
                    Key = "ITEMLEVEL",
                    Name = L.RULEUI_KEEP_UNCOMMON_INFO,
                    Default = 0,
                }
            },
        Order = 1400,
    },

    -- Optional Safeguard - Might be useful for leveling or early max-level.
    {
        Id = "keep.raregear",
        Type = KEEP_RULE,
        Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
        Name = L["SYSRULE_KEEP_RAREGEAR"],
        Description = L["SYSRULE_KEEP_RAREGEAR_DESC"],
        ScriptText = "IsEquipment and Quality == 3 and (Level >= ITEMLEVEL)",
        Script = function()
                return IsEquipment and (Quality == 3) and (Level >= ITEMLEVEL);
            end,
        Params = 
            {
                {
                    Type = "numeric",
                    Key = "ITEMLEVEL",
                    Name = L.RULEUI_KEEP_RARE_INFO,
                    Default = 0,
                }
            },
        Order = 1500,
    },

    -- Optional Safeguard - If you're a bit paranoid.
    {
        Id = "keep.epicgear",
        Type = KEEP_RULE,
        Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
        Name = L["SYSRULE_KEEP_EPICGEAR"],
        Description = L["SYSRULE_KEEP_EPICGEAR_DESC"],
        ScriptText = "IsEquipment and Quality == 4 and (Level >= ITEMLEVEL)",
        Script = function()
                return IsEquipment and (Quality == 4) and (Level >= ITEMLEVEL);
            end,
        Params = 
            {
                {
                    Type = "numeric",
                    Key = "ITEMLEVEL",
                    Name = L.RULEUI_KEEP_EPIC_INFO,
                    Default = 0,
                }
            },
        Order = 1600,
    },

    -- Safeguard against selling item sets, even if it matches some
    -- other rule, for example, a fishing or transmog set.
    {
        Id = "keep.equipmentset",
        Type = KEEP_RULE,
        Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
        Name = L["SYSRULE_KEEP_EQUIPMENTSET"],
        Description = L["SYSRULE_KEEP_EQUIPMENTSET_DESC"],
        ScriptText = "IsInEquipmentSet()",
        Script = function() return IsInEquipmentSet() end,
        Order = 1050,
    },

    --*****************************************************************************
    -- Destroy Rules
    --*****************************************************************************

    -- Item is in the Never Sell list.
    {
        Id = "destroy.alwaysdestroy",
        Type = DESTROY_RULE,
        Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true },
        Name = L["SYSRULE_DESTROYLIST"],
        Description = L["SYSRULE_DESTROYLIST_DESC"],
        ScriptText = "IsInList(\"Destroy\")",
        Script = function() 
            return IsInList(DESTROY_LIST) 
        end,
        Locked = true,
        Order = -1000,
    },

    {
        Id = "destroy.knowntoys",
        Type = DESTROY_RULE,
        Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
        Name = L["SYSRULE_DESTROY_KNOWNTOYS"],
        Description = L["SYSRULE_DESTROY_KNOWNTOYS_DESC"],
        ScriptText = "IsSoulbound and IsToy and IsAlreadyKnown and IsUnsellable",
        Script = function()
                return IsSoulbound and IsToy and IsAlreadyKnown and IsUnsellable;
            end,
        Order = 1200,
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
                return ruleDef
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
        -- We have to filter out unsupported rules.
        local supported = ruleDef.Supported[Addon.Systems.Info.ReleaseName]
        if (supported and not ruleDef.Locked and ((not typeFilter) or (ruleDef.Type == typeFilter))) then
            local def = Addon.DeepTableCopy(ruleDef)
            def.Source = Addon.RuleSource.SYSTEM
            table.insert(defs, def);
        end
    end

    -- Gather custom rules
    -- We dont' need to worry about supported here, we assume it is and let the user decide after
    -- migration if their rule still works.
    if (Vendor_CustomRuleDefinitions) then
        for _, ruleDef in ipairs(Vendor_CustomRuleDefinitions) do
            if (not typeFilter) or (ruleDef.Type == typeFilter) then
                local def = Addon.DeepTableCopy(ruleDef)
                def.Source = Addon.RuleSource.CUSTOM
                table.insert(defs, def);
            end
        end
    end

    -- Gather extensions
    -- We don't need to worry about supportee here, we filtered out unsupported on extension registration.
    if (Package.Extensions) then
        for _, ruleDef in ipairs(Package.Extensions:GetRules(typeFilter)) do
            ruleDef.Locked = false;
            local def = Addon.DeepTableCopy(ruleDef)
            def.Source = Addon.RuleSource.EXTENSION
            table.insert(defs, def);
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
function Rules.GetDefinition(ruleId, ruleType, includeLocked)
    local id = string.lower(ruleId);

    -- Check the system rules.
    for _, ruleDef in ipairs(Rules.SystemRules) do
        local supported = not ruleDef.Supported or ruleDef.Supported[Addon.Systems.Info.ReleaseName]
        if (supported and (not ruleDef.Locked or includeLocked)) then
            if (string.lower(ruleDef.Id) == id) then
                if ((not ruleType) or (ruleType == ruleDef.Type)) then
                    return ruleDef, "SYSTEM";
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
            return ext, "EXT";
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
