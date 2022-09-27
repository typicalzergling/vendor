local _, Addon = ...
local AutolootFeature = {
    NAME = "SmartLoot",
    STATE = "preview",
    DESCRIPTION = " [tbd] ",
    VERSION = 1
}

Addon.SmartLoot = {
    CATEGORY_TAKE = 200,
    CATEGORY_SKIP = 100,   
}

local CATEGORY_TAKE = Addon.SmartLoot.CATEGORY_TAKE
local CATEGORY_SKIP = Addon.SmartLoot.CATEGORY_SKIP
local THRESHOLD = 1.0/3.0
local PENDING = "pending"
local SKIP = "skip"
local ROLLING = "rolling"
local ALWAYS = "always"
local LOOTED = "looted"
local CLEARED = "cleared"


local function debug(message, ...) 
    Addon:Debug("AUTOLOOT", message, ...)
end

-- Check if the item has the specific state
local function CheckState(item, ...)
    for _, state in ipairs({...}) do
        if (not item[state]) then
            return false;
        end
    end

    return true
end

-- Sets the state of the tiem
local function SetState(item, ...)
    for _, state in ipairs({...}) do
        item[state] = true
    end
end

-- Clears the state of an item
local function ClearState(item, ...)
    for _, state in ipairs({...}) do
        item[state] = nil
    end
end

-- Counts the number if items in the list which have the state
local function CountState(list, ...)
    local count = 0
    for _, item in ipairs(list) do
        if (CheckState(item, ...)) then
            count = count + 1
        end
    end

    return count
end

-- Counts the number of empty bag slots
local function CountEmptySlots()
    local free = {}
    local count = 0
    for bag=0,NUM_BAG_SLOTS do 
        GetContainerFreeSlots(bag, free);
        count = count + #free
    end
    return count
end

function AutolootFeature:OnInitialize()
    debug("Initializing auto-loot feature");
    local rulesEngine = Addon:CreateRulesEngine(false)

    for _, category in ipairs(Addon.SmartLoot.Category) do
        rulesEngine:CreateCategory(category.Id, category.Name, category.Weight)
    end

    for _, rule in ipairs(Addon.SmartLoot.BuiltinRules) do
        rulesEngine:AddRule(rule.Category, rule)
    end

    self.rulesEngine = rulesEngine
    return true;
end

function AutolootFeature:OnTerminate()
    self.rulesEngine = nil;
end

function AutolootFeature:ON_LOOT_OPENED(autoloot, fromItem)
end

function AutolootFeature:ON_LOOT_CLOSED()
    if (self.lootTable) then
        self:FinishLooting()
    end
end

function AutolootFeature:ON_ZONE_CHANGED()
    Vendor_XX_InstanceInfo = Vendor_XX_InstanceInfo or {}
    local instance = {GetInstanceInfo()}
    Vendor_XX_InstanceInfo[instance[1]] = instance
end

-- Need to loop through picking high item first
-- need to define instance specific rules these aren't 
-- the rules as we've normally got.

function AutolootFeature:ON_LOOT_READY(autoloot)
    debug("Loot ready : %s", tostring(autoloot))

    print(pcall(function()
        self:CreateLootTable()
        self:StartLooting()
    end))
end

function AutolootFeature:ON_LOOT_SLOT_CHANGED(slot)
    if (self.lootTable) then
        for _, item in ipairs(self.lootTable) do
            if (item.slot == slot and not CheckState(LOOTED,SKIPPED)) then
                debug("Unprocessed item in slot '%d' was updated", slot)

                local loot = GetLootInfo()
                item.info = loot[slot]

                C_Timer.After(THRESHOLD, function() self:LootNextItem() end)
            end
        end
    end
end

function AutolootFeature:ON_LOOT_SLOT_CLEARED(slot)
    debug("---> slot cleared %d", slot)
end

function AutolootFeature:CreateLootTable()
    local loot = GetLootInfo()
    local lootInfo = {}
    for slot=1,#loot do
        local item = { 
            info = loot[slot],
            slot = slot,
            link = GetLootSlotLink(slot),
        }


        local info = item.info

        -- Quest items and currency are always loot
        if (item.link and not info.currencyId and not info.isQuestItem and not info.questId and LootSlotHasItem(slot)) then
            item.props = self:CreateLootItemProperties(slot, item.link);

            if (not item.props or item.props.IsCurrency) then
                SetState(item, ALWAYS)
            end
        else 
            SetState(item, ALWAYS)
        end

        SetState(item, PENDING)
        if (loot[slot].roll == true) then
            SetState(item, ROLLING)
        end

        table.insert(lootInfo, item)
    end

    self.lootTable = lootInfo
end

function AutolootFeature:StartLooting()
    self.looted = {}
    self.passed = {}

    if (not self.lootTimer and table.getn(self.lootTable) ~= 0) then
        C_Timer.After(THRESHOLD, function() self:LootNextItem() end)
    end
end

function AutolootFeature:CheckLoot(item)
    if (CheckState(item, LOOTED, SKIPPED, ROLLING, CLEARED)) then
        return false, -1, -1
    end

    if (CheckState(item, ALWAYS)) then
        return true, item.slot, -1
    end

    if (CheckState(item, PENDING)) then
        item.props.FreeSpace = self.empty
        local eval = self.rulesEngine:EvaluateEx(item.props)

        if (eval.result) then
            item.rule = { id = eval.ruleId, name = eval.ruleName }

            if (eval.categoryId == CATEGORY_SKIP) then
                -- This item evaluated to skip, so lets mark it
                SetState(item, SKIPPED)
                ClearState(item, PENDING)
                table.insert(self.passed, item)

                Vendor_XX_LootInfo = Vendor_XX_LootInfo or {}
                table.insert(Vendor_XX_LootInfo, loot)
    
            elseif (eval.categoryId == CATEGORY_TAKE) then
                -- This item evaluated to loot
                return true, item.slot, eval.weight
            end
        else
            debug("[%s] did't match any rules (force looting)", item.link)
            return true, -1, -1
        end
    end

    return false, -1, -1
end

function AutolootFeature:LootNextItem()    
    if (not self.lootTable) then
        return -1;
    end

    local lootSlot = -1
    local lootWeight = -1
    local loot = nil
    local value = 0

    self.empty = CountEmptySlots()
    for _, item in ipairs(self.lootTable) do

        local should, slot, weight = self:CheckLoot(item)
        debug("CheckLoot :: %s  loot=%s, slot=%d, weight=%d", item.link or item.info.item, tostring(should), slot, weight)

        if should then
            if (CheckState(item, ALWAYS)) then
                loot = item
                break
            end

            if (lootWeight < 0 or weight > lootWeight) then
                loot = item
                lootWeight = weight
                value = item.props.TotalValue
            elseif (weight == lootWeight) then
                if (item.props.TotalValue > value) then
                    loot = item
                    lootWeight = weight
                    value = item.props.TotalValue
                end
            end
        end
    end

    if (loot) then        
        debug("Looting :: %s  %d/%d", loot.link or loot.info.item, loot.slot, #self.lootTable)
        
        if (not CheckState(loot, ALWAYS)) then
            Vendor_XX_LootInfo = Vendor_XX_LootInfo or {}
            table.insert(Vendor_XX_LootInfo, loot)
        end

        SetState(loot, LOOTED)
        ClearState(loot, PENDING)
        table.insert(self.looted, loot)
        LootSlot(loot.slot)
    end

    if (0 == CountState(self.lootTable, PENDING)) then
        C_Timer.After(THRESHOLD, function() self:FinishLooting() end)
    else
        C_Timer.After(THRESHOLD, function() self:LootNextItem() end)
    end
end

function AutolootFeature:FinishLooting()
    if (not self.lootTable) then
        return
    end

    local numLooted = 0
    local numPassed = 0
    for _, item in ipairs(self.lootTable) do

        local text = self:CreateLootedString(item)
        if ((type(text) == "string") and (string.len(text) ~= 0)) then
            if (item.props and (item.props.TotalValue ~= 0)) then
                text = text .. " << " .. Addon:GetPriceString(item.props.TotalValue) .. " >> "
            end

            if (item.rule) then
                text = text .. " (" .. item.rule.name .. ")"
            elseif (item.info.isQuestItem or item.info.questId) then
                text = text .. " <quest>"
            elseif (item.info.currencyId) then
                text = text .. " <currency>"
            end
                
            if (CheckState(item, LOOTED)) then
                numLooted = numLooted + 1
            elseif (CheckState(item, SKIPPED)) then
                numPassed = numPassed + 1
            end

            item.text = text
        end
    end

    if numLooted ~= 0 then 
        Addon:Print("Auto-looted %d items:", numLooted)
        i = 1
        for _, item in ipairs(self.looted) do
            if (item.text) then
                Addon:Print("%3d)  %s", i, item.text)
                i = i + 1
            end
        end
    end

    if numPassed ~= 0 then
        Addon:Print("Auto-passed %d items: (%d)", numPassed, table.getn(self.passed))
        i = 1
        for _, item in ipairs(self.passed) do
            if (item.text) then
                Addon:Print("%3d)  %s", i, item.text)
                i = i + 1
            else
                Addon:Print("%3d)  %s (unknown)", i, item.info.name)
                i = i + 1
            end
        end
    end
        
    self.lootTable = nil
    self.passed = nil
    self.looted = nil
    LootFrame_Close()
end

function AutolootFeature:CreateLootedString(item)
    assert(type(item) == "table", "Expected the looted item to be a table")

    -- coin (gold/silver/copper) show up with no quanity so we will just ignore 
    -- those items.
    if (not item.info or (not item.info.quantity or item.info.quantity == 0)) then
        return nil
    end

    local count = item.info.quantity or 1
    local _, _, _, quality = GetItemQualityColor(item.info.quality or 1)

    if item.link then 
        -- Use the link and quantity
        if (count == 1) then
            return item.link
        else
            return string.format("%s x %d", item.link, count)
        end
    elseif (item.props) then
        -- Use the item
        if (count == 1) then
            return string.format("|c%s%s|r x %d", quality, item.item.Name, count)
        end
    elseif (item.info) then
        -- use the info
        return string.format("|c%s%s|r x %d", item.info.item or "<unknown>", count)
    end

    return nil
end

function AutolootFeature:CreateLootItemProperties(slot, link)
    local itemInfo = {}

    local _, _, quantity, currencyId, _, locked, _, questItem, questId, active = GetLootSlotInfo(slot)

    -- Always loot currency and quest items
    if (currencyId or questItem) then
        return nil
    end

    -- If we can't figure out what it is then loot it always
    local itemInfo = Addon:GetItemPropertiesFromItemLink(link) 
    if (questItem or currencyId or not itemInfo) then
        return nil
    end

    itemInfo.FreeSlots = CountEmptySlots()
    itemInfo.IsLootable = not locked
    itemInfo.IsActive = active or false
    itemInfo.Count = quantity or 1
    itemInfo.StackSize = quantity or 1
    itemInfo.TotalValue = (itemInfo.UnitValue * quantity)

    itemInfo.IsCurrency = (currencyId ~= nil)
    itemInfo.CurrencyId = currencyId or -1

    if (itemInfo.IsCurrency) then 
        local info = C_CurrencyInfo.GetCurrencyContainerInfo(currencyId, quantity)
        if (info) then 
            itemInfo.Name = info.name
            itemInfo.Quality = info.quality
            itemInfo.StackCount = info.displayAmount
            itemInfo.TotalValue = quantity * itemInfo.UnitValue
        end
    end

    return itemInfo
end

Addon.Features = Addon.Features or {}
Addon.Features.AutolootFeature = AutolootFeature
