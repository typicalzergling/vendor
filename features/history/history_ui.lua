local _, Addon = ...
local debugp = function (...) Addon:Debug("historytab", ...) end

local History = Addon.Features.History

function History:GetCharacterHistoryEntries()
    local rules = Addon:GetFeature("rules")
    local items = {}

    for _, item in pairs(History:GetCharacterHistory()) do
        local id = item.Id or 0
        local ruleId, ruleName = History:GetRuleInfoFromHistoryId(item.Rule)
        local profileId, profileName = History:GetProfileInfoFromHistoryId(item.Profile)
        
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
    local rules = Addon:GetFeature("Rules")

    local engine = rules:CreateRulesEngine()
    engine:CreateCategory(1, "-matched-")
    engine:AddConstants(self.FILTER_CONSTANTS)

    for _, filter in ipairs(self:GetFilters()) do
        if (not filters or filters[filter.Id]) then
            engine:AddRule(1, filter)
        end
    end

    local handler = function(item)
        return engine:Evaluate(item)
    end

    return handler
end
