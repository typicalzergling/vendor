local AddonName, Addon = ...
local L = Addon:GetLocale();
local ButtonState = Addon.MerchantButton
local MERCHANT = Addon.c_Config_MerchantButton
local AUTO_SELL_START = Addon.Events.AUTO_SELL_START
local AUTO_SELL_COMPLETE = Addon.Events.AUTO_SELL_COMPLETE
local MAX_SELL = Addon.c_Config_MaxSellItems
local AUTO_SELL_ITEM = Addon.Events.AUTO_SELL_ITEM
local MERCHANT_SELL_ITEMS = L["MERCHANT_SELL_ITEMS"]
local MERCHANT_DESTROY_ITEMS = L["MERCHANT_DESTROY_ITEMS"]
local PROFILE_CHANGED = Addon.Events.PROFILE_CHANGED

local MerchantButton = 
{
	Events = { "BAG_UPDATE" },
	_autoHookHandlers = true
}

--[[===========================================================================
   | Called when this panel is loaded 
   ==========================================================================]]
function MerchantButton:OnLoad()
	Addon:Debug("merchantbutton", "OnLoad of merchant button")
end

--[[===========================================================================
   | Called to adjust the button state of sell/destroy
   ==========================================================================]]
function MerchantButton:SetButtonState(button, text, count)
	button:SetFormattedText(text, count)
	if (count == 0 or self.inProgress) then
		button:Disable()
	else
		button:Enable()
	end
end

--[[===========================================================================
   | Called to update the state of our buttons on the merchant frame
   ==========================================================================]]
function MerchantButton:UpdateSellState(inProgress)
	local sell = self.Sell
	local destroy = self.Destroy

	if (inProgress) then
		sell:Disable()
		destroy:Disable()

		local left = math.max(0, self.limit - self.sold)
		if (left > 0) then
			Addon:Debug("merchantbutton", "Updating button to reflect sold item: %d left", left)
			self:SetButtonState(sell, MERCHANT_SELL_ITEMS, left)
		end
	else		
		local _, _, toSell, toDestroy = Addon:GetEvaluationStatus()
		Addon:Debug("merchantbutton", "Updating state items to sell %d, destory %d", toSell, toDestroy)

		self.total = toSell
		self:SetButtonState(sell, MERCHANT_SELL_ITEMS, toSell)
		self:SetButtonState(destroy, MERCHANT_DESTROY_ITEMS, toDestroy)
	end
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function MerchantButton:OnShow()
	Addon:Debug("merchantbutton", "Merchant button OnShow")
	Addon:RegisterCallback(AUTO_SELL_START, self, self.OnAutoSellStarted)
	Addon:RegisterCallback(AUTO_SELL_COMPLETE, self, self.OnAutoSellComplete)

	local selling = Addon:IsAutoSelling()
	self.inProgress = selling
	self:UpdateSellState(selling)
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function MerchantButton:OnHide()
	Addon:Debug("merchantbutton", "Merchant button onHide")
	Addon:UnregisterCallback(AUTO_SELL_START, self)
	Addon:UnregisterCallback(AUTO_SELL_COMPLETE, self)
end

--[[===========================================================================
   | Called when the sell button is clicked, run auto-sell
   ==========================================================================]]
function MerchantButton:OnSellClicked()
	Addon:Debug("merchantbutton", "auto-sell was clicked")
	if (not Addon:IsAutoSelling()) then
		Addon:AutoSell()
	end
end

--[[===========================================================================
   | Called when the destory button is clicked, destroys one item
   ==========================================================================]]
function MerchantButton:OnDestroyClicked()
	Addon:Debug("merchantbutton", "destroy was clicked")
	if (not Addon:IsAutoSelling()) then
		Addon:DestroyItems()
	end
end

function MerchantButton.SetupButton()
	local state = Addon:GetProfile():GetValue(MERCHANT)

	Addon:Debug("merchantbutton", "Upadding button state: %s", state)
	if (state) then
		if (not MerchantButton.frame) then
			local frame = CreateFrame("Frame", "VendorMerchantButton", MerchantFrame, "Vendor_Merchant_Button")
			MerchantButton.frame = frame;
			frame:ObserveProfile()
		end

		MerchantButton.frame:Show()
	else
		if (MerchantButton.frame) then
			MerchantButton.frame:Hide()
		end
	end
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function MerchantButton.OnMerchantOpened()
	Addon:Debug("merchantbutton", "merchant open")
	Addon:RegisterCallback(PROFILE_CHANGED, MerchantButton, MerchantButton.SetupButton)
	MerchantButton.SetupButton()
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function MerchantButton.OnMerchantClosed()
	Addon:Debug("merchantbutton", "merchant closed")
	Addon:UnregisterCallback(PROFILE_CHANGED, MerchantButton)
	if (MerchantButton.frame) then
		MerchantButton.frame:Hide()
	end
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function MerchantButton:OnAutoSellStarted(limit)
	Addon:Debug("merchantbutton", "Merchant button auto-sell started (limit: %d) [%d]", limit, self.total or 0)
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
   
--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function MerchantButton:OnAutoSellComplete()
	Addon:Debug("merchantbutton", "Merchant buton auto-sell completed")
	Addon:UnregisterCallback(AUTO_SELL_ITEM, self)

	self.inProgress = false
	self.total = 0
	self.limit = 0
	self.sold = 0
	self:UpdateSellState(false)
end   

function MerchantButton:OnAutoSellItem(link, sold, limit)
	if (self.inProgress) then
		Addon:Debug("merchantbutton", "Auto-sold item updating button status %d / %d [%d]", sold, limit, self.total)
		self.itemLimit = math.min(limit, self.total)
		self.sold = sold
		self:UpdateSellState(true)
	end
end

--[[===========================================================================
   | Called when the bag is updated
   ==========================================================================]]
function MerchantButton:BAG_UPDATE(bag)
	if (self:IsShown()) then
		Addon:Debug("merchantbutton", "Merchant buton bag %d updated", bag)
		self:UpdateSellState(self.inProgress)
	end
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function MerchantButton.Initialize()
	Addon:Debug("merchantbutton", "Initializing merchant button")

    Addon:PreHookWidget(MerchantFrame, "OnShow", MerchantButton.OnMerchantOpened)
    Addon:PreHookWidget(MerchantFrame, "OnHide", MerchantButton.OnMerchantClosed)
end
   
Addon.MerchantButton = Mixin(MerchantButton, Addon.UseProfile)