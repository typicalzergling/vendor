local AddonName, Addon = ...
local L = Addon:GetLocale()

-- This registers all of the commands in this file.
function Addon:SetupConsoleCommands()
    self:RegisterConsoleCommandName(AddonName, "/vendor", "/ven")
    self:AddConsoleCommand(nil, nil, "OpenConfigDialog_Cmd")                        -- Override the default
    self:AddConsoleCommand("rules", L.CMD_RULES_HELP, "OpenConfigDialog_Cmd")
    self:AddConsoleCommand("list", L.CMD_LISTTOGGLE_HELP, "ListToggle_Cmd")
    self:AddConsoleCommand("keys", L.CMD_KEYS_HELP, "OpenKeybindings_Cmd")
    self:AddConsoleCommand("settings", L.CMD_SETTINGS_HELP, "OpenSettings_Cmd")
    self:AddConsoleCommand("withdraw", L.CMD_WITHDRAW_HELP, "Withdraw_Cmd")
    self:AddConsoleCommand("api", L.CMD_API_HELP, "PrintAPI_Cmd")
    self:AddConsoleCommand("history", L.CMD_HISTORY_HELP, "History_Cmd")
    self:AddConsoleCommand("destroy", L.CMD_DESTROY_HELP, "Destroy_Cmd")
    self:AddConsoleCommand("import", "imports", "Import_Cmd")
end

function Addon:Import_Cmd(text)
    local feature = Addon:GetFeature("import")
    if (feature) then
        feature:ShowImportDialog(text)
    end
end

-- Add or remove items from the blacklist or whitelist.
function Addon:ListToggle_Cmd(list, item)

    -- Get the key in the ListType to which this value belongs.
    local function inListType(list)
        for k, v in pairs(Addon.ListType) do
            if list == v then
                return k
            end
        end
    end

    -- need at least one command, should print usage
    if not list or not inListType(list) then
        self:Print(L["CMD_LISTTOGGLE_INVALIDARG"])
        return
    end

    -- get item id
    local id = select(1, GetItemInfoInstant(item))

    -- if id specified, add or remove it
    if id then
        local retval = self:ToggleItemInBlocklist(list, id)
        if retval == 1 then
            self:Print(string.format(L["CMD_LISTTOGGLE_ADDED"], tostring(id), list))
        else
            self:Print(string.format(L["CMD_LISTTOGGLE_REMOVED"], tostring(id), list))
        end

    -- otherwise dump the list
    else
        self:PrintAddonList(list)
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
    Addon:WithFeature("Vendor", function(vendor)
        vendor:ShowDialog("settings")
    end)
end


function Addon:OpenKeybindings_Cmd()
    if Addon.Systems.Info.IsClassicEra then
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
                if button.element and button.element.name and button.element.name == "Vendor Addon" then
                    -- Found it. Click it to set the category.
                    if Addon.Systems.Info.IsClassicEra then
                        KeybindingsCategoryListButton_OnClick(button)
                    else
                        button:OnClick()
                    end
                end
            end
        end

        -- Show the keybinding frame. Even if we dont' find it, its closer.
        KeyBindingFrame:Show()
    else
        Settings.OpenToCategory(54, "Vendor Addon")
    end
end

function Addon:OpenConfigDialog_Cmd()
    Addon:WithFeature("Vendor", function(vendor)
        vendor:ShowDialog("rules")
    end)
end

-- Initiates a manual Auto-Sell. This ignores the auto-sell configuration setting.
function Addon:AutoSell_Cmd()

    local merchant = Addon:GetFeature("Merchant")
    -- Check for merchant not being open.
    if not merchant:IsMerchantOpen() then
        self:Print(L["CMD_AUTOSELL_MERCHANTNOTOPEN"])
        return
    end

    -- Check for sell in progress.
    if merchant:IsAutoSelling() then
        self:Print(L["CMD_AUTOSELL_INPROGRESS"])
        return
    end

    -- OK to do the auto-sell.
    self:Print(L["CMD_AUTOSELL_EXECUTING"])
    merchant:AutoSell()
end

-- Withdraws all items which match your currently enabled rules set
function Addon:Withdraw_Cmd()
    local function findBagWithSpace()
        for i=0,Addon:GetNumTotalEquippedBagSlots()  do
            if C_Container.GetContainerNumFreeSlots(i) ~= 0 then
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

function Addon:Destroy_Cmd()
    Addon:Print(L.CMD_RUNDESTROY)
    local destroy = Addon:GetFeature("Destroy")
    destroy:DestroyItems()
end

-- Prints the public API
function Addon:PrintAPI_Cmd()
    Addon:PrintPublic()
end
