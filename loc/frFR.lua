-- frFR Localization
-- If the loading order of the files is incorrect, this will fail when trying to use AddonLocales.
-- Locales should be loaded AFTER Init and before anything that uses them.
-- So basically make sure they are all loaded together in the TOC right after Init (constants is OK too).
local AddonLocales = _G[select(1,...).."_LOC"]()
AddonLocales["frFR"] =
{
-- Core
["ADDON_NAME"] = "Vendeur",

-- Add translations as learned. Anything not listed here in will inherit default language as a fallback.

} -- END OF LOCALIZATION TABLE

