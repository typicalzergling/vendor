-- Addon core. Handles initialization and first-run setup. 
local _, Addon = ...
local L = Addon:GetLocale()

-- This is the first event fired after Addon is completely ready to be loaded.
-- This is one-time initialization and setup.
function Addon:OnInitialize()
    self:GenerateEvents(self.Events)

    -- Setup Console Commands
    self:SetupConsoleCommands()

    --@do-not-package@
    if self.SetupDebugConsoleCommands then
        self:SetupDebugConsoleCommands()
    end

    if self.SetupTestConsoleCommands then
        self:SetupTestConsoleCommands()
    end
    --@end-do-not-package@
end
