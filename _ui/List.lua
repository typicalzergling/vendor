--[[===========================================================================
    | Copyright (c) 2018
    |
    | List:
    |   This mixin provides the support for a scrolling list of items (model)
    |   this handles all of the basic functionality but abstracts the parts
	|   which are list specific. 
	|
    ==========================================================================]]

local _, Addon = ...
local locale = Addon:GetLocale()
local List = Mixin({}, Addon.CommonUI.Mixins.Border)
local STATE_KEY = {}
local SCROLLFRAME_TEMPLATE = "UIPanelScrollFrameTemplate"
local Colors = Addon.CommonUI.Colors
local UI = Addon.CommonUI.UI
local Layouts = Addon.CommonUI.Layouts
local DISCARD_TIME = 60.0

--[[ Calls a hanlder on the list or it's parent ]]
local function list_callHandler(list, handler, ...)
    local func = list[handler]
    if (type(func) == "string") then
        local parent = list:GetParent()
        func = parent[func]
        if (type(func) == "function") then
            xpcall(func, CallErrorHandler, parent, ...)
        end
    elseif (type(func) == "function") then
        xpcall(func, CallErrorHandler, list, ...)
    end
end

--[[
    Create the child scrollview which actually holds the contents
]]
local function _createScrollframe(list)
    local scroller = CreateFrame("ScrollFrame", nil, list, SCROLLFRAME_TEMPLATE)
    scroller:SetScrollChild(CreateFrame("Frame", nil, scroller))
    scroller:SetPoint("TOPLEFT", 3, -3)
    scroller:SetPoint("BOTTOMRIGHT", -3, 3)
    ScrollFrame_OnLoad(scroller)
    
    local scrollbar = scroller.ScrollBar
    local up = scrollbar.ScrollUpButton
    local down = scrollbar.ScrollDownButton

    scrollbar:SetWidth(up:GetWidth())
    up:ClearAllPoints()
    up:SetPoint("TOPRIGHT", list, -2, -2)

    down:ClearAllPoints()
    down:SetPoint("BOTTOMRIGHT", list, -2, 1)

    scrollbar:ClearAllPoints()
    scrollbar:SetPoint("TOPLEFT", up, "BOTTOMLEFT")
    scrollbar:SetPoint("BOTTOMRIGHT", down, "TOPRIGHT")

    return scroller
end

--[[ Discards any frames which are not currently in the view from the framses cache ]]
local function list_DiscardFrames(self, state)
    state = state or rawget(self, STATE_KEY)
    if (not self:IsVisible() and state.viewFrames) then
        
        local frames = {}
        for _, litem in ipairs(state.viewFrames) do
            frames[litem:GetModel()] = litem
        end

        state.frames = frames
        Addon:Debug("list", "Discarded unused frames for list '%s'", self:GetParentKey() or "<unknown>")
    end
end

--[[ Create an error item if something goes badly ]]
local function list_ErrorItemCreator(parent, model)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(22)
    local text = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    text:SetText("Error: " .. tostring(model))
    text:SetTextColor(RED_FONT_COLOR:GetRGBA())
    text:SetAllPoints(frame)
    return frame
end

--[[ Build a function in our state to create an item (compute it once) ]]
local function list_EnsureCreateItem(self, state)
    state = state or rawget(self, STATE_KEY)
    local parent  = self:GetParent()

    -- The parent/list takes care of creating the item
    if (type(self.ItemCreator)) == "string" then
        local creator = parent[self.ItemCreator]
        local target = parent
        if (type(creator) ~= "function") then
            creator = self[self.ItemCreator]
            target = self
        end

        if (type(creator) ~= "function") then
            Addon:Debug("list", "The provided function '%s' is invalid", self.ItemCreator)
            Addon:DebugForEach("list", parent)
            state.itemCreator = list_ErrorItemCreator
        else
            Addon:Debug("list", "Using '%s' as the item creator provided by '%s'", self.ItemCreator, target:GetParentKey() or "<unknown>")
            state.itemCreator = function(parent, model)
                    return creator(target,model)
                end
        end    
    elseif (type(self.OnCreateItem) == "function") then
        Addon:Debug("list", "Using self.OnCreateItem as the item creator for '%s'", self:GetParentKey() or "<unknown>")
        state.itemCreator = self.OnCreateItem
    elseif (type(self.ItemTemplate) == "string") then
        local template = self.ItemTemplate

        local frameType = "Button"
        if (type(self.ItemFrameType) == "string") then
            frameType = self.ItemFrameType
        end

        local class
        if (type(self.ItemClass) == "string") then
            class = UI.Resolve(self.ItemClass)
            if (not class) then
                Addon:Debug("list", "The list '%s' specified an invalid item class : %s", self:GetParentKey() or "<unknown>", self.ItemClass)
            end
        elseif (type(self.ItemClass) == "table") then
            class = self.ItemClass
        else
            class = {}
        end

        Addon:Debug("list", "Using type=%s, template=%s to create items for '%s'", frameType, template, self:GetParentKey() or "<unknown>")
        state.itemCreator = function(parent, model)
                local frame = CreateFrame(frameType, nil, parent, template)
                UI.Attach(frame, class)
                return frame
            end
    end

    if (not state.itemCreator) then
        Addon:Debug("list", "Unable to determine how to create items for lsit '%s'", self:GetParentKey() or "<unknown>")
        state.itemCreator = list_ErrorItemCreator
    end
end

--[[ Create an item for the specified model ]]
local function list_CreateItem(self, state, model)
    state = state or rawget(self, STATE_KEY)

    --@debug@
    assert(type(state.itemCreator) == "function", "We should have a resovled item creator by this point")
    --@end-debug@

    local litem = Mixin(state.itemCreator(self, model), List.ListItem)
    litem:Attach(self);
    litem:SetModel(model)
    litem:SetParent(state.scroller:GetScrollChild())
    
    litem:SetScript("OnSizeChanged", function(_item, ...)
            state.layout = true
            if (type(_item.OnSizeChanged) == "function") then
                _item:OnSizeChanged(...)
            end
        end)

    return litem
end

--[[ Using the current view, create a mirror of the item in the view, this will pull
     items from the caches and put them back into the cache if need ]]
local function list_PopulateItems(self, state)
    state = state or rawget(self, STATE_KEY)

    assert(type(state.view) == "table")
    
    local viewFrames = {}
    local cache = state.frames
    local misses = 0

    -- Push the current view back into the cache
    if (state.viewFrames) then
        for _, litem in ipairs(state.viewFrames) do
            cache[litem:GetModel()] = litem
        end
    end

    for _, model in ipairs(state.view) do
        local litem = cache[model]
        if (not litem) then
            -- We haven't created an item for this frame yet
            litem = list_CreateItem(self, state, model)
            misses = misses + 1

            --@debug@
            local modelName = tostring(model)
            if (type(model) == "table") then
                if (model.GetName) then
                    modelName = "" --model:GetName()
                else
                    modelName = model.Name or model.Text or modelName
                end
            end

            Addon:Debug("listitems", "Created frame for item '%s' on list '%s'", modelName, self:GetParentKey() or "<unknown>")
            --@end-debug@
        else
            -- This frame  can live in the view frames
            cache[model] = nil
        end
        
        table.insert(viewFrames, litem)
        litem:ClearAllPoints()
        litem:SetWidth(0)
        litem:Show()
    end

    -- Move any frames we were using into the cache
    for model, litem in pairs(cache) do
        litem:ClearAllPoints()
        litem:Hide()
        cache[model] = litem
    end

    state.viewFrames = viewFrames
    state.pendingSelection = state.selection

    Addon:Debug("list", "Created %s frames for '%s' (new=%d)", table.getn(state.viewFrames), self:GetParentKey() or "<unknown>", misses)
end

--[[ Construct the view for this list ]]
local function list_BuildView(self, state)
    state = state or rawget(self, STATE_KEY)

    if (not state.view) then
        local view = {}
        local filter = state.filter
        local sort = state.sort

        --@debug@
        --assert(type(state.items) == "table" and table.getn(state.items) ~= 0)
        --@end-debug@


        -- Traverse the models, exluding things which don't match 
        -- our filter if one was provided.
        for _,  model in ipairs(state.items) do
            if (filter) then
                if (filter(model)) then
                    table.insert(view, model)
                end
            else
                table.insert(view, model)
            end
        end

        -- If we have sort, then sort the resulting view
        if (type(sort) == "function") then
            table.sort(view, sort)
        end

        state.view = view
        Addon:Debug("list", "Created view %s/%s items for '%s'", table.getn(state.view or {}), table.getn(state.items or {}), self:GetParentKey() or "<unknown>")

        list_PopulateItems(self, state)        
        list_callHandler(self, "OnViewCreated", view)
        state.layout = true
    end
end

--[[ Layout the list ]]
local function list_Layout(self, state)
    local spacing = 0
    if (type(self.ItemSpacing) == "number") then
        spacing = self.ItemSpacing
    end

    local padding = 0
    if (type(self.Padding) == "number") then
        padding = self.Padding
    end

    local scroller = state.scroller:GetScrollChild()
    local width = scroller:GetWidth()
    if (not state.viewFrames) then
        Addon:Debug("list", "List '%s' has no frames (%s)", self:GetParentKey() or "<unknown>", table.getn(state.view or {}))
    else
        Layouts.Stack(scroller, state.viewFrames, padding, spacing, width)
        Addon:Debug("list", "List '%s' has finshed layout %s x %s (%s frames)", self:GetParentKey() or "<unknown>", width, scroller:GetHeight(), table.getn(state.viewFrames or {}))    
    end
end

--[[ Display the empty list ]]
local function list_showEmpty(list, show)
    local text = list.EmptyText
    local state = rawget(list, STATE_KEY)
    local scroller = state.scroller
    local empty = list.empty

    if (not text or not show) then
        empty:SetText("")
    elseif show and not empty:IsShown() then
        UI.SetText(empty, text)
        UI.SetColor(empty, "LIST_EMPTY_TEXT")
        empty:SetText(locale[text] or text)
        empty:SetTextColor(Colors.LIST_EMPTY_TEXT:GetRGBA())
    end

    Addon:Debug("list", "Showing empty text '%s' for list '%s'", text or "", list:GetParentKey() or "<unknown>")
    UI.Show(scroller, not show)
    UI.Show(empty, show)
end
    
--[[===========================================================================
    | List:GetItems
    |   Handle retrieves the items (models) for the list, these will get mapped
    |   1-to-1 to into the view
    ========================================================================--]]
local function list_GetItems(list)
    local state = rawget(list, STATE_KEY)
    if (not state.itemCreator) then
        list_EnsureCreateItem(list, state)
    end

    local func = list.GetItems
    if (not func) then
        func = list.OnGetItems
    end

    if (type(func) == "function") then
        -- List handles the fetch
        local items = func(list)
        return items or {}
    else
        -- If we didn't find a handler ask he parent
        local parent = list:GetParent()
        local target = list.ItemSource

        if (type(target) == "string") then
            Addon:Debug("list", "Getting items from parent using '%s' for list '%s'", list.ItemSource or "<error>", list:GetParentKey() or "<unknown>")
            func = parent[target]
            if (func) then
                local success, items = xpcall(func, CallErrorHandler, parent, list)
                if (success) then
                    return items or {}
                else
                    Addon:Debug("list", "Failed to retrieve the items for list '%s'", list:GetParentKey() or "<unknown>")
                end
            end
        end
    end

    return {}
end
    
    
--[[
    OnLoad handler for the list base, sets some defaults and hooks up
    some scripts.
]]
function List:OnLoad()
    local state = {
        frames = {},
        models = {},
        update = true,
    }

    rawset(self, STATE_KEY, state)
    self:OnBorderLoaded(nil, Colors.LIST_BORDER, Colors.LIST_BACK)
    self:SetClipsChildren(true)
    state.scroller = _createScrollframe(self)
end

--[[ Handler for show ]]
function List:OnShow()
    local state = rawget(self, STATE_KEY)

    if (state.discardTimer) then
        state.discardTimer:Cancel()
        state.discardTimer = nil
    end
    
    self:Update()
end

--[[ Handler for hide ]]
function List:OnHide()
    local state = rawget(self, STATE_KEY)

    if (state.discardTimer) then
        state.discardTimer:Cancel()
        state.discardTimer = nil
    end

    state.discardTimer = C_Timer.After(DISCARD_TIME, function()
            state.discardTimer = nil
            list_DiscardFrames(self, state)
        end)
end

--[[ Handler for size changed ]]
function List:OnSizeChanged(width, height)
    local state = rawget(self, STATE_KEY)
    Addon:Debug("List '%s' size has changed %d x %d", self:GetParentKey() or "<unknown>", width, height)
    state.layout = true
end

--[[
    Searches the list to locate the item which the specified view/model
]]
function List:FindItem(model)
    local state = rawget(self, STATE_KEY)

    if (state.viewFrames) then
        for _, litem in ipairs(state.viewFrames) do
            if (litem:GetModel() == model) then
                return litem
            end
        end
    end

    -- Itm isn't in the view
    return nil
end

--[[ Called ensre there is a selection ]]
function List:EnsureSelection()
    local state = rawget(self, STATE_KEY)
    state.ensureSelection = true
end

--[[
    Selects the specified item, called from the list items, will invoke
    OnSelection only if the selection has changed.
]]
function List:Select(item)
    local state = rawget(self, STATE_KEY)
    state.pendingSelection = item
end

--[[
    Gets the currently selected item in the view.
]]
function List:GetSelected()
    local state = rawget(self, STATE_KEY)

    if (state.pendingSelection) then
        return state.pendingSelection
    elseif (state.selection) then
        return state.selection
    end
    
    return nil;
end

--[[ Handle a pending selection ]]
local function list_ProcessSelection(self, state)
    if (state.pendingSelection) then
        local selection = state.selection
        if (selection ~= state.pendingSelection and state.viewFrames) then
            local newSelection

            for _, litem in ipairs(state.viewFrames) do
                local model = litem:GetModel()
                litem:SetSelected(model == state.pendingSelection)
                if (model == state.pendingSelection) then
                    newSelection = model
                end
            end

            state.selection = newSelection
            state.pendingSelection = nil
            list_callHandler(self, "OnSelection", state.selection, item)
        end
    elseif (state.ensureSelection) then
        if (not state.selection and state.view and table.getn(state.view)) then
            state.pendingSelection = state.view[1]
        end

        state.ensureSelection = nil
    end
end

--[[
    Update handler, delegates to each of the frames (if they are visible)
]]
function List:OnUpdate()
    if (self:IsVisible()) then
        local state = rawget(self, STATE_KEY)
        if (state.update) then
            state.update = false
            xpcall(self.Update, CallErrorHandler, self)
        elseif (state.layout) then
            state.layout = false
            xpcall(list_Layout, CallErrorHandler, self, state)
        elseif (state.ensureSelection or state.pendingSelection) then
            xpcall(list_ProcessSelection, CallErrorHandler, self, state)
        end
    end
end
-- Sets the filter for the item list
function List:Filter(filter)
    local state = rawget(self, STATE_KEY)
    assert(not filter or type(filter) == "function", "The filter must be a function or nil")

    state.filter = filter
    state.view = nil
    state.update = true
end

--[[
     Set a sort handler (or clear it) dpending on the argument
]]
function List:Sort(less)
    local state = rawget(self, STATE_KEY)
    assert(not sort or type(sort) == "function", "The sort must be a function or nil")

    state.sort = less
    state.view = nil
    state.update = true
end

--[[ 
    Marks the view as needing an update, which will happen on the next 
    pdate cycle
]]
function List:Refresh()
    local state = rawget(self, STATE_KEY)

    state.update = true
    state.view = nil
end

--[[
    Marks the view and needing to be rebuilt (item list has changed)
]]
function List:Rebuild()
    local state = rawget(self, STATE_KEY)

    state.update = true
    state.items = nil
    state.view = nil
    Addon:Debug("list", "Issuing a rebuild for list '%s'", self:GetParentKey() or "<unknown")
    self:Update()
end

--[[
    Called to handle updating both the FauxScrollFrame and the items 
    layout to synchronize the view state.
]]
function List:Update()
    local state = rawget(self, STATE_KEY)
    state.update = false        
    local scroller = state.scroller
    local container = scroller:GetScrollChild()
    local width = self:GetWidth() - scroller.ScrollBar:GetWidth() - 6

    Addon:Debug("lise", "Performing update for list '%s'", self:GetParentKey() or "<unknown>")

    -- Populate the items
    if (not state.items) then
        state.items = list_GetItems(self)
    end

    -- Populate the view
    if (not state.view) then
        list_BuildView(self, state)
    end

    if not state.view or table.getn(state.view) == 0 then
        list_showEmpty(self, true)
        list_callHandler(self, "OnViewCreated", STATE_KEY)
    else
        list_showEmpty(self, false)
        
        if (container:GetWidth() ~= width) then
            container:SetWidth(width)
        end

        list_Layout(self, state)
        self.layout = false
    end
end

Addon.CommonUI.List = List