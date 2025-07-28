local AddonName, Addon = ...
local L = Addon:GetLocale()
local function debugp(...) Addon:Debug("ldbstatus", ...) end

-- Feature Definition
local StatusPlugin = {
    NAME = "StatusPlugin",
    VERSION = 1,
    DEPENDENCIES = { 
        "LibDataBroker",     -- This is just for feature load order, we don't actually depend on it.
        --"ItemProtection",  -- Optional dependency on ItemProtection, we can't take a dependency since it may not exist.
        "Status",
    },
}

local ldbstatusplugin = nil

-- Local data for the plugin
local isUpdatePending = false
local totalCount = 0
local sellValue = 0
local sellCount = 0
local deleteCount = 0
local totalCountStr = ""
local sellCountStr = ""
local sellValueStr = ""
local deleteCountStr = ""
local statusStr = ""
local sellItems = {}
local deleteItems = {}
local protectionEnabled = false

local function updateStatus()
    totalCount, sellValue, sellCount, deleteCount, sellItems, deleteItems = Vendor.GetEvaluationStatus()
    totalCountStr = tostring(totalCount)
    sellCountStr = tostring(sellCount)
    deleteCountStr = tostring(deleteCount)
    sellValueStr = Addon:GetPriceString(sellValue)
    statusStr = HIGHLIGHT_FONT_COLOR_CODE .. totalCountStr .. FONT_COLOR_CODE_CLOSE .. "  " .. sellValueStr

    -- protectionEnabled will be updated on the OnProfileChanged callback since that will only change
    -- if the profile changes, we dont' need to check it constantly.

    if ldbstatusplugin then
        ldbstatusplugin.text = statusStr
    end
    debugp("Status Updated")
end

local DATAOBJECT_NAME = AddonName
local plugin_definition = {
    type = "data source",
    text = "Updating...",
	label = L.ADDON_NAME,
    icon = "Interface\\Addons\\Vendor\\assets\\TreasureGolem",
    OnClick = function(self, button)
        debugp("In OnClick Handler")
        if button == "RightButton" then
            local protection = Addon:GetFeature("ItemProtection")
            if protection and IsShiftKeyDown() then
                -- If SHIFT + Right click -> toggle protection state
                protection:ToggleProtectionState()
            else
                -- Right click -> Open Profiles
                Vendor.ShowProfiles()
            end
        else
            local profile = Addon:GetProfile();
            local showItemDialog = profile:GetValue(Addon.c_Config_ShowItemDialog) or false
            local itemDialog = Addon:GetFeature("ItemDialog")
            local item = C_Cursor.GetCursorItem()
            if item and itemDialog and showItemDialog then
                itemDialog:ShowDialog()
            else
                if (IsShiftKeyDown()) then
                    -- If SHIFT is held, Run Destroy for one item.
                    Addon:Destroy_Cmd()
                else
                    -- Left click -> Open Rules
                    Vendor.ShowRules()
                end
            end
        end
    end,
    OnTooltipShow = function(self)
        -- TODO: Build this a bit more efficiently.
        debugp("In OnTooltipShow Handler")
        if isUpdatePending then
            self:AddLine(L.LDB_BUTTON_TOOLTIP_TITLEREFRESH, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        else
            self:AddLine(L.LDB_BUTTON_TOOLTIP_TITLE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        end
        self:AddDoubleLine(L.LDB_BUTTON_TOOLTIP_VALUE, sellValueStr)
        self:AddLine(" ")
        self:AddDoubleLine(L.LDB_BUTTON_TOOLTIP_TOSELL, sellCountStr)
        self:AddLine("    "..table.concat(sellItems, "\n    "))
        self:AddLine(" ")
        self:AddDoubleLine(L.LDB_BUTTON_TOOLTIP_TODESTROY, deleteCountStr)
        self:AddLine("    "..table.concat(deleteItems, "\n    "))

        -- Add protection state if protection feature exists
        if Addon:IsFeatureEnabled("ItemProtection") then
            self:AddLine(" ")
            if (protectionEnabled) then
                self:AddLine(L.LDB_BUTTON_TOOLTIP_PROTECTIONSTATUS_ON, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            else
                self:AddLine(L.LDB_BUTTON_TOOLTIP_PROTECTIONSTATUS_OFF, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            end
        end

        if not IsAltKeyDown() then
            -- Tell user how to see more help
            self:AddLine(L.LDB_BUTTON_TOOLTIP_HOWTOSHOWHELP)
        else
            -- Add the help
            self:AddLine(" ")
            self:AddLine(L.LDB_BUTTON_TOOLTIP_HELP_TITLE)
            self:AddLine(L.LDB_BUTTON_TOOLTIP_HELP_RULES, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            self:AddLine(L.LDB_BUTTON_TOOLTIP_HELP_PROFILES, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            self:AddLine(L.LDB_BUTTON_TOOLTIP_HELP_DESTROY, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            if Addon.Systems.Info.IsRetailEra then
                -- Protection is Retail-only feature
                self:AddLine(L.LDB_BUTTON_TOOLTIP_HELP_PROTECTION, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
            end
        end
    end,
}

-- We can use the same definition internally, with or without LDB there to consume it.
function StatusPlugin:GetStatusPluginDefinition()
    return plugin_definition
end

function StatusPlugin:CreateLDBDataObject()
    if ldbstatusplugin then return true end

    local ldb = Addon:GetFeature("LibDataBroker")
    if (not ldb or not ldb:IsLDBAvailable()) then
        debugp("LibDataBroker not available: %s", tostring(ldb))
        return
    end

    ldbstatusplugin = ldb:CreateLDBDataObject(DATAOBJECT_NAME, plugin_definition)
    debugp("Plugin Created: %s", tostring(not not ldbstatusplugin))
end

function StatusPlugin:GetDataObjectName()
    return DATAOBJECT_NAME
end

function StatusPlugin:Update()
    debugp("Updating...")
    updateStatus()
end

function StatusPlugin:OnProfileChanged()
    local feature = Addon:GetFeature("ItemProtection")
    if feature then
        protectionEnabled = feature:IsProtectionEnabled()
    end
end

function StatusPlugin:OnStatusUpdated()
    isUpdatePending = false
    self:Update()
end

function StatusPlugin:OnRefreshTriggered()
    isUpdatePending = true
    self:Update()
end

function StatusPlugin:OnInitialize()
    debugp("Initializing plugin")

    -- We don't actually need this to be successful
    self:CreateLDBDataObject()

    Addon:RegisterCallback(Addon.Events.EVALUATION_STATUS_UPDATED, self, self.OnStatusUpdated)
    Addon:RegisterCallback(Addon.Events.ITEMRESULT_REFRESH_TRIGGERED, self, self.OnRefreshTriggered)
    Addon:RegisterCallback(Addon.Events.PROFILE_CHANGED, self, self.OnProfileChanged)

    -- This will set default values for the plugin data.
    StatusPlugin:OnProfileChanged()
    updateStatus()
end

Addon.Features.StatusPlugin = StatusPlugin