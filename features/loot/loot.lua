local _, Addon = ...

local L = Addon:GetLocale()
local DEBUG_CHANNEL = "loot"
local function debugp(...) Addon:Debug(DEBUG_CHANNEL, ...) end

local Loot = Mixin({}, Addon.UseProfile)
Loot.NAME = "Loot"
Loot.VERSION = 1
Loot.DEPENDENCIES = {}

local LOOT_DELAY = .3
local function onLootReady()
    if not Loot:IsFastLootEnabled() then return end
    if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
        debugp("Looting...")
        -- The LOOT_READY event fires twice, so ideally we have a single timer
        -- that is replaced when a second event comes in. However, this does
        -- not seem harmful or to cause error, and having a little redundancy
        -- with a second loot attempt is probably good for reliability.
        C_Timer.After(LOOT_DELAY, function() 
            for i = GetNumLootItems(), 1, -1 do
                LootSlot(i)
            end
        end)
    end
end

function Loot:IsFastLootEnabled()
    return Addon:GetAccountSetting(Addon.c_Config_FastLoot, true)
end

function Loot.SetFastLoot(value)
    Addon:SetAccountSetting(Addon.c_Config_FastLoot, value)
end

function Loot:CreateSettingForFastLoot()
    return Addon.Features.Settings.CreateSetting(nil, true, self.IsFastLootEnabled, self.SetFastLoot)
end


function Loot:OnInitialize()
    if Addon.IsDebug then
        Addon:RegisterDebugChannel(DEBUG_CHANNEL)
    end

    Addon:RegisterEvent("LOOT_READY", onLootReady)
end

function Loot:OnTerminate()
end

Addon.Features.Loot = Loot
