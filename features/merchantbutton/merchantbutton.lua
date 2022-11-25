local AddonName, Addon = ...
local L = Addon:GetLocale();
local UI = Addon.CommonUI.UI
local function debugp(...) Addon:Debug("merchantbutton", ...) end


local AUTO_SELL_START = Addon.Events.AUTO_SELL_START
local AUTO_SELL_COMPLETE = Addon.Events.AUTO_SELL_COMPLETE
local MAX_SELL = Addon.c_Config_MaxSellItems
local AUTO_SELL_ITEM = Addon.Events.AUTO_SELL_ITEM
local MERCHANT_SELL_ITEMS = L["MERCHANT_SELL_ITEMS"]
local MERCHANT_DESTROY_ITEMS = L["MERCHANT_DESTROY_ITEMS"]
local PROFILE_CHANGED = Addon.Events.PROFILE_CHANGED



-- Feature Definition
local MerchantButton = {
    NAME = "MerchantButton",
    VERSION = 1,
    DEPENDENCIES = {
        "Merchant",
		"Destroy",
    },
}

MerchantButton.c_ButtonFrameName = string.format("%s_%s", AddonName, "MerchantButton")
MerchantButton.c_TooltipFrameName = string.format("%s_MerchantTooltip", AddonName)


function MerchantButton:OnInitialize()
	debugp("OnInitialize")
    --Addon:SecureHookWidget(MerchantFrame, "OnShow", MerchantButton.OnMerchantOpened)
    --Addon:SecureHookWidget(MerchantFrame, "OnHide", MerchantButton.OnMerchantClosed)

	self.limit = 0
	self.sold = 0
	self.total = 0
end

function MerchantButton:OnTerminate()
end

function MerchantButton:ON_MERCHANT_SHOW()
	debugp("merchant open")
	MerchantButton.SetupButton()

	Addon:RegisterCallback(AUTO_SELL_START, self, self.OnAutoSellStarted)
	Addon:RegisterCallback(AUTO_SELL_COMPLETE, self, self.OnAutoSellComplete)
	Addon:RegisterCallback(PROFILE_CHANGED, MerchantButton, MerchantButton.SetupButton)

	local selling = Addon:GetFeature("Merchant"):IsAutoSelling()
	self.inProgress = selling
	self:UpdateSellState(selling)
end

function MerchantButton:ON_MERCHANT_CLOSED()
	debugp("merchant closed")
	if (MerchantButton.frame) then
		MerchantButton.frame:Hide()
	end

	Addon:UnregisterCallback(AUTO_SELL_START, self)
	Addon:UnregisterCallback(AUTO_SELL_COMPLETE, self)
end

--[[===========================================================================
   | Called to update the state of our buttons on the merchant frame
   ==========================================================================]]
function MerchantButton:UpdateSellState(inProgress)
	if (inProgress) then
		local left = math.max(0, self.limit - self.sold)
		if (left > 0) then
			debugp("Updating button to reflect sold item: %s left", tostring(left))
			self.frame:SetSellState(inProgress, MERCHANT_SELL_ITEMS, left)
		end
	else		
		local _, _, toSell, toDestroy = Addon:GetEvaluationStatus()
		debugp("Updating state items to sell %d, destory %d", toSell, toDestroy)

		self.total = toSell
		self.frame:SetSellState(inProgress, MERCHANT_SELL_ITEMS, toSell)
		self.frame:SetDestroyState(inProgress, MERCHANT_DESTROY_ITEMS, toDestroy)
	end
end

local MerchantButtonFrame = {}

function MerchantButtonFrame:OnLoad()
	debugp("MerchantButtonFrame:OnLoad")
	self.Sell.HasTooltip = function()
			debugp("Sell::HasTooltip")
			return true
		end

	self.Sell.OnTooltip = function(self, tooltip)
			debugp("Sel::OnTooltip")
			tooltip:SetText("--- sell button tooltip text --", 1, 1, 1, true)
		end
end

--[[ update the sell state ]]
function MerchantButtonFrame:SetSellState(inprogress, text, count)
	UI.Enable(self.Sell, not inprogress and count ~= 0)	
	self.Sell:SetLabel(string.format(text, count))
end

--[[ Set the destroy state ]]
function MerchantButtonFrame:SetDestroyState(inprogress, text, count)
	UI.Enable(self.Destroy, not inprogress and count ~= 0)
	self.Destroy:SetLabel(string.format(text, count))
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
	debugp("merchantbutton", "Merchant button onHide")
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
	debugp("Upadding button state: %s", state)
	if (state) then
		if (not MerchantButton.frame) then
			local frame = CreateFrame("Frame", MerchantButton.c_ButtonFrameName, MerchantFrame, "Vendor_Merchant_Button")
			Addon.CommonUI.UI.Attach(frame, MerchantButtonFrame)
			frame:SetSellState(false, MERCHANT_SELL_ITEMS, 0)
			frame:SetDestroyState(false, MERCHANT_DESTROY_ITEMS, 0)	
			MerchantButton.frame = frame;
			--frame:ObserveProfile()
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
	self.inProgress = true

	if (limit == 0) then
		self.limit = self.total
	else
		self.limit = 0
	end
	
	self.sold = 0
	self:UpdateSellState(true)
	Addon:RegisterCallback(AUTO_SELL_ITEM, self, self.OnAutoSellItem)
end
   
function MerchantButton:OnAutoSellComplete()
	debugp("Merchant buton auto-sell completed")
	Addon:UnregisterCallback(AUTO_SELL_ITEM, self)

	self.inProgress = false
	self.total = 0
	self.limit = 0
	self.sold = 0
	self:UpdateSellState(false)
end   

function MerchantButton:OnAutoSellItem(link, sold, limit)
	if (self.inProgress) then
		debugp("Auto-sold item updating button status %d / %d [%d]", sold, limit, self.total)
		self.itemLimit = math.min(limit, self.total)
		self.sold = sold
		self:UpdateSellState(true)
	end
end

Addon.Features.MerchantButton = MerchantButton