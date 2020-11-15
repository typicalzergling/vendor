local AddonName, Addon = ...
local AboutPanel = {};

--[[============================================================================
    | Called ot load the panel
    ==========================================================================]]
function AboutPanel:OnLoad()
	self:CreateVersionList()
    self.Version:SetText(Addon:GetVersion())

    self.Releases.OnSelection = function(_, index) 
        local notes = Addon.ReleaseNotes[index]
        self.ReleaseNotesText:SetHtml(notes.html)
    end
end

--[[============================================================================
    | Create the list of relase notes
    ==========================================================================]]
function AboutPanel:CreateVersionList()
    local releases = {}
    for index, notes in ipairs(Addon.ReleaseNotes) do
		releases[index] = string.format("%s (%s)", notes.release, notes.on)
    end
    self.Releases:SetItems(releases)
end

Addon.Panels = Addon.Panels or {};
Addon.Panels.AboutPanel = AboutPanel
