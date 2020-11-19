
local AddonName, Addon = ...
local L = Addon:GetLocale()

-- Tooltip scanning for item information. This is necessary because not all information is available via item info API.

-- Create tooltip used for scanning items for properties not available normally.
-- Following wowwiki's example here.
local loaded = false
local scanningtip = CreateFrame('GameTooltip', 'VendorScanningTip', nil, 'GameTooltipTemplate')
scanningtip:SetOwner(WorldFrame, 'ANCHOR_NONE')


local function importTooltipTextToTable(tooltip, text, location)
    -- We assume the tooltip is the GameTooltip
    local tooltipText = "GameTooltipText"..text

    -- If we don't have the gametooltip, use the scanning tooltip and use the bag item.
    if not tooltip then
        tooltip = scanningtip
        tooltip:ClearLines()
        tooltipText = "VendorScanningTipText"..text
        if location and C_Item.DoesItemExist(location) then
            if location:IsEquipmentSlot() then
                tooltip:SetInventoryItem("player", location:GetEquipmentSlot())
            elseif location:IsBagAndSlot() then
                tooltip:SetBagItem(location:GetBagAndSlot())
            else
                error("Invalid location")
            end
        else
            error("Invalid arguments to Tooltip Import")
        end
    end

    -- Import the tooltip into a table
    local tooltipTable = {}
    for i=1, tooltip:NumLines() do
        if _G[tooltipText..i] and _G[tooltipText..i]:GetText() then
            table.insert(tooltipTable, _G[tooltipText..i]:GetText())
        end
    end
    return tooltipTable
end

function Addon:ImportTooltipTextLeft(tooltip, location)
    return importTooltipTextToTable(tooltip, "Left", location)
end

function Addon:ImportTooltipTextRight(tooltip, location)
    return importTooltipTextToTable(tooltip, "Right", location)
end


local function isStringInTooltipText(tooltip, text, location, str)
    -- We assume the tooltip is the GameTooltip
    local tooltipText = "GameTooltipText"..text

    -- If we don't have the gametooltip, use the scanning tooltip and use the bag item.
    if not tooltip then
        tooltip = scanningtip
        tooltip:ClearLines()
        tooltipText = "VendorScanningTipText"..text
        if location and C_Item.DoesItemExist(location) then
            if location:IsEquipmentSlot() then
                tooltip:SetInventoryItem("player", location:GetEquipmentSlot())
            elseif location:IsBagAndSlot() then
                tooltip:SetBagItem(location:GetBagAndSlot())
            else
                error("Invalid location")
            end
        else
            error("Invalid arguments to Tooltip Scanner")
        end
    end

    -- Scan the tooltip left text.
    for i=1, tooltip:NumLines() do
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
function Addon:IsStringInTooltipLeftText(tooltip, location, str)
    return isStringInTooltipText(tooltip, "Left", location, str)
end

-- Text scan for right text.
function Addon:IsStringInTooltipRightText(tooltip, location, str)
    return isStringInTooltipText(tooltip, "Right", location, str)
end

-- Text scan for entire tooltip.
function Addon:IsStringInTooltip(tooltip, location, str)
    local left = Addon:IsStringInTooltipLeftText(tooltip, location, str)
    if left then return left end
    return Addon:IsStringInTooltipRightText(tooltip, location, str)
end

-- You haven't collected this appearance
function Addon:IsItemUnknownAppearanceInTooltip(tooltip, location)
    return self:IsStringInTooltipLeftText(tooltip, location, L["TOOLTIP_SCAN_UNKNOWNAPPEARANCE"])
end

-- Artifact Power
function Addon:IsItemArtifactPowerInTooltip(tooltip, location)
    return self:IsStringInTooltipLeftText(tooltip, location, L["TOOLTIP_SCAN_ARTIFACTPOWER"])
end

-- Toy
function Addon:IsItemToyInTooltip(tooltip, location)
    return self:IsStringInTooltipLeftText(tooltip, location, L["TOOLTIP_SCAN_TOY"])
end

-- Already known
function Addon:IsItemAlreadyKnownInTooltip(tooltip, location)
    return self:IsStringInTooltipLeftText(tooltip, location, L["TOOLTIP_SCAN_ALREADYKNOWN"])
end

-- Crafting Reagent
function Addon:IsItemCraftingReagentInTooltip(tooltip, location)
    -- Look, I don't know why it's called that, but it is. Blizzard has...reasons.
    return self:IsStringInTooltipLeftText(tooltip, location, L["TOOLTIP_SCAN_CRAFTINGREAGENT"])
end


