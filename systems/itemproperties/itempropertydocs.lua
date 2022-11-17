local AddonName, Addon = ...

local DOCS = {
    Name = [[The item name, as it appears in the tooltip. This is a localized string.]],
    Link = [[The item link, including all color codes and the item string. This may be useful if you want to string.find specific ids in the item string.]],
    Id =[[The item ID, as a number.]],
    Count = [[
    The quantity of the item in the stack, as a number. This is not the total number of items you have in your inventory; it is the total number in this stack.
    
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
    * 8 = Wow Token
    
    You can also use the following constants in your scripts: POOR, COMMON, UNCOMMON, RARE, EPIC, LEGENDARY, ARTIFACT, HEIRLOOM
    ]],
    Level = [[This will be the item's effective item level if it is Equipment, otherwise it will be the base item level if it does not have an effective item level.]],
    MinLevel = [[The required character level for equipping the item.]],
    Type = [[The name of the item's Type. This is a localized string. You can use this in conjunction with SubType to zero in on specific types of items.]],
    TypeId = [[
    The numeric ID of the item's Type.
    
    ### Notes:
    
    This is not localized so it will be portable to players using other locales.
    It's also faster than a string compare, so you should use this over Type if possible.
    ]],
    SubType = [[The name of the item's SubType. This is a localized string. You can use this in conjunction with Type to zero in on specific types of items.]],
    SubTypeId = [[
    The numeric ID of the item's SubType.
    
    This is not localized so it will be portable to players using other locales. It's 
    also faster than a string compare, so you should use this over SubType if possible.
    ]],
    EquipLoc = [[The equip location of this item. This will be nil if the item is not equipment.]],
    EquipLocName = [[Localised string of the EquipLoc.]],
    InventoryType = [[
    The numeric representation of EquipLoc.
    ]],
    BindType = [[The binding behavior for the item.
    
    * 0 = None
    * 1 = On Pickup
    * 2 = On Equip
    * 3 = On Use
    * 4 = Quest
    
    ### Notes:
    
    This is the base behavior of the item itself, not the current bind state of the item. This does NOT
    accurately tell you if the item is SoulBound or Bind-on-Equip by itself
    If you want to know if an item is BoE or Soulbound, use IsBindOnEquip and IsSoulbound"
    ]],
    StackSize = [[The max stack size of this item.]],
    UnitValue = [[
    The vendor price in copper for one of these items.
    
    ## Notes:
    Items with UnitValue == 0 cannot be sold to a vendor. We use this to determine if an item is unsellable.
    ]],
    TotalValue = [[
    The vendor price in copper for the the entire stack of this item. Equivalent to Count * UnitValue.
    
    ## Notes:
    Items with UnitValue == 0 cannot be sold to a vendor. We use this to determine if an item is unsellable.
    ]],
    UnitGoldValue = [[
    The vendor price in gold for one of these items, rounded down.  This is equivalent ot math.floor(UnitValue / 10000).
    
    ## Notes:
    Items with UnitValue == 0 cannot be sold to a vendor. We use this to determine if an item is unsellable.
    ]],
    TotalGoldValue = [[
    The vendor price in gold for the the entire stack of this item. Equivalent to math.floor((Count*UnitValue) / 10000).
    
    ## Notes:
    Items with UnitValue == 0 cannot be sold to a vendor. We use this to determine if an item is unsellable.
    ]],
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
    IsAzeriteItem = [[True if the item is Azerite gear from BFA.]],
    IsEquipment = [[
    True if the item is wearable equipment. This is equivalent to EquipLoc ~= nil
    
    ### Notes:
    
    This does NOT tell you if your character can equip the item. This tells you whether the item is equippable gear.
    ]],
    IsEquipped = [[
    True if the item is currently being worn by your character.
    
    ### Notes:
    
    This is not a particularly useful property for selling things, as you cannot sell things you are wearing, but it
    is expected to be more useful with future rules based features.
    ]],
    IsEquippable = [[
    True if your character can equip this item.
    ]],
    IsConduit = [[
    True if this is a Shadowlands Conduit item.
    ]],
    
    IsSoulbound = [[
    True if this specific item is currently "Soulbound" to you.
    If the item's bind type is Bind-on-pickup then this will always report true, even for items you have not
    yet picked up if you are mousing over them. This is because the item will be Soulbound if you were to pick it up,
    so we are accurately representing the resulting behavior of the item. If an item is Binds-when-equipped or on use,
    then IsSoulbound will be false unless you actually have the item in your possession and it is in fact soulbound to you.
    ]],
    IsAccountBound = [[
    True if this item is Account Bound.
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
    IsCosmetic = [[
    True if the item is an Account-Bound Cosmetic item. These are items you can trade to your other characters to learn the transmog.
    ]],
    IsCollectable = [[
    True if the item has an appearance which you have not collected on this character. Also is only true if the equipment is transmogrifiable, and either bind on equip or bind on account.
    
    ### Notes:
    
    Will always be false for gear this character cannot equip, even if it is an unknown appearance on another character. This is a Blizzard limitation. Some addons keep track of appearances
    across characters; we do not. We use Blizzard's API to determine if it is collected, and that API currently only reports the current character.
    This will also be true for Soulbound gear since you have already collected it.
    If you are concerned about missing transmogs for other characters, we recommend making a rule that keeps Bind-on-Equip equipment which your character cannot use. 
    ]],
    IsCollected = [[
    If your character has a confirmed collection of this appearance.
    
    ### Notes:
    
    We only ever set IsCollected to true if the Blizzard transmog API confirms to us that it is a collected appearance by this character, otherwise it is false in all other circumstances.
    ]],
    
    IsProfessionEquipment = [[
    Returns true if the item is an equippable piece of profession equipment.
    ]],
    
    IsTransmogEquipment = [[
    Is equipment that can be transmogrified. Not to be confused with an uncollected appearance. 
    ]],
    IsToy = "True if the item is a toy.",
    IsCraftingReagent = [[
    True if this specific item is a crafting reagent.
    ]],
    IsAlreadyKnown = [[True if the item is "Already known", such as a Toy or Recipe you have already learned. This matches the tooltip text indicating this.]],
    IsUsable = [[True if the item can be used, such as if it has a "Use:" effect described in its tooltip.]],
    IsUnsellable = [[
    True if the item has 0 value.
    
    ### Notes:
    
    There are a few very rare exceptions where items may have value but are unsellable and so you may get an occasional false negative here. This appears to be an item data error on Blizzard's end.
    ]],
    IsBagAndSlot = [[True if the item has a defined bag and slot.]],
    Bag = [[The bag ID of the item, or -1 if it is not in a bag and slot.]],
    Slot = [[The slot ID of the item, or -1 if it is not in a bag and slot.]],
    CraftedQuality = [[The Dragonflight Profession Crafted Quality of an item or reagent. 0 means the item has no crafted quality, if it is > 0 then it has crafted quality.]],
    }

    function Addon.Systems.ItemProperties:GetPropertyDocumentation()
        -- TODO filter the docs based on what properties are available on this platform.
        return DOCS
    end