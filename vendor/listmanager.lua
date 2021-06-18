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

function CustomListManager:CreateList(listName, listDescription, listItems)
	local id = Addon:GetExtensionManger():CreateUniqueId()
	local list = 
	{
		Name = listName,
		Description = listDescription,
		Items = listItems or EMPTY,
	}

	savedLists:Set(id, list)
	list.Id = id
	self:TriggerEvent("OnListChanged", id, "ADDED")
	return list
end

function CustomListManager:GetListContents(listId)
	local list = savedLists:Get(GetListId(listId))
	if (not list) then
		return EMPTY, false
	end
	return (list.Items or EMPTY), true
end

function CustomListManager:UpdateListContents(listId, items)
	Addon:Debug("test", "updaing list contents %s", listId)
	listId = GetListId(listId)	
	local list = savedLists:Get(listId)
	if (not list) then
		return false
	end

	list.Items = table.copy(items or EMPTY)
	savedLists:Set(listId, list)	
	Addon:Debug("test", "firing event %s", listId)
	self:TriggerEvent("OnListChanged", listId, "UPDATED")
end

function CustomListManager:GetLists()
	local results = {}
	savedLists:ForEach(function(list, id)
		table.insert(results, {
			Id = id,
			Name = list.Name,
			Description = list.Description
		})
	end)

	return results
end

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
			Items = table.copy(result.Items or EMPTY)
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