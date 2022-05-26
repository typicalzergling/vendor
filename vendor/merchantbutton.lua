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

local PROGESS = 
{ 
	"|cff808080...|r", 
	"|cffffff00o|cff808080...|r", 
	"|cffffff00Oo|cff808080..|r", 
	"|cffffff00oO|cff808080.|r", 
	".|cffffff00Oo|r|r", 
	"..|cffffff00o|r",
}

--[[===========================================================================
   | Called when this panel is loaded 
   ==========================================================================]]
function MerchantButton:OnLoad()
	Addon:Debug("merchantbutton", "OnLoad of merchant button")
	self.progressIndex = 1
end

function MerchantButton:UpdateSellState(inProgress)
	local sell = self.Sell

	if (inProgress) then
		sell:SetText("Vendor")
		sell:Disable()
	else		
		local _, _, toSell = Addon:GetEvaluationStatus()
		local maxSell = self:GetProfileValue(MAX_SELL) or 0
		Addon:Debug("merchantbutton", "Updating state items to sell %d with max %d", toSell, maxSell)

		if (maxSell ~= 0) then
			toSell = math.min(maxSell, toSell)
		end

		if (toSell ~= 0) then
			sell:Enable()
			sell:SetFormattedText("Vendor (%d items)", toSell)
			sell:Enable()
		else
			sell:Disable()
			sell:SetText("Vendor")
		end
	end
end

function MerchantButton:OnProgress()
	self.Sell:SetText(PROGESS[self.progressIndex])
	self.progressIndex = self.progressIndex + 1
	if (self.progressIndex > table.getn(PROGESS)) then
		self.progressIndex = 1
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
	self:UpdateSellState(selling)
	if (selling) then
		self.progressIndex = 1
		Addon:RegisterCallback(AUTO_SELL_ITEM, self, self.OnProgress)
	end
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
	self:UpdateSellState(true)
	self.progressIndex = 1
	Addon:RegisterCallback(AUTO_SELL_ITEM, self, self.OnProgress)
end
   
--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function MerchantButton:OnAutoSellComplete()
	Addon:Debug("merchantbutton", "Merchant buton auto-sell completed")
	Addon:UnregisterCallback(AUTO_SELL_ITEM, self)
	self:UpdateSellState(false)
end   

function MerchantButton:BAG_UPDATE(bag)
	Addon:Debug("merchantbutton", "Merchant buton bag %d updated", bag)
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