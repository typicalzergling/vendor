local Addon, L, Config = _G[select(1,...).."_GET"]()
local SCROLL_PADDING_X = 4;
local SCROLL_PADDING_Y = 17;
local SCROLL_BUTTON_PADDING = 4;
local ITEM_INFO_HTML_BODY_FMT = "<!DOCTYPE html><html><body><h1>%s</h1>%s</body></html>";
local ITEM_HTML_FMT = "<p>%s == %s%s%s</p>";
local NIL_ITEM_STRING = GRAY_FONT_COLOR_CODE .. "nil" .. FONT_COLOR_CODE_CLOSE;
local MATCHES_HTML_START = "<!DOCTYPE html><html><body>";
local MATCHES_HTML_END = "</body></html>";
local MATCHES_LINK_FMT1 = "<p>%s</p>";
local MODE_READONLY = 1;
local MODE_EDIT = 2;

local ITEMINFO_ID = 1;
local MATCHES_ID = 2;
local HELP_ID = 3;

local RuleManager = Addon.RuleManager;
--Addon.EditRuleDialog = {};

Addon.EditTemplate = {}
local EditTemplate = Addon.EditTemplate;

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


Addon.RuleDocumentation =
{
    CreateHeader = function(name, item)
        if (type(item) == "table") then
            if (item.Args) then
                return string.format("<h1>%s%s(%s)%s</h1>", BATTLENET_FONT_COLOR_CODE, name, item.Args, FONT_COLOR_CODE_CLOSE);
            end
        end
        return string.format("<h1>%s%s()%s</h1>", BATTLENET_FONT_COLOR_CODE, name, FONT_COLOR_CODE_CLOSE);
     end,

    CreateValues = function(item)
        if ((type(item) == "table") and item.Map) then
            local temp = {}
            for val, _ in pairs(item.Map) do
                table.insert(temp, string.format("\"%s\"", val))
            end
            return "<h2>Possible Values:</h2><p>" .. table.concat(temp, ", ") .. "</p>";
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

    CreateSingleItem = function(name, item)
        return  Addon.RuleDocumentation.CreateHeader(name, item) ..
                Addon.RuleDocumentation.CreateContent(item) ..
                Addon.RuleDocumentation.CreateValues(item);

    end,

    Create = function()
        -- Create our singleton cache
        if (not Addon.RuleDocumentation.__docs) then
            local docs = {};
            for _, section in pairs(Addon.ScriptReference) do
                for name, content in pairs(section) do
                    docs[string.lower(name)] = Addon.RuleDocumentation.CreateSingleItem(name, content);
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

Addon.ScrollFrame =
{
    OnLoad = function(self)
        ScrollFrame_OnLoad(self);
        local scrollbar = _G[self:GetName() .. "ScrollBar"]

        local offsetY = self.scrollBarOffsetY or 0
	    _G[scrollbar:GetName().."ScrollDownButton"]:SetPoint("TOP", scrollbar, "BOTTOM", 0, SCROLL_BUTTON_PADDING);
	    _G[scrollbar:GetName().."ScrollUpButton"]:SetPoint("BOTTOM", scrollbar, "TOP", 0, -SCROLL_BUTTON_PADDING);
	    scrollbar:ClearAllPoints()
	    scrollbar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -SCROLL_PADDING_X, SCROLL_PADDING_Y - offsetY - 2)
	    scrollbar:SetPoint("TOPRIGHT", self, "TOPRIGHT", -SCROLL_PADDING_X, -SCROLL_PADDING_Y + offsetY)
        if (self.scrollbarBack) then
	        self.scrollbarBack:SetAllPoints(scrollbar);
            self.scrollbarBack:Hide()
            scrollbar.scrollbarBack = self.scrollbarBack
        end

       self.scrollBarHideable = 1;
       self.scrollbar = scrollbar;
       scrollbar:Hide();

        scrollbar.Show = function(self)
                local frame = self:GetParent();
                local width = (frame:GetWidth() - self:GetWidth() - SCROLL_PADDING_X);
                frame.content:SetWidth(width);
                frame:GetScrollChild():SetWidth(width);
                if (self.scrollbarBack) then
                    self.scrollbarBack:Show();
                end
                getmetatable(self).__index.Show(self);
            end

        scrollbar.Hide = function(self)
                local frame = self:GetParent();
                local width = frame:GetWidth()
                frame:GetScrollChild():SetWidth(width);
                frame.content:SetWidth(width);
                if (self.scrollbarBack) then
                    self.scrollbarBack:Hide();
                end
                getmetatable(self).__index.Hide(self);
            end
    end,
}

Addon.EditRuleDialog =
{
    OnLoad = function(self)
        Mixin(self, Addon.EditRuleDialog);
        SetPortraitToTexture(self.portrait, "Interface\\Spellbook\\Spellbook-Icon");
        self:SetClampedToScreen(true)

        Addon.EditRuleDialog.SetEditLabel(self.name, L.EDITRULE_NAME_LABEL);
        Addon.EditRuleDialog.SetEditHelpText(self.name, L.EDITRULE_NAME_HELPTEXT);
        Addon.EditRuleDialog.SetEditLabel(self.script, L.EDITRULE_SCRIPT_LABEL);
        Addon.EditRuleDialog.SetEditHelpText(self.script, L.EDITRULE_SCRIPT_HELPTEXT);
        Addon.EditRuleDialog.SetEditLabel(self.description, L.EDITRULE_DESCR_LABEL);
        Addon.EditRuleDialog.SetEditHelpText(self.description, L.EDITRULE_DESCR_HELPTEXT);

        -- Initialize the tabs
        self.helpButton.text:SetText(L.EDITRULE_HELP_TAB_NAME);
        self.infoButton.text:SetText(L.EDITRULE_ITEMINFO_TAB_NAME);
        self.itemInfoPanel.topText:SetText(L.EDITRULE_ITEMINFO_TAB_TEXT);
        self.matchesButton.text:SetText(L.EDITRULE_MATCHES_TAB_NAME); 
        self.matchesPanel.topText:SetText(L.EDITRULE_MATCHES_TAB_TEXT);
        Addon.EditRuleDialog.SetMode(self, MODE_EDIT);

        self:SetupRuleType();

        -- Setup callbacks from the parts.
        self.script.content:SetScript("OnTextChanged", function() Addon.EditRuleDialog.OnScriptChanged(self); end);
    end,

    OnScriptTextLoad = function(self, scrollFrame)
        local scrollbar = _G[scrollFrame:GetName().."ScrollBar"]
	    _G[scrollbar:GetName().."ScrollDownButton"]:SetPoint("TOP", scrollbar, "BOTTOM", 0, SCROLL_BUTTON_PADDING);
	    _G[scrollbar:GetName().."ScrollUpButton"]:SetPoint("BOTTOM", scrollbar, "TOP", 0, -SCROLL_BUTTON_PADDING);
	    scrollbar:ClearAllPoints()
	    scrollbar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", -SCROLL_PADDING_X, SCROLL_PADDING_Y)
	    scrollbar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", -SCROLL_PADDING_X, -SCROLL_PADDING_Y + 1)
	    scrollFrame.scrollbarBack:SetAllPoints(scrollbar)

       scrollFrame.scrollBarHideable = 1;
       scrollFrame.scrollbar = scrollbar;
       scrollFrame.scrollbarBack:Hide();
       scrollbar:Hide();

        scrollbar.Show = function(self)
                local width = (scrollFrame:GetWidth() - self:GetWidth() - SCROLL_PADDING_X);
                scrollFrame.content:SetWidth(width);
                scrollFrame:GetScrollChild():SetWidth(width);
                scrollFrame.scrollbarBack:Show();
                getmetatable(self).__index.Show(self);
            end

        scrollbar.Hide = function(self)
                local width = scrollFrame:GetWidth();
                scrollFrame:GetScrollChild():SetWidth(width);
                scrollFrame.content:SetWidth(width);
                scrollFrame.scrollbarBack:Hide();
                getmetatable(self).__index.Hide(self);
            end
    end,

    OnHelpPaneLoad = function(self)
        self.filterLabel:SetText(L.EDITRULE_FILTER_LABEL);
        Addon.EditRuleDialog.SetEditHelpText(self.filter, L.EDITRULE_FILTER_HELPTEXT)
    end,

    --*****************************************************************************
    -- Called when we need to update our help content this will apply the filter
    -- then generate HTML for the content of the control
    --*****************************************************************************
    UpdateReference = function(helpPane)
        local docs  = Addon.RuleDocumentation.Filter(helpPane.filter:GetText());
        local temp = {}

        -- Sort/Build temporary array that we can concat.
        for _, content in spairs(docs) do
            table.insert(temp, content)
        end

        -- Put the text into the body
        local html = "<html><body>" .. table.concat(temp, "<br/>") .. "</body></html>"
        helpPane.reference.scrollFrame.content:SetText(html)
    end,

    UpdateItemProperties = function(infoPane)
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
                    if ((value == nil) or (valStr == "") or (string.len(valStr) == 0)) then
                        valStr = NIL_ITEM_STRING;
                    end

                    table.insert(props, string.format(ITEM_HTML_FMT, name, GREEN_FONT_COLOR_CODE, htmlEncode(valStr), FONT_COLOR_CODE_CLOSE));
                end                    
            end

            infoPane.propHtml.scrollFrame.content:SetText(string.format(ITEM_INFO_HTML_BODY_FMT, link, table.concat(props)));
        end
    end,

    --*****************************************************************************
    -- Called when our "filter" focus state changes, we want to show/hide our
    -- help text if we've got content.
    --*****************************************************************************
    OnEditFocusChange = function(self, gained)
        local helpText = self.helpText or self:GetParent().helpText;
        if (helpText) then
            if (gained) then
                helpText:Hide()
            else
                local text = self:GetText()
                if (not text or (text == "") or (string.len(text) == 0)) then
                    helpText:Show()
                else
                    helpText:Hide();
                end
            end
        end
    end,

    OnEditDisable = function(self)
        local textColor = self.disabledColor;
        if (textColor) then
            self:SetTextColor(textColor.r, textColor.g, textColor.b);
        end
    end,

    OnEditEnable = function(self)
        local textColor = self.normalColor;
        if (textColor) then
            self:SetTextColor(textColor.r, textColor.g, textColor.b);
        end
    end,

    SetEditLabel = function(self, text)
        if (self.label) then
            self.label:SetText(text);
        end
    end,

    SetEditHelpText = function(self, text)
        if (self.helpText) then
            self.helpText:SetText(text);
        end
    end,

    OnEditLoad = function(self)
        self.SetLabel = Addon.EditRuleDialog.SetEditLable;
        self.SetHelpText = Addon.EditRuleDialog.SetEditHelpText;
        Addon.EditRuleDialog.OnEditEnable(self);
    end,
};

local EditRuleDialog = Addon.EditRuleDialog;


--[[===========================================================================
    | Called to handle updating the matches panel, this is called whenever
    | the panel is shown, or the rule has been updated.
    ===========================================================================--]]
function EditRuleDialog.UpdateMatches(self)
    if (self:IsShown()) then
        local ruleDialog = self:GetParent();
        if (ruleDialog.scriptValid) then
            local matches = Addon:GetMatchesForRule(ruleDialog.ruleDef.Id, ruleDialog.script.content:GetText());
            local sb = Addon.Utils.StringBuilder:Create();

            sb:Add(MATCHES_HTML_START);
            for _, link in ipairs(matches) do
                sb:AddFormatted(MATCHES_LINK_FMT1, link);
            end
            sb:Add(MATCHES_HTML_END);

            self.propMatches.scrollFrame.content:SetText(sb:Get());
        end
     end
end

--[[===========================================================================
    | Toggle the layout of the dialog to either the read-only or edit layout
    ===========================================================================--]]
function EditRuleDialog.SetMode(self, mode)
    if (mode ~= self.mode) then
        self.mode = mode;
        if (mode == MODE_READONLY) then
            self.TitleText:SetText(L["VIEWRULE_CAPTION"]);
            self.script.content:Disable();
            self.name:Disable();
            self.description.content:Disable();
            self.save:Disable();
            EditRuleDialog.SetInfoContent(self, MATCHES_ID);
            self.errorText:Hide();
            self.successText:Hide();
        else
            self.TitleText:SetText(L.EDITRULE_CAPTION);
            self.script.content:Enable();
            self.name:Enable();
            self.description.content:Enable();
            EditRuleDialog.SetInfoContent(self, HELP_ID);
            self.errorText:Hide();
            self.successText:Hide();
        end
    end
end

-- todo move to rule manager
function RuleManager.CreateRuleFunction(script)
    local result, message = loadstring("return " .. script,  "");
    if (not result) then
       return result, message:gsub("%[string.*:%d+:%s*", "");
    end

    return result, ""
end

--[[===========================================================================
    | Called when the text of the rule edit field has changed, this will queue
    | a timer to delay evaluation until the user has stopped typing. If the
    | dialog is not currently in editing mode then we simply bail out.
    ===========================================================================--]]
function EditRuleDialog.UpdateButtonState(self)
    local ruleName = self.name:GetText();
    local ruleScript = self.script.content:GetText();
    local ruleDescription = self.description.content:GetText();

    if (self.mode ~= MODE_READONLY) then
        if (self.scriptValid and
            (ruleName and (string.len(ruleName) ~= 0)) and
            (ruleScript and (string.len(ruleScript) ~= 0)) and
            (ruleDescription and (string.len(ruleDescription) ~= 0))) then
            self.save:Enable()
        else
            self.save:Disable();
        end
    else
        self.save:Disable();
    end

    EditRuleDialog.UpdateMatches(self.matchesPanel);    
end

--[[===========================================================================
    | Called when the text of the rule edit field has changed, this will queue
    | a timer to delay evaluation until the user has stopped typing. If the
    | dialog is not currently in editing mode then we simply bail out.
    ===========================================================================--]]
function EditRuleDialog.OnScriptChanged(self)
    -- If we are not editing we are done.
    if (self.mode ~= MODE_EDIT) then
        return;
    end

    -- If we are currently waiting to evaluate then cancel
    self.scriptValid = false;
    if (self.timer) then
        self.timer:Cancel();
    end

    self.timer = C_Timer.NewTimer(0.60, function() EditRuleDialog.ValidateScript(self); end);
end

--[[===========================================================================
    | Called when both the script, and our timer has fired. This is a helper
    | to user which validates the script is OK, if we find an error, we show
    | and error widget (with the message).
    ===========================================================================--]]
function EditRuleDialog.ValidateScript(self)
    Addon:Debug("Validating script");

    local scriptText = self.script.content:GetText();
    if (scriptText and (string.len(scriptText) ~= 0)) then
        local result, message = RuleManager.CreateRuleFunction(scriptText);
        if (not result) then
            self.errorText:Show();
            self.errorText:SetFormattedText(L.EDITRULE_SCRIPT_ERROR, message);
            self.successText:Hide();
            self.scriptValid = false;
        else
            self.errorText:Hide();
            self.successText:SetText(L.EDITRULE_SCRIPT_OKAY);
            self.successText:Show();
            self.scriptValid = true;
        end
    else
        self.errorText:Hide();
        self.successText:Hide();
        self.scriptValid = false;
    end

    EditRuleDialog.UpdateButtonState(self);
end

--[[===========================================================================
    | Called when the user clicks OKAY, this will create  a new custom
    | rule definition and place it into the saved variable.
    ===========================================================================--]]
function EditRuleDialog.HandleOk(self)
    Addon:Debug("Creating new custom rule definition");

    local newRuleDef = {};
    newRuleDef.Id = self.ruleDef.Id;
    newRuleDef.Type = Addon.c_RuleType_Sell;
    newRuleDef.Script = self.script.content:GetText();
    newRuleDef.Name = self.name:GetText();
    newRuleDef.Description = self.description.content:GetText();
    Vendor.Rules.UpdateDefinition(newRuleDef);
end

function EditRuleDialog.SetInfoContent(self, id)
    assert(#self.infoPanels == #self.infoButtons);
    local grayFont = GRAY_FONT_COLOR;
    local activeFont = NORMAL_FONT_COLOR;

    print("setting mode: ", id);

    for i=1,#self.infoPanels do
        local panel = self.infoPanels[i];
        local button = self.infoButtons[i];

        if (panel:GetID() == id) then
            panel:SetAllPoints(self.infoArea);
            panel:Show();
        else
            panel:Hide();
        end

        if (button:GetID() == id) then
            button.text:SetTextColor(activeFont.r, activeFont.g, activeFont.b);
            button.icon:SetAlpha(1.0);
        else            
            button.text:SetTextColor(grayFont.r, grayFont.g, grayFont.b);
            button.icon:SetAlpha(0.5);
        end
    end
end

local function initializeTypeDropdown()
    local info = UIDropDownMenu_CreateInfo();
    print("---- initDropDown");

    for _, typeInfo in ipairs(RULE_TYPE_INFO) do
        info.isTitle = false;
        info.disabled = nil;
        info.checked = nil;
        info.notCheckable = 1;
        info.tooltipOnButton = nil;
        info.tooltipWhileDisabled = nil;
        info.func = nil;
        for key, value in pairs(typeInfo) do
            info[key] = value;
        end

        print("addbutton---", info.text);
        UIDropDownMenu_AddButton(info);
    end
end

function EditRuleDialog:SetupRuleType()
end



--*****************************************************************************
-- Create a new rule (Generates a unique new id for it) and then opens the
-- dialog to the rule (read only is considered false)
--*****************************************************************************
function EditRuleDialog:CreateRule()
    self:EditRule({ Id = RuleManager.CreateCustomRuleId() })
end

--*****************************************************************************
-- Called when our "filter" focus state changes, we want to show/hide our
-- help text if we've got content.
--*****************************************************************************
function EditRuleDialog:EditRule(ruleDef, readOnly)
    self.ruleDef = ruleDef;
    self.readOnly = readOnly or false;
    self.scriptValid = false;

    -- Set the name / description
    self.name:SetText(ruleDef.Name or "")
    Vendor.EditRuleDialog.OnEditFocusChange(self.name);
    self.description.content:SetText(ruleDef.Description or "")
    Vendor.EditRuleDialog.OnEditFocusChange(self.description.content);

    -- Set the script text
    if (ruleDef.ScriptText) then
        self.script.content:SetText(ruleDef.ScriptText)
    elseif (ruleDef.Script) then
        self.script.content:SetText(ruleDef.Script)
    else
        self.script.content:SetText("")
    end
    Vendor.EditRuleDialog.OnEditFocusChange(self.script.content, false);

    -- If we're read-only disable all the fields.
    if (readOnly) then
        Addon.EditRuleDialog.SetMode(self, MODE_READONLY);
        Addon.EditRuleDialog.UpdateButtonState(self);
    else
        Addon.EditRuleDialog.SetMode(self, MODE_EDIT);
        Addon.EditRuleDialog.ValidateScript(self);
    end

    self:Show()
end
