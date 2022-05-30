local AddonName, Addon = ...
local locale = Addon:GetLocale();
local ButtonState = Addon.MerchantButton
local MERCHANT = Addon.c_Config_MerchantButton
local AUTO_SELL_START = Addon.Events.AUTO_SELL_START
local AUTO_SELL_COMPLETE = Addon.Events.AUTO_SELL_COMPLETE
local MAX_SELL = Addon.c_Config_MaxSellItems
local AUTO_SELL_ITEM = Addon.Events.AUTO_SELL_ITEM

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

local MERCHANT_SELL_ITEMS = "Sell [%d]"
local MERCHANT_DESTROY_ITEMS = "Destroy [%d]"

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
	local destory = self.Destroy

	if (inProgress) then
		sell:Disable()
		destroy:Disable()
	else		
		local _, _, toSell, toDestroy = Addon:GetEvaluationStatus()
		local maxSell = self:GetProfileValue(MAX_SELL) or 0
		Addon:Debug("merchantbutton", "Updating state items to sell %d with max %d, destory %d", toSell, maxSell, toDestroy)

		if (maxSell ~= 0) then
			toSell = math.min(maxSell, toSell)
		end

		self:SetButtonState(sell, MERCHANT_SELL_ITEMS, toSell)
		self:SetButtonState(destory, MERCHANT_DESTROY_ITEMS, toDestroy)
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

function MerchantButton:OnSellClicked()
	Addon:Debug("merchantbutton", "auto-sell was clicked")
	if (not Addon:IsAutoSelling()) then
		Addon:AutoSell()
	end
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function MerchantButton.OnMerchantOpened()
	Addon:Debug("merchantbutton", "merchant open")
	if (not MerchantButton.frame) then
		frame = CreateFrame("Frame", "VendorMerchantButton", MerchantFrame, "Vendor_Merchant_Button")
		MerchantButton.frame = frame;
	end

	MerchantButton.frame:Show()
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function MerchantButton.OnMerchantClosed()
	Addon:Debug("merchantbutton", "merchant closed")

	if (MerchantButton.frame) then
		MerchantButton.frame:Hide()
	end
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function MerchantButton:OnAutoSellStarted()
	Addon:Debug("merchantbutton", "Merchant button auto-sell started")
	self.inProgress = true
	self:UpdateSellState(true)
end
   
--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function MerchantButton:OnAutoSellComplete()
	Addon:Debug("merchantbutton", "Merchant buton auto-sell completed")
	self.inProgress = false
	self:UpdateSellState(false)
end   

function MerchantButton:BAG_UPDATE(bag)
	Addon:Debug("merchantbutton", "Merchant buton bag %d updated", bag)
	self:UpdateSellState(self.inProgress)
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