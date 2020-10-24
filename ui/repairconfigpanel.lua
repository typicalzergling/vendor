local AddonName, Addon = ...
local L = Addon:GetLocale()

Addon.ConfigPanel = Addon.ConfigPanel or {}
Addon.ConfigPanel.Repair = {}

--*****************************************************************************
-- Called when the enabled state of "auto-repair" to keep the state
-- of hte sub-options in sync.
--*****************************************************************************
function Addon.ConfigPanel.Repair.updateGuildRepair(self, repairState)
    if (not repairState) then
        self.GuildRepair.State:Disable()
    else
        self.GuildRepair.State:Enable()
    end
end

--*****************************************************************************
-- Called to sync the values on our page with the config.
--*****************************************************************************
function Addon.ConfigPanel.Repair.Set(self)
    Addon:Debug("config", "Setting repair panel config");

    local profile = Addon:GetProfile();
    self.AutoRepair.State:SetChecked(profile:GetValue(Addon.c_Config_AutoRepair));
    self.GuildRepair.State:SetChecked(profile:GetValue(Addon.c_Config_GuildRepair));
end

--*****************************************************************************
-- Push the values from our UI into the config
--*****************************************************************************
function Addon.ConfigPanel.Repair.Apply(self)
    Addon:Debug("config", "Applying repair options")

    local profile = Addon:GetProfile();
    local autorepair = self.AutoRepair.State:GetChecked()
    profile:SetValue(Addon.c_Config_AutoRepair, autorepair)
    profile:SetValue(Addon.c_Config_GuildRepair, autorepair and self.GuildRepair.State:GetChecked())
end

--*****************************************************************************
-- Apply the default settings
--*****************************************************************************
function Addon.ConfigPanel.Repair:Default()
    local profile = Addon:GetProfile();
    local defaults = Addon.DefaultConfig.Settings;

    profile:SetValue(Addon.c_Config_AutoRepair, defaults[Addon.c_Config_AutoRepair]);
    profile:SetValue(Addon.c_Config_GuildRepair, defaults[Addon.c_Config_GuildRepair]);
end

--*****************************************************************************
-- Called to setup our panel
--*****************************************************************************
function Addon.ConfigPanel.Repair.Init(self)
    self.Title:SetText(L["OPTIONS_HEADER_REPAIR"])
    self.HelpText:SetText(L["OPTIONS_DESC_REPAIR"])
    self.AutoRepair.Text:SetText(L["OPTIONS_SETTINGDESC_AUTOREPAIR"])
    self.AutoRepair.Label:SetText(L["OPTIONS_SETTINGNAME_AUTOREPAIR"])
    self.GuildRepair.Label:SetText(L["OPTIONS_SETTINGNAME_GUILDREPAIR"])
    self.GuildRepair.Text:SetText(L["OPTIONS_SETTINGDESC_GUILDREPAIR"])

	-- If classic hide the guild repair option
	if (Addon.IsClassic) then
		self.GuildRepair:Hide();
	end

    self.AutoRepair.OnStateChange =
        function(checkbox, state)
           Addon.ConfigPanel.Repair.updateGuildRepair(self, state)
        end
end

-- Export to Public
if not Addon.Public.ConfigPanel then Addon.Public.ConfigPanel = {} end
Addon.Public.ConfigPanel.Repair = Addon.ConfigPanel.Repair