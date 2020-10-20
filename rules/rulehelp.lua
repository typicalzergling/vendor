local AddonName, Addon = ...
local L = Addon:GetLocale()

Addon.ScriptReference = Addon.ScriptReference or {}
Addon.ScriptReference.ItemProperties =
{
    Name = { Html = L["HELP_NAME_HTML"] },
    Link = { Html = L["HELP_LINK_HTML"] },
    Id = { Html = L["HELP_ID_HTML"] },
    Count = { Html = L["HELP_COUNT_HTML"] },
    Quality = { Html = L["HELP_QUALITY_HTML"] },
    Level = { Html = L["HELP_LEVEL_HTML"] },
    MinLevel = { Html = L["HELP_MINLEVEL_HTML"] },
    Type = { Html = L["HELP_TYPE_HTML"] },
    TypeId = { Html = L["HELP_TYPEID_HTML"] },
    SubType = { Html = L["HELP_SUBTYPE_HTML"] },
    SubTypeId = { Html = L["HELP_SUBTYPEID_HTML"] },
    EquipLoc = { Html = L["HELP_EQUIPLOC_HTML"] },
    BindType = { Html = L["HELP_BINDTYPE_HTML"] },
    StackSize = { Html = L["HELP_STACKSIZE_HTML"] },
    UnitValue = { Html = L["HELP_UNITVALUE_HTML"] },
    NetValue = { Html = L["HELP_NETVALUE_HTML"] },
    ExpansionPackId  = { Html = L["HELP_EXPANSIONPACKID_HTML"] },
    IsEquipment = { Html = L["HELP_ISEQUIPMENT_HTML"] },
    IsSoulbound = { Html = L["HELP_ISSOULBOUND_HTML"] },
    IsBindOnEquip = { Html = L["HELP_ISBINDONEQUIP_HTML"] },
    IsBindOnUse = { Html = L["HELP_ISBINDONUSE_HTML"] },
    IsArtifactPower = { Html = L["HELP_ISARTIFACTPOWER_HTML"] },
    IsUnknownAppearance = { Html = L["HELP_ISUNKNOWNAPPEARANCE_HTML"] },
    IsCraftingReagent = { Html = L["HELP_ISCRAFTINGREAGENT_HTML"] },
    IsToy = { Html = L["HELP_ISTOY_HTML"] },
    IsAlreadyKnown  = { Html = L["HELP_ISALREADYKNOWN_HTML"] },
    IsUsable  = { Html = L["HELP_ISUSABLE_HTML"] },
}

Addon.ScriptReference.Functions =
{
    PlayerLevel = L["HELP_PLAYERLEVEL"],
    PlayerClass = L["HELP_PLAYERCLASS"],
    IsAlwaysSellItem = L["HELP_ISALWAYSSELLITEM"],
    IsNeverSellItem = L["HELP_ISNEVERSELLITEM"],
    PlayerItemLevel = L["HELP_PLAYERITEMLEVEL"],

    ItemQuality =
    {
        Args = L["HELP_ITEMQUALITY_ARGS"],
        Map = Addon.Maps.ItemQuality,
        Text = L["HELP_ITEMQUALITY_TEXT"],
    },

    IsFromExpansion =
    {
        Args = L["HELP_ITEMISFROMEXPANSION_ARGS"],
        Text = L["HELP_ITEMISFROMEXPANSION_TEXT"],
        Map = Addon.Maps.Expansion,
    },

    ItemType =
    {
        Args = L["HELP_ITEMTYPE_ARGS"],
        Text = L["HELP_ITEMTYPE_TEXT"],
        Map = Addon.Maps.Quality,
    },

    IsInEquipmentSet =
    {
        Args = L["HELP_ISINEQUIPMENTSET_ARGS"],
        Html = L["HELP_ISINEQUIPMENTSET_HTML"],
    },
    
    TooltipContains =
    {
        Args = L["HELP_TOOLTIPCONTAINS_ARGS"],
        Html = L["HELP_TOOLTIPCONTAINS_HTML"],
    },

    HasStat = 
    {
        Args = "stat [, stat1 .. statN]",
        Map = Addon.Maps.Stats,
        Html =  "<p>describe" ..
                "<br/><br/>Examples:<br/>" ..
                "Haste:  " .. GREEN_FONT_COLOR_CODE .. "HasStat('haste')" .. FONT_COLOR_CODE_CLOSE .. "<br/>" ..
                "Strength no haste:  " .. GREEN_FONT_COLOR_CODE .. "HasStat('str') and not HasStat('haste')" .. FONT_COLOR_CODE_CLOSE .. "<br/>" ..
                "Corrupted Items:  " .. GREEN_FONT_COLOR_CODE .. "HasStat('corruption')" .. FONT_COLOR_CODE_CLOSE .. "<br/></p>",
    },
}
