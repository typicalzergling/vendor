local _, Addon = ...
local LIST_MGR_KEY = {}
local EMPTY = {}
local CustomListManager = {}
local savedLists = Addon.SavedVariable:new("CustomLists")

local function GetListId(source)
	if ((type(source) == "table") and (type(source.Id) == "string")) then
		return source.Id
	elseif (type(source) == "string") then
		return source
	end

	error("Unable to determine list ID: " .. type(source))
	return nil
end

--[[ Creates a custom list ]]
function CustomListManager:CreateList(listName, listDescription, listItems)
	local id = Addon:GetExtensionManger():CreateUniqueId()
	local list = {
		Name = listName,
		Id = id,
		Description = listDescription,
		Items = listItems or EMPTY,
		Timestamp = time(),
		CreatedBy = Addon:GetCharacterFullName()
	}

	savedLists:Set(id, list)
	list.Id = id
	self:TriggerEvent("OnListChanged", id, "ADDED")
	Addon:Debug("customlists", "Created List '%s' [%s]", listName, id)
	return list
end

--[[ Updates a custom list ]]
function CustomListManager:UpdateList(id, name, description, items)
	--@debug@
	assert(type(savedLists:Get(id)) == "table", "There is no custom list with the specified ID :: " .. tostring(id))
	--@end-debug@

	savedLists:Set(id, {
			Name = name, 
			Description = description,
			Id = id,
			Items = items or {},
			Timestamp = time(),
			ModifiedBy = Addon:GetCharacterFullName()
		})
end

--[[ Gets the contents of a custom list ]]
function CustomListManager:GetListContents(listId)
	local list = savedLists:Get(GetListId(listId))
	if (not list) then
		return EMPTY, false
	end
	return (list.Items or EMPTY), true
end

--[[ Updates the contents of a custom list ]]
function CustomListManager:UpdateListContents(listId, items)
	Addon:Debug("test", "updaing list contents %s", listId)
	listId = GetListId(listId)	
	local list = savedLists:Get(listId)
	if (not list) then
		return false
	end

	list.Items = Addon.DeepTableCopy(items or EMPTY)
	savedLists:Set(listId, list)
	self:TriggerEvent("OnListChanged", listId, "UPDATED")
end

--[[ Retrieves all of the custom lists ]]
function CustomListManager:GetLists()
	local results = {}
	savedLists:ForEach(function(list, id)
		--@debug@
		assert(id == list.Id, "Expected the list ID to match the key")
		--@end-debug@

		table.insert(results, {
			Id = id,
			Name = list.Name,
			Description = list.Description,
			Items = list.items
		})
	end)

	return results
end

--[[ Gets a specific list ]]
function CustomListManager:GetList(search)
	local result = nil
	local resultId = nil
	savedLists:ForEach(function(list, id)
		if (not result) then
			if (id == search) then
				result = list
				resultId = id
			elseif (list.Name == search) then
				result = list
				resultId = id
			end
		end
	end)

	if (result) then
		return {
			Id = resultId,
			Name = result.Name,
			Description = result.Description,
			Items = Addon.DeepTableCopy(result.Items or EMPTY)
		}
	end

	return nil
end

function Addon:GetListManager()
	local mgr = rawget(self, LIST_MGR_KEY)
	if (not mgr) then
		local instance = {
		}
		
		mgr = Addon.object("CustomListManager", instance, CustomListManager, { "OnListChanged", "OnListAdded" })
		rawset(self, LIST_MGR_KEY, mgr)
	end

	return mgr
end