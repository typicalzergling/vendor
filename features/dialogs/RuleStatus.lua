local _, Addon = ...
local Dialogs = Addon.Features.Dialogs
local locale = Addon:GetLocale()
local RuleStatus = {}
local COLORS = Addon.CommonUI.COLORS

local RULE_STATUS_INFO = {
    ok = {
        Title = locale.EDITRULE_OK_TEXT,
        Text = locale.EDITRULE_RULEOK_TEXT,
        TitleColor = GREEN_FONT_COLOR,
        TextColor = HIGHLIGHT_FONT_COLOR,
    },
    invalid = {
        Title = locale.EDITRULE_ERROR_RULE,
        Text = locale.EDITRULE_SCRIPT_ERROR,
        TitleColor = RED_FONT_COLOR,
        TextColor = HIGHLIGHT_FONT_COLOR,
    },
    unhealthy = {
        Title = locale.EDITRULE_UNHEALTHY_RULE,
        Text = locale.EDITRULE_SCRIPT_ERROR,
        TitleColor = ORANGE_FONT_COLOR,
        TextColor = HIGHLIGHT_FONT_COLOR,
    },
    outOfDate = {
        Title = locale.EDITRULE_MIGRATE_RULE_TITLE,
        Text = locale.EDITRULE_MIGRATE_RULE_TEXT,
        TitleColor = LEGENDARY_ORANGE_COLOR,
        TextColor = WHITE_FONT_COLOR,
    },
    extension = {
        Title = locale.EDITRULE_EXTENSION_RULE,
        Text = locale.EDITRULE_EXTENSION_RULE_TEXT,
        TitleColor = Addon.HEIRLOOM_BLUE_COLOR,
        TextColor = HIGHLIGHT_FONT_COLOR,
    },
    system = {
        Title = locale.EDITRULE_SYSTEM_RULE,
        Text = locale.EDITRULE_SYSTEM_RULE_TEXT,
        TitleColor = Addon.ARTIFACT_GOLD_COLOR,
        TextColor = HIGHLIGHT_FONT_COLOR,
    }
};

function RuleStatus:OnLoad()
    self.text:Hide()
end

function RuleStatus:SetStatus(status, message)
    local info = RULE_STATUS_INFO[status]
    if (not info) then
        self:Hide()
        return
    end

    local text = self.text
    local content = info.Text
    if type(content) == "string" then
        local loc = locale[message]
        text:SetFormattedText(content, message or "<error>")
        text:SetTextColor(info.TextColor:GetRGBA())
        text:Show()
    else
        text:Hide()
    end

    self.title:SetText(info.Title)
    self.title:SetTextColor(info.TitleColor:GetRGBA())

    self:Show()
end

function RuleStatus:Clear()
    self:Hide()
end

Dialogs.RuleStatus = RuleStatus