-- This is exclusively for the debug options panel and Debug-specific commands that do not appear in a normal build.
-- This entire file is excluded from packaging and it is not localized intentionally.
local Addon, L = _G[select(1,...).."_GET"]()

-- Sets up all the console commands for debug functions in this file.
function Addon:SetupDebugConsoleCommands()
    self:AddConsoleCommand("debug", "Toggle Debug", function() Addon:ToggleDebug("default") end)
    self:AddConsoleCommand("debugrules", "Toggle Debug Rules", function() Addon:ToggleDebug("rules") end)
    self:AddConsoleCommand("link", "Dump hyperlink information", "DumpLink_Cmd")
    self:AddConsoleCommand("test", "It is a mystery!", "Test_Cmd")
    self:AddConsoleCommand("lfg", "dumps some lfg info", "Test_lfg")
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
    local Item = PawnGetItemData(select(1,...))
    local UpgradeInfo, BestItemFor, SecondBestItemFor, NeedsEnhancements = PawnIsItemAnUpgrade(Item)

    self:Print("UpgradeInfo: %s", tostring(UpgradeInfo))
        if UpgradeInfo then
            for key, data in pairs(UpgradeInfo) do
                self:Print("Key: %s  Value: %s", tostring(key), tostring(data))
                for key1, data1 in pairs(data) do
                    self:Print("Key: %s  Value: %s", tostring(key1), tostring(data1))
                end
            end
        end
    self:Print("BestItemFor: %s", tostring(BestItemFor))
    self:Print("SecondBestItemFor: %s", tostring(SecondBestItemFor))
    self:Print("NeedsEnhancements: %s", tostring(NeedsEnhancements))


    --[[local upgradeInfo = {PawnIsItemAnUpgrade(Item)}
    for _, v in ipairs(upgradeInfo) do
        if type(v) == "table" then
            for key, data in pairs(v) do
                self:Print("Key: %s  Value: %s", tostring(key), tostring(data))
            end
        else
            self:Print("Info: %s", tostring(v))
        end
    end]]
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

function Addon:Test_lfg(...)
    local tCats = C_LFGList.GetAvailableCategories(LE_LFG_LIST_FILTER_PVE);
    for _, catId in ipairs(tCats) do
        print("catId:", catId, C_LFGList.GetCategoryInfo(catId));


        tAct = C_LFGList.GetAvailableActivities(catId, nil, LE_LFG_LIST_FILTER_PVE);
        for _, actId in ipairs(tAct) do
            print("actId:", actId, C_LFGList.GetActivityInfo(actId));

            --local tGroups = C_LFGList.GetAvailableActivityGroups(tCat, LE_LFG_LIST_FILTER_PVE);
           -- for _, groupId in ipairs(tGroups) do
           --     print("groupId:", groupId);
           -- end

        end

    end
end
