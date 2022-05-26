local AddonName, Addon = ...
local ToolTipPage = {}

local TOOLTIP = Addon.c_Config_Tooltip
local TOOLTIP_RULE = Addon.c_Config_Tooltip_Rule

--[[===========================================================================
   | Called when this panel is loaded 
   ==========================================================================]]
function ToolTipPage:OnLoad()
   self.Tooltip.OnChange = function(state)
      Addon:Debug("settings", "Tooltip:  tooltip state has changed to: %s", state)
      self:SetProfileValue(TOOLTIP, state == true)
      self.TooltipRule:SetEnabled(state)
   end

   self.TooltipRule.OnChange = function(state)
      Addon:Debug("settings", "Tooltip:  tooltip-rule state has changed to: %s", state)
      self:SetProfileValue(TOOLTIP_RULE, state == true)
   end
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function ToolTipPage:OnShow()
   local tooltip, rule = self:GetProfileValues(TOOLTIP, TOOLTIP_RULE)

   self.Tooltip:SetChecked(tooltip)
   self.TooltipRule:SetEnabled(tooltip)
   self.TooltipRule:SetChecked(rule)
end

Addon.Settings = Addon.Settings or {}
Addon.Settings.Tooltip = Mixin(ToolTipPage, Addon.UseProfile)