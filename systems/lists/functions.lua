local _, Addon = ...
local Lists = Addon.Systems.Lists
local SystemListId = Addon.SystemListId

local ListRuleFunctions = {
{
    Name = "IsNeverSellItem",
    Documentation =
[[
Returns true if the item is in the "Keep" list.
]],
    Function = function()
        local list = Lists:GetList(SystemListId.NEVER)
        return list:Contains(Id)
    end
},

{
    Name = "IsAlwaysSellItem",
    Documentation =
[[
Returns true if the item is in the "Sell" list.
]],
    Function = function()
        local list = Lists:GetList(SystemListId.ALWAYS)
        return list:Contains(Id)
    end
},

{
    Name = "IsDestroyItem",
    Documentation =
[[
Returns true if the item is in the "Destroy" list.
]],
    Function = function()
        local list = Lists:GetList(SystemListId.DESTROY)
        return list:Contains(Id)
    end
},

{
    Name = "IsInList",
    Documentation =
[[
IsInList( list1 [, list2, ... listN )

Returns true if the item is in any of the provided lists by name. The name provided is the name identifier of the list. For Custom lists, this is the name of the list. For built-in lists it is one of the following:

* keep - Same as IsNeverSellItem
* sell - Same as IsAlwaysSellItem
* destroy - Same as IsDestroyItem

## Examples:
> IsInList("keep")
> IsInList("sell", "destroy")
> IsInList("MyCustomListName")

]],
    Function = function(...)
        for _, name in ipairs({...}) do
            if (type(name) ~= "string") then
                error("The list identifier must be a string")
            end

            local lower = string.lower(name)
            local  list = nil
            if (lower == "sell") then
                list = Lists:GetList(SystemListId.ALWAYS)
            elseif (lower == "keep") then
                list = Lists:GetList(SystemListId.NEVER)
            elseif (lower == "destroy") then
                list = Lists:GetList(SystemListId.DESTROY)
            else
                local custom = Lists.customLists:Find(name)
                if (custom) then
                    list = Lists:GetList(custom.Id)
                end
            end

            if (list and list:Contains(Id)) then
                return true
            end
        end
        return false
    end
}}

--[[ Register functions ]]
function Lists:RegisterFunctions()
    self.Rules:RegisterFunctions(ListRuleFunctions)
end

--[[ Unregister functions ]]
function Lists:UnregisterFunctions()
    self.Rules:UnregisterFunctions(ListRuleFunctions)
end