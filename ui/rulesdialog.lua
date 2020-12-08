local AddonName, Addon = ...
local RulesDialog = {}

function RulesDialog:OnLoad()
    Mixin(self, Addon.Controls.TabFrameMixin)
    self:SetClampedToScreen(true)    
    self:RegisterForDrag("LeftButton")
    table.insert(UISpecialFrames, self:GetName())
    self:InitializeTabs(self.Tabs, self.Panels, 1)
end

function RulesDialog:Open(tab)
    local tabIndex = 1
    local quiet = false;
    if (type(tab) == "number") then
        assert((tab >= 1) and (tab <= table.getn(self.Tabs)), "Tab index is out of range")
        tabIndex = tab;
    elseif (type(tab) == "string") then
        tab = string.lower(tab)
        local frame = assert(table.find(self.Tabs, function(t) 
            return (t.TabName == tab)
        end), string.format("The tab name '%s' is not valid", tab))
        tabIndex = frame:GetID()
    elseif (tab ~= nil) then
        assert("Invalid argument to RulesDialog:Open()")
    end

    if (not self:IsShown()) then
        self:Show()
        quiet = true
    end
    self:SetActiveTab(tabIndex, quiet)
end

Addon.RulesDialog = RulesDialog;
