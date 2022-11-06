local _, Addon = ...
local locale = Addon:GetLocale()
local Vendor = Addon.Features.Vendor
local UI = Addon.CommonUI.UI
local ProfilesTab = {}
local Colors = Addon.CommonUI.Colors

--[[ Helper function for debugging ]]
local function debug(...)
    local message = ""
    for _, arg in ipairs({...}) do
        message = message .. tostring(arg)
    end
    Addon:Debug("profilestab", message)
end

function ProfilesTab:OnLoad()
    self.profileManager = Addon:GetProfileManager()
    self.profiles:Sort(function(a, b)
            return a:GetName() < b:GetName()
        end)
end

-- investigate why we are passing ourself
function ProfilesTab:OnSizeChanged(_, width)
    local createText = self.createText
    Addon.CommonUI.Layouts.Stack(createText, createText.stack, 0, 6, width)
end

--[[ Get the lis of profiles ]]
function ProfilesTab:GetProfiles()
    return Addon:GetProfileList()
end

function ProfilesTab:OnProfileDeleted()
    debug("Profiles have changed")
    self.profiles:Rebuild()
    self:Update()
end

function ProfilesTab:OnProfileCreated()
    debug("Profiles have changed")
    self.profiles:Rebuild()
    self:Update()
end

function ProfilesTab:OnActivate()
    self:Update()
end

function ProfilesTab:OnDeactivate()
end

--[[ Callback for a selected profile ]]
function ProfilesTab:OnProfileSelected()
    self:Update()
end

--[[ Create a new profile ]]
function ProfilesTab:CreateProfile()
    local profileName = self:GetNewProfileName()

    -- Verify the name is acceptable
    if (not self:NameExists(profileName)) then
        local newProfile = self.profileManager:CreateProfile(profileName)
        self.profiles:Select(newProfile)
        self.name:SetText()
    end
end

--[[ Copy the selected the profile ]]
function ProfilesTab:CopyProfile()
    local selected = self:GetSelectedProfile()
    if (selected) then
        debug("Copy profile '", selected:GetName(), "'")

        local profileName = self:GetCopyProfileName(selected)
         
        -- Verify the name is correct
        if (not self:NameExists(profileName)) then
            local profile = self.profileManager:CopyProfile(selected, profileName)
            self.profiles:Select(profile)
            self.name:SetText()
        end
    end
end

--[[ Called to handle deleting the profile ]]
function ProfilesTab:DeleteProfile()
    local selected = self:GetSelectedProfile()
    if (selected) then
        UI.MessageBox("OPTIONS_CONFIRM_PROFILE_DELETE_CAPTION",
            locale:FormatString("OPTIONS_CONFIRM_PROFILE_DELETE_FMT1", selected:GetName()), 
            {
                {
                    text = "OPTIONS_CONFIRM_PROFILE_DELETE_CONFIRM",
                    handler = function()
                        self.profileManager:DeleteProfile(selected)
                    end
                },
                CANCEL
            })
    end
end

--[[ Rename the selected profile ]]
function ProfilesTab:RenameProfile()
    local selected = self:GetSelectedProfile()
    if (selected) then
        local text = self.name:GetText()

        if (not self:NameExists(text)) then
            debug("Changing the name of profile '", selected:GetName(), "' to : ", text)
            selected:SetName(text)
            self.name:SetText()
        end
    end
end

--[[ Called when the active profile has chaneged ]]
function ProfilesTab:OnProfileChanged(profile)
    self:Update()
end

--[[ Changes the profile to the one selected in the list ]]
function ProfilesTab:SetProfile()
    local selectedProfile = self:GetSelectedProfile()
    if (selectedProfile) then
        debug("SetProfile selecting new profile '", selectedProfile:GetName(), "'")
        self.profileManager:SetProfile(selectedProfile)
    else
        debug("SetProfile was called without a selected profile")
    end
end

--[[ Checks if a profile with the specified name already exists]]
function ProfilesTab:NameExists(name)
    local exists = false
    local check = string.lower(name)
    for _, profile in self.profileManager:EnumerateProfiles() do
        if (string.lower(profile:GetName()) == check) then
            exists = true
            break
        end
    end

    -- Show an error when it exists
    if (exists) then
        debug("A profile with the name '", name, "' already exists")
        UI.MessageBox("OPTIONS_PROFILE_DUPLICATE_NAME_CAPTION",
            locale:FormatString("OPTIONS_PROFILE_DUPLICATE_NAME_FMT1", name),
            OK)
    end
    
    return exists
end

--[[ Update the button state ]]
function ProfilesTab:Update()
    local selected = self:GetSelectedProfile()
    local activeProfile = self.profileManager:GetProfile()

    UI.Enable(self.copy, selected)
    UI.Enable(self.set, selected and not activeProfile:Equals(selected))
    UI.Enable(self.delete, selected and not activeProfile:Equals(selected))
    UI.Enable(self.rename, selected and self.name:HasText())
end

--[[ Gets the current selected profiles ]]
function ProfilesTab:GetSelectedProfile()
    return self.profiles:GetSelected()
end

--[[ Gets the name for a new profile ]]
function ProfilesTab:GetNewProfileName()
    local text = self.name:GetText()

    if (not text or string.len(text) == 0) then
        text = Addon:GetCharacterFullName()
    end

    return text
end

--[[ Retrieve the default name for a copied profile ]]
function ProfilesTab:GetCopyProfileName(profile)
    local text = self.name:GetText()

    if (not text or string.len(text) == 0) then
        return locale:FormatString("OPTIONS_PROFILE_DEFAULT_COPY_NAME", profile:GetName())
    end

    return text
end

Vendor.ProfilesTab = ProfilesTab