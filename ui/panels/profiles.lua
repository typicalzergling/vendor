local _, Addon = ...;
local L = Addon:GetLocale();
local ProfileConfig = {};
local ProfileItem = {};

--[[===========================================================================
   | Compares the profile for this item, the specified model.
   ==========================================================================]]
function ProfileItem:CompareModel(other)
	if (not other) then
		return false;
	end

	local model = self:GetModel();
	if (not model) then
		return false;
	end

	return (model:GetId() == other:GetId());
end

--[[===========================================================================
   | Invoked when the item is created, we need to hook our click event
   ==========================================================================]]
function ProfileItem:OnCreated()
	self:SetScript("OnClick", self.OnClick);
end

--[[===========================================================================
   | Called when the model is changed
   ==========================================================================]]
function ProfileItem:OnModelChanged(profile)
	self.Name:SetText(profile:GetName());
	if (profile:IsActive()) then
		self.Active:Show()
		self.Name:SetTextColor(WHITE_FONT_COLOR:GetRGB())
	else
		self.Active:Hide()
		self.Name:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
	end
end

--[[===========================================================================
   | Called when this item is selected
   ==========================================================================]]
function ProfileItem:OnSelected(selected)
	if (selected) then
		self.Selected:Show();
		self.Name:SetTextColor(WHITE_FONT_COLOR:GetRGB());
	else
		self.Selected:Hide();
		if (not self.Active:IsShown()) then
			self.Name:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		end
	end
end

--[[===========================================================================
   | Called to update this item (show/hide) or hover state
   ==========================================================================]]
function ProfileItem:OnUpdate()
    if (self:IsMouseOver()) then
        self.Hover:Show();
    else
        self.Hover:Hide();
    end
end
--[[===========================================================================
   | Called when this item is clicked
   ==========================================================================]]
function ProfileItem:OnClick()
	self:GetParent():Select(self:GetModel());
end

--[[===========================================================================
   | Creates a list of the profile objects, then sorts that list by name
   ==========================================================================]]
function ProfileConfig:LoadProfiles()
	local profiles = {};

	for _, profile in Addon:GetProfileManager():EnumerateProfiles() do
		table.insert(profiles, profile);
	end

	table.sort(profiles, 
		function(a, b)
			if (not a) then
				return false;
			elseif (not b) then 
				return true;
			else
				if (a:GetName() == b:GetName()) then
					return a:GetId() < b:GetId()
				end
				
				return a:GetName() < b:GetName()
			end
		end)

	self.profiles = profiles;
end

--[[===========================================================================
   | Update the state of all of the buttons on our config page.
   ==========================================================================]]
function ProfileConfig:UpdateState()
	local selected = self.Profiles:GetSelected();
	local text = self.Name:GetText();

	-- Copy it only enable if we have both a selectrion and a valid 
	-- profile name.
	if (selected) then
		self.Copy:Enable();
	else
		self.Copy:Disable();
	end

	-- Create is enable if we have a valid profile name.
	if (text and (string.len(text) ~= 0)) then
		self.Create:Enable();
	else
		self.Create:Disable();
	end

	-- The set buttonis only enabled if it will do something
	if (selected and not selected:IsActive()) then
		self.Set:Enable();
		self.Delete:Enable();
	else
		self.Set:Disable();
		self.Delete:Disable();
	end
end

--[[===========================================================================
   | Called to load the profiles config page, setup the various one time
   | items on our page.
   ==========================================================================]]
function ProfileConfig:OnLoad()
	print("--> profiule config load");
	Addon.LocalizeFrame(self);
	--Addon.ConfigPanel:AddPanel(self);
	self:SetScript("OnShow", self.OnShow);
	self:SetScript("OnHide", self.OnHide);

	self.Profiles.ItemClass = ProfileItem;
	self.Profiles.GetItems = function() 
		return self.profiles or {} 
	end
	self.Profiles.OnSelection = function()
		self:UpdateState();
	end

	self.Create:SetScript("OnClick", function()
			self:OnCreateProfile(false)
		end)

	self.Copy:SetScript("OnClick", function()
			self:OnCreateProfile(true)
		end)

	self.Delete:SetScript("OnClick", function()
			self:OnDeleteProfile()
		end)

	self.Set:SetScript("OnClick", function()
			self:OnSetProfile()
		end)
end

--[[===========================================================================
   | Refresh the view, preserving selection if possible.
   ==========================================================================]]
function ProfileConfig:Refresh()
	local selected = self.Profiles:GetSelected();
	self:LoadProfiles();
	self.Profiles:Update();
	if (selected) then
		self.Profiles:Select(selected);
	end
end

--[[===========================================================================
   | Called when the view is displayed, hookup our callbacks.
   ==========================================================================]]
function ProfileConfig:OnShow()
	self:Refresh();
	self.Name:RegisterCallback("OnChange", self.UpdateState, self);
	local profileManager = Addon:GetProfileManager()
	profileManager:RegisterCallback("OnProfileChanged", self.Refresh, self);
	profileManager:RegisterCallback("OnProfileDeleted", self.Refresh, self);
end

--[[===========================================================================
   | Called when the view is hidden, we don't need callback/notifications
   | when the view is not visible.
   ==========================================================================]]
function ProfileConfig:OnHide()
	local profileManager = Addon:GetProfileManager()
	self.Name:UnregisterCallback("OnChange", self);
	profileManager:UnregisterCallback("OnProfileChanged", self);
	profileManager:UnregisterCallback("OnProfileDeleted", self);
end

--[[===========================================================================
   | Called to create/copy a profile
   ==========================================================================]]
function ProfileConfig:OnCreateProfile(copy)
	local profileManager = Addon:GetProfileManager();
	local text = self.Name:GetText();
	local selected = self.Profiles:GetSelected();

	if (copy and not text or (string.len(text) == 0)) then
		text = string.format(L.OPTIONS_PROFILE_DEFAULT_COPY_NAME, selected:GetName());
	else
		local duplicate = false;
		for _, profile in profileManager:EnumerateProfiles() do
			if (string.lower(profile:GetName()) == string.lower(text)) then
				duplicate = true;
			end
		end

		if (duplicate) then
			StaticPopup_Show("VENDOR_CONFIG_PROFILE_EXISTS", text)
			return;
		end
	end

	local profile = nil;
	if (copy) then
		profile = profileManager:CopyProfile(selected, text);
	else
		profile = profileManager:CreateProfile(text);
	end

	self.Name:SetText("");
	self:Refresh();
	self.Profiles:Select(profile);
end

--[[===========================================================================
   | Called to delete a profile
   ==========================================================================]]
function ProfileConfig:OnDeleteProfile()
	local selected = assert(self.Profiles:GetSelected());
	local dialog = StaticPopup_Show("VENDOR_CONFIG_PROFILE_DELETE", selected:GetName());
	dialog.data = selected:GetId();
end

--[[===========================================================================
   | Called to change the active profile.
   ==========================================================================]]
function ProfileConfig:OnSetProfile()
	local profileManager = Addon:GetProfileManager();
	local selected = assert(self.Profiles:GetSelected());

	profileManager:SetProfile(selected);
	self:Refresh();
end

StaticPopupDialogs["VENDOR_CONFIG_PROFILE_DELETE"] = {
    text = L["OPTIONS_CONFIRM_PROFILE_DELETE_FMT1"],
    button1 = YES,
    button2 = NO,
	OnAccept = function(self, profileId)
		local profileManager = Addon:GetProfileManager();
		profileManager:DeleteProfile(profileId);
    end,
    timeout = 0,
    hideOnEscape = true,
    whileDead = true,
    exclusive = true,
};

StaticPopupDialogs["VENDOR_CONFIG_PROFILE_EXISTS"] = {
	--text = L["OPTIONS_CONFIRM_PROFILE_DELETE_FMT1"],
	text = "A profile with then name '%s' already exists please choose another name",
    button1 = OKAY,
    timeout = 0,
    hideOnEscape = true,
    whileDead = true,
    exclusive = true,
};

Addon.ProfileConfigPanel = ProfileConfig;

