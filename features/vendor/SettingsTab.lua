local _, Addon = ...
local Vendor = Addon.Features.Vendor
local SettingsTab = {}

--[[ Retreive the categories for the rules ]]
function SettingsTab:GetCategories()
    local settings = Addon:GetFeature("Settings")
    return settings:GetSettings()
end

function SettingsTab:OnActivate()
    self.settings:EnsureSelection()
end

function SettingsTab:ShowSettings(settings)
    local frame = settings.frame
    if (not frame) then
        settings.frame = settings.CreateList(self)
        frame = settings.frame
        self.frames = self.frames or {}
        table.insert(self.frames, frame)    
    end

    -- Hide the other frames
    if (self.frames) then
        for _, f in ipairs(self.frames) do
            if (f ~= frame) then
                f:Hide()
            end
        end
    end

    -- Show this frame
    frame:SetAllPoints(self.host)
    frame:Show()
end

Vendor.MainDialog.SettingsTab = SettingsTab