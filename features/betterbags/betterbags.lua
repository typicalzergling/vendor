local _, Addon = ...
local locale = Addon:GetLocale()
local ItemProperties = Addon.Systems.ItemProperties

local function debugp(msg, ...) Addon:Debug("betterbags",  msg, ...) end

local BetterBags= { 
    NAME = "BetterBags",
    VERSION = 1, 
    DEPENDENCIES = { "rules", "settings", "addon:betterbags" },
    BETA = true,
    DESCRIPTION = [[Description of the BetterBags feature]],
    OPTIONAL = true,

    c_EnabledFiltersKey = "betterbags:enabled-filters",
    c_EnableSellFilter = "betterbags:enable-sell-filter",
    c_EnableDestroyFilter = "betterbags:enable-junk-filter",

    sellFilter = nil,
    destroyFilter = nil,
    filters = {}
}

function BetterBags:IsBetterBagsEnabled()
    local addon = {Addon:GetAddOnInfo('BetterBags')}
    for k, v in pairs(addon) do
        debugp(" "..tostring(k).." Value: "..tostring(v))
    end
    local loadable = select(4, addon)
    if loadable then
        debugp("Not present, exiting")
        return false
    end

    local enabledForCharacter = {C_AddOns.GetAddOnEnableState("BetterBags", UnitGUID("player"))}
    debugp("Enabledstate: "..tostring(enabledForCharacter))
    for k, v in pairs(enabledForCharacter) do
        debugp("K = "..tostring(k).." V = "..tostring(v))
    end
    if enabledForCharacter[1] == 0 then
        debugp("Not enabled for current character, exiting")
        return false
    end

    return true
end

function BetterBags:OnInitialize()
    debugp("BetterBags.OnInitialize()")

    if not self:IsBetterBagsEnabled() then return end

    self.ruleFeature = Addon:GetFeature("rules")
    self.betterbags = LibStub('AceAddon-3.0'):GetAddon('BetterBags')
    self.betterbagsLoc = setmetatable({}, { __index = self.betterbags.L })

    debugp("BetterBags loaded")
    local settings = Addon:GetFeature("Settings")
    settings:RegisterPage(
        "BETTERBAGS_SETTINGS_NAME",
        "BETTERBAGS_SETTINGS_SUMMARY",
        function(parent)
            local frame = CreateFrame("Frame", nil, parent or UIParent, "Vendor_BetterBags_Settings")
            Addon.CommonUI.UI.Attach(frame, self.Settings)
            return frame
        end, nil, false)

    local profile = Addon:GetProfile()

    if (profile:GetValue(self.c_EnableSellFilter) == nil) then
        profile:SetValue(self.c_EnableSellFilter, true)
    end

    if (profile:GetValue(self.c_EnableDestroyFilter) == nil) then
        profile:SetValue(self.c_EnableDestroyFilter, true)
    end

    self:OnProfileChanged(profile)
end

function BetterBags:OnTerminate()
    debugp("BetterBags.OnTerminate()")

    local settings = Addon:GetFeature("settings")
    settings:UnregisterPage("BETTERBAGS_SETTINGS_NAME")

    if (self.sellFIlter) then
        self.sellFIlter:Disable()
    end

    if (self.destroyFilter) then
        self.destroyFilter:Disable()
    end

    for _, filter in pairs(self.filters) do
        filter:DisableFIlter()
    end

    if (self.betterbags) then
        self.betterbags:UpdateFilters()
    end

    self.betterbags = nil
    self.betterbagsLoc = nil
end


-- BetterBags Sell Filter for Vendor
function BetterBags:CreateSellFilter()
    -- Use highest priority, since Vendor could end up reclassifying absolutely anything in the bags.
    local sellFilter = self.betterbags:RegisterFilter("VendorSell", 100, 'BBEvent-1.0')
    sellFilter.uiName = locale:GetString("BETTERBAGS_FILTER_VENDOR_SELL_NAME")
    sellFilter.uiDesc = locale:GetString("BETTERBAGS_FILTER_VENDOR_SELL_DESC")
    sellFilter.cannotDisable = true
    sellFilter.categroy = locale:GetString("BETTERBAGS_CATEGORY_VENDOR_SELL") 
    sellFilter.junk = self.betterbagsLoc.Junk

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

-- BetterBags Destroy Filter for Vendor
function BetterBags:CreateDestroyFilter()
    -- Use highest priority, since Vendor could end up reclassifying absolutely anything in the bags.
    local destroyFilter = self.betterbags:RegisterFilter("VendorDestroy", 100, 'BBEvent-1.0')
    destroyFilter.uiName = locale:GetString("BETTERBAGS_FILTER_VENDOR_DESTROY_NAME")
    destroyFilter.uiDesc = locale:GetString("BETTERBAGS_FILTER_VENDOR_DESTROY_DESC")
    destroyFilter.cannotDisable = true
    destroyFilter.categroy = locale:GetString("BETTERBAGS_CATEGORY_VENDOR_DESTROY")
    destroyFilter.junk = self.betterbagsLoc.Junk
    
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

function BetterBags:CreateRuleFilter(rule)
    local ruleFeature = self.ruleFeature

    if (not self.filterEngine) then
        self.filterEngine = Addon:CreateRulesEngine()
        self.filterEngine:CreateCategory(1, "=betterbags=", 0)
    end

    -- For regular rules start with apriority jsut below the highest
    local filter = self.betterbags:RegisterFilter(rule.Id, 90, 'BBEvent-1.0')
    filter.rule = rule
    filter.cannotDisable = true
    filter.uiName = locale:FormatString("BETTERBAGS_RULEFILTER_NAME_" .. string.upper(rule.Type), rule.Name)
    if (type(rule.Description) == "stirng") then
        filter.uiDesc = locale:FormatString("BETTERBAGS_RULEFILTER_DESCRIPTION_FMT", rule.Description)
    else
        filter.uiDesc = locale:GetString("BETTERBAGS_RULEFILTER_NO_DESCRIPTION")
    end
    filter.category = locale:FormatString("BETTERBAGS_RULEFILTER_CATEGORY_" .. string.upper(rule.Type), rule.Name)
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

function BetterBags:OnProfileChanged(profile)
    debugp("BetterBags: profile changed")
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

    debugp("Notifying BetterBags of changes")
    if (self.betterbags) then
        self.betterbags:UpdateFilters()
    end
end

function BetterBags:OnRulesChanged()
    debugp("Rules have changed")

    for _, filter in pairs(self.filters) do
        filter:UpdateRule()
    end

    if (self.betterbags) then
        self.betterbags:UpdateFilters()
    end
end

Addon.Features.BetterBags = BetterBags