
local AddonName, Addon = ...
local L = Addon:GetLocale()

-- Tooltip scanning for item information. This is necessary because not all information is available via item info API.

-- Create tooltip used for scanning items for properties not available normally.
-- Following wowwiki's example here.
local loaded = false
local scanningtip = CreateFrame('GameTooltip', 'VendorScanningTip', nil, 'GameTooltipTemplate')
scanningtip:SetOwner(WorldFrame, 'ANCHOR_NONE')


local function importTooltipTextToTable(tooltip, text, bag, slot)
    -- We assume the tooltip is the GameTooltip
    local tooltipText = "GameTooltipText"..text

    -- If we don't have the gametooltip, use the scanning tooltip and use the bag item.
    if not tooltip then
        tooltip = scanningtip
        tooltip:ClearLines()
        tooltipText = "VendorScanningTipText"..text
        if bag and slot then
            tooltip:SetBagItem(bag, slot)
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



local function importTooltipColorToTable(tooltip, side, bag, slot)
    -- We assume the tooltip is the GameTooltip
    local tooltipText = "GameTooltipText"..side

    -- If we don't have the gametooltip, use the scanning tooltip and use the bag item.
    if not tooltip then
        tooltip = scanningtip
        tooltip:ClearLines()
        tooltipText = "VendorScanningTipText"..side
        if bag and slot then
            tooltip:SetBagItem(bag, slot)
        else
            error("Invalid arguments to Tooltip Import")
        end
    end

    -- Import the tooltip into a table
    local tooltipTable = {}
    for i=1, tooltip:NumLines() do
        if _G[tooltipText..i] and _G[tooltipText..i]:GetText() then
            local r, g, b = _G[tooltipText..i]:GetTextColor()

            r = math.floor(r * 100 + 0.5) / 100
            g = math.floor(g * 100 + 0.5) / 100
            b = math.floor(b * 100 + 0.5) / 100

            if r == 1 and g == 0.13 and b == 0.13 then
                table.insert(tooltipTable, "red")
            elseif r == 0 and g == 1 and b == 0 then
                table.insert(tooltipTable, "green")
            else
                table.insert(tooltipTable, "white")
            end


        end
    end
    return tooltipTable
end



function Addon:ImportTooltipTextLeft(tooltip, bag, slot)
    return importTooltipTextToTable(tooltip, "Left", bag, slot)
end

function Addon:ImportTooltipTextRight(tooltip, bag, slot)
    return importTooltipTextToTable(tooltip, "Right", bag, slot)
end

function Addon:ImportTooltipColorLeft(tooltip, bag, slot)
    return importTooltipColorToTable(tooltip, "Left", bag, slot)
end

function Addon:ImportTooltipColorRight(tooltip, bag, slot)
    return importTooltipColorToTable(tooltip, "Right", bag, slot)
end

function Addon:TooltipHasRedText(tooltip, bag, slot)
    local left = importTooltipColorToTable(tooltip, "Left", bag, slot)
    local right = importTooltipColorToTable(tooltip, "Right", bag, slot)

    local function checkColor(colorTable)
        for _, color in ipairs(colorTable) do
            if color == "red" then
                return true
            end
        end
        return false
    end

    return checkColor(left) or checkColor(right)
end


local function isStringInTooltipText(tooltip, text, bag, slot, str)
    -- We assume the tooltip is the GameTooltip
    local tooltipText = "GameTooltipText"..text

    -- If we don't have the gametooltip, use the scanning tooltip and use the bag item.
    if not tooltip then
        tooltip = scanningtip
        tooltip:ClearLines()
        tooltipText = "VendorScanningTipText"..text
        if bag and slot then
            tooltip:SetBagItem(bag, slot)
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
function Addon:IsStringInTooltipLeftText(tooltip, bag, slot, str)
    return isStringInTooltipText(tooltip, "Left", bag, slot, str)
end

-- Text scan for right text.
function Addon:IsStringInTooltipRightText(tooltip, bag, slot, str)
    return isStringInTooltipText(tooltip, "Right", bag, slot, str)
end

-- Text scan for entire tooltip.
function Addon:IsStringInTooltip(tooltip, bag, slot, str)
    local left = Addon:IsStringInTooltipLeftText(tooltip, bag, slot, str)
    if left then return left end
    return Addon:IsStringInTooltipRightText(tooltip, bag, slot, str)
end

-- Soulbound
function Addon:IsItemSoulboundInTooltip(tooltip, bag, slot)
    return self:IsStringInTooltipLeftText(tooltip, bag, slot, L["TOOLTIP_SCAN_SOULBOUND"])
end

-- You haven't collected this appearance
function Addon:IsItemUnknownAppearanceInTooltip(tooltip, bag, slot)
    return self:IsStringInTooltipLeftText(tooltip, bag, slot, L["TOOLTIP_SCAN_UNKNOWNAPPEARANCE"])
end

-- Artifact Power
function Addon:IsItemArtifactPowerInTooltip(tooltip, bag, slot)
    return self:IsStringInTooltipLeftText(tooltip, bag, slot, L["TOOLTIP_SCAN_ARTIFACTPOWER"])
end

-- Toy
function Addon:IsItemToyInTooltip(tooltip, bag, slot)
    return self:IsStringInTooltipLeftText(tooltip, bag, slot, L["TOOLTIP_SCAN_TOY"])
end

-- Already known
function Addon:IsItemAlreadyKnownInTooltip(tooltip, bag, slot)
    return self:IsStringInTooltipLeftText(tooltip, bag, slot, L["TOOLTIP_SCAN_ALREADYKNOWN"])
end

-- Crafting Reagent
function Addon:IsItemCraftingReagentInTooltip(tooltip, bag, slot)
    -- Look, I don't know why it's called that, but it is. Blizzard has...reasons.
    return self:IsStringInTooltipLeftText(tooltip, bag, slot, L["TOOLTIP_SCAN_CRAFTINGREAGENT"])
end
