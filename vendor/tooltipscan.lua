
local AddonName, Addon = ...
local L = Addon:GetLocale()

-- No more need for a scanning tip, we assume properties are importing the tooltip data and can pass it along.
-- This set of utilities just scans the blizzard tooltip data as-is.

local function isStringInTooltipText(tooltipdata, str, location)
    assert(type(str) == "string", "Missing string argument.")
    assert(type(location) == "string" and (location == "Left" or location == "Right"), "Invalid arguments to isStringInTooltipText")
    if not tooltipdata then return false end
    assert(tooltipdata.lines, "Tooltip data is not populated.")
    for i, line in ipairs(tooltipdata.lines) do
        local txt = nil
        if location == "Left" and line.leftText then
            txt = line.leftText
        elseif location == "Right" and line.rightText then
            txt = line.rightText
        end
        if txt and string.find(txt, str) then
            return true
        end
    end
    return false
end

-- Text scan for left text.
function Addon:IsStringInTooltipLeftText(tooltipdata, str)
    return isStringInTooltipText(tooltipdata, str, "Left")
end

-- Text scan for right text.
function Addon:IsStringInTooltipRightText(tooltipdata, str)
    return isStringInTooltipText(tooltipdata, str, "Right")
end

-- Text scan for entire tooltip.
function Addon:IsStringInTooltip(tooltipdata, str)
    local left = Addon:IsStringInTooltipLeftText(tooltipdata, str)
    if left then return true end
    return Addon:IsStringInTooltipRightText(tooltipdata, str)
end

-- Artifact Power
function Addon:IsItemArtifactPowerInTooltip(tooltipdata)
    return self:IsStringInTooltipLeftText(tooltipdata, L["TOOLTIP_SCAN_ARTIFACTPOWER"])
end

-- Toy
function Addon:IsItemToyInTooltip(tooltipdata)
    return self:IsStringInTooltipLeftText(tooltipdata, L["TOOLTIP_SCAN_TOY"])
end

-- Already known
function Addon:IsItemAlreadyKnownInTooltip(tooltipdata)
    return self:IsStringInTooltipLeftText(tooltipdata, L["TOOLTIP_SCAN_ALREADYKNOWN"])
end

-- Crafting Reagent
function Addon:IsItemCraftingReagentInTooltip(tooltipdata)
    return self:IsStringInTooltipLeftText(tooltipdata, L["TOOLTIP_SCAN_CRAFTINGREAGENT"])
end

-- Account Bound
function Addon:IsItemAccountBoundInTooltip(tooltipdata)
    return self:IsStringInTooltipLeftText(tooltipdata, L["TOOLTIP_SCAN_BLIZZARDACCOUNTBOUND"])
end

-- Cosmetic Item
function Addon:IsItemCosmeticInTooltip(tooltipdata)
    return self:IsStringInTooltipLeftText(tooltipdata, L["TOOLTIP_SCAN_COSMETIC"])
end
