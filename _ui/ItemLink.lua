local _, Addon  = ...
local Colors = Addon.CommonUI.Colors

--[[
    KeyValues:
        AllowDrop (boolean) - allows items to be dropped intot he control
        OnItemChanged (string) - the name of the function to invoke on the parent when
            the item changed (via SetItem) or a drop, this will be invoked when the item
            is loaded, and instance of ItemMixin is passed
        Placeholder - The placeholder to show when there is no item
]]
Addon.CommonUI.ItemLink = Mixin({

    --[[
        Initialize our item link control
    ]]
    OnLoad = function(itemlink)
        itemlink:OnBorderLoaded(nil, Colors.EDIT_BORDER, Colors.EDIT_BACK)
        itemlink:InitializePlaceholder()
        itemlink:ShowPlaceholder(true)
    end,

    --[[
        Handle the mouse netering
    ]]
    OnEnter = function(itemlink)
    end,

    --[[
        Hnadle the mouse leaving 
    ]]
    OnLeave = function(itemlink)
    end,

    --[[
        Handle dropping an item into this link (if we are not read only)
    ]]
    OnMouseDown = function(itemlink)
        if (itemlink.AllowDrop) then
            local item = itemlink.GetCursorItem()
            if (item ~= nil) then
                itemlink:SetItem(item)
                ClearCursor()
            end
        end
    end,

    --[[
        Sets the item to show in this control, this can either be a numeric identifer, 
        an item link, or an item location
    ]]
    SetItem = function(itemlink, item)
        local itemType = type(item)
        
        if (itemType == "table") and type(item.HasAnyLocation) == "function" then
            itemlink:SetItemLocation(item)
        elseif (itemType == "string") then
            itemlink:SetItemLink(item)
        elseif (itemType == "number") then
            itemlink:SetItemID(item)
        else
            error("Usage: SetItem( link | id | location) got '" .. itemType .. "' as an argument")
        end
        
        itemlink:ContinueOnItemLoad(function()
                if (not itemlink:IsItemEmpty()) then
                    itemlink:ShowPlaceholder(false)
                    
                    -- Set our state
                    itemlink.text:SetText(itemlink:GetItemName())
                    local color = itemlink:GetItemQualityColor() or GRAY_FONT_COLOR
                    itemlink.text:SetTextColor(color.r, color.g, color.b)

                    -- Pass our parent the item for updates
                    local handler = itemlink.OnItemChanged
                    if (type(handler) == "string") then
                        Addon.Invoke(itemlink:GetParent(), handler, itemlink)
                    end
                else 
                    itemlink:ShowPlaceholder(true)
                end
            end)
    end,

    --[[
        static

        Retrieves the item location or item id or link from the cursor
    ]]
    GetCursorItem = function()
        local what = GetCursorInfo();
        if (not what or (what ~= "item")) then
            return nil;
        end

        item = C_Cursor.GetCursorItem();
        if (item) then
            return item;
        end

        local _, itemId, itemLink = GetCursorInfo();
        if (type(itemLink) == "string") then
            return itemLink;
        end

        if (type(itemId) == "number") then
            return itemId;
        end

        return nil;
    end,

    --[[
        Static

        Attempts to retrieve the item item from the specified target, which can be an
        item location, and string link, or a numeric identifier
    ]]
    GetItemId = function(item)
        if (type(item) == "table") then
            return C_Item.GetItemID(item);
        elseif (type(item) == "string") then
            local itemInfo = Item:CreateFromItemLink(item);
            return itemInfo:GetItemID();
        elseif (type(item) == "number") then
            return item;
        end
        return nil;
    end,

}, ItemMixin, Addon.CommonUI.Mixins.Border, Addon.CommonUI.Mixins.Placeholder)