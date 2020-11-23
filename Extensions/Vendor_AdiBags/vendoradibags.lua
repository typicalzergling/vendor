
local AddonName, Addon = ...
local L = Addon:GetLocale()

-- The Horror - AdiBags uses ACE.
-- We still hate ACE and don't have to take a dependency on it because if AdiBags is loaded we'll use the one they have.
-- Since this addon depends on AdiBags to load, we are guaranteed to be loaded after AdiBags and therefore this is safe.
local adiBags = LibStub('AceAddon-3.0'):GetAddon('AdiBags')
local LAdiBags = setmetatable({}, {__index = adiBags.L})

-- For tracking whether we need to refresh AdiBags
local sellFilterEnabled = false
local destroyFilterEnabled = false

-- This will register a callback to AdiBags with Vendor so when vendor's evaluation changes, AdiBags will be refreshed.
local function registerAdiBagsExtension()
    local adiBagsExtension =
    {
        -- Vendor will check this source is loaded prior to registration.
        -- It will also be displayed in the Vendor UI.
        Source = "AdiBags",
        Addon = AddonName,

        -- This is called by Vendor whenever its rules change and AdiBags needs to update its filters.
        OnRuleUpdate = function()
            -- We'll only tell AdiBags to update filters if one of our filters is enabled.
            if sellFilterEnabled or destroyFilterEnabled then
                adiBags:UpdateFilters()
            end
        end
    }

    assert(Vendor and Vendor.RegisterExtension, "Vendor RegisterExtension not found, cannot register extension: "..tostring(adiBagsExtension.Source))
    if (not Vendor.RegisterExtension(adiBagsExtension)) then
        -- something went wrong
    end
end
registerAdiBagsExtension()


-- AdiBags Sell Filter for Vendor

-- Use highest priority, since Vendor could end up reclassifying absolutely anything in the bags.
local sellFilter = adiBags:RegisterFilter("VendorSell", 100, 'ABEvent-1.0')
sellFilter.uiName = "Vendor: Sell"
sellFilter.uiDesc = "Put items that the Vendor addon will sell at a merchant into this collection."..
" This filter must be a very high priority to work correctly, as it can reclassify any item in your inventory."

function sellFilter:OnInitialize()
    -- No settings, so nothing to initialize at this time.
end

function sellFilter:OnEnable()
    sellFilterEnabled = true
    adiBags:UpdateFilters()
end

function sellFilter:OnDisable()
    sellFilterEnabled = false
    adiBags:UpdateFilters()
end

function sellFilter:Filter(slotData)
    assert(Vendor and Vendor.EvaluateItem, "Expected Vendor functions not available. Something went horribly wrong; please report to Vendor Addon developers.")
    if not slotData then
        return
    end

    result = Vendor.EvaluateItem(slotData.bag, slotData.slot)
    if result == 1 then
        return L.CATEGORY_VENDOR_SELL, LAdiBags["Junk"]
    end
end

-- No filter options at this time
function sellFilter:GetFilterOptions()
    return
end

-- AdiBags Destroy Filter for Vendor

-- Use highest priority, since Vendor could end up reclassifying absolutely anything in the bags.
local destroyFilter = adiBags:RegisterFilter("VendorDestroy", 100, 'ABEvent-1.0')
destroyFilter.uiName = L.FILTER_VENDOR_DESTROY_NAME
destroyFilter.uiDesc = L.FILTER_VENDOR_DESTROY_DESC

function destroyFilter:OnInitialize()
    -- No settings, so nothing to initialize at this time.
end

function destroyFilter:OnEnable()
    destroyFilterEnabled = true
    adiBags:UpdateFilters()
end

function destroyFilter:OnDisable()
    destroyFilterEnabled = false
    adiBags:UpdateFilters()
end

function destroyFilter:Filter(slotData)
    assert(Vendor and Vendor.EvaluateItem, "Expected Vendor functions not available. Something went horribly wrong; please report to Vendor Addon developers.")
    if not slotData then
        return
    end

    result = Vendor.EvaluateItem(slotData.bag, slotData.slot)
    if result == 2 then
        return L.CATEGORY_VENDOR_DESTROY, LAdiBags["Junk"]
    end
end

-- No filter options at this time
function destroyFilter:GetFilterOptions()
    return
end