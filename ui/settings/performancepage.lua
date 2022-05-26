local AddonName, Addon = ...
local PerformancePage = {}

local SELL_THROTTLE = Addon.c_Config_SellThrottle
local TIME_THROTTLE = Addon.c_Config_ThrottleTime

--[[===========================================================================
   | Called when this panel is loaded 
   ==========================================================================]]
function PerformancePage:OnLoad()
   self.TimeThrottle.OnChange = function(value)
      Addon:Debug("settings", "Perf: time throttle has changed to: %0.2f", value)
      self:SetProfileValue(TIME_THROTTLE, value)
   end

   self.SellThrottle.OnChange = function(value)
      Addon:Debug("settings", "Perf: sell throttle has changed to: %d", value)
      self:SetProfileValue(SELL_THROTTLE, value)
   end
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function PerformancePage:OnShow()
   local sellThrottle, timeThrottle = self:GetProfileValues(SELL_THROTTLE, TIME_THROTTLE)

   self.TimeThrottle:SetValue(timeThrottle)
   self.SellThrottle:SetValue(sellThrottle)
end

Addon.Settings = Addon.Settings or {}
Addon.Settings.Performance = Mixin(PerformancePage, Addon.UseProfile)