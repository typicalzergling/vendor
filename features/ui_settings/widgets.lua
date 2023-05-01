local _, Addon = ...
local locale = Addon:GetLocale()
local Checkbox = {}
local Colors = Addon.CommonUI.Colors
local Settings = Addon.Features.Settings

--[[ Local helper function which handles setting localaized text on a control ]]
local function _setText(region, text)
    if (region) then
        if (type(text) == "string") then
            local loc = locale:GetString(text)
            region:SetText(loc or text)
            region:Show()
        else
            region:Hide()
        end
    end
end

--[[ Default setting predicate if none is provided ]]
local function _defaultPredicate(setting)
    if (not setting) then
        return false
    end

    if (setting:GetType() == "boolean") then
        return setting:GetValue() == true
    end

    local value = setting:GetValue()
    return not not value
end

--[[ Shows a new tag on the frame ]]
local function _showNewTag(frame, point, x, y)
    if (Addon.Systems.Info.IsRetailEra) then
        local tag = CreateFrame("Frame", nil,  frame, "NewFeatureLabelTemplate")
        tag:SetPoint("TOPRIGHT", frame, point, x, y)
        tag:Show()
    end
end

--[[ Checkbox ]]-----------------------------------------------------------------

--[[ Initialize a setting ]]
function Checkbox:OnLoad()
    Mixin(self.check, Addon.CommonUI.Mixins.Border)
    self.check:OnBorderLoaded(nil, Colors.CHECKBOX_BORDER, Colors.CHECKBOX_BACK)
    self.label:SetTextColor(Colors.TEXT:GetRGBA())
    self.help:SetTextColor(Colors.SECONDARY_TEXT:GetRGBA())

    self.check.checked:SetColorTexture(Colors.CHECKBOX_CHECK:GetRGBA())
    self.check:SetScript("OnEnter", self.OnCheckEnter)
    self.check:SetScript("OnLeave", self.OnCheckLeave)
    self.check:SetScript("OnClick", function()
            self:OnCheckClicked()
        end)
end

--[[ Called when this control is shown ]]
function Checkbox:OnShow()
    if (self.setting) then 
        self:UpdateValue()
    else
        self:Disable()
    end
end

function Checkbox.OnCheckLeave(check)
    if (check:IsEnabled()) then
        check:SetBorderColor(Colors.CHECKBOX_BORDER)
        check:SetBackgroundColor(Colors.CHECKBOX_BACK)
    end
end

function Checkbox.OnCheckEnter(check)
    if (check:IsEnabled()) then
        check:SetBorderColor(Colors.CHECKBOX_HOVER_BORDER)
        check:SetBackgroundColor(Colors.CHECKBOX_HOVER_BACK)
    end
end

function Checkbox:IsChecked()
    return self.check.checked:IsShown() == true
end

function Checkbox:OnCheckClicked()
    if (self.check:IsEnabled()) then
        local checked = self:IsChecked()
        self.setting:SetValue(not checked)
    end
end

--[[ Assign a setting to this control ]]
function Checkbox:SetSetting(setting)
    assert(setting:GetType() == "boolean", "Checkbox only work on boolean settings")

    self.setting = setting
    setting:RegisterHandler(self.UpdateValue, self)
end

--[[ Retrievethe setting this control is using ]]
function Checkbox:GetSetting()
    return self.setting
end

--[[ Updates the state based on the value of the setting ]]
function Checkbox:UpdateValue()
    local value = self.setting:GetValue() == true
    if (value) then
        self.check.checked:Show()
    else
        self.check.checked:Hide()
    end
end

--[[ Called when the size is changed to compute a new size for the control ]]
function Checkbox:OnSizeChanged()
    self:Layout()
end

function Checkbox:Layout()
    local height = self.label:GetHeight()
    if (self.help:IsShown()) then
        self.help:SetHeight(0)
        height = height + self.help:GetHeight() + 2
    end

    if (height > self:GetHeight()) then
        self:SetHeight(height)
    end
end

--[[ Sets the label for this setting ]]
function Checkbox:SetLabel(label)
    _setText(self.label, label or "<error>")
end

--[[ Sets the help text, or none of there is no help for this setting ]]
function Checkbox:SetHelp(help)
    _setText(self.help, help)
end

function Checkbox:Disable()
    self.check:Disable()

    self.check:SetBorderColor(Colors.CHECKBOX_DISABLED)
    self.check.checked:SetColorTexture(Colors.CHECKBOX_DISABLED:GetRGBA())
    self.label:SetTextColor(Colors.CHECKBOX_DISABLED:GetRGBA())
    self.help:SetTextColor(Colors.CHECKBOX_DISABLED:GetRGBA())
end

function Checkbox:Enable()
    self.check:Enable()

    self.check:SetBorderColor(Colors.CHECKBOX_BORDER)
    self.label:SetTextColor(Colors.TEXT:GetRGBA())
    self.help:SetTextColor(Colors.SECONDARY_TEXT:GetRGBA())
    self.check.checked:SetColorTexture(Colors.CHECKBOX_CHECK:GetRGBA())
end

--[[ Create a checkbox control for the specified setting ]]
function Addon.Features.Settings.CreateCheckbox(setting, label, help, parent)
    local frame = CreateFrame("Frame", nil, (parent or UIParent), "Vendor_Settings_Checkbox")
    Addon.AttachImplementation(frame, Checkbox, true)
    frame:SetSetting(setting)
    frame:SetLabel(label)
    frame:SetHelp(help)
    frame:UpdateValue()
    return frame
end

--[[ Header ]]-----------------------------------------------------------------

local Header = {}

function Header:OnLoad()
    self.header:SetTextColor(Colors.TEXT:GetRGBA())
    self.help:SetTextColor(Colors.SECONDARY_TEXT:GetRGBA())
end

function Header:SetHeader(header)
    _setText(self.header, header or "<error>")
end

function Header:SetHelp(help)
    _setText(self.help, help)
end

function Header:OnSizeChanged()
    self:Layout()
end

function Header:Layout()
    local height = self.header:GetHeight()
    if (self.help:IsShown()) then
        height = height + self.help:GetHeight() + 2
    end

    self:SetHeight(height)
end

function Addon.Features.Settings.CreateHeader(header, help, parent)
    local frame = CreateFrame("Frame", nil, (parent or UIParent), "Vendor_Settings_Header")
    Addon.AttachImplementation(frame, Header, true)
    frame:SetHeader(header)
    frame:SetHelp(help)
    return frame
end

--[[ Setting List ]]-----------------------------------------------------------

local SettingsList = {}

--[[ Handle laoding the settign list ]]
function SettingsList:OnLoad()
    self.settings = {}
    self.ItemSpacing = 12
    self.Padding = 12
    Addon.CommonUI.List.OnLoad(self)
end

--[[ Create an item for the setting list ]]
function SettingsList:OnCreateItem(model)
    local setting = nil

    if (not model.Setting) then
        return Settings.CreateHeader(model.Header, model.Help, self)
    else
        if (model.Setting:GetType() == "boolean") then
            setting = Settings.CreateCheckbox(model.Setting, model.Label, model.Help, self)
        end
    end

    if (model.Margins) then
        setting.Margins = model.Margins
    end

    if type(model.Depend)  == "table" then
        local function handleUpdate()
            local result = false
            if type(model.Predicate) == "function" then
                result = model.Predicate(model.Depend)
            else
                result = _defaultPredicate(model.Depend)
            end
    
            if (result) then
                setting:Enable()
            else
                setting:Disable()
            end
        end
    
        model.Depend:RegisterHandler(handleUpdate)
        handleUpdate()
    end

    if (setting and model.isNew == true) then
        _showNewTag(setting, "TOPRIGHT", -24, -8)
    end

    return setting
end

--[[ Get the settings items for the list ]]
function SettingsList:OnGetItems()
    return self.settings
end

--[[ Adds a header to the help list ]]
function SettingsList:AddHeader(header, help)
    table.insert(self.settings, {
            Header = header,
            Help = help
        })
end

--[[ Adds a setting to the help list ]]
function SettingsList:AddSetting(setting, label, help, depend)
    local setting = {
            Setting = setting,
            Label = label,
            Help = help,
            Depend = depend
        }
    table.insert(self.settings, setting)
    return setting
end

--[[ Create a new settings list ]]
function Settings.CreateList(parent)
    local frame = CreateFrame("Frame", nil, (parent or UIParent), "CommonUI_List")
    Addon.CommonUI.UI.Attach(frame, SettingsList)
    return frame
end