local AddonName, Addon = ...
local SellPage = {}

local AUTO_SELL = Addon.c_Config_AutoSell
local ENABLE_BUYBACK = Addon.c_Config_MaxSellItems
local LIMIT = Addon.c_BuybackLimit

--[[===========================================================================
   | Called when this panel is loaded 
   ==========================================================================]]
function SellPage:OnLoad()
   self.AutoSell.OnChange = function(state)
      Addon:Debug("settings", "Sell: Auto sell was changed to: %s", state)
      self:SetProfileValue(AUTO_SELL, state == true)
      self.EnableBuyback:SetEnabled(state)
   end

   self.EnableBuyback.OnChange = function(state)
      Addon:Debug("settings", "Sell: Auto sell was changed to: %s", state)
      if (state) then
         self:SetProfileValue(ENABLE_BUYBACK, LIMIT)
      else
         self:SetProfileValue(ENABLE_BUYBACK, 0)
      end
   end
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function SellPage:OnShow()
   local autoSell, enableBuyback = self:GetProfileValues(AUTO_SELL, ENABLE_BUYBACK)

   self.AutoSell:SetChecked(autoSell)
   self.EnableBuyback:SetChecked(enableBuyback ~= 0)
   self.EnableBuyback:SetEnabled(autoSell)
end

Addon.Settings = Addon.Settings or {}
Addon.Settings.Sell = Mixin(SellPage, Addon.UseProfile)