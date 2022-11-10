local _, Addon = ...
local Lists = Addon.Systems.Lists
local SystemListId = Addon.SystemListId

local ListRuleFunctions = {
{
    Name = "IsNeverSellItem",
    Documentation =
[[
Returns the state of the item in the never sell list.  A return value of true 
indicates it belongs to the list false indicates it does not.
]],
    Function = function()
        return Addon:GetFeature("Lists"):GetList(SystemListId.NEVER):Contains(Id)
    end
},

{
    Name = "IsAlwaysSellItem",
    Documentation =
[[
Returns the state of the item in the always sell list.  A return value of tue 
indicates it belongs to the list while false indicates it does not.
]],
    Function = function()
        return Addon:GetFeature("Lists"):GetList(SystemListId.ALWAYS):Contains(Id)
    end
},

{
    Name = "IsDestroyItem",
    Documentation =
[[
[re-visit] need to document this
]],
    Function = function()
        return Addon:GetFeature("Lists"):GetList(SystemListId.DESTROY):Contains(Id)
    end
},

{
    Name = "IsInList",
    Documentation =
[[
# IsInList( list0 ... listN )

[re-visit] document IsInList

Can also be one of thse constants:

* keep - Same as IsNeverSellItem
* sell - Same as IsAlwaysSellItem
* destroy - Same as IsDestroyItem
]],
    Function = function(...)
        local lists = Addon:GetFeature("Lists")
        for _, name in ipairs({...}) do
            if (type(name) ~= "string") then
                error("The list identifier must be a string")
            end

            local lower = string.lower(name)
            local  list = nil
            if (lower == "sell") then
                list = lists:GetList(SystemListId.ALWAYS)
            elseif (lower == "keep") then
                list = lists:GetList(SystemListId.NEVER)
            elseif (lower == "destroy") then
                list = Lists:GetList(SystemListId.DESTROY)
            else
                local custom = Lists.GetCustomLists()
                list = custom:Find(name)
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
    Addon:GetRuleManager():RegisterFunctions(ListRuleFunctions)
end

--[[ Unregister functions ]]
function Lists:UnregisterFuncstions()
    Addon:GetRuleManager():UnregisterFunctions(ListRuleFunctions)
end