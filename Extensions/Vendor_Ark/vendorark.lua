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
    if (not Vendor:RegisterExtension(arkExtension)) then
        -- something went wrong
    end
end
registerArkExtension()

-- The following is the plugin to Ark itself to add a function that runs vendor rules against an item Ark is evaluating.

-- Checks if an item is auto-sold by vendor
function Addon:Vendor_AutoSell()
    local fn = "Vendor_AutoSell";
    local object = ArkInventoryRules.Object;
    if (not object.h or (object.class ~= "item")) then
        return;
    end

    local item = Vendor:GetItemProperties(GameTooltip, object.h);
    if (item) then
        return Vendor:EvaluateItemForSelling(item);
    end

    return false;
end

if (ArkInventoryRules and Vendor) then
    local rules = ArkInventoryRules:NewModule(AddonName);
    function rules:OnEnable()
        ArkInventoryRules.Register(self, "vensell", Addon.Vendor_AutoSell);
    end;
end



