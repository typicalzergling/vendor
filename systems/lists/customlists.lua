local AddonName, Addon = ...
local Lists = Addon.Systems.Lists
local CustomLists = {}
local ListEvents = Lists.ListEvents
local CUSTOM_LIST_VERSION = 1

--[[ Determine the ID ]]
local function getListId(source)
	if ((type(source) == "table") and (type(source.Id) == "string")) then
		return source.Id
	elseif (type(source) == "string") then
		return source
	end

	error("Unable to determine list ID: " .. type(source))
	return nil
end

--[[ Initialize the custom lists ]]
function CustomLists:Init()
    self.variable = Addon:CreateSavedVariable("CustomLists")
end

--[[ Creates a custom list ]]
function CustomLists:Create(name, description, items)
	local id = Addon:GetExtensionManger():CreateUniqueId()
	local list = {
		Name = name,
		Id = id,
		Description = description,
		Items = items or {},
		Timestamp = time(),
        Version = CUSTOM_LIST_VERSION,
		CreatedBy = Addon:GetCharacterFullName()
	}

	self.variable:Set(id, list)
	Addon:Debug("customlists", "Created List '%s' [%s]", name, id)
	return list
end

--[[ Checks if the list exists ]]
function CustomLists:Exists(listId)
    return self.variable:Get(getListId(listId)) ~= nil
end

--[[ Updates a custom list ]]
function CustomLists:Update(listId, updates)
    local list = self:Get(listId)
    if (not list) then
        error("Unable to locate list to update '" .. tostring(listId) .. "'")
    end
    
    if (type(updates) == "table") then
        for key, value in pairs(updates) do
            list[key] = value
        end
    end

	self.variable:Set(list.Id, list)
    Addon:Debug("customlists", "Updated list '%s' [%s]", list.Name, list.Id)
end

--[[ Gets the contents of a custom list ]]
function CustomLists:GetContents(listId)
	local list = self:Get(listId)
	if (not list) then
		error("Unable to locate list '" .. tostring(listId) .. "'")
	end
    return list.Items or {}
end

--[[ Updates the contents of a custom list ]]
function CustomLists:SetContents(listId, items)
    local list = self:Get(listId)
    if (not list) then
        error("Unable to locate custom list '" .. tostring(listId) .. "'")
    end

    list.UpdatedBy = Addon:GetCharacterFullName()
    list.Timestamp = time
    list.Items = items or {}

    self.variable:Set(list.Id, list)
    Addon:Debug("customlists", "Updated list '%s' [%s]", list.Name, list.Id)
end

--[[ Retrieves all of the custom lists ]]
function CustomLists:GetLists()
	local results = {}

	self.variable:ForEach(function(list, id)
		--@debug@
		assert(id == list.Id, "Expected the list ID to match the key")
		--@end-debug@

		table.insert(results, list)
	end)

	return results
end

--[[ Retrieve a specific list by ID ]]
function CustomLists:Get(listId)
    return self.variable:Get(getListId(listId))
end

--[[ Gets a specific list ]]
function CustomLists:Find(search)
    if (type(search) ~= "string") then
        error("Usage: CustomLists:Find( string )")
    end

	local result = nil
    search = string.lower(search)

	self.variable:ForEach(
        function(list, id)
            if (result ~= nil) then
                return
            end
                if (id == search) then
				    result = list
			    elseif (string.lower(list.Name) == search) then
				    result = list
			    end
		    end)

	return result
end

--[[ Create a custom list manager ]]
function Lists:CreateCustomListManager()
    return CreateAndInitFromMixin(CustomLists)
end