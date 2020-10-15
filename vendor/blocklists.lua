local AddonName, Addon = ...
local L = Addon:GetLocale()
local Config = Addon:GetConfig()

local BlockList = {}
function BlockList:Create(_config, _listType, _configValue)
    local instance = {
        listType = _listType,
        config = _config,
        configValue = _configValue,
    };

   setmetatable(instance, self)
   self.__index = self
   return instance
end

function BlockList:Add(itemId)
    local list = self.config:GetValue(self.configValue);
    if (not list[itemId]) then
        list[itemId] = true;
        Addon:Debug("BlockList: Added %d to '%s' list", itemId, self.listType);
        self.config:NotifyChanges();
        return true;
    end

    return false;
end

function BlockList:Remove(itemId)
    local list = self.config:GetValue(self.configValue);
    if (list[itemId]) then
        list[itemId] = nil;
        Addon:Debug("BlockList: Removed %d from '%s' list", itemId, self.listType);
        self.config:NotifyChanges();
        return true;
    end
    return false;
end

function BlockList:Contains(itemId)
    local list = self.config:GetValue(self.configValue);
    return list[itemId] == true;
end

function BlockList:GetContents()
    --todo: this should be a clone of the table
    return self.config:GetValue(self.configValue);
end

function BlockList:GetType()
    return self.listType;
end

function BlockList:IsType(listType)
    return (self.listType == listType);
end


-- Manages the always-sell and never-sell blocklists.
-- Consider - adding "toggle" as a method on config can (and should) fire a config change.

-- Returns 1 if item was added to the list.
-- Returns 2 if item was removed from the list.
-- Returns nil if no action taken.
function Addon:ToggleItemInBlocklist(list, item)
    local function toggle(l, o, i)
        if (l[i]) then
            l[i] = nil
            return 2
        else
            l[i] = true
            o[i] = nil
            return 1
        end
    end

    if not item then return nil end

    local id = self:GetItemId(item)
    if not id then return nil end

    -- Add it to the specified list.
    -- If it already existed, remove it from that list.
    if list == self.c_AlwaysSellList then
        local ret = toggle(Config:GetValue("sell_always"), Config:GetValue("sell_never"), id)
        if (ret) then
            Config:NotifyChanges()
        end
        return ret
    elseif list == self.c_NeverSellList then
        local ret = toggle(Config:GetValue("sell_never"), Config:GetValue("sell_always"), id)
        if (ret) then
            Config:NotifyChanges()
        end
        return ret
    else
        return nil
    end
end

-- Quick direct accessor for Never Sell List
function Addon:IsItemIdInNeverSellList(id)
    local list = self:GetConfig():GetValue("sell_never")
    if id and list then
        return list[id]
    end
    return false
end

-- Quick direct accessor for Always Sell List
function Addon:IsItemIdInAlwaysSellList(id)
    local list = self:GetConfig():GetValue("sell_always")
    if id and list then
        return list[id]
    end
    return false
end

-- Returns whether an item is in the list and which one.
function Addon:GetBlocklistForItem(item)
    local id = self:GetItemId(item)
    if id then
        if self:IsItemIdInNeverSellList(id) then
            return self.c_NeverSellList
        elseif self:IsItemIdInAlwaysSellList(id) then
            return self.c_AlwaysSellList
        else
            return nil
        end
    end
    return nil
end

-- Returns the list of items on the black or white list
function Addon:GetBlocklist(list)
    local vlist = {}
    if list == self.c_AlwaysSellList then
        vlist = self:GetConfig():GetValue("sell_always")
    elseif list == self.c_NeverSellList then
        vlist = self:GetConfig():GetValue("sell_never")
    end
    return vlist
end

-- Permanently deletes the associated blocklist.
function Addon:ClearBlocklist(list)
    if list == self.c_AlwaysSellList then
        self:GetConfig():SetValue("sell_always", {})
    elseif list == self.c_NeverSellList then
        self:GetConfig():SetValue("sell_never", {})
    end

    -- Blocklist changed, so clear the Tooltip cache.
    self:ClearTooltipResultCache()
end

function Addon:GetList(listType)
    if (listType == self.c_AlwaysSellList) then
        return BlockList:Create(Config, listType, "sell_always");
    elseif (listType == self.c_NeverSellList) then
        return BlockList:Create(Config, listType, "sell_never");
    end
    return nil;
end
