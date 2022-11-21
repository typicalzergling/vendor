local _, Addon = ...
local ActionType = Addon.ActionType

Addon.Features.History.FILTER_CONSTANTS = {
    ACTION_SELL = ActionType.SELL,
    ACTION_DESTROY = ActionType.DESTROY,

    POOR = 0,
    COMMON = 1,
    UNCOMMON = 2,
    RARE = 3,
    EPIC = 4,
    LEGENDARY = 5,
    ARTIFACT = 6,
    HEIRLOOM = 7,
    TOKEN = 8,

    SOURCE_SYSTEM = 1,
    SOURCE_EXTENSION = 2
}

Addon.Features.History.FILTERS = {
	{
		Id ="sold",
		Name = "OPTIONS_AUDIT_FILTER_SOLD",
		Description = "OPTIONS_AUDIT_FILTER_SOLD_DESC",
		Script = function()
            return Action == ACTION_SELL
        end
	},
	{
		Id = "destroy",
		Name = "OPTIONS_AUDIT_FILTER_DESTROYED",
		Description = "OPTIONS_AUDIT_FILTER_DESTROYED_DESC",
		Script = function()
            return Action == ACTION_DESTROY
        end
	},
	{
		Id = "lessthencommon",
		Name = "OPTIONS_AUDIT_FILTER_COMMON",
		Description = "OPTIONS_AUDIT_FILTER_COMMON_DESC",
		Script = function()
            return Quality <= COMMON
        end
	},
	{
		Id = "epic",
		Name = "OPTIONS_AUDIT_FILTER_EPIC",
		Description = "OPTIONS_AUDIT_FILTER_EPIC_DESC",
		Script = function()
            return Quality == EPIC
        end
	},
	{
		Id = "uncommon",
		Name = "OPTIONS_AUDIT_FILTER_UNCOMMON",
		Description = "OPTIONS_AUDIT_FILTER_UNCOMMON_DESC",
		Script = function()
            return Quality == UNCOMMON
        end
	},
	{
		Id = "rare",
		Name = "OPTIONS_AUDIT_FILTER_RARE",
		Description = "OPTIONS_AUDIT_FILTER_RARE_DESC",
		Script = function()
            return Quality == RARE
        end
	},
	{
		Id = "legendandbetter",
		Name = "OPTIONS_AUDIT_FILTER_LEGENDARY",
		Description = "OPTIONS_AUDIT_FILTER_LEGENDARY_DESC",
		Script = function()
            return Quality >= LEGENDARY
        end
	},
	{
		Id = "extension",
		Name = "OPTIONS_AUDIT_FILTER_EXTENSION",
		Description = "OPTIONS_AUDIT_FILTER_EXTENSION_DESC",
		Script = function()
            return (RuleSource == SOURCE_EXTENSION)
        end
	}
}