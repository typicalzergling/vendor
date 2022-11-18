local _, Addon = ...
local L = Addon:GetLocale()
local debugp = function (...) Addon:Debug("itempropertyinfo", ...) end

--[[
    Format is the following

    PropertyName = { 
        Default=value,
        Required=true,
        Supported = {
            Retail = boolean,
            Classic = boolean,
            PTR = boolean,
            Beta = boolean,
        }
    }

    Documentation is separately tracked.

]]

local ITEM_PROPERTIES = {
    -- Core properties
    -- GUID is intentionally defaulted to false. If we dont have it, we dont have item properties.
    GUID                    = { Default=false,  Hide=true,    Type="string",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    Link                    = { Default="",     Hide=true,    Type="string",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    Count                   = { Default=0,      Hide=false,   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    Name                    = { Default="",     Hide=false,   Type="string",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    Id                      = { Default=0,      Hide=false,   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },

    -- Location properties
    IsBagAndSlot            = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    Bag                     = { Default=-1,     Hide=false,   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    Slot                    = { Default=-1,     Hide=false,   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    IsEquipped              = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    EquipLoc                = { Default="",     Hide=false,   Type="string",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    EquipLocName            = { Default="",     Hide=false,   Type="string",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },

    -- Base properties
    Level                   = { Default=0,      Hide=false,   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    MinLevel                = { Default=0,      Hide=false,   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    Quality                 = { Default=0,      Hide=false,   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    Type                    = { Default="",     Hide=false,   Type="string",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    TypeId                  = { Default=0,      Hide=false,   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    SubType                 = { Default="",     Hide=false,   Type="string",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    SubTypeId               = { Default=0,      Hide=false,   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    StackSize               = { Default=0,      Hide=false,   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    UnitValue               = { Default=0,      Hide=false,   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    IsCraftingReagent       = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    IsUsable                = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    IsEquipment             = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    ExpansionPackId         = { Default=0,      Hide=false,   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    InventoryType           = { Default=0,      Hide=false,   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    IsConduit               = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true } },
    IsAzeriteItem           = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true } },
    CraftedQuality          = { Default=0,      Hide=false,   Type="number",     Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true } },

    -- Derived base properties - not given directly by Blizzard
    UnitGoldValue           = { Default=0,      Hide=false,   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    TotalValue              = { Default=0,      Hide=false,   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    TotalGoldValue          = { Default=0,      Hide=false,   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    IsUnsellable            = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    IsEquippable            = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true } },
    IsProfessionEquipment   = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true } },

    -- Bind properties
    BindType                = { Default=0,      Hide=false,   Type="number",     Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    IsSoulbound             = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    IsAccountBound          = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    IsBindOnEquip           = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    IsBindOnUse             = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },

    -- Transmog properties
    IsTransmogEquipment     = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true } },
    IsCollectable           = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true } },
    IsCollected             = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true } },
    AppearanceId            = { Default=0,      Hide=true,    Type="number",     Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true } },

    -- Tooltip-derived Properties (excluding IsAccountBound)
    IsCosmetic              = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=true } },
    IsToy                   = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
    IsAlreadyKnown          = { Default=false,  Hide=false,   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },

    -- Aliased properties for compat (hidden)
    IsUnknownAppearance     = { Default=false,  Hide=true ,   Type="boolean",    Supported={ Retail=true, Classic=true, RetailNext=true, ClassicNext=true } },
}

-- Property info accessors

function Addon.Systems.ItemProperties:GetPropertyType(name)
    assert(name and type(name) == "string", "Invalid property name.")
    assert(ITEM_PROPERTIES[name], "No such property.")
    return ITEM_PROPERTIES[name].Type
end

function Addon.Systems.ItemProperties:GetPropertyDefault(name)
    assert(name and type(name) == "string", "Invalid property name.")
    assert(ITEM_PROPERTIES[name], "No such property.")
    return ITEM_PROPERTIES[name].Default
end

function Addon.Systems.ItemProperties:IsPropertyHidden(name)
    assert(name and type(name) == "string", "Invalid property name.")
    return ITEM_PROPERTIES[name] and ITEM_PROPERTIES[name].Hide
end

function Addon.Systems.ItemProperties:IsPropertySupported(name)
    assert(name and type(name) == "string", "Invalid property name.")
    return ITEM_PROPERTIES[name] and ITEM_PROPERTIES[name].Supported[Addon.Systems.Info.ReleaseName]
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
