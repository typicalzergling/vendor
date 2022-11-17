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
    GUID                    = { Default="",     Hide=true,    Type="string",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    Link                    = { Default="",     Hide=true,    Type="string",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    Count                   = { Default=0,      Hide=false,   Type="number",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    Name                    = { Default="",     Hide=false,   Type="string",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    Id                      = { Default=0,      Hide=false,   Type="number",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },

    -- Location properties
    IsBagAndSlot            = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    Bag                     = { Default=-1,     Hide=false,   Type="number",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    Slot                    = { Default=-1,     Hide=false,   Type="number",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    IsEquipped              = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    EquipLoc                = { Default="",     Hide=false,   Type="string",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    EquipLocName            = { Default="",     Hide=false,   Type="string",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },

    -- Base properties
    Level                   = { Default=0,      Hide=false,   Type="number",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    MinLevel                = { Default=0,      Hide=false,   Type="number",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    Quality                 = { Default=0,      Hide=false,   Type="number",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    Type                    = { Default="",     Hide=false,   Type="string",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    TypeId                  = { Default=0,      Hide=false,   Type="number",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    SubType                 = { Default="",     Hide=false,   Type="string",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    SubTypeId               = { Default=0,      Hide=false,   Type="number",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    StackSize               = { Default=0,      Hide=false,   Type="number",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    UnitValue               = { Default=0,      Hide=false,   Type="number",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    IsCraftingReagent       = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    IsUsable                = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    IsEquipment             = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    ExpansionPackId         = { Default=0,      Hide=false,   Type="number",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    InventoryType           = { Default=0,      Hide=false,   Type="number",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    IsConduit               = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=false, PTR=true, Beta=true } },
    IsAzeriteItem           = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=false, PTR=true, Beta=true } },
    CraftedQuality          = { Default=0,      Hide=false,   Type="number",     Support={ Retail=true, Classic=false, PTR=true, Beta=true } },

    -- Derived base properties - not given directly by Blizzard
    UnitGoldValue           = { Default=0,      Hide=false,   Type="number",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    TotalValue              = { Default=0,      Hide=false,   Type="number",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    TotalGoldValue          = { Default=0,      Hide=false,   Type="number",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    IsUnsellable            = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    IsEquippable            = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    IsProfessionEquipment   = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=false, PTR=true, Beta=true } },

    -- Bind properties
    BindType                = { Default=0,      Hide=false,   Type="number",     Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    IsSoulbound             = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    IsAccountBound          = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    IsBindOnEquip           = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    IsBindOnUse             = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=true, PTR=true, Beta=true } },

    -- Transmog properties
    IsTransmogEquipment     = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=false, PTR=true, Beta=true } },
    IsCollectable           = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=false, PTR=true, Beta=true } },
    IsCollected             = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=false, PTR=true, Beta=true } },
    AppearanceId            = { Default=0,      Hide=true,    Type="number",     Support={ Retail=true, Classic=false, PTR=true, Beta=true } },

    -- Tooltip-derived Properties (excluding IsAccountBound)
    IsCosmetic              = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=false, PTR=true, Beta=true } },
    IsToy                   = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
    IsAlreadyKnown          = { Default=false,  Hide=false,   Type="boolean",    Support={ Retail=true, Classic=true, PTR=true, Beta=true } },

    -- Aliased properties for compat (hidden)
    IsUnknownAppearance     = { Default=false,  Hide=true ,   Type="boolean",    Support={ Retail=true, Classic=true, PTR=true, Beta=true } },
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
    local retval = (ITEM_PROPERTIES[name] and ITEM_PROPERTIES[name].Hide)
    debugp("Hidden: "..name.. " = "..tostring(retval))
    return retval
end

-- Creates a list of properties that are supported on the current platform.
function Addon.Systems.ItemProperties:GetPropertyList()
    local propList = {}
    for k, v in pairs(ITEM_PROPERTIES) do

    end
    return propList
end
