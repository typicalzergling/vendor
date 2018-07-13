Vendor = Vendor or {}

-- Manages the always-sell and never-sell blocklists.
-- Consider - adding "toggle" as a method on config can (and should) fire a config change.

-- Returns 1 if item was added to the list.
-- Returns 2 if item was removed from the list.
-- Returns nil if no action taken.
function Vendor:ToggleItemInBlocklist(list, item)
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

    local config = self:GetConfig()

    -- Add it to the specified list.
    -- If it already existed, remove it from that list.
    if list == self.c_AlwaysSellList then
        local ret = toggle(config:GetValue("sell_always"), config:GetValue("sell_never"), id)
        if (ret) then self:ClearTooltipResultCache() end
        return ret
    elseif list == self.c_NeverSellList then
        local ret = toggle(config:GetValue("sell_never"), config:GetValue("sell_always"), id)
        if (ret) then  self:ClearTooltipResultCache() end
        return ret
    else
        return nil
    end
end

-- Quick direct accessor for Never Sell List
function Vendor:IsItemIdInNeverSellList(id)
    local list = self:GetConfig():GetValue("sell_never")
    if id and list then
        return list[id]
    end
    return false
end

-- Quick direct accessor for Always Sell List
function Vendor:IsItemIdInAlwaysSellList(id)
    local list = self:GetConfig():GetValue("sell_always")
    if id and list then
        return list[id]
    end
    return false
end

-- Returns whether an item is in the list and which one.
function Vendor:GetBlocklistForItem(item)
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
function Vendor:GetBlocklist(list)
    local vlist = {}
    if list == self.c_AlwaysSellList then
        vlist = self:GetConfig():GetValue("sell_always")
    elseif list == self.c_NeverSellList then
        vlist = self:GetConfig():GetValue("sell_never")
    end
    return vlist
end

-- Permanently deletes the associated blocklist.
function Vendor:ClearBlocklist(list)
    if list == self.c_AlwaysSellList then
        self:GetConfig():SetValue("sell_always", {})
    elseif list == self.c_NeverSellList then
        self:GetConfig():SetValue("sell_never", {})
    end

    -- Blocklist changed, so clear the Tooltip cache.
    self:ClearTooltipResultCache()
end
