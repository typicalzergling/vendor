
local AddonName, Addon = ...
local L = Addon:GetLocale()

-- Tooltip scanning for item information. This is necessary because not all information is available via item info API.

-- Create tooltip used for scanning items for properties not available normally.
-- Following wowwiki's example here.
local loaded = false
local scanningtip = CreateFrame('GameTooltip', 'VendorScanningTip', nil, 'GameTooltipTemplate')
scanningtip:SetOwner(WorldFrame, 'ANCHOR_NONE')

local function importTooltipTextToTable(text, location)
    -- Always use the scanning tip, always get the item locatio
    scanningtip:ClearLines()
    local tooltipText = "VendorScanningTipText"..text
    if location and C_Item.DoesItemExist(location) then
        if location:IsEquipmentSlot() then
            scanningtip:SetInventoryItem("player", location:GetEquipmentSlot())
        elseif location:IsBagAndSlot() then
            scanningtip:SetBagItem(location:GetBagAndSlot())
        else
            error("Invalid location")
        end
    else
        error("Invalid arguments to Tooltip Import")
    end

    -- Import the tooltip into a table
    local tooltipTable = {}
    for i=1, scanningtip:NumLines() do
        if _G[tooltipText..i] and _G[tooltipText..i]:GetText() then
            table.insert(tooltipTable, _G[tooltipText..i]:GetText())
        end
    end
    return tooltipTable
end

function Addon:ImportTooltipTextLeft(location)
    return importTooltipTextToTable("Left", location)
end

function Addon:ImportTooltipTextRight(location)
    return importTooltipTextToTable("Right", location)
end


local function isStringInTooltipText(text, location, str)
    -- We assume the tooltip is the GameTooltip
    local tooltipText = "GameTooltipText"..text

    -- If we don't have the gametooltip, use the scanning tooltip and use the bag item.
    scanningtip:ClearLines()
    tooltipText = "VendorScanningTipText"..text
    if location and C_Item.DoesItemExist(location) then
        if location:IsEquipmentSlot() then
            scanningtip:SetInventoryItem("player", location:GetEquipmentSlot())
        elseif location:IsBagAndSlot() then
            scanningtip:SetBagItem(location:GetBagAndSlot())
        else
            error("Invalid location")
        end
    else
        error("Invalid arguments to Tooltip Scanner")
    end


    -- Scan the tooltip left text.
    for i=1, scanningtip:NumLines() do
        local txt = nil
        local left = _G[tooltipText..i]
        if left then
            txt = left:GetText()
        end
        if txt and string.find(txt, str) then
            return true
        end
    end
    return false
end

-- Text scan for left text.
function Addon:IsStringInTooltipLeftText(location, str)
    return isStringInTooltipText("Left", location, str)
end

-- Text scan for right text.
function Addon:IsStringInTooltipRightText(location, str)
    return isStringInTooltipText("Right", location, str)
end

-- Text scan for entire tooltip.
function Addon:IsStringInTooltip(location, str)
    local left = Addon:IsStringInTooltipLeftText(location, str)
    if left then return left end
    return Addon:IsStringInTooltipRightText(location, str)
end

-- You haven't collected this appearance
function Addon:IsItemUnknownAppearanceInTooltip(location)
    return self:IsStringInTooltipLeftText(location, L["TOOLTIP_SCAN_UNKNOWNAPPEARANCE"])
end

-- Artifact Power
function Addon:IsItemArtifactPowerInTooltip(location)
    return self:IsStringInTooltipLeftText(location, L["TOOLTIP_SCAN_ARTIFACTPOWER"])
end

-- Toy
function Addon:IsItemToyInTooltip(location)
    return self:IsStringInTooltipLeftText(location, L["TOOLTIP_SCAN_TOY"])
end

-- Already known
function Addon:IsItemAlreadyKnownInTooltip(location)
    return self:IsStringInTooltipLeftText(location, L["TOOLTIP_SCAN_ALREADYKNOWN"])
end

-- Crafting Reagent
function Addon:IsItemCraftingReagentInTooltip(location)
    -- Look, I don't know why it's called that, but it is. Blizzard has...reasons.
    return self:IsStringInTooltipLeftText(location, L["TOOLTIP_SCAN_CRAFTINGREAGENT"])
end

-- Account Bound
function Addon:IsItemAccountBoundInTooltip(location)
    return self:IsStringInTooltipLeftText(location, L["TOOLTIP_SCAN_BLIZZARDACCOUNTBOUND"])
end

-- Cosmetic Item
function Addon:IsItemCosmeticInTooltip(location)
    return self:IsStringInTooltipLeftText(location, L["TOOLTIP_SCAN_COSMETIC"])
end
