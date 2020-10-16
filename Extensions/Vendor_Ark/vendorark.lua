local AddonName = select(1, ...);
local Addon  = select(2, ...);

-- This will register a callback to Ark with Vendor
local function registerArkExtension()
    local arkExtension =
    {
        -- Vendor will check this source is loaded prior to registration.
        -- It will also be displayed in the Vendor UI.
        Source = "ArkInventory",
        Addon = AddonName,

        -- This is called by Vendor whenever its rules change and Ark needs to redo its classification of items into buckets.
        OnRuleUpdate = function()
            assert(ArkInventory and ArkInventory.ItemCacheClear and ArkInventory.Frame_Main_Generate)
            -- Clear the Ark Inventory item cache, becuase this also caches rule results, which are now invalid becuase our rules changed.
            ArkInventory.ItemCacheClear()
            -- After clearing the cache we need to redraw the main window.
            ArkInventory.Frame_Main_Generate(nil, ArkInventory.Const.Window.Draw.Recalculate)
        end
    }

    assert(Vendor and Vendor.RegisterExtension, "Vendor RegisterExtension not found, cannot register extension: "..tostring(arkExtension.Source))
    if (not Vendor.RegisterExtension(arkExtension)) then
        -- something went wrong
    end
end
registerArkExtension()

-- The following is the plugin to Ark itself to add a function that runs vendor rules against an item Ark is evaluating.

-- Checks if an item is auto-sold by vendor
function Addon:Vendor_AutoSell()
    assert(ArkInventory and ArkInventory.API.InternalIdToBlizzardBagId)
    local object = ArkInventoryRules.Object;
    if (not object or not object.loc_id or not object.bag_id or not object.slot_id) then
        return;
    end

    -- Becuase Ark is on another planet and has its own concept of bags, must convert to blizzard bags.
    local bag = ArkInventory.API.InternalIdToBlizzardBagId( object.loc_id, object.bag_id )
    result, ruleid, name = Vendor.EvaluateItem(bag, object.slot_id)
    if not result then
        return false
    else
        return result > 0
    end
end

-- Empty function to not break Ark
local deprecatedMessageDisplayed = false
local deprecatedMessage = "ArkInventory rule for Vendor scrap, 'venscrap()' is deprecated and no longer functional. For the future stability of Ark, please remove that rule."
function Addon:Vendor_AutoScrap()
    if not deprecatedMessageDisplayed then
        DEFAULT_CHAT_FRAME:AddMessage(RED_FONT_COLOR_CODE..deprecatedMessage..FONT_COLOR_CODE_CLOSE)
        deprecatedMessageDisplayed = true
    end
    return false;
end


if (ArkInventoryRules and Vendor) then
    local rules = ArkInventoryRules:NewModule(AddonName);
    function rules:OnEnable()
        ArkInventoryRules.Register(self, "vensell", Addon.Vendor_AutoSell);
        ArkInventoryRules.Register(self, "venscrap", Addon.Vendor_AutoScrap);
    end;
end



