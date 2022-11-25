local AddonName, Addon = ...
local L = Addon:GetLocale();
local UI = Addon.CommonUI.UI
local function debugp(...) Addon:Debug("merchantbutton", ...) end


local AUTO_SELL_START = Addon.Events.AUTO_SELL_START
local AUTO_SELL_COMPLETE = Addon.Events.AUTO_SELL_COMPLETE
local DESTROY_START = Addon.Events.DESTROY_START
local DESTROY_COMPLETE = Addon.Events.DESTROY_COMPLETE
local MAX_SELL = Addon.c_Config_MaxSellItems
local AUTO_SELL_ITEM = Addon.Events.AUTO_SELL_ITEM
local MERCHANT_SELL_ITEMS = L["MERCHANT_SELL_ITEMS"]
local MERCHANT_DESTROY_ITEMS = L["MERCHANT_DESTROY_ITEMS"]
local PROFILE_CHANGED = Addon.Events.PROFILE_CHANGED
local EVALUATION_STATUS_UPDATED = Addon.Events.EVALUATION_STATUS_UPDATED
local ITEMRESULT_REFRESH_TRIGGERED = Addon.Events.ITEMRESULT_REFRESH_TRIGGERED




-- Feature Definition
local MerchantButton = {
    NAME = "MerchantButton",
    VERSION = 1,
    DEPENDENCIES = {
        "Merchant",
		"Destroy",
		"Status",
    },
}

MerchantButton.c_ButtonFrameName = string.format("%s_%s", AddonName, "MerchantButton")
MerchantButton.c_TooltipFrameName = string.format("%s_MerchantTooltip", AddonName)


function MerchantButton:OnInitialize()
	debugp("OnInitialize")
	self.isUpdatePending = false
	self.isAutoSellInProgress = false
	self.isDestroyInProgress = false
	self.totalCount = 0
	self.sellValue = 0
	self.sellItems = {}
	self.destroyItems = {}
	self.sellCount = 0
	self.destroyCount = 0
	self.nextDestroy = ""
	self.isOpen = false
	self.enabled = self.IsMerchantButtonEnabled()
end

function MerchantButton:OnTerminate()
	self:SaveState()
end

function MerchantButton:Enable()
	MerchantButton:SetupButton()
	if self.enabled then
		Addon:RegisterCallback(AUTO_SELL_START, self, self.OnAutoSellStarted)
		Addon:RegisterCallback(AUTO_SELL_COMPLETE, self, self.OnAutoSellComplete)
		Addon:RegisterCallback(DESTROY_START, self, self.OnDestroyStarted)
		Addon:RegisterCallback(DESTROY_COMPLETE, self, self.OnDestroyComplete)
		Addon:RegisterCallback(EVALUATION_STATUS_UPDATED, self, self.OnStatusUpdated)
		Addon:RegisterCallback(ITEMRESULT_REFRESH_TRIGGERED, self, self.OnRefreshTriggered)

		-- The autosell feature might be on and running right now.
		local selling = Addon:GetFeature("Merchant"):IsAutoSelling()
		self.isAutoSellInProgress = selling
		self.isUpdatePending = true	-- we just opened and dont know the real counts yet.

		local status = Addon:GetFeature("Status")
		status:EnableUrgentRefresh("merchantbutton")
		status:StartItemResultRefresh()    -- Zero delay scan
		self:UpdateSellState(selling)
	end
end

function MerchantButton:Disable()
	if (MerchantButton.frame) then
		MerchantButton.frame:Hide()
	end
	Addon:GetFeature("Status"):DisableUrgentRefresh("merchantbutton")
	Addon:UnregisterCallback(AUTO_SELL_START, self)
	Addon:UnregisterCallback(AUTO_SELL_COMPLETE, self)
	Addon:UnregisterCallback(DESTROY_START, self)
	Addon:UnregisterCallback(DESTROY_COMPLETE, self)
	Addon:UnregisterCallback(EVALUATION_STATUS_UPDATED, self)
	Addon:UnregisterCallback(ITEMRESULT_REFRESH_TRIGGERED, self)
end

function MerchantButton:ON_MERCHANT_SHOW()
	debugp("merchant open")
	self.isOpen = true
	self:Enable()
end

function MerchantButton:ON_MERCHANT_CLOSED()
	debugp("merchant closed")
	self.isOpen = false
	self:Disable()
end

function MerchantButton:OnStatusUpdated()
	self.isUpdatePending = false
	self.isAutoSellInProgress = false
	self.isDestroyInProgress = false
	self:UpdateSellState()
end

function MerchantButton:OnRefreshTriggered()
	--self.isUpdatePending = true
	self:UpdateSellState()
end



--[[===========================================================================
   | Called to update the state of our buttons on the merchant frame
   ==========================================================================]]
function MerchantButton:UpdateSellState()
	self.totalCount, self.sellValue, self.sellCount, self.destroyCount, self.sellItems, self.destroyItems, self.nextDestroy = Addon:GetEvaluationStatus()
	debugp("Updating state items to sell %d, destroy %d", self.sellCount, self.destroyCount)
	local isDisabled = self.isAutoSellInProgress or self.isDestroyInProgress
	self.frame:SetSellState(isDisabled, self.isUpdatePending, MERCHANT_SELL_ITEMS, self.sellCount)
	self.frame:SetDestroyState(isDisabled, self.isUpdatePending, MERCHANT_DESTROY_ITEMS, self.destroyCount)
end

local MerchantButtonFrame = {}

function MerchantButtonFrame:OnLoad()
	debugp("MerchantButtonFrame:OnLoad")
	self.Sell.HasTooltip = function()
			debugp("Sell::HasTooltip")
			return true
		end

	self.Sell.OnTooltip = function(self, tooltip)
			debugp("Sell::OnTooltip")
			tooltip:SetText(L.MERCHANT_SELL_BUTTON_TOOLTIP_TITLE, 1, 1, 0, 1, false)
			tooltip:AddLine("  "..table.concat(MerchantButton.sellItems, "\n  "))
		end

	debugp("MerchantButtonFrame:OnLoad")
	self.Destroy.HasTooltip = function()
			debugp("Destroy::HasTooltip")
			return true
		end

	self.Destroy.OnTooltip = function(self, tooltip)
			debugp("Destroy::OnTooltip")
			tooltip:SetText(L.MERCHANT_DESTROY_BUTTON_TOOLTIP_TITLE, 1, 1, 0, 1, false)
			tooltip:AddLine(L.MERCHANT_DESTROY_BUTTON_TOOLTIP_NEXT..MerchantButton.nextDestroy)
			if (MerchantButton.destroyCount > 1) then
				tooltip:AddLine(L.MERCHANT_DESTROY_BUTTON_TOOLTIP_REMAINING)
				tooltip:AddLine("  "..table.concat(MerchantButton.destroyItems, "\n  ", 2))
			end
		end
end

--[[ update the sell state ]]
function MerchantButtonFrame:SetSellState(disable, updatepending, text, count)
	UI.Enable(self.Sell, not disable and count ~= 0)
	if not updatepending then
		self.Sell:SetLabel(string.format(text, tostring(count)))
	else
		self.Sell:SetLabel(string.format(text, "..."))
	end
end

--[[ Set the destroy state ]]
function MerchantButtonFrame:SetDestroyState(disable, updatepending, text, count)
	UI.Enable(self.Destroy, not disable and count ~= 0)
	if not updatepending then
		self.Destroy:SetLabel(string.format(text, tostring(count)))
	else
		self.Destroy:SetLabel(string.format(text, "..."))
	end
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function MerchantButtonFrame:OnShow()
	debugp("Merchant button OnShow")
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function MerchantButtonFrame:OnHide()
	debugp("Merchant button OnHide")
end

--[[===========================================================================
   | Called when the sell button is clicked, run auto-sell
   ==========================================================================]]
function MerchantButtonFrame:OnSellClicked()
	debugp("auto-sell was clicked")
	Addon:GetFeature("Merchant"):AutoSell()
end

--[[===========================================================================
   | Called when the destory button is clicked, destroys one item
   ==========================================================================]]
function MerchantButtonFrame:OnDestroyClicked()
	debugp("destroy was clicked")
	if (not Addon:GetFeature("Merchant"):IsAutoSelling()) then
		Addon:GetFeature("Destroy"):DestroyItems()
	end
end

function MerchantButton:SetupButton()
	if (self.enabled) then
		if (not self.frame) then
			local frame = CreateFrame("Frame", self.c_ButtonFrameName, MerchantFrame, "Vendor_Merchant_Button")
			Addon.CommonUI.UI.Attach(frame, MerchantButtonFrame)
			frame:SetSellState(false, MERCHANT_SELL_ITEMS, 0)
			frame:SetDestroyState(false, MERCHANT_DESTROY_ITEMS, 0)	
			self.frame = frame;
		end
		self.frame:Show()
	else
		if (self.frame) then
			self.frame:Hide()
		end
	end
end

function MerchantButton:OnAutoSellStarted(limit)
	debugp("Merchant button auto-sell started (limit: %d) [%d]", limit, self.total or 0)
	self.isAutoSellInProgress = true
	self.isUpdatePending = true
	self:UpdateSellState()
end
   
function MerchantButton:OnAutoSellComplete()
	debugp("Merchant button auto-sell completed")
	self:UpdateSellState()
end

function MerchantButton:OnDestroyStarted()
	debugp("Merchant button destroy started")
	self.isDestroyInProgress = true
	self:UpdateSellState()
end
   
function MerchantButton:OnDestroyComplete(item)
	debugp("Merchant button destroy completed: %s", tostring(item))
	self:UpdateSellState()
end   


-- Default merchant settings
merchantDefault = {
	enabled = true,
}

local function resetMerchantDataToDefault()
    debugp("Resetting MerchantButton data to defaults.")
    Addon:SetAccountSetting(Addon.c_Config_MerchantData, merchantDefault)
end

local function updateMerchantButtonVisibility()
    local accountMerchantData = Addon:GetAccountSetting(Addon.c_Config_MerchantData)
    assert(accountMerchantData and type(accountMerchantData.enabled) == "boolean", "Error retrieving settings for MerchantButton")
    debugp("Updating button visibility. Enabled = %s", tostring(accountMerchantData.enabled ))
    if accountMerchantData.enabled then
		if not MerchantButton.enabled then
    	    MerchantButton.enabled = true
			if MerchantButton.isOpen then
				MerchantButton:Enable()
			end
		end
    else
		if MerchantButton.enabled then
			MerchantButton.enabled = false
			if MerchantButton.isOpen then
				MerchantButton:Disable()
			end
		end
    end
end

function MerchantButton:SaveState()
    -- It's possible the minimap button wasn't created if the dependency is missing.
    debugp("Saving MerchantButton Settings")
    -- The button holds truth since it can be manipulated by other addons to manage how minimap buttons
    -- appear. So another addon may disable our minimap button on the user's behalf so we will reflect
    -- that state here.
    -- It's possible the minimap button wasn't created if the dependency is missing.

    -- Remove old bad data by creating new table.
    local state = {
        enabled = self.enabled,
    }

    debugp("State: Enabled = %s", tostring(state.enabled))
    Addon:SetAccountSetting(Addon.c_Config_MerchantData, state)
end

function MerchantButton:CreateSettingForMerchantButton()
    return Addon.Features.Settings.CreateSetting(nil, true, self.IsMerchantButtonEnabled, self.SetMerchantButtonEnabled)
end

function MerchantButton.IsMerchantButtonEnabled()
    local accountMerchantData = Addon:GetAccountSetting(Addon.c_Config_MerchantData)
    if accountMerchantData then
        return accountMerchantData.enabled
    else
        -- Going to assume that if the data is corrupted or missing they want the minimap button.
        -- this should help get back into a good state.
        resetMerchantDataToDefault()
        return true
    end
end

function MerchantButton.SetMerchantButtonEnabled(value)
    local accountMerchantData = Addon:GetAccountSetting(Addon.c_Config_MerchantData)
    if value then
        accountMerchantData.enabled = true
    else
        accountMerchantData.enabled = false
    end
    Addon:SetAccountSetting(Addon.c_Config_MerchantData, accountMerchantData)
end

function MerchantButton:OnAccountSettingChange(settings)
    if (settings[Addon.c_Config_MerchantData]) then
        debugp("MerchantButton Settings Update")
        updateMerchantButtonVisibility()
    end
end

Addon.Features.MerchantButton = MerchantButton