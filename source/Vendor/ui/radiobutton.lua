local Package = select(2, ...);
local RadioButton = {};
local SELECTED_VALUE_KEY = {};

-- TODO: Use "id="x"" to create a group of buttons

local function getSelectedValue(button)
    return rawget(button, SELECTED_VALUE_KEY);
end

function RadioButton:Init(selectedValue, label, text)
    rawset(self, SELECTED_VALUE_KEY, selectedValue);
    self.check:SetScript("OnClick", 
        function() 
            self:OnClick();
        end);

    if (label and self.label) then
        self.label:SetText(label);
        self._labelTextColor = { self.label:GetTextColor() };
    end

    if (text and self.text) then
        self.text:SetText(text);
        self._textTextColor = { self.text:GetTextColor() };
    end
end

function RadioButton:OnClick()
    local selectedValue = getSelectedValue(self);
    if (selectedValue) then
        self:SetSelected(selectedValue);
    end
end

function RadioButton:SetSelected(selected)
    local buttons = self:GetParent().radioButtons;
    if (buttons) then
        for _, button in ipairs(buttons) do
            button.check:SetChecked(getSelectedValue(button) == selected);
        end
    end
end

function RadioButton:GetSelected()
    local buttons = self:GetParent().radioButtons;
    if (buttons) then
        for _, button in ipairs(buttons) do
            if (button.check:GetChecked()) then
                return getSelectedValue(button);
            end
        end
    end
end

function RadioButton:Disable()
    self.check:Disable();

    if (self.text) then
        self.text:SetTextColor(DISABLED_FONT_COLOR.r, DISABLED_FONT_COLOR.g, DISABLED_FONT_COLOR.b);
    end        

    if (self.label) then
        self.label:SetTextColor(DISABLED_FONT_COLOR.r, DISABLED_FONT_COLOR.g, DISABLED_FONT_COLOR.b);
    end        
end

function RadioButton:Enable()
    self.check:Enable();

    if (self.text) then
        self.text:SetTextColor(unpack(self._textTextColor));
    end

    if (self.label) then
        self.label:SetTextColor(unpack(self._labelTextColor));
    end
end

-- Expose the function to initialize the radio button.
Package.InitializeRadioButton =
    function(button, selectedValue, label, text)
        Mixin(button, RadioButton):Init(selectedValue, label, text);
    end;
