local AddonName, Addon = ...
local L = Addon:GetLocale()

-- This registers all of the commands in this file.
function Addon:SetupConsoleCommands()
    self:RegisterConsoleCommandName(self.c_AddonName, "/vendor", "/ven")
    self:AddConsoleCommand(nil, nil, "OpenConfigDialog_Cmd")                        -- Override the default
    self:AddConsoleCommand("rules", L["CMD_RULES_HELP"], "OpenConfigDialog_Cmd")
    self:AddConsoleCommand("sell", L["CMD_SELLITEM_HELP"], "SellItem_Cmd")
    self:AddConsoleCommand("clear", L["CMD_CLEARDATA_HELP"], "ClearData_Cmd")
    self:AddConsoleCommand("list", L["CMD_LISTDATA_HELP"], "ListData_Cmd")
    self:AddConsoleCommand("keys", L["CMD_KEYS_HELP"], "OpenKeybindings_Cmd")
    self:AddConsoleCommand("settings", L["CMD_SETTINGS_HELP"], "OpenSettings_Cmd")
    self:AddConsoleCommand("withdraw", L["CMD_WITHDRAW_HELP"], "Withdraw_Cmd")
end

-- Add or remove items from the blacklist or whitelist.
function Addon:SellItem_Cmd(list, item)

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
        self:PrintAddonList(list)
    end
end

-- Clear the blacklist and or whitelist.
function Addon:ClearData_Cmd(arg)
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
function Addon:ListData_Cmd(arg)
    if arg and arg ~= self.c_NeverSellList and arg ~= self.c_AlwaysSellList then
        self:Print(string.format(L["CMD_LISTDATA_INVALIDARG"], arg))
        return
    end

    if not arg then
        self:PrintAddonList(self.c_NeverSellList)
        self:PrintAddonList(self.c_AlwaysSellList)
    else
        self:PrintAddonList(arg)
    end
end

function Addon:PrintAddonList(list)
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

-- This is defunct, but in case we add a hook in...
function Addon:OpenSettings_Cmd()
    -- Call it twice so it opens first to the Game options, then to the AddOns category.
    InterfaceOptionsFrame_OpenToCategory(L["ADDON_NAME"])
    InterfaceOptionsFrame_OpenToCategory(L["ADDON_NAME"])
end

function Addon:OpenKeybindings_Cmd()
    -- Blizzard delay-loads the keybinding frame. If it doesn't exist, load it.
    if not KeyBindingFrame then
        KeyBindingFrame_LoadUI()
    end

    -- If we still don't have it, bail.
    if not KeyBindingFrame then
        return
    end

    -- Make sure the buttons and categories exist, and enumerate them.
    if KeyBindingFrameCategoryList and KeyBindingFrameCategoryList.buttons then
        -- Find our category in the list of categories.
        for i, button in pairs(KeyBindingFrameCategoryList.buttons) do
            if button.element and button.element.name and button.element.name == _G["BINDING_CATEGORY_VENDOR"] then
                -- Found it. Click it to set the category.
                if Addon.IsClassic then
                    KeybindingsCategoryListButton_OnClick(button)
                else
                    button:OnClick()
                end
            end
        end
    end

    -- Show the keybinding frame. Even if we dont' find it, its closer.
    KeyBindingFrame:Show()
end

function Addon:OpenConfigDialog_Cmd()
    VendorRulesDialog:Toggle()
end

-- Initiates a manual Auto-Sell. This ignores the auto-sell configuration setting.
function Addon:AutoSell_Cmd()
    -- Check for merchant not being open.
    if not self:IsMerchantOpen() then
        self:Print(L["CMD_AUTOSELL_MERCHANTNOTOPEN"])
        return
    end

    -- Check for sell in progress.
    if self:IsAutoSelling() then
        self:Print(L["CMD_AUTOSELL_INPROGRESS"])
        return
    end

    -- OK to do the auto-sell.
    self:Print(L["CMD_AUTOSELL_EXECUTING"])
    self:AutoSell()
end

-- Withdraws all items which match your currently enabled rules set
function Addon:Withdraw_Cmd()
    local function findBagWithSpace()
        for i=0,NUM_BAG_SLOTS do
            if GetContainerNumFreeSlots(i) ~= 0 then
                return i;
            end
        end
        return -1;
    end

    local items = self:LookForItemsInBank();
    local count = 0;
    if #items then
        for _, item in ipairs(items) do
            local bag, slot, link = unpack(item);
            local tobag = findBagWithSpace();
            if (tobag > 0) then
                PickupContainerItem(bag, slot);
                PutItemInBag(ContainerIDToInventoryID(tobag));
                Addon:Print(L["MERCHANT_WITHDRAW_ITEM"], link);
                count = (count + 1);
            elseif (tobag == 0) then
                PickupContainerItem(bag, slot);
                PutItemInBackpack();
                Addon:Print(L["MERCHANT_WITHDRAW_ITEM"], link);
                count = (count + 1);
            else
                break;
            end
        end
    end
    Addon:Print(L["MERCHANT_WITHDRAWN_ITEMS"], count);
end
