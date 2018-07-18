local Addon, L, Config = _G[select(1,...).."_GET"]()
local HELP_WIDTH = 360 + 32;
local SCROLL_PADDING_X = 4;
local SCROLL_PADDING_Y = 17;
local SCROLL_BUTTON_PADDING = 4;
local ITEM_INFO_HTML_BODY_FMT = "<html><body><h1>%s</h1>%s</body></html>";
local ITEM_HTML_FMT = "<p>%s() = %s%s%s</p>";
local NIL_ITEM_STRING = GRAY_FONT_COLOR_CODE .. "nil" .. FONT_COLOR_CODE_CLOSE;
local MATCHES_HTML_BODY_FMT1 = "<html><body>%s</body></html>";
local MATCHES_LINK_FMT1 = "<p>%s</p>";
local MODE_READONLY = 1;
local MODE_EDIT = 2;

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
                return string.format("<h1>%s(%s)</h1>", name, item.Args);
            end
        end
        return string.format("<h1>%s()</h1>", name);
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
                local width = frame:GetWidth();
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
        self.CreateRule = Addon.EditRuleDialog.CreateNewRule
        self.EditRule = Addon.EditRuleDialog.EditRule
        self:SetClampedToScreen(true)

        Addon.EditRuleDialog.SetEditLabel(self.name, L["EDITRULE_NAME_LABEL"]);
        Addon.EditRuleDialog.SetEditLabel(self.script, L["EDITRULE_SCRIPT_LABEL"]);
        Addon.EditRuleDialog.SetEditLabel(self.description, "[DESCRIPTION]");
        self.ToggleHelp:GetNormalTexture():SetTexCoord(0.5, 1, 0, 1);

        -- Initialize the tabs
        Addon.EditRuleDialog.InitTab(self, self.helpTab, "[HELP]")
        Addon.EditRuleDialog.InitTab(self, self.itemInfoTab, "[ITEM_INFO]")
        Addon.EditRuleDialog.InitTab(self, self.matchesTab, "[MATCHES]")
        PanelTemplates_SetNumTabs(self, table.getn(self.Tabs))
        self.selectedTab = self.helpTab:GetID()
        PanelTemplates_UpdateTabs(self);
        Addon.EditRuleDialog.SetMode(self, MODE_EDIT);
    end,

    ShowTab = function(self, tabId)
        -- Update the state of the tab and it's children
        for _, tab in pairs(self.Tabs) do
            for _, spacer in pairs(tab.Spacers) do
                if (tab:GetID() ~= tabId) then
                    spacer:Hide()
                else
                    spacer:Show()
                end
            end
        end

        -- Udpate the state of the panels
        for _, panel in pairs(self.Panels) do
            if (panel:GetID() == tabId) then
                panel:ClearAllPoints();
                panel:SetAllPoints(self.tabContainer);
                panel:Show();
            else
                panel:Hide();
            end
        end
    end,
    
    InitTab = function(self, tab, name)
        tab:SetText(name)        
        PanelTemplates_TabResize(tab, 0)
        for _, spacer in ipairs(tab.Spacers) do
            spacer:SetVertexColor(0.8, 0.8, 0.8, 0.50); 
            spacer:Hide();
        end
    end,

    OnTabClicked = function(self, tab)
        local tabId = tab:GetID()
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
        PanelTemplates_Tab_OnClick(tab, self);
        Addon.EditRuleDialog.ShowTab(self,  self.selectedTab)
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

    UpdateHelpControls = function(self)
        if (not self.expanded) then
            for _, panel in pairs(self.Panels) do
                panel:Hide();
            end
            for _, tab in pairs(self.Tabs) do
                tab:Hide();
            end
            self.tabContainer:Hide();
        else
            Addon.EditRuleDialog.ShowTab(self, self.selectedTab)
            Addon.EditRuleDialog.UpdateReference(self.helpPane)
            for _, tab in pairs(self.Tabs) do
                tab:Show();
            end
            self.tabContainer:Show();
        end
    end,

    ToggleExpand = function(self, button)
        if (not self.expanded) then
	        button:GetNormalTexture():SetTexCoord(0.5, 1, 0, 1);
	        self:SetWidth(self:GetWidth() + HELP_WIDTH)
	        self.expanded = true
        else
        	button:GetNormalTexture():SetTexCoord(0, 0.5, 0, 1);
        	self:SetWidth(self:GetWidth() - HELP_WIDTH)
        	self.expanded = false
        end
        Addon.EditRuleDialog.OnExpandLeave(self, button)
        Addon.EditRuleDialog.UpdateHelpControls(self)
    end,

    OnExpandEnter = function(self, button)
        GameTooltip:SetOwner(button, "ANCHOR_NONE")
        GameTooltip:SetPoint("TOPLEFT", button, "RIGHT")
        if (self.expanded) then
            GameTooltip:SetText(L["EDITRULE_COLLAPSE_TOOLTIP"])
        else
            GameTooltip:SetText(L["EDITRULE_EXPAND_TOOLTIP"])
        end
        GameTooltip:Show()
    end,

    OnExpandLeave = function(self, button)
        if (GameTooltip:GetOwner() == button) then
            GameTooltip:Hide()
        end
    end,

    OnHelpPaneLoad = function(self)
        Addon.EditRuleDialog.SetEditHelpText(self.filter, "[CLICK_TO_FILTER]")
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
                local valStr = tostring(value);
                if ((value == nil) or (valStr == "") or (string.len(valStr) == 0)) then
                    valStr = NIL_ITEM_STRING;
                end

                table.insert(props, string.format(ITEM_HTML_FMT, name, GREEN_FONT_COLOR_CODE, htmlEncode(valStr), FONT_COLOR_CODE_CLOSE));
            end
            
            infoPane.propHtml.scrollFrame.content:SetText(string.format(ITEM_INFO_HTML_BODY_FMT, link, table.concat(props)));
        end
    end,

    UpdateMatches = function(self)
        local links = {}
        local player, realm = UnitFullName("player");
        local params = { itemlevel = 220, };
        local matches = Addon:GetMatchesForRule(string.format("cr.%s.%s.%d", player, realm, time()), "Level() > RULE_PARAMS.ITEMLEVEL", params);
        for _, link in ipairs(matches) do
            table.insert(links, "<p>" .. link .. "</p>");
        end
        self.propMatches.scrollFrame.content:SetText("<html><body>" .. table.concat(links) .. "</body></html>");
    end,

    --*****************************************************************************
    -- Called when our "filter" focus state changes, we want to show/hide our 
    -- help text if we've got content.
    --*****************************************************************************
    OnEditFocusChange = function(self, gained)
        if (self.helpText) then
            if (gained) then
                self.helpText:Hide()
            else
                local text = self:GetText()
                if (not text or (text == "") or (string.len(text) == 0)) then
                    self.helpText:Show()
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

    --*****************************************************************************
    -- Create a new rule (Generates a unique new id for it) and then opens the 
    -- dialog to the rule (read only is considered false)
    --*****************************************************************************
    CreateRule = function(self)
        self:EditRule({ Id = string.format("cr%d%s", UnitName("player"), time()) })
    end,

    --*****************************************************************************
    -- Called when our "filter" focus state changes, we want to show/hide our 
    -- help text if we've got content.
    --*****************************************************************************
    EditRule = function(self, ruleDef, readOnly)
        self.ruleDef = ruleDef;
        self.readOnly = readOnly or false;

        -- Set the name / description
        self.name:SetText(ruleDef.Name or "")
        self.description.content:SetText(ruleDef.Description or "")
        
        -- Set the script text        
        if (ruleDef.ScriptText) then
            self.script.content:SetText(ruleDef.ScriptText)
        elseif (ruleDef.Script) then
            self.script.content:SetText(ruleDef.Script)
        else
            self.script.content:SetText("")
        end

        -- If we're read-only disable all the fields.
        if (readOnly) then
            Addon.EditRuleDialog.SetMode(self, MODE_READONLY);
        else
            Addon.EditRuleDialog.SetMode(self, MODE_EDIT);
        end

        self:Show()
    end,
};

local EditRuleDialog = Addon.EditRuleDialog;

function EditRuleDialog.SetMode(self, mode)
    print("settingmode:", self.mode, mode);
    if (mode ~= self.mode) then
    print("changing mode");
        self.mode = mode;
        if (mode == MODE_READONLY) then
            self.Caption:SetText(L["EDITRULE_CAPTION"]);
            
            -- ReadOnly hides the panels to the right
            for _, panel in ipairs(self.Tabs) do
                panel:Hide();
            end
            for _, tab in ipairs(self.Tabs) do
                tab:Hide();
            end

            self.tabContainer:Hide();
            self.script.content:Disable();
            self.name:Disable();
            self.description.content:Disable();            
        else
            self.Caption:SetText("[RULEDIALOG_READONLY_CAPTION]");

            -- Full mode shows everything
            for _, tab in ipairs(self.Tabs) do
                tab:Show();
            end

            self.script.content:Enable();
            self.name:Enable();
            self.description.content:Enable();
            self.tabContainer:Show();
            EditRuleDialog.ShowTab(self.selectedTab)
        end
    end
end
