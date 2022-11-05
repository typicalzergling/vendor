--[[===========================================================================
    | Copyright (c) 2018
    |
    | List:
    |   This mixin provides the support for a scrolling list of items (model)
    |   this handles all of the basic functionality but abstracts the parts
	|   which are list specific. 
	| 
	| Required:
	|	ItemTemplate: The name of the item template to use when creating 
	|                 or items. They all need to be the same neight.
	|	ItemHeight: The height each item in the list.
	|	ItemClass: The name of the class to attach to the item when
	|			   it is created.
    |   
    |   Subclasses can provided:
    |       OnUpdateItem(item, first, last) - Called when an item is laid out in 
    |           the view.  This is given the item and two bools to indicate it
    |           it's position in the view.
    |       OnViewBuilt() - Called after all of the items have been created.
    |       CompareItems(a, b) - Used for sorting the list, if not defined
    |           then the list will not be sorted. Receives two items as 
    |           arguments, returns true if a is before b.
    |       CreateItem(model)  - Called to create new entry in the list,
    |           given the data, returns a frame.
    |
    | ListItem:
    |   This is mixed into the item when it is created and provides 
    |   the following functionality which can be used by consumers/subclasses.
    |
    |       GetModel() - Returns the data/model item for this visual.
    |       GetIndex() - Returns the raw index into view
    |       GetModelIndex() - Returns the index into the model collection.
    |
    ==========================================================================]]

local _, Addon = ...
local locale = Addon:GetLocale()
local List = Mixin({}, Addon.CommonUI.Mixins.Border)
local STATE_KEY = {}
local SCROLLFRAME_TEMPLATE = "UIPanelScrollFrameTemplate"
local Colors = Addon.CommonUI.Colors

local function debug(...)
    print(YELLOW_FONT_COLOR_CODE, "####LIST###:|r", ...)
end

local function _invokeHandler(list, handler, ...)
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

-- Simple helper that resolve "a.b.c" from the addon
local function _resolve(root, path)
    local function split(str)
        local result = {};
        for match in string.gmatch(str .. ".", "(.-)" .. "[.]" ) do
            table.insert(result, match)
        end
        return result
    end

    local c = root
    for _, part in ipairs(split(path)) do
        if (not c) then
            return nil
        end

        c = c[part]
    end

    return c
end

--[[ 
    Creates a new item for the specified model in the list (this will overwrite any item in the list)
]]
local function _createItem(list, state, model)
    local frame = nil
    local success = false

    -- Does the list or parent handle the creation?
    local creator = list.ItemCreator
    if (type(creator) == "string") then
        local func = list[creator]
        if (not func) then
            local parent = list:GetParent()
            func = parent[creator]
            if (func) then
                success, frame = xpcall(func, CallErrorHandler, parent, model)
            end
        else
            success, frame = xpcall(func, CallErrorHandler,  list, model)
        end

        assert(success, "failed to create the frame for the model")
        assert(frame, "Expected the item creator to create a frame")
        frame:SetParent(state.scroller:GetScrollChild())
    end

    if (not frame and type(list.OnCreateItem) == "function") then
        frame = list:OnCreateItem(model)

        assert(frame, "Expected the item creator to create a frame")
        frame:SetParent(state.scroller:GetScrollChild())
    end

    -- Create it ourselves with the keys
    if not frame then
        local template = list.FrameType or list.ItemType or list.ItemTemplate
        local itemClass = list.ItemClass
    
        -- Determine if we have an implementation to attach	
        if (not state.itemclass) then
            local class = itemClass or list.ItemClass;
            if ((type(class) == "string") and (string.len(class) ~= 0)) then
                class = _resolve(Addon, class)
            elseif (type(class) ~= "table") then
                class = nil
            end
    
            state.itemclass = class or {}
        end

        frame = CreateFrame("Button", nil, state.scroller:GetScrollChild(), template)
        Addon.AttachImplementation(frame, state.itemclass, true)
    end
    
    -- Create the actual item, and attach our implementaition
    Mixin(frame, list.ListItem)
    frame:Attach(list);
    frame:SetModel(model)
    Addon.Invoke(frame, "OnCreated", frame)
    Addon.Invoke(list, "OnItemCreated", frame, model)

    frame:SetScript("OnSizeChanged", function(_item, ...)
        state.reflow = true
        local func = _item.OnSizeChanged
        if type(func) == "function" then
            pcall(func, _item, ...)
        end
    end)

    return frame;
end

--[[===========================================================================
    | _buildView
    |   Given a list state, create the view which is the sorted filtered 
    |   models we are going to use display the actual view
    ========================================================================--]]
local function _buildView(list, state)
    if (not state.view) then
        local view = {}
        local filter = state.filter

        -- Traverse the models, exluding things which don't match 
        -- our filter if one was provided.
        for _,  model in ipairs(state.items) do
            if (filter) then
                if (filter(model)) then
                    if (not state.frames[model]) then
                        state.frames[model] = _createItem(list, state, model)
                    end
    
                    table.insert(view, model)
                end
            else
                if (not state.frames[model]) then
                    state.frames[model] = _createItem(list, state, model)
                end

                table.insert(view, model)
            end
        end

        -- If we have sort, then sort the resulting view
        if (type(state.sort) == "function") then
            local sortFunc = state.sort
            table.sort(view, function(a, b)
                local success, less = pcall(sortFunc, a, b)
                return (success and (less == true))
            end)
        end

        state.view = view
        _invokeHandler(list, "OnViewCreated", view)
    end
end

local NO_MARGINS = { left = 0, right = 0 }

-- Layout he view relative relative to the specified frame, if they are outside of the
-- current view bounds the frame is hidden, returns the total width/height of the resulting
-- view
local function _layoutView(list, container, state, cx, cy)
    local top = 0

    for _, frame in pairs(state.frames) do
        frame:ClearAllPoints()
        frame:Hide()
    end

    local last = table.getn(state.view)
    cx = cx - 1
    for index, model in ipairs(state.view) do
        local litem = state.frames[model]
        if (not litem) then
            litem = _createItem(list, state, model)
            state.frames[model] = litem
        end

        local margins = litem.Margins or NO_MARGINS
        litem:SetWidth(cx -  (margins.left or 0) - (margins.right or 0))

        if (index == 1) then
            litem:SetPosition("first")
        elseif (index == last) then
            litem:SetPosition("last")
        else
            litem:SetPosition("none")
        end
    
        litem:Show()
        top = top + litem:GetHeight() + (margins.top or 0) + (margins.bottom or 0)
        state.reflow  = true
    end

    return top
end

local function _reflow(list)
    local state = rawget(list, STATE_KEY)
    if (state.reflow) then
        state.reflow = false
        local space = tonumber(list.ItemSpacing) or 0
        local height = space

        for pos, model in ipairs(state.view) do            
            local frame = state.frames[model]
            local margins = frame.Margins or NO_MARGINS

            height = height + (margins.top or 0)
            frame:SetPoint("TOPLEFT", (margins.left or 0), -height)
            height = height + frame:GetHeight() + space + (margins.bottom or 0)
        end

        height = height + space
        state.scroller:GetScrollChild():SetHeight(height)
    end
end

local function _showEmpty(list, show)
    local text = list.EmptyText
    local state = rawget(list, STATE_KEY)
    local scroller = state.scroller
    local empty = list.empty

    if (not text or not show) then
        empty:Hide()
    elseif show and not empty:IsShown() then
        empty:SetText(locale[text] or text)
        empty:Show()
        empty:SetTextColor(Colors.LIST_EMPTY_TEXT:GetRGBA())
    end

    if (show and scroller:IsShown()) then
        scroller:Hide()
    elseif (not show and not scroller:IsShown()) then
        scroller:Show()
    end
end
    
--[[===========================================================================
    | List:GetItems
    |   Handle retrieves the items (models) for the list, these will get mapped
    |   1-to-1 to into the view
    ========================================================================--]]
local function _getItems(list)
    local func = list.GetItems
    if (not func) then
        func = list.OnGetItems
    end

    if (type(func) == "function") then
        -- List handles the fetch
        local success, items = xpcall(func, CallErrorHandler, list)        
        if (success) then 
            return items or {}
        end
    else
        -- If we didn't find a handler ask he parent
        local parent = list:GetParent()
        local target = list.ItemSource or "GetItems"

        func = parent[target]
        if (func) then
            local success, items = xpcall(func, CallErrorHandler, parent, list)
            if (success) then
                return items or {}
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
    debug("OnLoad")
    local state = {
        frames = {},
        models = {},
        update = true,
    }

    rawset(self, STATE_KEY, state)
    self:OnBorderLoaded(nil, Colors.LIST_BORDER, Colors.LIST_BACK)
    self:SetClipsChildren(true)
    self:SetScript("OnShow", function() state.update = true end)
    self:SetScript("OnSizeChanged", function() state.reflow = true end)
    state.scroller = _createScrollframe(self)
end

--[[
    Searches the list to locate the item which the specified view/model
]]
function List:FindItem(model)
    local state = rawget(self, STATE_KEY)
    return state.frames[model]
end

--[[
    Retrieves the view index for the specified item.
]]
function List:FindIndexOfItem(item)
    local state = rawget(self, STATE_KEY)
    local model = item:Getmodel();
    for index, item in ipairs(state.view) do
        if (item == model) then
            return index
        end
    end

    return nil
end

--[[
    Selects the specified item, called from the list items, will invoke
    OnSelection only if the selection has changed.
]]
function List:Select(item)
    local state = rawget(self, STATE_KEY)
    local sel = nil;

    local currentSel = self:GetSelected();
    local newSel = nil;

    if (type(item) == "number") then
        if (not state.items) then
            state.items = _getItems(self)
        end

        if (not state.view) then
            _buildView(self, state)
        end

        local model = state.view[item];
        if (not model) then
            return
        end

        sel = self:FindItem(model)
        if (not sel) then
            sel = _createItem(self, state, model)
            state.frames[model] = sel
        end
    elseif (type(item) == "table") then
        sel = self:FindItem(item);
    end

    for _, frame in pairs(state.frames) do
        if (frame == sel) then
            newSel = frame;
            frame:SetSelected(true);
        else
            frame:SetSelected(false);
        end
    end

    if (not currentSel or newSel ~= currentSel) then
        local model = nil;
        if (newSel) then
            model = newSel:GetModel();
        end

        local func = self.OnSelection
        if (type(func) == "function") then
            self:OnSelected(model, newSel)
        end

        _invokeHandler(self, "OnSelection", model, newSel)
    end
end

--[[
    Gets the currently selected item in the view.
]]
function List:GetSelected()
    local state = rawget(self, STATE_KEY)
    for _, frame in pairs(state.frames) do
        if (frame:IsVisible() and frame:IsSelected()) then
            return frame:GetModel();
        end
    end

    return nil;
end

--[[
    Update handler, delegates to each of the frames (if they are visible)
]]
function List:OnUpdate()
    local state = rawget(self, STATE_KEY)
    if (state.update) then
        self:Update()
    elseif (state.reflow) then
        _reflow(self)
    end

    for _, frame in ipairs(state.frames) do
        if (frame:IsVisible()) then
            local func = frame.OnUpdate
            if (type(func) == "function") then
                pcall(func, frame)
            end
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

    debug("Rebuiid")

    state.update = true
    state.items = nil
    state.view = nil

    if (state.frames) then
        for _, f in pairs(state.frames) do
            f:Hide()
        end
    end

    state.frames = {}
end

function List:Reflow()
    local state = rawget(self, STATE_KEY)
    state.reflow = true
end

--[[
    Called to handle updating both the FauxScrollFrame and the items 
    layout to synchronize the view state.
]]
function List:Update()
    local state = rawget(self, STATE_KEY)
    if (state.update) then
        state.update = false        
        local scroller = state.scroller
        local container = scroller:GetScrollChild()
        local width = scroller:GetWidth() - scroller.ScrollBar:GetWidth()

        -- Populate the items
        if (not state.items) then
            state.items = _getItems(self)
        end

        -- Populate the view
        if (not state.view) then
            _buildView(self, state)
        end

        if not state.view or table.getn(state.view) == 0 then
            _showEmpty(self, true)
            _invokeHandler(self, "OnViewCreated", STATE_KEY)
        else
            _showEmpty(self, false)
            local vh = _layoutView(self, container, state, width)
            container:SetWidth(width)
            container:SetHeight(vh)
            state.reflow = true
        end
    end
end

Addon.CommonUI.List = List