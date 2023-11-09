
local AddonName, Addon = ...
local L = Addon:GetLocale()

-- For tracking whether we need to refresh AdiBags
local sellFilterEnabled = false
local destroyFilterEnabled = false
local adiBags = nil
local LAdiBags = nil
local filters = {}
local filterEngine = nil
local destroyFilter = nil

-- AdiBags Sell Filter for Vendor
local function registerSellFilter()
    -- Use highest priority, since Vendor could end up reclassifying absolutely anything in the bags.
    local sellFilter = adiBags:RegisterFilter("VendorSell", 100, 'ABEvent-1.0')
    sellFilter.uiName = L.ADIBAGS_FILTER_VENDOR_SELL_NAME
    sellFilter.uiDesc = L.ADIBAGS_FILTER_VENDOR_SELL_DESC

    sellFilter.Filter = function(self, slotData)        
        assert(Vendor and Vendor.EvaluateItem, "Expected Vendor functions not available. Something went horribly wrong; please report to Vendor Addon developers.")

        if not slotData then
            return
        end

        result = Vendor.EvaluateItem(slotData.bag, slotData.slot)
        if result == 1 then
            return L.ADIBAGS_CATEGORY_VENDOR_SELL, LAdiBags["Junk"]
        end
    end
end


-- AdiBags Destroy Filter for Vendor
local function registerDestroyFilter()

    -- Use highest priority, since Vendor could end up reclassifying absolutely anything in the bags.
    destroyFilter = adiBags:RegisterFilter("VendorDestroy", 100, 'ABEvent-1.0')
    destroyFilter.uiName = L.ADIBAGS_FILTER_VENDOR_DESTROY_NAME
    destroyFilter.uiDesc = L.ADIBAGS_FILTER_VENDOR_DESTROY_DESC


    destroyFilter.Filter = function(self, slotData)
        assert(Vendor and Vendor.EvaluateItem, "Expected Vendor functions not available. Something went horribly wrong; please report to Vendor Addon developers.")
        if not slotData then
            return
        end

        result = Vendor.EvaluateItem(slotData.bag, slotData.slot)
        if result == 2 then
            return L.ADIBAGS_CATEGORY_VENDOR_DESTROY, LAdiBags["Junk"]
        end
    end
end

-- Create and registers a filter for each non-locked rule
local function createRuleFilters()
    if (not filterEngine) then
        filterEngine = Addon:CreateRulesEngine()
        filterEngine:CreateCategory(1, "=adibags=", 0)
    end

    local rules = Addon:GetFeature("rules"):GetRules()
    rules = Addon.Rules.GetDefinitions();

    for _, rule in ipairs(rules) do
        if (not rule.Locked) then
            local filter = adiBags:RegisterFilter("Vendor:rule:" .. rule.Id, 99, 'ABEvent-1.0')
            filter.uiName = L.ADDON_NAME .. ": " .. rule.Name
            filter.uiDesc = rule.Description
            filterEngine:AddRule(1, rule)
                
            filter.Filter = function(self, slotData)
                -- Get Item info for bag/slot
                local item = Addon.Systems.ItemProperties:GetItemPropertiesFromBagAndSlot(slotData.bag, slotData.slot)
                if (item) then
                    local result = filterEngine:EvaluateOne(rule.Id, item, {})
                    if (result == true) then
                        return filter.uiName
                    end
                end
            end

            table.insert(filters, filter)
        end
    end
end


-- This will register a callback to AdiBags with Vendor so when vendor's evaluation changes, AdiBags will be refreshed.
local function registerAdiBagsExtension()
    local adiBagsExtension =
    {
        -- Vendor will check this source is loaded prior to registration.
        -- It will also be displayed in the Vendor UI.
        Source = "AdiBags",
        Addon = "AdiBags",
        Version = 1.0,

        -- This is called by Vendor whenever its rules change and AdiBags needs to update its filters.
        OnRuleUpdate = function()
            -- We'll only tell AdiBags to update filters if one of our filters is enabled.
            --adiBags:UpdateFilters()
        end,

        Register = function()
            --[[
            if not adiBags then 
                adiBags = LibStub('AceAddon-3.0'):GetAddon('AdiBags')
            end
            if not LAdibags then
                LAdiBags = setmetatable({}, {__index = adiBags.L})
            end
            registerSellFilter()
            registerDestroyFilter()            
            --adiBags:UpdateFilters()

            Addon:RegisterCallback("OnFeaturesReady", {}, function()
                    createRuleFilters()
                    if (destroyFilter) then
                        destroyFilter:SetEnabledState(false)
                        destroyFilter:SetEnabledState(true)
                    end
                    adiBags:UpdateFilters()
                end)
                ]]
            return true
        end,
    }

    local extmgr = Addon.Systems.ExtensionManager
    extmgr:AddInternalExtension("AdiBags", adiBagsExtension)
end

registerAdiBagsExtension()