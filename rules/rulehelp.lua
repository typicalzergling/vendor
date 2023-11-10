local AddonName, Addon = ...
local L = Addon:GetLocale()

Addon.ScriptReference = Addon.ScriptReference or {}
Addon.ScriptReference.ItemProperties =
{
    Name = L["HELP_NAME_TEXT"],
    Link = L["HELP_LINK_TEXT"],
    Id = L["HELP_ID_TEXT"],
    Quality = L["HELP_QUALITY_TEXT"],
    Level = L["HELP_LEVEL_TEXT"],
    MinLevel = L["HELP_MINLEVEL_TEXT"],
    Type = L["HELP_TYPE_TEXT"],
    TypeId = {
        Text = L["HELP_TYPEID_TEXT"],
        Motes = L["HELP_TYPEID_NOTES"]
    },
    SubType = L["HELP_SUBTYPE_TEXT"],
    SubTypeId = { 
        Text = L["HELP_SUBTYPEID_TEXT"],
        Mptes = L["HELP_SUBTYPEID_NOTES"]
    },
    EquipLoc = L["HELP_EQUIPLOC_TEXT"],
    BindType = { 
        Text = L["HELP_BINDTYPE_TEXT"],
        Notes = L["HELP_BINDTYPE_NOTES"] 
    },
    Count = L["HELP_STACKSIZE_TEXT"],
    UnitValue = { 
        Text = L["HELP_UNITVALUE_TEXT"],
        Notes = L["HELP_UNITVALUE_NOTES"] 
    },
    NetValue = L["HELP_NETVALUE_TEXT"],
    ExpansionPackId = {
        Text = L["HELP_EXPANSIONPACKID_TEXT"],
        Notes = L["HELP_EXPANSIONPACKID_NOTES"],
    },
    IsEquipment = { 
        Text = L["HELP_ISEQUIPMENT_TEXT"],
        Notes = L["HELP_ISEQUIPMENT_NOTES"] 
    },
    IsSoulbound = { 
        Text = L["HELP_ISSOULBOUND_TEXT"],
        Notes = L["HELP_ISSOULBOUND_NOTES"] 
    },
    IsBindOnEquip = { 
        Text = L["HELP_ISBINDONEQUIP_TEXT"],
        Notes = L["HELP_ISBINDONEQUIP_NOTES"] 
    },
    IsBindOnUse = { 
        Text = L["HELP_ISBINDONUSE_TEXT"],
        Notes = L["HELP_ISBINDONUSE_NOTES"] 
    },
    IsCraftingReagent = { 
        Text = L["HELP_ISCRAFTINGREAGENT_TEXT"],
        Notes = L["HELP_ISCRAFTINGREAGENT_NOTES"] 
    },
    IsToy = L["HELP_ISTOY_TEXT"],
    IsAlreadyKnown = L["HELP_ISALREADYKNOWN_TEXT"],
    IsUsable = L["HELP_ISUSABLE_TEXT"],
    IsAzeriteItem = L["HELP_ISAZERITEITEM_TEXT"],
    IsUnsellable = {
        Text = L["HELP_ISUNSELLABLE_TEXT"],
        Notes = L["HELP_ISUNSELLABLE_NOTES"] 
    },
    IsEquipped = L["HELP_ISEQUIPPED_TEXT"],
    IsBagAndSlot = L["HELP_ISBAGANDSLOT_TEXT"],
    Bag = L["HELP_BAG_TEXT"],
    Slot = L["HELP_SLOT_TEXT"],
    CraftedQuality = L["HELP_CRAFTEDQUALITY_TEXT"],
    PlayerName = L["HELP_PLAYERNAME_TEXT"],
    PlayerRealm = L["HELP_PLAYERREALM_TEXT"],
}

Addon.ScriptReference.Functions =
{
    PlayerLevel = {
        Text = L["HELP_PLAYERLEVEL"],
        IsFunction = true
    },
    PlayerClass ={
        Text = L["HELP_PLAYERCLASS"],
        IsFunction = true
    },    
    IsAlwaysSellItem = {
        Text = L["HELP_ISALWAYSSELLITEM"],
        IsFunction = true,
    },
    IsNeverSellItem = {
        Text = L["HELP_ISNEVERSELLITEM"],
        IsFunction = true,
    },
    --@retail@
    PlayerItemLevel = {
        IsFunction = true,
        Text = L["HELP_PLAYERITEMLEVEL"]
    },
    --@end-retail@

    IsInEquipmentSet =
    {
        IsFunction = true,
        Args = L["HELP_ISINEQUIPMENTSET_ARGS"],
        Text = L["HELP_ISINEQUIPMENTSET_TEXT"],
    },
    
    TooltipContains =
    {
        Args = L["HELP_TOOLTIPCONTAINS_ARGS"],
        Text = L["HELP_TOOLTIPCONTAINS_TEXT"],
        IsFunction = true,
    },

    HasStat = 
    {
        IsFunction = true,
        Args = L["HELP_HASSTAT_ARGS"],
        Text = L["HELP_HASSTAT_TEXT"],
        Map = Addon.Maps.Stats,
    },
}
