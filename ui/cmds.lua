local L = Vendor:GetLocalizedStrings()

-- Add or remove items from the blacklist or whitelist.
function Vendor:SellItem_Cmd(info)
    -- split arg from command line
    local list = info.input:match("^[^%s]+%s+([^%s]+)")
    local item = info.input:match("^[^%s]+%s+[^%s]+%s+([^%s].*)")
    self:Debug(tostring(list).." "..tostring(item))
    
    -- need at least one command, should print usage
    if not list or (list ~= self.c_AlwaysSellList and list ~= self.c_NeverSellList) then 
        self:Print(L["CMD_SELLITEM_INVALIDARG"])
        return 
    end
    
    -- get item id
    local id = self:GetItemId(item)
    
    -- if id specified, add or remove it
    if id then
        local retval = self:ToggleItemInBlocklist(list, id)
        if retval == 1 then
            self:Print(string.format(L["CMD_SELLITEM_ADDED"], tostring(id), list))
        else
            self:Print(string.format(L["CMD_SELLITEM_REMOVED"], tostring(id), list))        
        end

    -- otherwise dump the list
    else
        self:PrintVendorList(list)
    end
end

-- Clear the blacklist and or whitelist.
function Vendor:ClearData_Cmd(info)
    local _, arg
    if info.input then
        _, arg = info.input:match("([^%s]+)%s+([^%s].*)")
    end

    if arg and arg ~= self.c_NeverSellList and arg ~= self.c_AlwaysSellList then
        self:Print(string.format(L["CMD_CLEARDATA_INVALIDARG"], arg))
        return
    end

    if not arg or arg == self.c_AlwaysSellList then
        self:ClearBlocklist(self.c_AlwaysSellList)
        self:Print(L["CMD_CLEARDATA_ALWAYS"])
    end

    if not arg or arg == self.c_NeverSellList then
        self:ClearBlocklist(self.c_NeverSellList)
        self:Print(L["CMD_CLEARDATA_NEVER"])
    end
end

-- List items in the blacklist and or whitelist.
function Vendor:ListData_Cmd(info)
    -- split arg from command line
    local _, arg
    if info.input then
        _, arg = info.input:match("([^%s]+)%s+([^%s].*)")
    end
    
    if arg and arg ~= self.c_NeverSellList and arg ~= self.c_AlwaysSellList then
        self:Print(string.format(L["CMD_LISTDATA_INVALIDARG"], arg))
        return
    end
    
    if not arg then
        self:PrintVendorList(self.c_NeverSellList)
        self:PrintVendorList(self.c_AlwaysSellList)
    else
        self:PrintVendorList(arg)
    end
end

function Vendor:PrintVendorList(list)
    local vlist = self:GetBlocklist(list)
    if self:TableSize(vlist) == 0 then
        self:Print(string.format(L["CMD_LISTDATA_EMPTY"], list))
        return
    end

    self:Print(string.format(L["CMD_LISTDATA_LISTHEADER"], list))
    for i, v in pairs(vlist) do
        -- Get item info for pretty display
        local name, link = GetItemInfo(tonumber(i))
        local disp = link or name

        -- Note that GetItemInfo will not return anything if the item has not yet been seen.
        if not disp then
            disp = L["CMD_LISTDATA_NOTINCACHE"]
        end
        self:Print(string.format(L["CMD_LISTDATA_LISTITEM"], tostring(i), tostring(disp)))
    end
end

function Vendor:OpenSettings_Cmd(info)
    -- Call it twice so it opens first to the Game options, then to the AddOns category.
    InterfaceOptionsFrame_OpenToCategory(L["ADDON_NAME"])
    InterfaceOptionsFrame_OpenToCategory(L["ADDON_NAME"])
end
