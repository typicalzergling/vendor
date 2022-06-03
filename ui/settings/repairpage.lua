local AddonName, Addon = ...
local RepairPage = {}

local GUILD_REPAIR = Addon.c_Config_GuildRepair
local AUTO_REPAIR = Addon.c_Config_AutoRepair

--[[===========================================================================
   | Called when this panel is loaded 
   ==========================================================================]]
function RepairPage:OnLoad()
   self.AutoRepair.OnChange = function(state)
      Addon:Debug("settings", "Repair: auto-repair has changed to: %s", state)      
      self:SetProfileValue(AUTO_REPAIR, state == true)
      self.GuildRepair:SetEnabled(state)
   end

   if (Addon.IsClassic) then
      self.GuildRepair:Hide()
   else
      self.GuildRepair.OnChange = function(state)
         Addon:Debug("settings", "Repair: guild repair has changed to: %s", state)
         self:SetProfileValue(GUILD_REPAIR, state == true)
      end
   end
end

--[[===========================================================================
   | Called when this page is shown
   ==========================================================================]]
function RepairPage:OnShow()
   local autoRepair, guildRepair = self:GetProfileValues(AUTO_REPAIR, GUILD_REPAIR)

   self.AutoRepair:SetChecked(autoRepair)
   self.GuildRepair:SetChecked(guildRepair)
   self.GuildRepair:SetEnabled(autoRepair)
end

Addon.Settings = Addon.Settings or {}
Addon.Settings.Repair = Mixin(RepairPage, Addon.UseProfile)