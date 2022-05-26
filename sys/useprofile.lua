local _, Addon = ...
local UseProfile = {}

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
   ==========================================================================]]
function UseProfile:GetProfileValues(...)
	local v = {}
	local profile = Addon:GetProfile()
	for i, name in ipairs({...}) do 
		table.insert(v, profile:GetValue(name) or nil)
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
function UseProfile:ListenForProfileChanges()
	if (type(self.OnProfileChanged) == "function") then
		local manager = Addon:GetProfileManager()
	end
end

Addon.UseProfile = UseProfile