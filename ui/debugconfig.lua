-- This is exclusively for the debug options panel and Debug-specific commands that do not appear in a normal build.
-- This entire file is excluded from packaging and it is not localized intentionally.
local Addon, L = _G[select(1,...).."_GET"]()

-- Sets up all the console commands for debug functions in this file.
function Addon:SetupDebugConsoleCommands()
    self:AddConsoleCommand("debug", "Toggle Debug", function() Addon:ToggleDebug("debug") end)
    self:AddConsoleCommand("debugrules", "Toggle Debug Rules", function() Addon:ToggleDebug("debugrules") end)
    self:AddConsoleCommand("link", "Dump hyperlink information", "DumpLink_Cmd")
    self:AddConsoleCommand("test", "It is a mystery!", "Test_Cmd")
end


-- Debug Commands

function Addon:DumpLink_Cmd(arg)
    self:Print("Link: "..tostring(arg))
    self:Print("Raw: "..gsub(arg, "\124", "\124\124"))
    self:Print("ItemString: "..tostring(self:GetLinkString(arg)))
    local props = self:GetLinkProperties(arg)
    for i, v in pairs(props) do
        self:Print("["..tostring(i).."] "..tostring(v))
    end
    self:Print("ItemInfo:")
    local itemInfo = {GetItemInfo(tostring(arg))}
    for i, v in pairs(itemInfo) do
        self:Print("["..tostring(i).."] "..tostring(v))
    end
end

function Addon:Test_Cmd(...)
    local iteminfo = self:GetAllBagItemInformation()
    for k, item in pairs(iteminfo) do
        local v = item.Properties
        self:Print(string.format("Item %s [%s] %s - %s (%s) / %s (%s)  Xpac=%s", tostring(v.Link), tostring(v.Level),tostring(v.Quality), tostring(v.Type), tostring(v.TypeId), tostring(v.SubType), tostring(v.SubTypeId), tostring(v.ExpansionPackId)))
        self:Print(string.format("   SB=%s BOE=%s BOU=%s AP=%s XMOG=%s Value=%s", tostring(v.IsSoulbound), tostring(v.IsBindOnEquip), tostring(v.IsBindOnUse), tostring(v.IsArtifactPower), tostring(v.IsUnknownAppearance), tostring(v.UnitValue)))
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

