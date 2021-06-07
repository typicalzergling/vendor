local _, Addon = ...
local EXT_MGR_KEY = {}
local EMPTY = {}

local ExtensionManager = {}

-- Simple function to generate a random, but generally unique id.
function ExtensionManager:CreateUniqueId(orefix)
	local name, realm = UnitFullName("player")
	return string.format("uid:%s:%s:%d%03d", string.lower(name), string.lower(realm), time(), math.random(0, 999))
end

function ExtensionManager:GetList(search)
	local list = nil
	for _, entry in ipairs(self.lists) do
		if (not list) then
			if (entry.Id == search) then
				list = entry
			elseif (entry.RawId == search) then
				list = entry
			elseif (string.lower(entry.Name) == string.lower(search)) then
				list = entry
			end
		end
	end
	return list
end

function ExtensionManager:GetLists()
	return self.lists or EMPTY
end

function ExtensionManager:RegisterList(extension, list)
	if (type(list) ~= "table") then
		error("List registration must be a table")
		return false
	end

	if (type(list.Id) ~= "string" or string.len(list.Id) == 0) then
		error("List registration must have a valid id")
		return false
	end

	if (type(list.Name) ~= "string" or string.len(list.Name) == 0) then
		error("List registration must have a valid name")
		return false
	end

	local itemsType = type(list.Items)
	if ((itemsType ~= "table") and (itemsType ~= "function")) then
		error("List items must be a literal or provided by a function")
		return false
	end

	if (self:GetList(list.Id) or self:GetList(list.Name)) then
		error("A list with the specified name already exists")
		return false
	end

	-- Keep a list of all the extensions
	if (not self.extensions[extension.Name]) then
		self.extensions[extension.Name] = extension
	end

	-- Create the entry for this list.
	local entry = {
		Extension = extension,
		Name = list.Name,
		Description = list.Description, 
		RawId = list.Id,
		Id = string.format("e[%s]", list.Id),
		Source = extension.Name,
	}

	if (itemsType == "function") then
		entry.Items = list.Items
	else
		-- Translate a flat list into a hash table.
		local items = {}
		for _, id in ipairs(list.Items) do
			if (type(id) == "number") then
				items[id] = true
			end			
		end
		entry.Items = items
	end

	table.insert(self.lists, entry)
	Addon:Debug("extension", "Registered list \"%s\" from extension \"%s\" items source %s [%d lists]", entry.Name, entry.Source, string.upper(itemsType), table.getn(self.lists))
	return true
end

function Addon:GetExtensionManger()
	local mgr = rawget(self, EXT_MGR_KEY)
	if (not mgr) then
		local instance = {
			callbacks = {},
			lists = {},
			extensions = {},
		}
		
		mgr = Addon.object("ExtensionManager", instance, ExtensionManager, {
			"OnFunctionsChanged", "OnRulesChanged", "OnListsChanged"
		})

		rawset(self, EXT_MGR_KEY, mgr)
	end

	if (not mgr:GetList("test.list")) then
	mgr:RegisterList({ 
		Name = 'Non-extension'
	}, {
		Name = "Ext. Test",
		Description = "Tooltip - Text",
		Items = function() return { 50349, 33470, 152494 } end,
		Id = "test.list",
	})
	end

	return mgr
end