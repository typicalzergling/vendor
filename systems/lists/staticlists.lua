local AddonName, Addon = ...
local Lists = Addon.Systems.Lists
local StaticLists = {}
local ListEvents = Lists.ListEvents

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
function StaticLists:Init()
    self.variable = Addon:CreateSavedVariable("StaticLists")
end

--[[ Creates a static custom list ]]
function StaticLists:Create(id, version, name, description, items)
	local list = {
		Name = name,
		Id = id,
		Description = description,
		Items = items or {},
		Timestamp = time(),
        Version = version,
		CreatedBy = "Vendor"
	}

	self.variable:Set(id, list)
	Addon:Debug("staticlists", "Created List '%s' [%s]", name, id)
	return list
end


--[[ Deletes a custom list ]]
function StaticLists:Delete(listId)
    listId = getListId(listId)

    local list = self:Get(listId)
    if (list) then
        self.variable:Set(list.Id, nil)
        Addon:Debug("staticlists", "Removed List '%s' [%s]", list.Name, list.Id)
	    return list
    end

    return nil
end

--[[ Checks if the list exists ]]
function StaticLists:Exists(listId)
    return self.variable:Get(getListId(listId)) ~= nil
end

--[[ Updates a custom list ]]
function StaticLists:Update(listId, updates)
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
    Addon:Debug("staticlists", "Updated list '%s' [%s]", list.Name, list.Id)
end

--[[ Gets the contents of a custom list ]]
function StaticLists:GetContents(listId)
	local list = self:Get(listId)
	if (not list) then
		error("Unable to locate list '" .. tostring(listId) .. "'")
	end
    return list.Items or {}
end

--[[ Updates the contents of a custom list ]]
function StaticLists:SetContents(listId, items)
    local list = self:Get(listId)
    if (not list) then
        error("Unable to locate custom list '" .. tostring(listId) .. "'")
    end

    list.UpdatedBy = Addon:GetCharacterFullName()
    list.Timestamp = time()
    list.Items = items or {}

    self.variable:Set(list.Id, list)
    Addon:Debug("staticlists", "Updated list '%s' [%s]", list.Name, list.Id)
end

--[[ Retrieves all of the custom lists ]]
function StaticLists:GetLists()
	local results = {}

	self.variable:ForEach(function(list, id)
		assert(id == list.Id, "Expected the list ID to match the key")
		table.insert(results, list)
	end)

	return results
end

--[[ Retrieve a specific list by ID ]]
function StaticLists:Get(listId)
    return self.variable:Get(getListId(listId))
end

--[[ Gets a specific list ]]
function StaticLists:Find(search)
    if (type(search) ~= "string") then
        error("Usage: StaticLists:Find( string )")
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
function Lists:CreateStaticListManager()
    return CreateAndInitFromMixin(StaticLists)
end