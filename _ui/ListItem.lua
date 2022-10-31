local _, Addon = ...;
local STATE_KEY = {};
local ListItem = {};

-- Helper for invoking members of the list item
local function invoke(object, handler, ...)
    local func = object[handler]
    if (type(func) == "function") then
        local res = { xpcall(func, CallErrorHandler, object, ...) }
        if (res[1]) then
            return select(1)
        end
    end
    return nil
end

--[[
    Called when the list lays out the items, this is called with first/list/none
    depending on where the item is positioned
]]
function ListItem:SetPosition(where)
    local state = rawget(self, STATE_KEY)
    where = string.upper(where)
    if (state.where ~= where) then
        state.where = where
        invoke(self, "OnPositionChange", where, state.model)
    end
end

--[[
    Returns the current special position of the item in the list
]]
function ListItem:GetPosition()
    local state = rawget(self, STATE_KEY)
    return state.where or "NONE"
end

--[[===========================================================================
	| Returns the data/model item this visual is using
	========================================================================--]]
function ListItem:GetModel()
    local state = rawget(self, STATE_KEY)
    return state.model
end

--[[===========================================================================
	| Sets the mode for this item base, if the model has changed then
    | OnModelChanged is invoked allowing the item to update itself.
	========================================================================--]]
function ListItem:SetModel(model)
    local state = rawget(self, STATE_KEY)
	if (state.model ~= model) then
        local current = state.model
		state.model = model

        invoke(self, "OnModelChange", model, current)
	end
end

--[[===========================================================================
	| Sets the model index (the index into the model collection)
	========================================================================--]]
function ListItem:SetModelIndex(modelIndex)
    local state = rawget(self, STATE_KEY)
    state.modelIndex = modelIndex
end

--[[===========================================================================
	| Retrieves the model index
	========================================================================--]]
function ListItem:GetModelIndex()
	local state = rawget(self, STATE_KEY)
    return state.modelIndex or -1
end

--[[===========================================================================
	| Checks if this and the specified item have the samde model.
	========================================================================--]]
function ListItem:IsSameModel(other)
    return (other:GetModel() == self:GetModel())
end

--[[===========================================================================
	| Returns true of the item has the model specified.
	========================================================================--]]
function ListItem:HasModel(check)
    local state = rawget(self, STATE_KEY)
    -- If the model has a comapre function
    local model = state.model
    if (type(model) == "table") then
	    local compare = model.Compare
	    if (type(compare) == "function") then
		    local success, result = xpcall(compare, CallErrorHnadler, model, check)
            return (success and result)
	    end
    end

	return (model == check)
end

--[[===========================================================================
	| Compares two items, if the item has a "Compare" functino it is invoked
	| otherwsie the indexs are compared.
	========================================================================--]]
function ListItem:CompareTo(other)
	if (type(self.Compare) == "function") then
		local success, result = xpcall(self.Compare, CallErrorHandler, self, other);
        return success and result
	end

	return rawget(self, STATE_KEY) == rawget(other, STATE_KEY)
end

--[[===========================================================================
	| returns true if the item is selected
	========================================================================--]]
function ListItem:IsSelected()
    local state = rawget(self, STATE_KEY)
	return state.selected == true
end

--[[===========================================================================
	| Modifies the selected state of this item
	========================================================================--]]
function ListItem:SetSelected(selected)
    local state = rawget(self, STATE_KEY)
	if (state.selected ~= selected) then
		state.selected = selected;
        if (selected) then
            invoke(self, "OnSelected", self, selected)
        else
            invoke(self, "OnUnselected", self, selected)
        end
	end
end

--[[===========================================================================
	| Retrieves the list for this item by walking the parent and looking 
	| sentinal which marks the list
	========================================================================--]]
function ListItem:GetList()
    local state = rawget(self, STATE_KEY)
    return state.list
end

--[[===========================================================================
	| Attach the list item
	========================================================================--]]
function ListItem:Attach(list)
    rawset(self, STATE_KEY, { list = list })

    for name, handler in pairs(self) do
        if (type(handler) == "function") then
            if (self:HasScript(name)) then
                self:SetScript(name, function(_, ...)
                    xpcall(handler, CallErrorHandler, self, ...)
                end)
            end
        end
    end
end

--[[===========================================================================
	| Detach the list item
	========================================================================--]]
function ListItem:Detach()
    for name, handler in pairs(self) do
        if (type(handler) == "function") then
            if self:HasScript(name) then
                self:SetScript(name, nil)
            end
        end
    end

    rawset(self, STATE_KEY, nil)
end

--[[
    Notify the parent of the list that a notable event happend (thise are up the list
    item and the parent to define)
]]
function ListItem:Notify(event, ...)
    local state = rawget(self, STATE_KEY)

    if state.list then
        local handler = state.list[event]
        if (type(handler) == "string") then
            local parent = state.list:GetParent()
            local target = parent[handler]
            if (type(target) == "function") then
                pcall(target, parent, self, ...)
            end
        end
    end
end

Addon.CommonUI.List.ListItem = ListItem