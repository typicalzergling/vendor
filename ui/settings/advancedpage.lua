local AddonName, Addon = ...
local AdvancedPage = {}

--[[===========================================================================
   | Called when this panel is loaded 
   ==========================================================================]]
function AdvancedPage:OnLoad()
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function AdvancedPage:OnShow()
end

Addon.Settings = Addon.Settings or {}
Addon.Settings.Advanced = Mixin(AdvancedPage, Addon.UseProfile)