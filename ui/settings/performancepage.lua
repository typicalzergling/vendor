local AddonName, Addon = ...
local PerformancePage = {}

--[[===========================================================================
   | Called when this panel is loaded 
   ==========================================================================]]
function PerformancePage:OnLoad()
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function PerformancePage:OnShow()
end

Addon.Settings = Addon.Settings or {}
Addon.Settings.Performance = Mixin(PerformancePage, Addon.UseProfile)