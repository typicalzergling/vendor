local _, Addon = ...
local Vendor = Addon.Features.Vendor
local HelpTab = {}
local Colors = Addon.CommonUI.Colors

function HelpTab:OnActivate()
    self.version:SetUrl(Addon:GetVersion())
    if (not self.releases:GetSelected()) then
        self.releases:EnsureSelection()
    end
end

--[[ Retreive the categories for the rules ]]
function HelpTab:GetCategories()
    local releases = {}

    if type(Addon.ReleaseNotes) == "table" then
        for index, notes in ipairs(Addon.ReleaseNotes) do
            table.insert(releases, { 
                Markdown = notes.Notes,
                Text = notes.Release
            })
        end
    end

    return releases
end

function HelpTab:GetContents()
    local model = self.releases:GetSelected()
    if (model and model.Notes) then
        return model.Notes
    end

    return {}
end

local NotesItem =
{
    OnSizeChanged = function(self)
        self.content:SetHeight(0)
        self:SetHeight(self.content:GetHeight())
    end
}

function HelpTab:CreateNoteItem(model)
    local frame = CreateFrame("Frame")
    local template = "GameFontNormal"
    frame:SetHeight(1)
    frame:SetWidth(1)

    if (type(model) == "table" and model.type == "header") then
        template = "GameFontNormalLarge"
    end
    
    local text = frame:CreateFontString(nil, "ARTWORK", template)
    text:SetJustifyV("TOP")
    text:SetJustifyH("LEFT")
    text:SetTextColor(Colors.SECONDARY_TEXT:GetRGBA())
    text:SetWordWrap(true)

    local content = nil
    if type(model) == "string" then
        content = model
    elseif (model.type == "paragraph") then
        content = model.text
    elseif (model.type == "header") then
        content = model.text
        text:SetTextColor(Colors.TEXT:GetRGBA())
        text:SetMaxLines(1)
        text:SetWordWrap(false)
    end

    frame.content = text
    text:SetText(Addon.StringTrim(content or (RED_FONT_COLOR_CODE .. "<error>|r")))
    text:SetHeight(2)
    text:SetPoint("TOPLEFT", frame, 6, 0)
    text:SetPoint("TOPRIGHT", frame, -6, 0)

    Addon.AttachImplementation(frame, NotesItem, true)
    return frame
end

--[[ Show the specified release notes ]]
function HelpTab:ShowRelease(release)
    if (release.Markdown) then
        self.notes:SetMarkdown(release.Markdown)
    else
        self.notes:SetMarkdown("")
    end
    self.notes:ScrollToTop()
end

Vendor.MainDialog.HelpTab = HelpTab