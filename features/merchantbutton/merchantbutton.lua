local AddonName, Addon = ...
local L = Addon:GetLocale();
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
    _autoHookHandlers = true,
}

MerchantButton.c_ButtonFrameName = string.format("%s_%s", AddonName, "MerchantButton")
MerchantButton.c_TooltipFrameName = string.format("%s_MerchantTooltip", AddonName)


function MerchantButton:OnInitialize()
	debugp("OnInitialize")
    Addon:SecureHookWidget(MerchantFrame, "OnShow", MerchantButton.OnMerchantOpened)
    Addon:SecureHookWidget(MerchantFrame, "OnHide", MerchantButton.OnMerchantClosed)
	self.limit = 0
	self.sold = 0
	self.total = 0
end

function MerchantButton:OnTerminate()
end

function MerchantButton.OnMerchantOpened()
	debugp("merchant open")
	Addon:RegisterCallback(PROFILE_CHANGED, MerchantButton, MerchantButton.SetupButton)
	MerchantButton.SetupButton()
end

function MerchantButton.OnMerchantClosed()
	debugp("merchant closed")
	if (MerchantButton.frame) then
		MerchantButton.frame:Hide()
	end
end

function MerchantButton:OnLoad()
	debugp("OnLoad of merchant button")
end

--[[===========================================================================
   | Called to adjust the button state of sell/destroy
   ==========================================================================]]
function MerchantButton:SetButtonState(button, text, count)
	button:SetFormattedText(text, count)
	if (self.inProgress) then
		button:Disable()
	else
		button:Enable()
	end
end

--[[===========================================================================
   | Called to update the state of our buttons on the merchant frame
   ==========================================================================]]
function MerchantButton:UpdateSellState(inProgress)

	if (inProgress) then
		sell:Disable()
		destroy:Disable()

		local left = math.max(0, self.limit - self.sold)
		if (left > 0) then
			debugp("Updating button to reflect sold item: %s left", tostring(left))
			self:SetButtonState(sell, MERCHANT_SELL_ITEMS, left)
		end
	else		
		local _, _, toSell, toDestroy = Addon:GetEvaluationStatus()
		debugp("Updating state items to sell %d, destory %d", toSell, toDestroy)

		self.total = toSell
		self:SetButtonState(sell, MERCHANT_SELL_ITEMS, toSell)
		self:SetButtonState(destroy, MERCHANT_DESTROY_ITEMS, toDestroy)
	end
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function MerchantButton:OnShow()
	debugp("Merchant button OnShow")
	Addon:RegisterCallback(AUTO_SELL_START, self, self.OnAutoSellStarted)
	Addon:RegisterCallback(AUTO_SELL_COMPLETE, self, self.OnAutoSellComplete)

	local selling = Addon:GetFeature("Merchant"):IsAutoSelling()
	self.inProgress = selling
	self:UpdateSellState(selling)
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function MerchantButton:OnHide()
	debugp("merchantbutton", "Merchant button onHide")
	Addon:UnregisterCallback(AUTO_SELL_START, self)
	Addon:UnregisterCallback(AUTO_SELL_COMPLETE, self)
end

--[[===========================================================================
   | Called when the sell button is clicked, run auto-sell
   ==========================================================================]]
function MerchantButton.OnSellClicked()
	debugp("auto-sell was clicked")
	Addon:GetFeature("Merchant"):AutoSell()
end

--[[===========================================================================
   | Called when the destory button is clicked, destroys one item
   ==========================================================================]]
function MerchantButton.OnDestroyClicked()
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

Addon.MerchantButton = MerchantButton
Addon.Features.MerchantButton = MerchantButton