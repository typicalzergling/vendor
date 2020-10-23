local AddonName, Addon = ...
local L = Addon:GetLocale()
local Config = Addon:GetConfig()
local EditRuleDialog = {};
local RuleManager = Addon.RuleManager;

local ITEM_INFO_HTML_BODY_FMT = "<!DOCTYPE html><html><body><h1>%s</h1>%s</body></html>";
local ITEM_HTML_FMT = "<p>%s == %s%s%s</p>";
local NIL_ITEM_STRING = GRAY_FONT_COLOR_CODE .. "nil" .. FONT_COLOR_CODE_CLOSE;
local MATCHES_HTML_START = "<!DOCTYPE html><html><body>";
local MATCHES_HTML_END = "</body></html>";
local MATCHES_LINK_FMT1 = "<p>%s</p>";
local MODE_READONLY = 1;
local MODE_EDIT = 2;

local RuleType = Addon.RuleType;

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
        TitleColor = HEIRLOOM_BLUE_COLOR,
        TextColor = HIGHLIGHT_FONT_COLOR,
    },
    [ScriptStatus.SYSTEM] = {
        Title = L.EDITRULE_SYSTEM_RULE,
        Text = L.EDITRULE_SYSTEM_RULE_TEXT,
        TitleColor = ARTIFACT_GOLD_COLOR,
        TextColor = HIGHLIGHT_FONT_COLOR,
    } 
};

StaticPopupDialogs["VENDOR_CONFIRM_DELETE_RULE"] = {
    text = "Are you sure you want to delete this rule? %s %s",
    button1 = "Confirm Delete",
    button2 = "No Thanks",
    OnAccept = function(self, ruleId)
        print("---> Delete Rule: ", ruleId);
    end,
    timeout = 0,
    hideOnEscape = true,
    whileDead = true,
};

Addon.Utils = Addon.Utils or {};
Addon.Utils.StringBuilder = {};
function Addon.Utils.StringBuilder:Create()
    local instance = { buffer = {} };
    setmetatable(instance, self);
    self.__index = self;
    return instance;
end

function Addon.Utils.StringBuilder:Add(str)
    local buffer = rawget(self, "buffer");
    table.insert(buffer, tostring(str));
    for i=table.getn(buffer)-1,1,-1 do
        if (string.len(buffer[i]) > string.len(buffer[i+1])) then
            break;
        end
        buffer[i] = (buffer[i] .. table.remove(buffer));
    end
end

function Addon.Utils.StringBuilder:AddFormatted(str, ...)
    self:Add(string.format(str, ...));
end

function Addon.Utils.StringBuilder:Get()
    return table.concat(rawget(self, "buffer"));
end

local function spairs(t, order)
    local keys = {};
    for key in pairs(t) do
        table.insert(keys, key);
    end
    table.sort(keys)

    local iter = 0
    return function()
        iter = iter + 1
        return keys[iter], t[keys[iter]];
    end
end


-- Move to rulehelp.lua
Addon.RuleDocumentation =
{
    CreateHeader = function(name, item, ext, isfunc)
        local postfix = "";
        if (ext) then
            postfix = string.format(" %s[Extension]%s", ORANGE_FONT_COLOR_CODE, FONT_COLOR_CODE_CLOSE);
        end

        local fmt = "<h1>%s%s%s%s%s</h1>"
        if isfunc then
           fmt = "<h1>%s%s(%s)%s%s</h1>"
        end

        local args = ""
        if (type(item) == "table") then
            if (item.Args) then
                args = item.Args
            end
        end

        return string.format(fmt, BATTLENET_FONT_COLOR_CODE, name, args, FONT_COLOR_CODE_CLOSE, postfix);
     end,

    CreateValues = function(item)
        if ((type(item) == "table") and item.Map) then
            local temp = {}
            for val, _ in pairs(item.Map) do
                table.insert(temp, string.format("\"%s\"", val))
            end
            return "<br/><h2>Possible Values:</h2><p>" .. table.concat(temp, ", ") .. "</p>";
        end
        return ""
    end,

    CreateContent = function(item)
        if (type(item) == "string") then
            return "<p>" .. item .. "</p>";
        elseif (type(item) == "table") then
            if (item.Html) then
                return item.Html;
            elseif (item.Text) then
                return "<p>" .. item.Text .. "</p>";
            end
        end
        return "";
    end,

    CreateSingleItem = function(name, item, ext, isfunc)
        return  Addon.RuleDocumentation.CreateHeader(name, item, ext, isfunc) ..
                Addon.RuleDocumentation.CreateContent(item) ..
                Addon.RuleDocumentation.CreateValues(item);

    end,

    Create = function()
        -- Create our singleton cache
        if (not Addon.RuleDocumentation.__docs) then
            local docs = {};
            for cat, section in pairs(Addon.ScriptReference) do
                for name, content in pairs(section) do
                    docs[string.lower(name)] = Addon.RuleDocumentation.CreateSingleItem(name, content, false, cat == "Functions");
                end
            end

            -- Document extension functons.
            if (Package.Extensions) then
                for name,help in pairs(Package.Extensions:GetFunctionDocs()) do
                    docs[string.lower(name)] = Addon.RuleDocumentation.CreateSingleItem(name, help, true, true);
                end
            end

            Addon.RuleDocumentation.__docs = docs;
        end
        return Addon.RuleDocumentation.__docs;
    end,

    --*****************************************************************************
    -- Get a list of documentation which matches the specified filter, if the
    -- filter empty/nil this returns the entire documentation
    --*****************************************************************************
    Filter = function(filter)
        -- Did the caller want everything?
        local docs = Addon.RuleDocumentation.Create()
        if ((not filter) or (string.len(filter) == 0) or (filter == "")) then
            return docs
        end

        -- Apply our filters
        local fltr = string.lower(filter)
        local results = {}
        for name, content in pairs(docs) do
            if (string.find(name, fltr)) then
                results[name] = content
            end
        end

        return results
    end
}

function EditRuleDialog:OnLoad()
    Mixin(self, Addon.TabFrameMixin);
    self:InitializeTabs(self.Tabs, self.infoPanels);
    self:SetClampedToScreen(true)

    self.Script:RegisterCallback("OnChange", self.OnScriptChanged, self);
    self.Name:RegisterCallback("OnChange", self.UpdateButtons, self);
    self.Description:RegisterCallback("OnChange", self.UpdateButtons, self);        
end
    --*****************************************************************************
    -- Called when we need to update our help content this will apply the filter
    -- then generate HTML for the content of the control
    --*****************************************************************************
function EditRuleDialog:UpdateReference(helpPane)
    local docs  = Addon.RuleDocumentation.Filter(helpPane.filter:GetText());
    local temp = {}

    -- Sort/Build temporary array that we can concat.
    for _, content in spairs(docs) do
        table.insert(temp, content)
    end

    -- Put the text into the body
    local html = "<html><body>" .. table.concat(temp, "<br/>") .. "</body></html>"
    helpPane.reference:SetHtml(html)
end

function EditRuleDialog:IsReadOnly()
    return (self.mode == MODE_READONLY);
end

function EditRuleDialog:ValidateScript(script)
    self.status = nil;
    self.statusMessage = nil;

    if (script and string.len(script) ~= 0) then
        Addon:DebugChannel("editrule", "Attempting to validate  \"%s\"", script);
        local valid, message = Addon:ValidateRuleAgainstBags(self.rulesEngine, script);
        if (not valid) then
            Addon:DebugChannel("editrule", "Script is invalid '%s'", message);
            self.status = ScriptStatus.INVALID;
            self.statusMessage = message;
        else
            Addon:DebugChannel("editrule", "Script validated");
            self.status = ScriptStatus.OK;
            self.statusMessage = nil;
        end
    else
        Addon:DebugChannel("editrule", "There was not script to validate");
    end
    
    self:SetRuleStatus();
    return (self.status == ScriptStatus.OK);
end

function EditRuleDialog:OnScriptChanged(text)
    print("script changed:", text);
    if (self:IsReadOnly()) then
        self:UpdateMatches();
    else
        if (self:ValidateScript(text)) then
            self:UpdateMatches();
        end
    end

    local rule = self:GetRule();
    table.forEach(rule, print);
end

function EditRuleDialog:UpdateItemProperties()
    if (not CursorHasItem()) then
        return;
    end

    local _, _, link = GetCursorInfo();
    ClearCursor();

    local function htmlEncode(str)
        return str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;");
    end

    local itemProps = Addon:GetItemProperties(GameTooltip, link);
    local props = {}
    if (itemProps) then
        for name, value in spairs(itemProps) do
            if ((type(name) == "string") and
                ((type(value) ~= "table") and (type(value) ~= "function"))) then
                local valStr = tostring(value);
                if (type(value) == "string") then
                    valStr = string.format("\"%s\"", value);
                else
                    if ((value == nil) or (valStr == "") or (string.len(valStr) == 0)) then
                        valStr = NIL_ITEM_STRING;
                    end
                end

                table.insert(props, string.format(ITEM_HTML_FMT, name, GREEN_FONT_COLOR_CODE, htmlEncode(valStr), FONT_COLOR_CODE_CLOSE));
            end
        end

        self.itemInfoPanel.propHtml.scrollFrame.content:SetText(string.format(ITEM_INFO_HTML_BODY_FMT, link, table.concat(props)));
    end
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

    print("isreadonly", self:IsReadOnly());
    table.forEach(ruleDef, print);

    if (not self:IsReadOnly()) then
        if (not ruleDef.Script or (string.len(string.trim(ruleDef.Script)) == 0)) then
            ruleDef = nil;
        end
    end
    print("ruleDef", ruleDef);

    if (ruleDef) then
        Addon:DebugChannel("editrule", "Building matches for rule '%s'", ruleDef.Id);
        matches = Addon:GetMatchesForRule(self.rulesEngine, ruleDef.Id, ruleDef.Script, params);
        if (not matches) then
            matches = {};
        end
        Addon:DebugChannel("editrule", "Found %d matches for rule '%s'", table.getn(matches), ruleDef.Id);
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
    | Called when the text of the rule edit field has changed, this will queue
    | a timer to delay evaluation until the user has stopped typing. If the
    | dialog is not currently in editing mode then we simply bail out.
    ===========================================================================--]]
function EditRuleDialog:UpdateButtonState()
    -- If we are read-only then we want always disable the delete/save buttons
    -- as they can never be enabled.
    if (self:IsReadOnly()) then
        self.delete:Disable();
        self.save:Disable();
    else
        -- Addon.RuleDefinitions.IsValid(rule)
        -- Need to track "saved" state
        self.delete:Disable();
        self.save:Enable();
    end
end


--[[===========================================================================
    | Called when the user clicks OKAY, this will create  a new custom
    | rule definition and place it into the saved variable.
    ===========================================================================--]]
function EditRuleDialog.HandleOk(self)
    if (not self.readOnly) then
        Addon:Debug("Creating new custom rule definition");
        local rtype, name, description, script = self.editRule:GetValues();
        local newRuleDef =
        {
            Id = self.ruleDef.Id,
            Type = rtype,
            Name = name,
            Description = description,
            Script = script,
			SupportsClassic = Addon.IsClassic,
        };

        Vendor.Rules.UpdateDefinition(newRuleDef);
    end
end

function EditRuleDialog:HandleDelete()
    local dialog = StaticPopup_Show("VENDOR_CONFIRM_DELETE_RULE", "arg1", "arg2");
    dialog.data = "temp-id";
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

    self:Show();
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

    Addon:DebugChannel("editrule", "Setting dialog status '%d' with message '%s'", status, statusMessage or "");

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
        frame:Show();
    end
end

function EditRuleDialog:OnShow()
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
    self:EnsureRulesEngine();
    Addon:LoadAllBagItemLinks()
end

function EditRuleDialog:OnHide()
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
    self.rulesEngine = nil;
end


--[[    -- Create our tab-group so we can handle tabbing
    self.tabgroup = CreateTabGroup(self.name, self.description.content,
        self.script.content, self.sellRule, self.keepRule);
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
        ruleDef.Script = string.trim(self.Script:GetText() or "");
        ruleDef.Name = string.trim(self.Name:GetText() or "");
        ruleDef.Description = string.trim(self.Description:GetText() or "");
        ruleDef.SupportsClassic = Addon.IsClassic;

        local ruleType = self.RuleTypeSell:GetSelected();
        if (not ruleType or (ruleType == "SELL")) then
            ruleDef.Type = RuleType.SELL;
        elseif (ruleType == "KEEP") then
            ruleDef.Type = RuleType.KEEP;
        elseif (ruleType == "DELETE") then
            ruleDef.Type = RuleType.DELETE;
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
    elseif (ruleType == RuleType.DELETE) then
        self.RuleTypeSell:SetSelected("DELETE");
    else
        error(string.format("Unknown rule type '%d'", ruleType));
    end
end

-- Export to Public
Addon.EditRuleDialog = EditRuleDialog;
Addon.Public.RuleDocumentation = Addon.RuleDocumentation
