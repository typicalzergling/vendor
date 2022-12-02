
local AddonName, Addon = ...
local L = Addon:GetLocale()

-- For tracking whether we need to refresh AdiBags
local sellFilterEnabled = false
local destroyFilterEnabled = false
local adiBags = nil
local LAdiBags = nil

-- AdiBags Sell Filter for Vendor
local function registerSellFilter()
    -- Use highest priority, since Vendor could end up reclassifying absolutely anything in the bags.
    local sellFilter = adiBags:RegisterFilter("VendorSell", 100, 'ABEvent-1.0')
    sellFilter.uiName = L.ADIBAGS_FILTER_VENDOR_SELL_NAME
    sellFilter.uiDesc = L.ADIBAGS_FILTER_VENDOR_SELL_DESC

    sellFilter.OnInitialize = function(self)
        -- No settings, so nothing to initialize at this time.
    end

    sellFilter.OnEnable = function(self)
        sellFilterEnabled = true
        adiBags:UpdateFilters()
    end

    sellFilter.OnDisable = function(self)
        sellFilterEnabled = false
        adiBags:UpdateFilters()
    end

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

    -- No filter options at this time
    sellFilter.GetFilterOptions = function(self)
        return
    end
end


-- AdiBags Destroy Filter for Vendor
local function registerDestroyFilter()

    -- Use highest priority, since Vendor could end up reclassifying absolutely anything in the bags.
    local destroyFilter = adiBags:RegisterFilter("VendorDestroy", 100, 'ABEvent-1.0')
    destroyFilter.uiName = L.ADIBAGS_FILTER_VENDOR_DESTROY_NAME
    destroyFilter.uiDesc = L.ADIBAGS_FILTER_VENDOR_DESTROY_DESC

    destroyFilter.OnInitialize = function(self)
        -- No settings, so nothing to initialize at this time.
    end

    destroyFilter.OnEnable = function(self)
        destroyFilterEnabled = true
        adiBags:UpdateFilters()
    end

    destroyFilter.OnDisable = function(self)
        destroyFilterEnabled = false
        adiBags:UpdateFilters()
    end

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

    -- No filter options at this time
    destroyFilter.GetFilterOptions = function(self)
        return
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
            if sellFilterEnabled or destroyFilterEnabled then
                adiBags:UpdateFilters()
            end
        end,

        Register = function()
            if not adiBags then
                adiBags = LibStub('AceAddon-3.0'):GetAddon('AdiBags')
            end
            if not LAdibags then
                LAdiBags = setmetatable({}, {__index = adiBags.L})
            end
            registerSellFilter()
            registerDestroyFilter()
            return true
        end,
    }

    local extmgr = Addon.Systems.ExtensionManager
    extmgr:AddInternalExtension("AdiBags", adiBagsExtension)
end

registerAdiBagsExtension()