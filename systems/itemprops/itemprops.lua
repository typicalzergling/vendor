local _, Addon = ...
local ItemProperties = {}

--[[ Retrieve our depenedencies ]]
function ItemProperties:GetDependencies()
    return { "rules", "savedvariables", "profile" }
end

--[[ Startup our system ]]
function ItemProperties:Startup()
    return { "GetPropertyDocumentation" }
end

--[[ Shutdown our system ]]
function ItemProperties:Shutdown()
    self:UnregisterFunctions()
end

Addon.Systems.ItemProperties = ItemProperties

--[[ temp move to a new file ]]

local DOCS = {
Name = [[The item name, as it appears in the tooltip. This is a localized string.]],
Link = [[The item link, including all color codes and the item string. This may be useful if you want to string.find specific ids in the item string.]],
Id =[[The item ID, as a number.]],
Count = [[
The quantity of the item, as a number.

## Notes:

This will always be 1 for links to items. When we scan items in your bag it will be the actual quantity
for the slot. This means if you make a rule that sells based on quantity then the tooltip for Vendor 
selling it will not be accurate when mousing over an item since that uses its tootip link, not 
the bag slot information. The matches tab uses items in your bag so it will be correct for what Vendor will sell.
]],
Quality = [[The quality of the item:

* 0 = Poor 
* 1 = Common
* 2 = Uncommon
* 3 = Rare
* 4 = Epic
* 5 = Legendary
* 6 = Artifact
* 7 = Heirloom
* 8 = Wow Token<

You can also use the following constants in your scripts: POOR, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, ARTIFACT, HEIRLOOM
]],
Level = "This will be the item's effective item level if it is Equipment, otherwise it will be the base item level if it does not have an effective item level.",
MinLevel = [[The required character level for equipping the item.]],
Type = [[The name of the item's Type. This is a localized string. You can use this in conjunction with SubType to zero in on specific types of items.]],
TypeId = [[
The numeric ID of the item's Type.

### Notes:

This is not localized so it will be portable to players using other locales.
"It's also faster than a string compare, so you should use this over Type() if possible.
]],
SubType = [[The name of the item's SubType. This is a localized string. You can use this in conjunction with Type to zero in on specific types of items.]],
SubTypeId = [[
The numeric ID of the item's SubType.

This is not localized so it will be portable to players using other locales. It's 
also faster than a string compare, so you should use this over SubType() if possible.
]],
EquipLoc = [[The equip location of this item. This will be nil if the item is not equipment.]],
BindType = [[The binding behavior for the item.

* 0 = None
* 1 = On Pickup
* 2 = On Equip
* 3 = On Use
* 4 = Quest

### Notes:

This is the base behavior of the item itself, not the current bind state of the item. This does NOT
accurately tell you if the item is SoulBound or Bind-on-Equip by itself
If you want to know if an item is BoE or Soulbound, use IsBindOnEquip() and IsSoulbound()"
]],
StackSize = [[The max stack size of this item.]],
UnitValue = [[
The vendor price in copper for one of these items.

## Notes:
Items with UnitValue == 0 cannot be sold to a vendor. Such items will never match any rules because you cannot possibly sell them.
]],
NetValue = [[The vendor price in copper for this stack. This is equivalent to Count() * UnitValue()]],
ExpansionPackId = [[The expansion pack ID to which this item belongs.

> 0 = Default / None (this matches many items)
> 1 = BC
> 2 = WoTLK
> 3 = Cata
> 4 = MoP
> 5 = WoD
> 6 = Legion
> 7 = BFA
> 8 = SL
> 9 = DF

## Notes:

Use caution when using this to identify items of previous expansions. Not every item is tagged with an
expansion ID. It appears that generally only wearable equipment is tagged. Zero is the default for
everything, including many items from Expansion packs (like reagants and Dalaran Hearthstones).

We recommend that you only use this for rules involving wearable equipment. Checking ExpansionPackId() == 0
intending to match Vanilla will not do what you want, as it will include non-Vanilla things. Likewise
ExpansionPackId() < 7 will match a great many items. If you want to be safe, use this in conjunction with
IsEquipment(), and have some items from Vanilla and several expansion packs to verify.
]],
IzAzeriteItem = [[True if the item is Azerite gear.]],
IsEquipment = [[
True if the item is wearable equipment. This is equivalent to EquipLoc() ~= nil

### Notes:

This does NOT tell you if your character can equip the item. This tells you whether the item is equippable gear.
]],
IsSoulbound = [[
True if this specific item is currently "Soulbound" to you.
If the item's bind type is Bind-on-pickup then this will always report true, even for items you have not
yet picked up if you are mousing over them. This is because the item will be Soulbound if you were to pick it up,
so we are accurately representing the resulting behavior of the item. If an item is Binds-when-equipped or on use,
then IsSoulbound() will return false unless you actually have the item in your possession and we can
]],
IsBindOnEquip = [[
True if this specific item is currently "Binds-when-equipped".

### Notes:

If the item's bind type is Bind-on-pickup then this will always report false, even for items you have not
yet picked up if you are mousing over them. This is becuase the item cannot possibly be Binds-when-equipped.
If the item has yet to be picked up and it has a bind type of On-Equip, then we will always report it as true. If it is in your possession and Soulbound to you, then this will return false.
]],
IsBindOnUse = [[
True if this specific item is currently "Binds-when-used".

### Notes:

If the item is not yet in your possession, then it will always return true if its bind type is On-Use. If it is in your possession and Soulbound to you then this will return false.
]],
IsUnknownAppearance = [[
True if the item you have not yet collected this item Appearance AND the item is not Bind-on-Pickup.

### Notes:

This will correctly detect items which are unknown appearances (i.e. transmogs you have not yet acquired). However, if the item is BoP, it will not be treated as an Unknown Appearance. This is because the moment you pick up the
item it will become a known appearance. Therefore, it is safe to sell and this inforamtion is irrelevant. This method is used to filter on Bind-on-Equip items that are Unknown Appearances and is generally useful for preventing
you from accidentally selling them. We have a built-in Keep rule for this purpose, so generally you won't need to use this.
]],
IsToy = "True if the item is a toy.",
IsCraftingReagent = [[
True if this specific item is a crafting reagent.

### Notes:

This is determined by the tooltip text. Note that if you drag a crafting reagent to the item box in a custom rule definition to read its properties, that item may incorrectly report as "false" but it will evaluate correctly with this property.
]],
IsAlreadyKnown = [[True if the item is "Already known", such as a Toy or Recipe you have already learned.]],
IsUsable = [[True if the item can be used, such as if it has a "Use:" effect described in its tooltip."]],
IsUnsellable = [[
True if the item has 0 value.

### Notes:

There are a few very rare exceptions where items may have value but are unsellable and so you may get an occasional false negative here. This appears to be an item data error on Blizzard's end.
]],
IsBagAndSlot = [[True if the item has a defined bag and slot.]],
Bag = [[The bag ID of the item, or -1 if it is not in a bag and slot.]],
Slot = [[The slot ID of the item, or -1 if it is not in a bag and slot.]],
}

function ItemProperties:GetPropertyDocumentation()
    return DOCS
end