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

--[[ Checkbox ]]-----------------------------------------------------------------

--[[ Initialize a setting ]]
function Checkbox:OnLoad()
    Mixin(self.check, Addon.CommonUI.Mixins.Border)
    self.check:OnBorderLoaded(nil, Colors.CHECKBOX_BORDER, Colors.CHECKBOX_BACK)
    self.label:SetTextColor(Colors.CHECKBOX_LABEL:GetRGBA())
    self.help:SetTextColor(Colors.CHECKBOX_HELP:GetRGBA())

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
    check:SetBorderColor(Colors.CHECKBOX_BORDER)
    check:SetBackgroundColor(Colors.CHECKBOX_BACK)
end

function Checkbox.OnCheckEnter(check)
    print("enter:", check)
    check:SetBorderColor(Colors.CHECKBOX_HOVER_BORDER)
    check:SetBackgroundColor(Colors.CHECKBOX_HOVER_BACK)
end

function Checkbox:OnCheckClicked()
    local checked = self.setting:GetValue()
    print("oncheckclicked", checked)
    self.setting:SetValue(not checked)
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
    print("checkbox - update setting", self.setting:GetValue())

    local value = self.setting:GetValue() == true
    if (not value) then
        self.check.checked:Show()
    else
        self.check.checked:Hide()
    end
end

--[[ Called when the size is changed to compute a new size for the control ]]
function Checkbox:OnSizeChanged()
    local height = self.label:GetHeight()
    if (self.help:IsShown()) then
        self.help:SetHeight(0)
        height = height + self.help:GetHeight()
    end

    if (height > self:GetHeight()) then
        self:SetHeight(height)
        print("height :: ", height)
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
    local height = self.header:GetHeight()
    if (self.help:IsShown()) then
        height = height + self.help:GetHeight()
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
end

--[[ Create an item for the setting list ]]
function SettingsList:CreateItem(model)
    if (not model.Setting) then
        return Settings.CreateHeader(model.Header, model.Help, self)
    elseif (model.Group) then
        -- todo
    else
        if (model.Setting:GetType() == "boolean") then
            local setting = Settings.CreateCheckbox(model.Setting, model.Label, model.Help, self)

            if (model.Predicate) then
                if (type(model.Predicate) == "table") then
                    model.Predicate:RegisterHandler(function()
                        print("--> predicate", model.Predicate:GetValue())
                        if (model.Predicate:GetValue()) then
                            setting:Enable()
                        else
                            setting:Disable()
                        end
                    end)
                else
                end
            end

            return setting
        end
    end
end

--[[ Get the settings items for the list ]]
function SettingsList:GetItems()
    table.forEach(self.settings, print, " getitems ")
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
function SettingsList:AddSetting(setting, label, help, predicate)
    table.insert(self.settings, {
            Setting = setting,
            Label = label,
            Help = help,
            Predicate = predicate
        })
end

--[[ Create a new settings list ]]
function Settings.CreateList(parent)
    local frame = CreateFrame("Frame", nil, (parent or UIParent), "CommonUI_List")
    Mixin(frame, SettingsList)
    SettingsList.OnLoad(frame)
    frame:Rebuild()
    return frame
end