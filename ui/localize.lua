local _, Addon = ...;
local locale = Addon:GetLocale();
local LOC_KEY = "LocKey";
local SET_TEXT = "SetText";


-- Given a Frame/Region checks for the presence if a localized key and a 
-- function to set the set text, and applies the localized string.
local function SetLocKey(target)
    local key = target[LOC_KEY];
    if (type(key) == "string") then
        local set = target[SET_TEXT];
        if (type(set) == "function") then
            xpcall(set, CallErrorHandler, target, locale[key]);
        end
    end
end

-- Visits a frame, and tries to localize all of the children/regions for the
-- frame, also visits all of the child frames.
local function VisitFrame(frame)
    for _, child in pairs({ frame:GetChildren() }) do
        SetLocKey(child);
        VisitFrame(child);
    end

    for _, region in pairs({ frame:GetRegions() }) do
        SetLocKey(region);
    end
end

-- Expose a top level visit call.
Addon.LocalizeFrame = VisitFrame;