--[[===========================================================================
    | Copyright (c) 2018
    |
    | ListBase:
    |   This mixin provides the support for a scrolling list of items (model)
    |   this handles all of the basic functionality but abstracts the parts
    |   which are list specific. 
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
    | ItemBase:
    |   This is mixed into the item when it is created and provides 
    |   the following functionality which can be used by consumers/subclasses.
    |
    |       GetModel() - Returns the data/model item for this visual.
    |       GetIndex() - Returns the raw index into view
    |       GetModelIndex() - Returns the index into the model collection.
    |
    ========================================================================--]]

local AddonName, Addon = ...
local L = Addon:GetLocale()

local ListBase = {};
local ItemBase = {};
local MODEL_KEY = {};
local MODEL_INDEX_KEY = {};
local function __noop(...) end

--[[===========================================================================
    | ItemBase:GetModel:
    |   Returns the data/model item this visual is using
    ========================================================================--]]
function ItemBase:GetModel()
    return rawget(self, MODEL_KEY);
end

--[[===========================================================================
   | ItemBase:GetIndex:
   |    Returns the index in the view of this item.  This index they are laid
   |    out in the list.
    ========================================================================--]]
function ItemBase:GetIndex()
    return self:GetParent():FindIndexOfItem(self);
end

--[[===========================================================================
   | ItemBase:GetModelIndex
   |    Returns the index of the model in the collection used to build the
   |    view, this will be different in the view is sorted.
    ========================================================================--]]
function ItemBase:GetModelIndex()
    return rawget(self, MODEL_INDEX_KEY);
end


--[[===========================================================================
    | ListBase:SortItems:
    |   Arranges the items in order using the CompareItems function, if there
    |   is not compare items function the list remains unsorted.
    ========================================================================--]]
function ListBase:SortItems()
    local sortFunction = self.CompareItems;
    if (self.items and sortFunction) then

        -- Check if some prep work needs to be done before sorting
        local prepareSort = self.PrepareSort;
        if (prepareSort) then
            prepareSort(self);
        end

        -- Execute the sort
        table.sort(self.items,
            function (a, b)
                return sortFunction(self, a, b);
            end);
    end
end

--[[===========================================================================
    | ListBase:ForEach:
    |   Calls the provided function for each item in the list.
    ========================================================================--]]
function ListBase:ForEach(callback)
    assert(type(callback) == "function");
    if (self.items) then
        for _, item in ipairs(self.items) do
            callback(item);
        end
    end
end

--[[===========================================================================
    | ListBase:FindItem:
    |   Searches the list to locate the item which the specified view/model
    ========================================================================--]]
function ListBase:FindItem(model)
    if (self.items) then
        for _, item in ipairs(self.items) do
            if (model == rawget(item, MODEL_KEY)) then
                return item;
            end
        end
    end
end

--[[===========================================================================
    | ListBase:FindIndexOfItem
    |   Searches the list to determine the index of the specified item
    ========================================================================--]]
function ListBase:FindIndexOfItem(item)
    if (self.items) then
        local model = rawget(item, MODEL_KEY);
        for index, i in ipairs(self.items) do
            if (model == rawget(i, MODEL_KEY)) then
                return index;
            end
        end
    end
end

--[[===========================================================================
    | ListBase:MoveItem
    |   This moves an item to the new position and then updates the view.
    |   the index is clamped to the extremes of the view.
    |
    |   returns true if the item was actually moved.
    ========================================================================--]]
function ListBase:MoveItem(item, newIndex)
    if (self.items) then
        local index = math.min(math.max(1, newIndex), #self.items);
        local current = self:FindIndexOfItem(item);
        if (index ~= current) then
            local items = self.items;
            table.remove(items, current);
            table.insert(items, index, item);            
            self:Update();
            return true;
        end
    end        
end

--[[===========================================================================
    | ListBase:EnsureItems:
    |   Synchronizes the view to the specified model collection, this can be
    |   either an associate or index based table.
    ========================================================================--]]
function ListBase:EnsureItems(model)
    assert(type(model) == "table");
    local createItemCallback = self.CreateItem or __noop;
    local refreshItemCallback = self.RefreshItem or __noop;

    -- Make sure we've got an item for each element of our model, if
    -- not then we'll call the create function to make one.
    local ids = {};
    local modelIndex = 1;    
    self.items = self.items or {};
    for _, element in pairs(model) do
        ids[element] = true;
        local item = self:FindItem(element);
        if (not item) then
            item =createItemCallback(self, element);
            rawset(item, MODEL_KEY, element);
            item = Mixin(item, ItemBase);
            table.insert(self.items, item);
        else
            refreshItemCallback(self, item, element);
        end

        rawset(item, MODEL_INDEX_KEY, modelIndex)
        modelIndex = (modelIndex + 1);
    end

    -- Remove any elements which are no-longer present in the list
    if (self.items) then
        local index = 1;
        while (index <= #self.items) do
            local item = self.items[index];
            if (not ids[rawget(item, MODEL_KEY)]) then
                table.remove(self.items, index);
                item:Hide();
                item:SetParent(nil);
            else
                index = (index + 1);
            end
        end
    end

    -- After we've created the view give our subclass a chance do something
    -- with the items.
    local onViewBuilt = self.OnViewBuilt or __noop;
    xpcall(onViewBuilt, self);

    -- Sort the items if a sort function was provided.
    self:SortItems();
end

--[[===========================================================================
    | ListBase:AdjustScrollbar:
    |   We want the scrollbar to occupy the space inside of dimensions rather 
    |   than outside, we also sometimes want a background behind it, so if we've 
    |   got one the anchor it the scrollbar.  Finally we want the buttons 
    |   stuck to the bottom of the scrollbar rather than a big space.
    |   TODO: possibly share this as it's own mix-in.
    ========================================================================--]]
function ListBase:AdjustScrollbar()
    -- than being offset
    local scrollbar = self.ScrollBar;
    if (scrollbar) then
        local buttonHeight = scrollbar.ScrollUpButton:GetHeight();
        local background = self.scrollbarBackground;
        if (background) then
            background:ClearAllPoints();
            background:SetPoint("TOPLEFT", scrollbar.ScrollUpButton, "BOTTOMLEFT", 0, buttonHeight / 2);
            background:SetPoint("BOTTOMRIGHT", scrollbar.ScrollDownButton, "TOPRIGHT", 0, -buttonHeight / 2);
        end

        scrollbar:ClearAllPoints();
        scrollbar:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -buttonHeight);
        scrollbar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, buttonHeight - 1);
        scrollbar.ScrollUpButton:ClearAllPoints();
        scrollbar.ScrollUpButton:SetPoint("BOTTOM", scrollbar, "TOP", 0, 0);
        scrollbar.ScrollDownButton:ClearAllPoints();
        scrollbar.ScrollDownButton:SetPoint("TOP", scrollbar, "BOTTOM", 0, 0);

        if (not self.items or not table.getn(self.items)) then
            scrollbar:Disable();
            scrollbar.ScrollUpButton:Disable();
            scrollbar.ScrollDownButton:Disable();
        else
            scrollbar:Enable();
            scrollbar.ScrollUpButton:Enable();
            scrollbar.ScrollDownButton:Enable();
        end
    end
end

--[[===========================================================================
    | ListBase:UpdateView:
    |   Handles synchronizing the view the specified model, and then laying
    |   out all the frames. 
    ========================================================================--]]
function ListBase:UpdateView(model)
    self:EnsureItems(model);
    self:Update();
end

--[[===========================================================================
    | ListBase:UpdateView:
    |   Rebuilds the view from the ground up, throwing out all of the 
    |   existing items.
    ========================================================================--]]
function ListBase:RebuildView(model)
    if (self.items) then
        for _, item in ipairs(self.items) do
            item:ClearAllPoints();
            item:Hide();
            item:SetParent(nil);
        end            
    end
    self.items = nil;
    self:UpdateView(model);
end

--[[===========================================================================
    | setEmptyText (local):
    |   This is a local helper which shows/hide the optional empty text
    |   element for the view.
    ========================================================================--]]
local function setEmptyText(self, show)
    if (self.emptyText) then
        if (show) then
            self.emptyText:Show();
        else
            self.emptyText:Hide();
        end
    end
end

--[[===========================================================================
    | ListBase:OnVerticalScroll
    |   Handles implementing the vertical scroll event, this should be hooked
    |   to the item via XML or SetScript.
    ========================================================================--]]
function ListBase:OnVerticalScroll(offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, self.itemHeight, function(self) self:Update() end);
end

--[[===========================================================================
    | ListBase:Update:
    |   Called to handle updating both the FauxScrollFrame and the items 
    |   layout to synchronize the view state.
    ========================================================================--]]
function ListBase:Update()
    local itemCallback = self.OnUpdateItem or __noop;
    setEmptyText(self, (not self.items or (#self.items == 0)));

    if (self.items) then
        -- Update the visible custom rules
        local itemHeight = self.itemHeight;
        local offset = FauxScrollFrame_GetOffset(self);
        local visible = math.floor(self:GetHeight() / itemHeight);
        local anchor = nil;
        local first = (1 + offset);
        local last = (first + visible);
        local width = (self:GetWidth() - self.ScrollBar:GetWidth() - 1);
        local itemCount = #self.items;

        FauxScrollFrame_Update(self, itemCount, visible, itemHeight, nil, nil, nil, nil, nil, nil, true);
        for index,item in ipairs(self.items) do
            item:ClearAllPoints();
            if ((index >= first) and (index < last)) then
                item:Show();
                item:SetWidth(width);

                if (not anchor) then
                    item:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
                else
                    item:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, 0);
                end

                itemCallback(self, item, (index == 1), (index == itemCount));
                anchor = item
            else
                item:Hide();
            end
        end
    end
end

Addon.ListBase = ListBase;
