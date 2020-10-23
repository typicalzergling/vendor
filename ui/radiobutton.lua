local _, Addon = ...;
local RadioButton = {};

function RadioButton:OnLoad()
    assert(self.Value, "Radio buttons must have a selected value");
    self.Check:SetScript("OnClick", 
        function(btn)
            btn:GetParent():SetSelected(self.Value);
        end);

    self.Label.LocKey = self.LabelKey
    if (self.LabelColor) then
        local color = self.LabelColor;
        self.Label:SetTextColor(color.r, color.g, color.b);
    end
    
    self.HelpText.LocKey = self.HelpTextKey;
    if (self.HelpTextColor) then
        local color = self.HelpTextColor;
        self.Label:SetTextColor(color.r, color.g, color.b);
    end

    if (not self.HelpTextKey) then
        self.HelpText:Hide();
    else    
        self.HelpText:Show();
    end

    self.CurrentLabelColor = { self.Label:GetTextColor() };
    self.CurrentHelpColor = { self.HelpText:GetTextColor() };
end

function RadioButton:SetSelected(selected)
    local peers = self:GetParent().RadioButtons or {}
    table.forEach(peers,
        function(button)
            button.Check:SetChecked(button.Value == selected);
        end);
end

function RadioButton:GetSelected()
    local peers = self:GetParent().RadioButtons or {};
    local selected = table.find(peers, 
        function(button)
            return button.Check:GetChecked();
        end);
    
    if (not selected) then
        return nil;
    end

    return selected.Value;
end

function RadioButton:Disable()
    self.Check:Disable();
    self.Label:SetTextColor(DISABLED_FONT_COLOR.r, DISABLED_FONT_COLOR.g, DISABLED_FONT_COLOR.b);
    self.HelpText:SetTextColor(DISABLED_FONT_COLOR.r, DISABLED_FONT_COLOR.g, DISABLED_FONT_COLOR.b);
end

function RadioButton:Enable()
    self.Check:Enable();
    self.Label:SetTextColor(unpack(self.CurrentLabelColor));
    self.HelpText:SetTextColor(unpack(self.CurrentHelpColor));
end

Addon.Controls = Addon.Controls or {};
Addon.Controls.RadioButton = RadioButton;