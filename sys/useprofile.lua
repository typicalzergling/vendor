local _, Addon = ...
local UseProfile = {}
local PROFILE_CHANGED = Addon.Events.PROFILE_CHANGED
local NOT_FOUND = {}

--[[===========================================================================
   | Gets a single profile value
   ==========================================================================]]
function UseProfile:GetProfileValue(name)
	Addon:GetProfile():GetValue(name)
end

--[[===========================================================================
   | Sets a single profile value
   ==========================================================================]]
function UseProfile:SetProfileValue(name, value)
	Addon:GetProfile():SetValue(name, value)
end

--[[===========================================================================
   | Gets multiple profile values and returns them
   | Example: 
   |    local a, b = GetProfileValue("a","b") 
   | 
   | Note: if the setting isn't found you will get a "NOT_FOUND" in that
   |       position
   ==========================================================================]]
function UseProfile:GetProfileValues(...)
	local v = {}
	local profile = Addon:GetProfile()
	for i, name in ipairs({...}) do 
		local pv = profile:GetValue(name)
		if (pv == nil) then pv = NOT_FOUND end
		table.insert(v, pv)
	end
	return unpack(v)
end

--[[===========================================================================
   | Sets multiple profile values, from the table argument
   | Example:
   |	local vals = { a = 1, b = 2}
   |	SetProfileValues(vals)
   ==========================================================================]]
function UseProfile:SetProfileValues(values)
	--@debug@--
	assert(type(values) == "table", "The values must be a table value");
	--@end-debug@	

	local profile = Addon:GetProfile()
	for name,value in pairs(values) do
		profile:SetValue(name, value)		
	end
end

--[[===========================================================================
   | Hooks up a change event to be called when the values in the profile
   | change, or hte profile itself changes
   ==========================================================================]]
function UseProfile:ObserveProfile()
	if (type(self.OnProfileChanged) == "function") then
		self._listening = true
		Addon:RegisterCallback(PROFILE_CHANGED, self, self.OnProfileChanged)
	end
end

function UseProfile:StopObservingProfile()
	if (self._listening) then
		Addon:UnregisterCallback(PROFILE_CHANGED, self)
	end
end

Addon.UseProfile = UseProfile