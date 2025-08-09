local _, Addon = ...

local L = Addon:GetLocale()
local function debugp(...) Addon:Debug("itemprotection", ...) end
local MessageType = Addon.Systems.Chat.MessageType

local ItemProtection = Mixin({}, Addon.UseProfile)
ItemProtection.NAME = "ItemProtection"
ItemProtection.VERSION = 1
ItemProtection.DEPENDENCIES = {
    -- Adding history here creates a circular dependency since History relies on rules, rules relies on settings
    -- settings relies on minimapbutton, minimapbutton relies on statusplugin, and statusplugin relies on protection
    -- TODO: Sort this mess out so we can use history with this feature.
    "system:chat",
}


local suppressBuybackProtection = false

function ItemProtection:IsProtectionEnabled()
    debugp("Getting Protection Status")
    return not not Addon:GetProfile():GetValue(Addon.c_Config_Protection)
end

function ItemProtection:OnDeleteItemConfirm(itemName, qualityId, bonding, questwarn)
    if not ItemProtection:IsProtectionEnabled() then return end
    local itemloc = C_Cursor.GetCursorItem()
    if not itemloc then return end
    local item = Addon:GetItemResultForLocation(itemloc)
    if not item then return end
    if item.Result.RuleType == Addon.RuleType.KEEP then
        Addon:Output(MessageType.Destroy, "Detected DELETE of keep item ("..item.Result.Rule..")! "..item.Item.Link.." Cancelling the deletion!")
        ClearCursor()
        -- TODO Add a history entry for protection events
    end
end


function ItemProtection:OnMerchantUpdate()
    ItemProtection:CheckAndBuybackKeepItem()
end

local buyBackSuppressGUID = nil

function ItemProtection:OnMerchantShow()
    if IsShiftKeyDown() then 
        suppressBuybackProtection = true
    end

    -- Check the first item in the buyback, which may have been sold on a previous
    -- suppressed interaction. We do not want to buy that back immediately.
    local data = C_TooltipInfo.GetBuybackItem(GetNumBuybackItems())
    if not data then return end
    local item = Addon.Systems.ItemProperties:GetItemPropertiesFromExternalTooltip(data)
    if not item then return end

    buyBackSuppressGUID = item.GUID
end

function ItemProtection:OnMerchantClosed()
    suppressBuybackProtection = false
end


function ItemProtection:CheckAndBuybackKeepItem()
    if suppressBuybackProtection then return end
    if not self:IsProtectionEnabled() then return end

    -- Ignore during autosell, too much spam and we do not want to re-evaluate
    -- every item we just sold, that would double the evaluation cost for no
    -- good reason. There is a chance the player may sell something while
    -- vendor is selling, and if that happens, welp, we can only do so much
    -- to protect the player from themselves.
    local merchant = Addon:GetFeature("Merchant")
    if merchant and merchant:IsAutoSelling() then return end

    debugp("Merchant updated outside autosell, player sold something...")
    local data = C_TooltipInfo.GetBuybackItem(GetNumBuybackItems())
    if not data then return false end
    local item = Addon.Systems.ItemProperties:GetItemPropertiesFromExternalTooltip(data)
    if not item then
        debugp("Found no item in the buyback")
        return false
    end

    -- Ignore the buyback suppressed item.
    if item.GUID == buyBackSuppressGUID then return false end

    -- Ignore the cache since that will have bad data and we want fresh evaluation.
    local result = Addon:EvaluateItem(item, true)
    if not result then
        debugp("Failed evaluating item: "..item.Link)
        return false
    end

    if result.RuleType == Addon.RuleType.KEEP then
        Addon:Output(MessageType.Merchant, "Detected SOLD Keep item ("..result.Rule..")! "..item.Link.."  Buying it back!")
        BuybackItem(GetNumBuybackItems())
        -- TODO Add a history entry for protection events
        return true
    end

    return false
end

function ItemProtection:ToggleProtectionState()
    local current = self:IsProtectionEnabled()
    self:SetProfileValue(Addon.c_Config_Protection, not current)
    debugp("Protection State Toggled to: "..tostring(not current))
end

function ItemProtection:OnInitialize()
    Addon:RegisterEvent("DELETE_ITEM_CONFIRM", ItemProtection.OnDeleteItemConfirm)
    Addon:RegisterEvent("MERCHANT_UPDATE", ItemProtection.OnMerchantUpdate)
    Addon:RegisterEvent("MERCHANT_SHOW", ItemProtection.OnMerchantShow)
    Addon:RegisterEvent("MERCHANT_CLOSED", ItemProtection.OnMerchantClosed)
    debugp("Protection initialized")
end

function ItemProtection:OnTerminate()
end

Addon.Features.ItemProtection = ItemProtection
