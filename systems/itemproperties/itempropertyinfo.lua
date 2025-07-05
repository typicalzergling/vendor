local _, Addon = ...
local L = Addon:GetLocale()
local function debugp(...) Addon:Debug("itempropertyinfo", ...) end

--[[
    Format is the following

    PropertyName = { 
        Default = value, -- Whatever the type is
        Hide = number, -- 0 = always show, 1 = always hide, 2 = show if value is not default
        Parent = string -- nil = no parent, string = name of parent property
        Type = string, -- the type
        Supported = {
            Retail = boolean,
            Classic = boolean,
            RetailNext = boolean,       -- Whenever next version of retail is on PTR or Beta
            ClassicNext = boolean,      -- Whenever next version of classic is on PTR or Beta
        }
    }

    Documentation is separately tracked.

]]

local ITEM_PROPERTIES_CATEGORIES = {
    {Name = "General", Display = true },
    {Name = "Location", Display = true },
    {Name = "Type", Display = true },
    {Name = "Binding", Display = true },
    {Name = "Equipment", Display = true },
    {Name = "Transmog", Display = true },
    {Name = "Pet", Display = true },
    {Name = "System", Display = false },
    {Name = "Debug", Display = Addon.IsDebug },
}

local ITEM_PROPERTIES = {
    -- Core properties
    -- GUID is intentionally defaulted to false. If we dont have it, we dont have item properties.
    GUID                    = { Default=false,  Hide=1,  Category="General",    Parent=nil,                   Type="string",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=1 },
    Name                    = { Default="",     Hide=0,  Category="General",    Parent=nil,                   Type="string",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=2 },
    Id                      = { Default=0,      Hide=0,  Category="General",    Parent=nil,                   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=3 },
    Link                    = { Default="",     Hide=1,  Category="General",    Parent=nil,                   Type="string",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=4 },
    Count                   = { Default=0,      Hide=0,  Category="General",    Parent=nil,                   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=5 },

    -- Location properties
    IsBagAndSlot            = { Default=false,  Hide=0,  Category="Location",   Parent=nil,                   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=6 },
    Bag                     = { Default=-1,     Hide=0,  Category="Location",   Parent="IsBagAndSlot",        Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=7 },
    Slot                    = { Default=-1,     Hide=0,  Category="Location",   Parent="IsBagAndSlot",        Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=8 },
    IsEquipped              = { Default=false,  Hide=0,  Category="Location",   Parent="IsEquipment",         Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=9 },
    EquipLoc                = { Default="",     Hide=0,  Category="Equipment",  Parent="IsEquipment",         Type="string",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=10 },
    EquipLocName            = { Default="",     Hide=0,  Category="Equipment",  Parent="IsEquipment",         Type="string",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=11 },

    -- Base properties
    Level                   = { Default=0,      Hide=0,  Category="General",    Parent=nil,                   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=12 },
    MinLevel                = { Default=0,      Hide=0,  Category="General",    Parent=nil,                   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=13 },
    Quality                 = { Default=0,      Hide=0,  Category="General",    Parent=nil,                   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=14 },
    Type                    = { Default="",     Hide=0,  Category="Type",       Parent=nil,                   Type="string",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=15 },
    TypeId                  = { Default=0,      Hide=0,  Category="Type",       Parent=nil,                   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=16 },
    SubType                 = { Default="",     Hide=0,  Category="Type",       Parent=nil,                   Type="string",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=17 },
    SubTypeId               = { Default=0,      Hide=0,  Category="Type",       Parent=nil,                   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=18 },
    StackSize               = { Default=0,      Hide=0,  Category="General",    Parent=nil,                   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=19 },
    UnitValue               = { Default=0,      Hide=0,  Category="General",    Parent=nil,                   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=20 },
    IsCraftingReagent       = { Default=false,  Hide=0,  Category="Type",       Parent=nil,                   Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true }, Rank=21 },
    HasUseAbility           = { Default=false,  Hide=0,  Category="Type",       Parent=nil,                   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=22 },
    IsEquipment             = { Default=false,  Hide=0,  Category="Type",       Parent=nil,                   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=23 },
    ExpansionPackId         = { Default=0,      Hide=0,  Category="Type",       Parent=nil,                   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=24 },
    InventoryType           = { Default=0,      Hide=0,  Category="Equipment",  Parent="IsEquipment",         Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=25 },
    IsConduit               = { Default=false,  Hide=2,  Category="Type",       Parent=nil,                   Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false }, Rank=26 },
    IsAzeriteItem           = { Default=false,  Hide=2,  Category="Type",       Parent=nil,                   Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false }, Rank=27 },
    CraftedQuality          = { Default=0,      Hide=2,  Category="General",    Parent=nil,                   Type="number",     Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false }, Rank=28 },
    IsUsable                = { Default=false,  Hide=0,  Category="Type",       Parent=nil,                   Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false }, Rank=29 },
    IsUpgradeable           = { Default=false,  Hide=0,  Category="Type",       Parent=nil,                   Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false }, Rank=30 },

    -- Derived base properties - not given directly by Blizzard
    UnitGoldValue           = { Default=0,      Hide=0,  Category="General",    Parent=nil,                   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=31 },
    TotalValue              = { Default=0,      Hide=0,  Category="General",    Parent=nil,                   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=32 },
    TotalGoldValue          = { Default=0,      Hide=0,  Category="General",    Parent=nil,                   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=33 },
    IsUnsellable            = { Default=false,  Hide=0,  Category="Type",       Parent=nil,                   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=34 },
    IsProfessionEquipment   = { Default=false,  Hide=0,  Category="Equipment",  Parent="IsEquipment",         Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false }, Rank=35 },
    IsEquippable            = { Default=false,  Hide=0,  Category="Equipment",  Parent="IsEquipment",         Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=36 },
    IsPet                   = { Default=false,  Hide=0,  Category="Type",       Parent=nil,                   Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true }, Rank=37 },

    -- Bind properties
    BindType                = { Default=0,      Hide=0,  Category="Binding",    Parent=nil,                   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=38 },
    IsSoulbound             = { Default=false,  Hide=0,  Category="Binding",    Parent=nil,                   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=39 },
    IsBindOnEquip           = { Default=false,  Hide=0,  Category="Binding",    Parent=nil,                   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=40 },
    IsBindOnUse             = { Default=false,  Hide=0,  Category="Binding",    Parent=nil,                   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=41 },
    IsWarbound              = { Default=false,  Hide=0,  Category="Binding",    Parent=nil,                   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true }, Rank=42 },
    IsWarboundUntilEquip    = { Default=false,  Hide=0,  Category="Binding",    Parent=nil,                   Type="boolean",    Supported={ Retail=false, Classic=false, RetailNext=true, ClassicNext=false }, Rank=43 },

    -- Transmog properties
    IsTransmogEquipment     = { Default=false,  Hide=0,  Category="Equipment",  Parent="IsEquipment",         Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true }, Rank=44 },
    IsAppearanceCollected   = { Default=false,  Hide=0,  Category="Transmog",   Parent="HasAppearance",       Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true }, Rank=45 },
    HasAppearance           = { Default=false,  Hide=0,  Category="Transmog",   Parent=nil,                   Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true }, Rank=46 },
    IsUnknownAppearance     = { Default=false,  Hide=0,  Category="Transmog",   Parent="HasAppearance",       Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true }, Rank=47 },
    AppearanceId            = { Default=0,      Hide=0,  Category="Transmog",   Parent="HasAppearance",       Type="number",     Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true }, Rank=48 },
    SourceId                = { Default=0,      Hide=0,  Category="Transmog",   Parent="HasAppearance",       Type="number",     Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true }, Rank=49 },

    -- Tooltip-derived Properties (excluding IsAccountBound)
    IsCosmetic              = { Default=false,  Hide=0,  Category="Equipment",  Parent="IsEquipment",         Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true }, Rank=50 },
    IsAlreadyKnown          = { Default=false,  Hide=0,  Category="Type",       Parent=nil,                   Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true }, Rank=51 },
    IsToy                   = { Default=false,  Hide=0,  Category="Type",       Parent=nil,                   Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true }, Rank=53 },

    -- Pet properties
    PetName                 = { Default="",     Hide=0,  Category="Pet",        Parent="IsPet",               Type="string",     Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false }, Rank=54 },
    PetType                 = { Default=0,      Hide=0,  Category="Pet",        Parent="IsPet",               Type="number",     Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false }, Rank=55 },
    IsPetTradeable          = { Default=false,  Hide=0,  Category="Pet",        Parent="IsPet",               Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false }, Rank=56 },
    PetSpeciesId            = { Default=0,      Hide=0,  Category="Pet",        Parent="IsPet",               Type="number",     Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false }, Rank=57 },
    PetCount                = { Default=0,      Hide=0,  Category="Pet",        Parent="IsPet",               Type="number",     Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false }, Rank=58 },
    PetLimit                = { Default=0,      Hide=0,  Category="Pet",        Parent="IsPet",               Type="number",     Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false }, Rank=59 },
    IsPetCollectable        = { Default=false,  Hide=0,  Category="Pet",        Parent="IsPet",               Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false }, Rank=60 },

    -- Aliased properties for compat (hidden)
    IsAccountBound          = { Default=false,  Hide=1,  Category="Binding",    Parent=nil,                   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } , Rank=61},

    -- Deprecated Properties for old Tooltip scanning in classic
    TooltipLeft             = { Default=nil,    Hide=1,  Category="System",     Parent=nil,                   Type="table",     Supported={ Retail=false, Classic=true, RetailNext=false, ClassicNext=false }, Rank=62 },
    TooltipRight            = { Default=nil,    Hide=1,  Category="System",     Parent=nil,                   Type="table",     Supported={ Retail=false, Classic=true, RetailNext=false, ClassicNext=false }, Rank=63 },

    -- Used for data only
    TooltipData             = { Default=nil,    Hide=1,  Category="System",     Parent=nil,                   Type="table",     Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true }, Rank=64 },

    -- Debug properties
    TransmogInfoSource      = { Default=nil,    Hide=0,  Category="Debug",     Parent=nil,                   Type="string",     Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false }, Rank=65 }
}

function Addon.Systems.ItemProperties:GetPropertyCategories()
    local categories = {}
    for i, v in ipairs(ITEM_PROPERTIES_CATEGORIES) do
        if v.Display then
            table.insert(categories, v.Name)
        end
    end
    return categories
end

-- Property info accessors
function Addon.Systems.ItemProperties:IsPropertyDefined(name)
    assert(name and type(name) == "string", "Invalid property name.")
    return not not ITEM_PROPERTIES[name]
end

function Addon.Systems.ItemProperties:GetPropertyType(name)
    assert(name and type(name) == "string", "Invalid property name.")
    assert(ITEM_PROPERTIES[name], "No such property: "..name)
    return ITEM_PROPERTIES[name].Type
end

function Addon.Systems.ItemProperties:GetPropertyCategory(name)
    assert(name and type(name) == "string", "Invalid property name.")
    assert(ITEM_PROPERTIES[name], "No such property: "..name)
    return ITEM_PROPERTIES[name].Category
end

function Addon.Systems.ItemProperties:GetPropertyParent(name)
    assert(name and type(name) == "string", "Invalid property name.")
    assert(ITEM_PROPERTIES[name], "No such property: "..name)
    return ITEM_PROPERTIES[name].Parent
end

function Addon.Systems.ItemProperties:GetPropertyDefault(name)
    assert(name and type(name) == "string", "Invalid property name.")
    assert(ITEM_PROPERTIES[name], "No such property: "..name)
    return ITEM_PROPERTIES[name].Default
end

function Addon.Systems.ItemProperties:IsPropertyHidden(name)
    assert(name and type(name) == "string", "Invalid property name.")
    assert(ITEM_PROPERTIES[name], "No such property: "..name)
    return ITEM_PROPERTIES[name].Hide
end

function Addon.Systems.ItemProperties:IsPropertySupported(name)
    assert(name and type(name) == "string", "Invalid property name.")
    assert(ITEM_PROPERTIES[name], "No such property: "..name)
    if not ITEM_PROPERTIES[name] then return false end
    return ITEM_PROPERTIES[name].Supported[Addon.Systems.Info.ReleaseName]
end

function Addon.Systems.ItemProperties:GetPropertyRank(name)
    assert(name and type(name) == "string", "Invalid property name.")
    assert(ITEM_PROPERTIES[name], "No such property: "..name)
    if not ITEM_PROPERTIES[name] then return false end
    return ITEM_PROPERTIES[name].Rank or 0
end

-- Creates a list of properties that are supported on the current platform.
-- Also sets the table as read-only so don't try modifying.
local propertyList = nil
function Addon.Systems.ItemProperties:GetPropertyList()
    if propertyList then return propertyList end
    propertyList = {}
    local releaseName = Addon.Systems.Info.ReleaseName
    for k, v in pairs(ITEM_PROPERTIES) do
        if v.Supported[releaseName] then
            propertyList[k] = v.Default
        else
            debugp("Property %s is not supported on %s", k, releaseName)
        end
    end
    return propertyList
end
