Vendor = Vendor or {}
Vendor.c_DefaultLocale = "enUS"

-- All Locs must be loaded prior to this call happening the first time.
function Vendor:GetLocalizedStrings()
    if not self.LocalizedStrings then
        self.LocalizedStrings = {}

		-- Import the Default Locale
        for k, v in pairs(self.Locales[self.c_DefaultLocale]) do
            self.LocalizedStrings[k] = v
        end

		-- Get current locale strings if available and merge.
        local locale = self.Locales[GetLocale()]
        if locale then
            for k, v in pairs(locale) do
                self.LocalizedStrings[k] = v
            end
        end
    end
    return self.LocalizedStrings
end
