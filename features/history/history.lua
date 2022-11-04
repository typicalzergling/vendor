local _, Addon = ...
local History = { NAME = "History", VERSION = 1, DEPENDENCIES = { "Rules" } }
local EVENTS = { "OnHistoryChanged" }

function History:OnInitialize()
    Addon:GeneratesEvents(EVENTS)

    Addon.OnHistoryChanged:Add(function(...)
        print("history has changed", ...)
        Addon:RaiseEvent("OnHistoryChanged", ...)
    end)
end

function History:OnTerminate()
    Addon:RemoveEvents(EVENTS)
end

function History:GetCharacterHistory()
    local rules = self:GetDependency("rules")
    local items = {}

    for _, item in pairs(Addon:GetCharacterHistory()) do
        local id = item.Id or 0
        local ruleId, ruleName = Addon:GetRuleInfoFromHistoryId(item.Rule)
        local profileId, profileName = Addon:GetProfileInfoFromHistoryId(item.Profile)
        
        -- Add common properties
        item.Quality = C_Item.GetItemQualityByID(id)
        item.ItemName = C_Item.GetItemNameByID(id)
        item.Keywords = string.lower(item.ItemName or "")
        item.RuleId = ruleId
        item.RuleName = ruleName
        item.ProfileId = profileId
        item.ProfileName = profileName

        -- Add source
        local rule = rules:FindRule(ruleId)
        if (rule) then
            if (rule.IsSystem) then
                item.RuleSource = 1
            elseif (rule.IsExtension) then
                item.RuleSource = 2
            end
        end

        table.insert(items, item)
    end

    return items
end

function History:GetFilters()
    return self.FILTERS
end

--[[ Create a fiilter function with the specified filters enabled ]]
function History:CreateFilter(filters)
    assert(not filters or type(filters) == "table")
    local rules = self:GetDependency("Rules")

    local engine = rules:CreateRulesEngine()
    engine:CreateCategory(1, "-matched-")
    engine:AddConstants(self.FILTER_CONSTANTS)

    for _, filter in ipairs(self:GetFilters()) do
        if (not filters or filters[filter.Id]) then
            engine:AddRule(1, filter)
        end
    end

    local handler = function(item)
        print("-> handle", item.Id)
        return engine:Evaluate(item)
    end

    return handler
end

Addon.Features.History = History