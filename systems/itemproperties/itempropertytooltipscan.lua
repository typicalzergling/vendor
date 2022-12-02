local _, Addon = ...
local L = Addon:GetLocale()
local debugp = function (...) Addon:Debug("tooltipscan", ...) end

-- No more need for a scanning tip, we assume properties are importing the tooltip data and can pass it along.
-- This set of utilities just scans the blizzard tooltip data as-is.

local ItemProperties = Addon.Systems.ItemProperties

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
function ItemProperties:IsStringInTooltipLeftText(tooltipdata, str)
    return isStringInTooltipText(tooltipdata, str, "Left")
end

-- Text scan for right text.
function ItemProperties:IsStringInTooltipRightText(tooltipdata, str)
    return isStringInTooltipText(tooltipdata, str, "Right")
end

-- Text scan for entire tooltip.
function ItemProperties:IsStringInTooltip(tooltipdata, str)
    local left = self:IsStringInTooltipLeftText(tooltipdata, str)
    if left then return true end
    return self:IsStringInTooltipRightText(tooltipdata, str)
end

-- Artifact Power
function ItemProperties:IsItemArtifactPowerInTooltip(tooltipdata)
    return self:IsStringInTooltipLeftText(tooltipdata, L["TOOLTIP_SCAN_ARTIFACTPOWER"])
end

-- Toy
function ItemProperties:IsItemToyInTooltip(tooltipdata)
    return self:IsStringInTooltipLeftText(tooltipdata, L["TOOLTIP_SCAN_TOY"])
end

-- Already known
function ItemProperties:IsItemAlreadyKnownInTooltip(tooltipdata)
    return self:IsStringInTooltipLeftText(tooltipdata, L["TOOLTIP_SCAN_ALREADYKNOWN"])
end

-- Crafting Reagent
function ItemProperties:IsItemCraftingReagentInTooltip(tooltipdata)
    return self:IsStringInTooltipLeftText(tooltipdata, L["TOOLTIP_SCAN_CRAFTINGREAGENT"])
end

-- Account Bound
function ItemProperties:IsItemAccountBoundInTooltip(tooltipdata)
    return self:IsStringInTooltipLeftText(tooltipdata, L["TOOLTIP_SCAN_BLIZZARDACCOUNTBOUND"])
end

-- Cosmetic Item
function ItemProperties:IsItemCosmeticInTooltip(tooltipdata)
    return self:IsStringInTooltipLeftText(tooltipdata, L["TOOLTIP_SCAN_COSMETIC"])
end
