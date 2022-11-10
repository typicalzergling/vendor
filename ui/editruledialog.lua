local AddonName, Addon = ...
local L = Addon:GetLocale()
local EditRuleDialog = {};
local RuleManager = Addon.RuleManager;
local RuleType = Addon.RuleType;

local MODE_READONLY = 1;
local MODE_EDIT = 2;
local ITEMINFO_ID = 1;
local MATCHES_ID = 2;
local HELP_ID = 3;

local ScriptStatus = {
    OK = 1,
    INVALID = 2,
    UNHEALTHY = 3,
    OUT_OF_DATE = 4,
    EXTENSION = 5,
    SYSTEM = 6,
};
Addon.ScriptStatus = ScriptStatus;

local RULE_STATUS_INFO = {
    [ScriptStatus.OK] = {
        Title = L.EDITRULE_OK_TEXT,
        Text = L.EDITRULE_RULEOK_TEXT,
        TitleColor = GREEN_FONT_COLOR,
        Icon = "Interface\\RAIDFRAME\\ReadyCheck-Ready"
    },
    [ScriptStatus.INVALID] = {
        Title = L.EDITRULE_ERROR_RULE,
        Text = L.EDITRULE_SCRIPT_ERROR,
        TitleColor = RED_FONT_COLOR,
        Icon = "Interface\\RAIDFRAME\\ReadyCheck-NotReady"
    },
    [ScriptStatus.UNHEALTHY] = {
        Title = L.EDITRULE_UNHEALTHY_RULE,
        Text = L.EDITRULE_SCRIPT_ERROR,
        TitleColor = ORANGE_FONT_COLOR,
        Icon = "Interface\\RAIDFRAME\\ReadyCheck-Waiting"
    },
    [ScriptStatus.OUT_OF_DATE] = {
        Title = L.EDITRULE_MIGRATE_RULE_TITLE,
        Text = L.EDITRULE_MIGRATE_RULE_TEXT,
        TitleColor = LEGENDARY_ORANGE_COLOR,
        TextColor = WHITE_FONT_COLOR,
        Icon = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew"
    },
    [ScriptStatus.EXTENSION] = {
        Title = L.EDITRULE_EXTENSION_RULE,
        Text = L.EDITRULE_EXTENSION_RULE_TEXT,
        TitleColor = Addon.HEIRLOOM_BLUE_COLOR,
        TextColor = HIGHLIGHT_FONT_COLOR,
    },
    [ScriptStatus.SYSTEM] = {
        Title = L.EDITRULE_SYSTEM_RULE,
        Text = L.EDITRULE_SYSTEM_RULE_TEXT,
        TitleColor = Addon.ARTIFACT_GOLD_COLOR,
        TextColor = HIGHLIGHT_FONT_COLOR,
    } 
};

StaticPopupDialogs["VENDOR_CONFIRM_DELETE_RULE"] = {
    text = L["CONFIG_DIALOG_CONFIRM_DELETE_FMT1"],
    button1 = YES,
    button2 = NO,
    OnAccept = function(self, ruleId, dialog)
        Addon:Debug("editrule", "Deleting rule '%s'", ruleId);
        Addon.Rules.DeleteDefinition(self.data); 
        if (dialog and dialog.ruleId == ruleId) then
            dialog:Hide();
        end
    end,
    timeout = 0,
    hideOnEscape = true,
    whileDead = true,
    exclusive = true,
};

function EditRuleDialog:OnLoad()
    Mixin(self, Addon.Controls.TabFrameMixin);
    self:InitializeTabs(self.Tabs, self.infoPanels);
    self:SetClampedToScreen(true)

    self.tabgroup = CreateTabGroup(
        self.Name:GetControl(), 
        self.Description:GetControl(),
        self.Script:GetControl())

    self.Script:RegisterCallback("OnChange", self.OnScriptChanged, self);
    self.Script:RegisterCallback("OnTab", function() self.tabgroup:OnTabPressed() end, self)
    self.Name:RegisterCallback("OnChange", self.UpdateButtonState, self);
    self.Name:RegisterCallback("OnTab", function() self.tabgroup:OnTabPressed() end, self)
    self.Description:RegisterCallback("OnChange", self.UpdateButtonState, self);        
    self.Description:RegisterCallback("OnTab", function() self.tabgroup:OnTabPressed() end, self)

    table.insert(UISpecialFrames, self:GetName());
    self:RegisterForDrag("LeftButton");

    self.ItemInfo.OnItemClicked = function(_, name, value)
        local valueText = value
        if (type(value )== "string") then
            valueText = string.format("\"%s\"", value)
        else
            valueText = tostring(value)
        end
        
        local current = self.Script:GetText();
        local empty = not current or (string.len(Addon.StringTrim(current)) == 0)
        local insertText = nil

        if (IsControlKeyDown()) then
            insertText = name
        elseif (IsAltKeyDown()) then
            insertText = valueText
        elseif (IsShiftKeyDown()) then
            if (type(value) == "boolean") then
                insertText = string.format("not %s", name)
            else
                insertText = string.format("%s ~= %s", name, valueText)
            end
        else
            if (type(value) == "boolean") then
                insertText = name
            else
                insertText = string.format("%s == %s", name, valueText)
            end
        end

        if (not empty) then
            self.Script:Insert(string.format(" (%s)", insertText))
        else
            self.Script:Insert(insertText)
        end

        self.Script:GetControl():SetFocus()
    end

    self.ItemInfo.OnItemContext = function(_, name)
        self.Help:DisplayKeyword(name)
        self:SetActiveTab(self.Help:GetID())
    end
end

function EditRuleDialog:IsReadOnly()
    return (self.mode == MODE_READONLY);
end

function EditRuleDialog:ValidateScript(script)
    self.status = nil;
    self.statusMessage = nil;

    if (script and string.len(script) ~= 0) then
        Addon:Debug("editrule", "Attempting to validate  \"%s\"", script);
        local valid, message = Addon:ValidateRuleAgainstBags(self.rulesEngine, script);
        if (not valid) then
            Addon:Debug("editrule", "Script is invalid '%s'", message);
            self.status = ScriptStatus.INVALID;
            self.statusMessage = message;
        else
            Addon:Debug("editrule", "Script validated");
            self.status = ScriptStatus.OK;
            self.statusMessage = nil;
        end
    else
        Addon:Debug("editrule", "There was not script to validate");
    end
    
    self:SetRuleStatus();
    return (self.status == ScriptStatus.OK);
end

function EditRuleDialog:OnScriptChanged(text)
    if (self:IsReadOnly()) then
        self:UpdateMatches();
    else
        self.dirty = true
        if (self:ValidateScript(text)) then
            self:UpdateMatches();
        end
    end

    self:UpdateButtonState();
end

-- Helper function which searches the config for the parameters for this rule,
-- if none is found then this will return nil.
local function findRuleParams(ruleDef)
    local profile = Addon:GetProfile();
    for _, config in ipairs(profile:GetRules(ruleDef.Type)) do
        if ((type(config) == "table") and config.rule) then
            if (string.lower(config.rule) == string.lower(ruleDef.Id)) then
                return config;
            end
        end
    end
end

--[[===========================================================================
    | Called to handle updating the matches panel, this is called whenever
    | the panel is shown, or the rule has been updated.
    ===========================================================================--]]
function EditRuleDialog:UpdateMatches()
    local ruleDef = self:GetRule();
    local params = findRuleParams(ruleDef);
    local matches = {};

    if (not self:IsReadOnly()) then
        if (not ruleDef.Script or (string.len(Addon.StringTrim(ruleDef.Script)) == 0)) then
            ruleDef = nil;
        end
    end

    if (ruleDef) then
        Addon:Debug("editrule", "Building matches for rule '%s'", ruleDef.Id);
        matches = Addon:GetMatchesForRule(self.rulesEngine, ruleDef.Id, ruleDef.Script, params);
        if (not matches) then
            matches = {};
        end
        Addon:Debug("editrule", "Found %s matches for rule '%s'", table.getn(matches), ruleDef.Id);
    end

    self.matchesPanel:SetMatches(matches);
end

--[[===========================================================================
    | Toggle the layout of the dialog to either the read-only or edit layout
    ===========================================================================--]]
function EditRuleDialog:SetMode(mode, infoId)
    self.mode = mode;
    self.editRule:ShowStatus();
    if (mode == MODE_READONLY) then
        if (self.TitleText) then
            self.TitleText:SetText(L["VIEWRULE_CAPTION"]);
        else
        end

        self.editRule:SetReadOnly(true);
        self.save:Disable();
        self:SetInfoContent(MATCHES_ID);
    else
        if (self.TitleText) then
            self.TitleText:SetText(L.EDITRULE_CAPTION);
        else
            self:SetCaption(L["EDITRULE_CAPTION"]);
        end

        self.editRule:SetReadOnly(false);
        self:SetInfoContent(infoId or MATCHES_ID);
    end
end

--[[===========================================================================
    | Check if we already have a saved rule with the specifed id.
    ===========================================================================--]]
local function hasCustomRuleId(ruleId)
    local defs = Addon.Rules.GetCustomDefinitions();
    for _, ruleDef in ipairs(defs) do
        if (ruleId == ruleDef.Id) then
            return true;
        end
    end

    return false;
end

--[[===========================================================================
    | Checks that a string is valid.
    ===========================================================================--]]
local function isValidString(str)
    if (type(str) ~= "string") then
        return false;
    end

    if (string.len(Addon.StringTrim(str)) == 0) then
        return false;
    end

    return true;
end

--[[===========================================================================
    | Called when the text of the rule edit field has changed, this will queue
    | a timer to delay evaluation until the user has stopped typing. If the
    | dialog is not currently in editing mode then we simply bail out.
    ===========================================================================--]]
function EditRuleDialog:UpdateButtonState()
    if (self:IsReadOnly()) then
        -- If we are read-only then we can never save or delete.
        self.delete:Disable();
        self.save:Disable();
    else
        local rule = self:GetRule();
        local canSave = true
        local startDef = self.ruleDef

        -- If we aren't read-only then we can only save if we've got
        -- a valid name, type, and script.

        if (not self.dirty and startDef and startDef.needsMigration) then
            canSave = true
        else
            if (not isValidString(rule.Name)) then
                canSave = false;
                Addon:Debug("editrule", "Can't save rule because name is invalid");
            end

            if (startDef and isValidString(startDef.Script) and (startDef.Script ~= rule.Script)) then
                if (not isValidString(rule.Script) or (self.status ~= ScriptStatus.OK)) then
                    canSave = false;
                    Addon:Debug("editrule", "Can't save rule because script is invalid");
                end
            end
        end

        if (not canSave) then
            self.save:Disable();
        else
            self.save:Enable();
        end

        -- We can only delete if this rules is already saved.
        if (hasCustomRuleId(rule.Id)) then
            self.delete:Enable();
        else
            Addon:Debug("editrule", "Cannot delete the rule because it hasn't been saved yet");
            self.delete:Disable();
        end
    end
end

--[[===========================================================================
    | Called when the user clicks OKAY, this will create  a new custom
    | rule definition and place it into the saved variable.
    ===========================================================================--]]
function EditRuleDialog:HandleSave()
    if (not self:IsReadOnly()) then
        Addon:Debug("editrule", "Creating new custom rule definition");
        local rule = self:GetRule();
        Addon.Rules.UpdateDefinition(rule);
        self:Hide();
    end
end

function EditRuleDialog:HandleDelete()
    if (not self:IsReadOnly()) then
        local rule = self:GetRule();
        local dialog = StaticPopup_Show("VENDOR_CONFIRM_DELETE_RULE", rule.Name);
        dialog.data = rule.Id;
        dialog.data2 = self;
    end
end

-- Verifies we've got a cached rules engine
function EditRuleDialog:EnsureRulesEngine()
    if (not self.rulesEngine) then
        self.rulesEngine = Addon:CreateRulesEngine(false);
    end
end

function EditRuleDialog:ClearRuleStatus()
    self.status = nil;
    self.statusMessage = nil;
end

function EditRuleDialog:SetRuleStatus(status, msg)
    self.status = status;
    self.statusMessage = msg or "";
end

--*****************************************************************************
-- Create a new rule (Generates a unique new id for it) and then opens the
-- dialog to the rule (read only is considered false)
--*****************************************************************************
function EditRuleDialog:CreateRule()
    self:EditRule({ 
        Id = string.lower(RuleManager.CreateCustomRuleId()), 
        Type = RuleType.SELL, 
        SupportsClassic = Addon.IsClassic 
    }, false, HELP_ID);
end

--*****************************************************************************
-- Called when our "filter" focus state changes, we want to show/hide our
-- help text if we've got content.
--*****************************************************************************
function EditRuleDialog:EditRule(ruleDef, readOnly, infoPanelId)
    self:EnsureRulesEngine();
    self:SetReadOnly(readOnly or false);    
    self:ClearRuleStatus();
    self:SetRule(ruleDef);

    -- Once we have set the rule, deterime what neeed to do with it
    -- if it's an extension, then we update the status, if it's not 
    -- and extension and it's ready only then it's a sustem rule.
    if (readOnly) then
        if (ruleDef.Extension) then
            self:SetRuleStatus(ScriptStatus.EXTENSION, ruleDef.Extension.Name or ruleDef.Extension.Source);
        else
            self:SetRuleStatus(ScriptStatus.SYSTEM);
        end
    end

    -- Unhealthy rule overrides any of the other status
    local healthMessage = self:CheckRuleHealth(ruleDef);
    if (healthMessage) then
        self:SetRuleStatus(ScriptStatus.UNHEALTHY, healthMessage);
    else
        if (not readOnly and (ruleDef.needsMigration)) then
            self:SetRuleStatus(ScriptStatus.OUT_OF_DATE);
        end
    end

    -- Change to the desired info page.
    if (infoPanelId) then
        -- TODO
    end

    -- Update the UX
    self:UpdateButtonState();
    self:UpdateMatches();

    if (readOnly) then
        self:SetCaption(L.VIEWRULE_CAPTION);
    else
        self:SetCaption(L.EDITRULE_CAPTION)
    end

    pcall(function() self:Show() end)
end

function EditRuleDialog:CheckRuleHealth(ruleDef)
    if (ruleDef and ruleDef.Script) then
        local _, _, status, _, message = Addon:GetRuleStatus(ruleDef.Id);
        if (status == "ERROR" and message) then
            return message;
        end
    end
    return nil;
end

function EditRuleDialog:SetRuleStatus(ruleStatus, statusMsg)
    local status = ruleStatus or self.status;
    local statusMessage = statusMsg or self.statusMessage;
    local frame = self.RuleStatus;

    -- If we have no status then simply return
    if (not status) then 
        frame:Hide();
        return;
    end;

    Addon:Debug("editrule", "Setting dialog status '%s' with message '%s'", status, statusMessage or "");

    local statusInfo = RULE_STATUS_INFO[status];
    assert(statusInfo, string.format("Expected there to be information for status: %d", status));

    -- Determine our content.
    local titleColor = statusInfo.TitleColor or HIGHLIGHT_FONT_COLOR;
    local textColor = statusInfo.TextColor or titleColor;
    local statusText = statusMessage;
    if (statusInfo.Text) then
        statusText = string.format(statusInfo.Text, statusMessage or "");
    end

    -- Update our icon
    if (statusInfo.Icon) then   
        frame.Icon:SetTexture(statusInfo.Icon);
        frame.Icon:Show();
        frame.Title:SetPoint("TOPLEFT", frame.Icon, "TOPRIGHT", 8, 0);
    else
        frame.Title:SetPoint("TOPLEFT");
        frame.Icon:Hide();
    end

    -- Update our text
    frame.Title:SetText(statusInfo.Title);
    frame.Title:SetTextColor(titleColor.r, titleColor.g, titleColor.b);
    frame.Text:SetText(statusText);
    frame.Text:SetTextColor(textColor.r, textColor.g, textColor.b);

    if (not frame:IsShown()) then
        pcall(function() frame:Show() end)
    end
end

function EditRuleDialog:OnShow()
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
    self:EnsureRulesEngine();
    Addon:LoadAllBagItemLinks();
end

function EditRuleDialog:OnHide()
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
    self.rulesEngine = nil;
end


--[[    -- Create our tab-group so we can handle tabbing
end

-- Called when tab is pressed in one of our sub-controls. Does not work on Classic
function EditRule:OnTabPressed()
    --@retail@
    self.tabgroup:OnTabPressed();
    --@end-retail@
end]]

function EditRuleDialog:SetReadOnly(readonly)
    if (readonly) then
        self.mode = MODE_READONLY;
        self.Name:Disable();
        self.Script:Disable();
        self.Description:Disable();
        self.delete:Disable();
        self.save:Disable();
        self.RuleTypeDelete:Disable();
        self.RuleTypeSell:Disable();
        self.RuleTypeKeep:Disable();
    else
        self.mode = MODE_EDIT;
        self.Name:Enable();
        self.Script:Enable();
        self.Description:Enable();
        self.RuleTypeDelete:Enable();
        self.RuleTypeSell:Enable();
        self.RuleTypeKeep:Enable();
    end
end

--[[===========================================================================
    | GetRule:
    |   Creates a rule definition from the current values in the form.
    =======================================================================--]]
function EditRuleDialog:GetRule()
    if (self:IsReadOnly()) then
        return self.ruleDef;
    else
        assert(self.ruleId, "Expected to have a valid rule id if we are editing a rule");

        local ruleDef = { Id = self.ruleId };
        ruleDef.Script = Addon.StringTrim(self.Script:GetText() or "");
        ruleDef.Name = Addon.StringTrim(self.Name:GetText() or "");
        ruleDef.Description = Addon.StringTrim(self.Description:GetText() or "");
        ruleDef.SupportsClassic = Addon.IsClassic;

        local ruleType = self.RuleTypeSell:GetSelected();
        if (not ruleType or (ruleType == "SELL")) then
            ruleDef.Type = RuleType.SELL;
        elseif (ruleType == "KEEP") then
            ruleDef.Type = RuleType.KEEP;
        elseif (ruleType == "DESTROY") then
            ruleDef.Type = RuleType.DESTROY;
        else
            error(string.format("Unknown rule type '%s'", ruleType));
        end

        return ruleDef;
    end
end

--[[===========================================================================
    | SetRule:
    |   Sets the rule state on our dialog (This fills in all of the fields
    |   which represent a rule, this does not setup the state.)
    =======================================================================--]]
function EditRuleDialog:SetRule(ruleDef)
    local name = "";
    local description = "";
    local script = "";
    local ruletype = RuleType.SELL;
    self.ruleId = nil;
    self.ruleDef = ruleDef;

    if (ruleDef) then
        self.ruleId = ruleDef.Id;
        name = ruleDef.Name or "";
        description = ruleDef.Description or "";
        if (type(ruleDef.Script) == "string") then
            script = ruleDef.Script;
        elseif (ruleDef.ScriptText) then
            script = ruleDef.ScriptText;
        else
            assert(not self:IsReadOnly());
            script = "";
        end
        ruleType = ruleDef.Type or RuleType.SELL;
    end

    self.Name:SetText(name);
    self.Description:SetText(description);
    self.Script:SetText(script);

    if (not ruleType or (ruleType == RuleType.SELL)) then
        self.RuleTypeSell:SetSelected("SELL");
    elseif (ruleType == RuleType.KEEP) then
        self.RuleTypeSell:SetSelected("KEEP");
    elseif (ruleType == RuleType.DESTROY) then
        self.RuleTypeSell:SetSelected("DESTROY");
    else
        error(string.format("Unknown rule type '%d'", ruleType));
    end
end

-- Export to Public
Addon.EditRuleDialog = EditRuleDialog;
Addon.Public.RuleDocumentation = Addon.RuleDocumentation