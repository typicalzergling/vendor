local _, Addon = ...
local EXT_MGR_KEY = {}
local EMPTY = {}

local ExtensionManager = {}



function Addon:GetExtensionManger()
	local mgr = rawget(self, EXT_MGR_KEY)
	if (not mgr) then
		local instance = {
			callbacks = {}
		}
		
		mgr = Addon.object("ExtensionManager", instance, ExtensionManager, {
			"OnFunctionsChanged", "OnRulesChanged", "OnListsChanged"
		})
	end
	return mgr
end