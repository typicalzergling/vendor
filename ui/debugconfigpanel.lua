local AddonName, Addon = ...
local L = Addon:GetLocale()
local Config = Addon:GetConfig()

local SETTING_MAX_ITEMS_TO_SELL = Addon.c_Config_MaxSellItems;
local SETTING_ENABLE_BUYBACK = Addon.c_Config_SellLimit; 
local MAX_ITEMS_TO_SELL = 144;
local MIN_ITEMS_TO_SELL = 1;

Addon.ConfigPanel = Addon.ConfigPanel or {}
Addon.ConfigPanel.Debug = {}

--*****************************************************************************
-- Called to sync the values on our page with the config.
--*****************************************************************************
function Addon.ConfigPanel.Debug.Set(self, config)
    Addon:Debug("Setting debug options panel values")
    self.Debug.State:SetChecked(not not config:GetValue("debug"))
    self.DebugRules.State:SetChecked(not not config:GetValue("debugrules"))

    local maxItems = math.max(MIN_ITEMS_TO_SELL, math.min(MAX_ITEMS_TO_SELL, Config:GetValue(SETTING_MAX_ITEMS_TO_SELL) or 0))
    self.maxItems.Value:SetValue(maxItems)
    self.maxItems.DisplayValue:SetFormattedText("%0d", maxItems)
    Addon.ConfigPanel.SetSliderEnable(self.maxItems, Config:GetValue(SETTING_ENABLE_BUYBACK));
end

--*****************************************************************************
-- Called to apply the values on our page into to the config
--*****************************************************************************
function Addon.ConfigPanel.Debug.Apply(self, config)
    Addon:Debug("Applying debugging panel options")
    Config:SetValue("debug", self.Debug.State:GetChecked())
    Config:SetValue("debugrules", self.DebugRules.State:GetChecked())
    if (self.maxItems.Value:IsEnabled()) then
        Config:SetValue(SETTING_MAX_ITEMS_TO_SELL, self.maxItems.Value:GetValue());
    end
end

--*****************************************************************************
-- Initialize the state of the panel
--*****************************************************************************
function Addon.ConfigPanel.Debug.Init(self)
    self.Title:SetText("Debugging")
    self.HelpText:SetText("<< Debugging options decription >>")
    self.Debug.Label:SetText("Debug Mode")
    self.Debug.Text:SetText("Toggles Debug Mode. Enables generic debugging settings and behaviors.")
    self.DebugRules.Label:SetText("Rule Debugging")
    self.DebugRules.Text:SetText("Toggles debugging mode for rules This will output LOTS of messages to console.")
    self:SetScript("OnShow", 
        function()
            local enableBuyback = VendorGeneralConfigPanel.enableBuyback;
            Addon.ConfigPanel.SetSliderEnable(self.maxItems, enableBuyback.State:IsEnabled() and enableBuyback.State:GetChecked());
        end);

    self.maxItems.Label:SetText("Limit number of items to sell");
    self.maxItems.Text:SetText("Controls the maximum number items vendor will auto-sell at each visit. If you want to be able to buy-back all items sold, set this to 12.");
    self.maxItems.Value:SetMinMaxValues(MIN_ITEMS_TO_SELL, MAX_ITEMS_TO_SELL);
    self.maxItems.Max:SetFormattedText("%d", MAX_ITEMS_TO_SELL);
    self.maxItems.Min:SetFormattedText("%d", MIN_ITEMS_TO_SELL);
    self.maxItems.Value:SetValueStep(1);
    self.maxItems.OnValueChanged =
        function(self, value)
            self.DisplayValue:SetFormattedText("%0d", value);
        end
end

-- Export to public
if not Addon.Public.ConfigPanel then Addon.Public.ConfigPanel = {} end
Addon.Public.ConfigPanel.Debug = Addon.ConfigPanel.Debug