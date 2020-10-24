-- This is exclusively for the debug options panel and Debug-specific commands that do not appear in a normal build.
-- This entire file is excluded from packaging and it is not localized intentionally.
local AddonName, Addon = ...
local L = Addon:GetLocale()

-- Sets up all the console commands for debug functions in this file.
function Addon:SetupDebugConsoleCommands()
    self:AddConsoleCommand("debug", "Toggle Debug. Accepts channel argument, default otherwise", function(channel) if not channel then channel = "default" end; Addon:ToggleDebug(channel) end)
    self:AddConsoleCommand("link", "Dump hyperlink information", "DumpLink_Cmd")
end

-- Debug Commands
function Addon:DumpLink_Cmd(arg)
    self:Print("Link: "..tostring(arg))
    self:Print("Raw: "..gsub(arg, "\124", "\124\124"))
    self:Print("ItemString: "..tostring(self:GetLinkFromString(arg)))
    local props = self:GetLinkPropertiesFromString(arg)
    for i, v in pairs(props) do
        self:Print("["..tostring(i).."] "..tostring(v))
    end
    self:Print("ItemInfo:")
    local itemInfo = {GetItemInfo(tostring(arg))}
    for i, v in pairs(itemInfo) do
        self:Print("["..tostring(i).."] "..tostring(v))
    end
end



-- Beyond this point are debug related functions that are not packaged.
function Addon:DumpTooltipItemProperties()
	local props = self:GetItemProperties(GameTooltip)
	self:Print("Properties for "..props["Link"])

	-- Print non-derived properties first.
	for i, v in Addon.orderedPairs(props) do
		if not string.find(i, "^Is") then
			local val = v
			if type(v) == "table" then
				val = "{"..table.concat(v, ", ").."}"
			end
			self:Print("    [%s] %s", tostring(i), tostring(val))
		end
	end

	-- Print all the derived properties ("Is*") together.
	for i, v in Addon.orderedPairs(props) do
		if string.find(i, "^Is") then
			self:Print("    ["..tostring(i).."] "..tostring(v))
		end
	end
end

-- Sorted Pairs from Lua-Users.org. We use this for pretty-printing tables for debugging purposes.

function Addon.__genOrderedIndex( t )
	local orderedIndex = {}
	for key in pairs(t) do
		table.insert( orderedIndex, key )
	end
	table.sort( orderedIndex )
	return orderedIndex
end

function Addon.orderedNext(t, state)
	-- Equivalent of the next function, but returns the keys in the alphabetic
	-- order. We use a temporary ordered key table that is stored in the
	-- table being iterated.

	local key = nil
	--print("orderedNext: state = "..tostring(state) )
	if state == nil then
		-- the first time, generate the index
		t.__orderedIndex = Addon.__genOrderedIndex( t )
		key = t.__orderedIndex[1]
	else
		-- fetch the next value
		for i = 1,table.getn(t.__orderedIndex) do
			if t.__orderedIndex[i] == state then
				key = t.__orderedIndex[i+1]
			end
		end
	end

	if key then
		return key, t[key]
	end

	-- no more value to return, cleanup
	t.__orderedIndex = nil
	return
end

function Addon.orderedPairs(t)
	-- Equivalent of the pairs() function on tables. Allows to iterate
	-- in order
	return Addon.orderedNext, t, nil
end