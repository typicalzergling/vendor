local _, Addon = ...
local Settings = Addon.Features.Settings
local BetaFeatures =  Mixin({})

--[[ Gets the name of this setting ]]
function BetaFeatures:GetName()
	return "beta_settings"
end

--[[ Gets the text of this setting page ]]
function BetaFeatures:GetText()
	return "SETTINGS_BETA_FEATURES"
end

--[[ Gets the summary of his setting list (opttional) ]]
function BetaFeatures:GetSummary()
	return "SETTINGS_BETA_FEATURES_TOOLTIP"
end

--[[ Checks if we should show this item ]]
function BetaFeatures:ShowShow()
    if (table.getn(Addon:GetBetaFeatures()) ~= 0) then
        return true
    end

    return false;
end

--[[ Persists the state of the feature ]]
function BetaFeatures:OnFeatureStateChanged(setting)
    Addon:SetBetaFeatureState(setting:GetName(), true)
end

--[[ Creates the list for this settings page ]]
function BetaFeatures:CreateList(parent)
    local beta = Addon:GetBetaFeatures()
	local list = Settings.CreateList(parent)

    list:AddHelpText("SETTINGS_BETA_FEATURES_HELP")
    for _, feature in ipairs(beta) do
        local setting = Settings.CreateFeatureSetting(feature.id)
        setting:RegisterHandler(self.OnFeatureStateChanged, self)
        list:AddSetting(setting, feature.name, feature.description)
    end

	return list;
end

function BetaFeatures:GetOrder()
	return 9999
end

function BetaFeatures:GetIsNew()
    return true
end

Settings.Categories.Beta = BetaFeatures