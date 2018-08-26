local AddonName = select(1, ...);
local Addon  = select(2, ...);

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

-- Checks to see if the provided item is scrap (according to scrap rules)
function Addon:Vendor_AutoScrap()
    local fn = "Vendor_AutoScrap";
    local object = ArkInventoryRules.Object;
    if (not object.h or (object.class ~= "item")) then
        return;
    end

    local item = Vendor:GetItemProperties(GameTooltip, object.h);
    if (item) then
        local rm = Vendor:GetRuleManager();
        return rm:CheckForScrap(item);
    end

    return false;
end


if (ArkInventoryRules and Vendor) then
print("--> registering vendor extensions");
    local rules = ArkInventoryRules:NewModule(AddonName);
    function rules:OnEnable()
        ArkInventoryRules.Register(self, "vensell", Addon.Vendor_AutoSell);
        ArkInventoryRules.Register(self, "venscrap", Addon.Vendor_AutoScrap);
    end;
end
