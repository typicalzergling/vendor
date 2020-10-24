-- This is exclusively for the debug options panel and Debug-specific commands that do not appear in a normal build.
-- This entire file is excluded from packaging and it is not localized intentionally.
local AddonName, Addon = ...
local L = Addon:GetLocale()

-- Sets up all the console commands for debug functions in this file.
function Addon:SetupDebugConsoleCommands()
    self:AddConsoleCommand("debug", "Toggle Debug. Accepts channel argument, default otherwise", function(channel) if not channel then channel = "default" end; Addon:ToggleDebug(channel) end)
    self:AddConsoleCommand("debugrules", "Toggle Debug Rules", function() Addon:ToggleDebug("rules") end)
    self:AddConsoleCommand("link", "Dump hyperlink information", "DumpLink_Cmd")
end

-- Debug Commands
function Addon:DumpLink_Cmd(arg)
    self:Print("Link: "..tostring(arg))
    self:Print("Raw: "..gsub(arg, "\124", "\124\124"))
    self:Print("ItemString: "..tostring(self:GetLinkFromString(arg)))
    local props = self:GetLinkPropertiesFromString(arg)
    for i, v in pairs(props) do
        self:Print("["..tostring(i).."] "..tostring(v))
    end
    self:Print("ItemInfo:")
    local itemInfo = {GetItemInfo(tostring(arg))}
    for i, v in pairs(itemInfo) do
        self:Print("["..tostring(i).."] "..tostring(v))
    end
end

function Addon:GetAllBagItemInformation()
    local items = {}
    for bag=0, NUM_BAG_SLOTS do
        for slot=1, GetContainerNumSlots(bag) do
            local item = self:GetBagItemFromCache(bag, slot)
            if item then
                table.insert(items, item)
            end
        end
    end

    self:Print("Items count: "..tostring(self:TableSize(items)));
    return items
end