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
	self.enabled = true
end

function MerchantButton:OnTerminate()
end

function MerchantButton:ON_MERCHANT_SHOW()
	debugp("merchant open")
	MerchantButton.SetupButton()
	if self.enabled then
		Addon:RegisterCallback(AUTO_SELL_START, self, self.OnAutoSellStarted)
		Addon:RegisterCallback(AUTO_SELL_COMPLETE, self, self.OnAutoSellComplete)
		Addon:RegisterCallback(DESTROY_START, self, self.OnDestroyStarted)
		Addon:RegisterCallback(DESTROY_COMPLETE, self, self.OnDestroyComplete)
		Addon:RegisterCallback(PROFILE_CHANGED, MerchantButton, MerchantButton.SetupButton)
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

function MerchantButton:ON_MERCHANT_CLOSED()
	debugp("merchant closed")
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
			tooltip:SetText("Auto-Sell", 1, 1, 0, 1, false)
			tooltip:AddLine("  "..table.concat(MerchantButton.sellItems, "\n  "))
		end

	debugp("MerchantButtonFrame:OnLoad")
	self.Destroy.HasTooltip = function()
			debugp("Destroy::HasTooltip")
			return true
		end

	self.Destroy.OnTooltip = function(self, tooltip)
			debugp("Destroy::OnTooltip")
			tooltip:SetText("Destroy Next Item", 1, 1, 0, 1, false)
			tooltip:AddLine("Next to be destroyed:\n  "..MerchantButton.nextDestroy)
			if (MerchantButton.destroyCount > 1) then
				tooltip:AddLine("Remaining:")
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

function MerchantButton.SetupButton()
	--local state = Addon:GetProfile():GetValue(MERCHANT)
	local state = true
	debugp("Updating button state: %s", state)
	if (state) then
		if (not MerchantButton.frame) then
			local frame = CreateFrame("Frame", MerchantButton.c_ButtonFrameName, MerchantFrame, "Vendor_Merchant_Button")
			Addon.CommonUI.UI.Attach(frame, MerchantButtonFrame)
			frame:SetSellState(false, MERCHANT_SELL_ITEMS, 0)
			frame:SetDestroyState(false, MERCHANT_DESTROY_ITEMS, 0)	
			MerchantButton.frame = frame;
		end
		MerchantButton.frame:Show()
	else
		if (MerchantButton.frame) then
			MerchantButton.frame:Hide()
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


Addon.Features.MerchantButton = MerchantButton