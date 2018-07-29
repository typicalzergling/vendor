local Addon, L, Config = _G[select(1,...).."_GET"]()

function Addon:IsPawnAvailable()
    return IsAddOnLoaded("Pawn")
end

function Addon:PawnIsItemUpgrade(link)
    self:Debug("In PawnIsItemUpgrade, for item: ", tostring(link))
    -- Make sure Pawn API hasn't changed
    if not PawnGetItemData or not PawnIsItemAnUpgrade then return false end

    -- Use Pawn as they do in the tooltip handler.
    local Item = PawnGetItemData(link)
    if not Item then return false end

    -- Get Upgrade Info
    local UpgradeInfo = PawnIsItemAnUpgrade(Item)
    self:Debug("Pawn UpgradeInfo: %s", tostring(UpgradeInfo))
    return not not UpgradeInfo
end

function Addon.RuleFunctions.IsPawnUpgrade()
    if Addon:IsPawnAvailable() then
        return Addon:PawnIsItemUpgrade(OBJECT.Link)
    end
    return false
end
