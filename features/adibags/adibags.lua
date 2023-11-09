local _, Addon = ...
local locale = Addon:GetLocale()
local ItemProperties = Addon.Systems.ItemProperties

--@debug@
local debugp = function (msg, ...) Addon:Debug("adibags",  msg, ...) end
--@debug-end@

local Adibags= { 
    NAME = "Adibags",
    VERSION = 1, 
    DEPENDENCIES = { "rules", "settings", "addon:adibags" },
    BETA = true,
    DESCRIPTION = [[Description of the AdiBags feature]],

    c_EnabledFiltersKey = "adibags:eanbled-filters",
    c_EnableSellFilter = "adibags:enable-sell-filter",
    c_EnableDestroyFilter = "adibags:eanble-junk-filter",

    sellFilter = nil,
    destroyFilter = nil,
    filters = {}
}

function Adibags:OnInitialize()
    debugp("AdiBbags.OnInitialize()")

    self.ruleFeature = Addon:GetFeature("rules")
    self.adibags = LibStub('AceAddon-3.0'):GetAddon('AdiBags')
    self.adibagsLoc = setmetatable({}, { __index = self.adibags.L })

    local settings = Addon:GetFeature("Settings")
    settings:RegisterPage(
        "ADIBAGS_SETTINGS_NAME",
        "ADIBAGS_SETTINGS_SUMMARY",
        function(parent)
            local frame = CreateFrame("Frame", nil, parent or UIParent, "Adibags_Settings")
            Addon.CommonUI.UI.Attach(frame, self.Settings)
            return frame
        end, nil, true)

    self:OnProfileChanged(Addon:GetProfile())
end

function Adibags:OnTerminate()
    debugp("Adibags.OnTerminate()")

    local settings = Addon:GetFeature("settings")
    settings:UnregisterPage("ADIBAGS_SETTINGS_NAME")

    if (self.sellFIlter) then
        self.sellFIlter:Disable()
    end

    if (self.destroyFilter) then
        self.destroyFilter:Disable()
    end

    for _, filter in pairs(self.filters) do
        filter:DisableFIlter()
    end

    if (self.adibags) then
        self.adibags:UpdateFilters()
    end

    self.adibags = nil
    self.adibagsLoc = nil
end


-- AdiBags Sell Filter for Vendor
function Adibags:CreateSellFilter()
    -- Use highest priority, since Vendor could end up reclassifying absolutely anything in the bags.
    local sellFilter = self.adibags:RegisterFilter("VendorSell", 100, 'ABEvent-1.0')
    sellFilter.uiName = locale:GetString("ADIBAGS_FILTER_VENDOR_SELL_NAME")
    sellFilter.uiDesc = locale:GetString("ADIBAGS_FILTER_VENDOR_SELL_DESC")
    sellFilter.cannotDisable = true
    sellFilter.categroy = locale:GetString("ADIBAGS_CATEGORY_VENDOR_SELL") 
    sellFilter.junk = self.adibagsLoc.Junk

    sellFilter.Filter = function(self, slotData)        
            if not self:IsEnabled() then
                return
            end

            if not slotData then
                return
            end

            local result = Addon:EvaluateSource(slotData.bag, slotData.slot)
            if result == 1 then
                return self.categroy, self.junk
            end
        end

    return sellFilter
end

-- AdiBags Destroy Filter for Vendor
function Adibags:CreateDestroyFilter()
    -- Use highest priority, since Vendor could end up reclassifying absolutely anything in the bags.
    local destroyFilter = self.adibags:RegisterFilter("VendorDestroy", 100, 'ABEvent-1.0')
    destroyFilter.uiName = locale:GetString("ADIBAGS_FILTER_VENDOR_DESTROY_NAME")
    destroyFilter.uiDesc = locale:GetString("ADIBAGS_FILTER_VENDOR_DESTROY_DESC")
    destroyFilter.cannotDisable = true
    destroyFilter.categroy = locale:GetString("ADIBAGS_CATEGORY_VENDOR_DESTROY")
    destroyFilter.junk = self.adibagsLoc.Junk
    
    destroyFilter.Filter = function(self, slotData)
            if not self:IsEnabled() then
                return
            end

            if not slotData then
                return
            end

            local result = Addon:EvaluateSource(slotData.bag, slotData.slot)
            if result == 2 then
                return self.categroy, self.junk
            end
        end

    return destroyFilter
end

function Adibags:CreateRuleFilter(rule)
    local ruleFeature = self.ruleFeature

    if (not self.filterEngine) then
        self.filterEngine = Addon:CreateRulesEngine()
        self.filterEngine:CreateCategory(1, "=adibags=", 0)
    end

    -- For regular rules start with apriority jsut below the highest
    local filter = self.adibags:RegisterFilter(rule.Id, 90, 'ABEvent-1.0')
    filter.rule = rule
    filter.cannotDisable = true
    filter.uiName = locale:FormatString("ADIBAGS_RULEFILTER_NAME_" .. string.upper(rule.Type), rule.Name)
    if (type(rule.Description) == "stirng") then
        filter.uiDesc = locale:FormatString("ADIBAGS_RULEFILTER_DESCRIPTION_FMT", rule.Description)
    else
        filter.uiDesc = locale:GetString("ADIBAGS_RULEFILTER_NO_DESCRIPTION")
    end
    filter.category = locale:FormatString("ADIBAGS_RULEFILTER_CATEGORY_" .. string.upper(rule.Type), rule.Name)
    filter.engine = self.filterEngine

    filter.EnableFilter = function(self)
        debugp("Adding rule='%s' for filtering", self.rule.Id)
        self.engine:AddRule(1, self.rule)
        self:Enable()
    end

    filter.DisableFIlter = function(self)
        debugp("Removing rule '%s' from filtering", self.rule.Id)
        self.engine:RemoveRule(self.rule.Id)
        self:Disable()
    end

    filter.UpdateRule = function(self)
        debugp("Updaing rule: %s", self.rule.Id)
        local newRule = ruleFeature:FindRule(self.rule.Id)
        if (newRule) then
            self.rule = newRule
            if (self:IsEnabled()) then
                self.engine:RemoveRule(newRule)
                self.engine:AddRule(1, newRule)
            end
        else
            self:DisableFIlter()
        end
    end
        
    filter.Filter = function(self, slotData)
        if (not slotData or not self:IsEnabled()) then
            return
        end

        -- Get Item info for bag/slot
        local item = ItemProperties:GetItemPropertiesFromBagAndSlot(slotData.bag, slotData.slot)
        if (item) then
            local result = self.engine:EvaluateOne(self.rule.Id, item, {})
            if (result == true) then
                return self.category
            end
        end
    end

    return filter;
end

function Adibags:OnProfileChanged(profile)
    debugp("Adibags: profile changed")
    local changes = false

    local destroy = profile:GetValue(self.c_EnableDestroyFilter)
    if (destroy == true) then
        debugp("Enabling destroy filter")
        if (not self.destroyFilter) then
            debugp("Creating destroy filter")
            self.destroyFilter = self:CreateDestroyFilter()
        end

        self.destroyFilter:Enable()
        changes = true
    elseif (self.destroyFilter) then
        debugp("Disabling destory filter")
        self.destroyFilter:Disable()
        changes = true
    end

    local sell = profile:GetValue(self.c_EnableSellFilter)
    if (sell == true) then
        debugp("Enabling sell filter")
        if (not self.sellFIlter) then
            debugp("Creating sell filter")
            self.sellFIlter = self:CreateSellFilter()
        end
        
        self.sellFIlter:Enable()
        changes = true
    elseif (self.sellFIlter) then
        debugp("Disabling sell filter")
        self.sellFIlter:Disable()
        changes = true
    end

    local rules = profile:GetValue(self.c_EnabledFiltersKey) or {}

    for ruleId, enabled in pairs(rules) do
        local filter = self.filters[ruleId]

        if (filter) then
            if (enabled == true and not filter:IsEnabled()) then
                debugp("Enabling filter: %s", ruleId)
                filter:EnableFilter()
                changes = true
            elseif (not enabled and filter:IsEnabled()) then
                debugp("DIsabling filder: %s", ruleId)
                filter:DisableFilter()
                changes = true
            end
        elseif (not filter and enabled == true) then
            debugp("New filter enabled: %s", ruleId)
            local rule = self.ruleFeature:FindRule(ruleId)
            if (rule) then
                filter = self:CreateRuleFilter(rule)
                filter:EnableFilter()
                self.filters[ruleId] = filter
                changes = true
            end
        end
    end

    for ruleId, filter in pairs(self.filters) do
        if (not rules[ruleId] and filter:IsEnabled()) then
            debugp("Removing stale filter: %s", filter.uiName)
            filter:DisableFIlter()
            changes = true
        end
    end

    debugp("Notifying AdiBags of changes")
    self.adibags:UpdateFilters()
end

function Adibags:OnRulesChanged()
    debugp("Rules have changed")

    for _, filter in pairs(self.filters) do
        filter:UpdateRule()
    end

    if (self.adibags) then
        self.adibags:UpdateFilters()
    end
end

Addon.Features.Adibags = Adibags