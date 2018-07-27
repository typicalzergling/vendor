--[[===========================================================================
    | ListBase/ItemBase:
    |
    ========================================================================--]]
local Package = select(2, ...);
local ListBase = {};
local ItemBase = {};
local MODEL_KEY = {};
local function __noop(...) end

--[[===========================================================================
    | ItemBase:GetModel
    ========================================================================--]]
function ItemBase:GetModel()
    return rawget(self, MODEL_KEY);
end

--[[===========================================================================
   | ItemBase:GetIndex
    ========================================================================--]]
function ItemBase:GetIndex()
    return self:GetParent():FindIndexOfItem(self);
end

--[[===========================================================================
    | SortItems:
    ========================================================================--]]
function ListBase:SortItems()
print("--- listbase:sortitems", self.CompareItems, self.PrepareSort);
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

function ListBase:SearchForItem(searchFunction)
    assert(type(searchFunction) == "function");
    if (self.items) then
        for _, item in ipairs(self.items) do
            if (searchFunction(self, rawget(item, MODEL_KEY))) then
                return item;
            end
        end
    end
end

--[[===========================================================================
    | FindItem:
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
    | FindIndex
    ========================================================================--]]
function ListBase:FindIndexOfItem(item)
    if (self.items) then
        local model = rawget(element, MODEL_KEY);
        for index, item in ipairs(self.items) do
            if (model == rawget(item, MODEL_KEY)) then
                return index;
            end                
        end
    end
end

--[[===========================================================================
    | EnsureItems:
    ========================================================================--]]
function ListBase:EnsureItems(model)
    assert(type(model) == "table");
    local createItemCallback = self.CreateItem or __noop;

    -- Make sure we've got an item for each element of our model, if 
    -- not then we'll call the create function to make one.
    local ids = {};
    self.items = self.items or {};
    for _, element in pairs(model) do
        ids[element] = true;
        local item = self:FindItem(element);   
        if (not item) then
            item = createItemCallback(self, element);
            rawset(item, MODEL_KEY, element);
            table.insert(self.items, Mixin(item, ItemBase));
        end        
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

    -- Sort the items if a sort function was provided.
    self:SortItems();
end

--[[===========================================================================
    | AdjustScrollbar:
    ========================================================================--]]
function ListBase:AdjustScrollbar()
    -- We want the scrollbar to occupy the space inside of dimensions rather than outside,
    -- We also sometimes want a background behind it, so if we've got one the anchor it the
    -- scrollbar.  And finally, we want the buttons stuck to the bottom of the scrollbar rather
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
        scrollbar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, buttonHeight);
        scrollbar.ScrollUpButton:SetPoint("BOTTOM", scrollbar, "TOP", 0, 0);
        scrollbar.ScrollDownButton:SetPoint("TOP", scrollbar, "BOTTOM", 0, 0);
    end
end

--[[===========================================================================
    | UpdateView:
    ========================================================================--]]
function ListBase:UpdateView(model)
    self:EnsureItems(model);
    self:Update();
end

--[[===========================================================================
    | UpdateView:
    ========================================================================--]]
function ListBase:RebuildView(model)
    self.items = nil;
    self:UptateView(mdodel);
end

--[[===========================================================================
    | setEmptyText:
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

function ListBase:OnVerticalScroll(offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, self.itemHeight, function(self) self:Update() end);
end    

--[[===========================================================================
    | Update:
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

                itemCallback(self, item, (index == 1), (index == itemCont));
                anchor = item
            else
                item:Hide();
            end
        end
    end        
end

Package.ListBase = ListBase;
