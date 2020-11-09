--[[===========================================================================
    | Copyright (c) 2018
    |
    | ListBase:
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
local ListItem = Addon.Controls.ListItem;
local L = Addon:GetLocale()
local function __noop() end

-- Simple helper for invoking handlers.
local function invoke(object, method, ...)
	local fn = object[method];
	if (type(fn) == "function") then
		local results = { xpcall(fn, CallErrorHandler, object, ...) };
		if (results[1]) then
			table.remove(results, 1);
			return unpack(results);
		end
	end 
	return nil;
end
	
local ListBase = {
	UpdateHandler = function(self)
		if (self:IsShown()) then
			self:ForEach(function(item)
				local update = item.OnUpdate;
				if (type(update) == "function") then
					update(item);
				end
			end)
		end
	end,

	EnsureUpdate = function(self)
		if (not self._hooked) then
			self:SetScript("OnUpdate", self.UpdateHandler);
			self._hooked = true;
		end
	end,

	ClearUpdate = function(self)
		if (self._hooked) then
			self:SetScript("OnUpdate", nil);
			self._hooked = false;
		end
	end,

	OnLoad = function(self)
		self:SetClipsChildren(true);
		self:AdjustScrollbar();
		self:SetScript("OnVerticalScroll", self.OnVerticalScroll);
		self:SetScript("OnShow", self.Update);
		self:SetScript("OnUpdate", self.OnUpdate);
	end
};

	
--[[===========================================================================
    | Sorts the items in the view
	========================================================================--]]
function ListBase:SortView()
	if (self.items) then
		invoke(self, "OnSort");
		table.sort(self.items, ListItem.CompareTo);
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
	| Searches the list to locate the item which the specified view/model
	========================================================================--]]
function ListBase:FindItem(model)
	if (self.items) then
		for _, item in ipairs(self.items) do
			if (item:HasModel(model)) then
				return item;
			end 
		end
	end
	return nil;
end

--[[===========================================================================
	| Retrieves teh view index for the specified item.
	========================================================================--]]
function ListBase:FindIndexOfItem(item)
	if (self.items) then
		local model = item:Getmodel();
		for index, i in self.items do 
			if (i:HasModel(model)) then
				return index;
			end
		end
	end
	return nil;
end

--[[===========================================================================
    | Populates our list of items.
	========================================================================--]]
function ListBase:Populate()
	local items = Addon.invoke(self, "GetItems");
	if (not items) then
		return
	end

	assert(type(model) == "table");

	-- Make sure we've got an item for each element of our model, if
	-- not then we'll call the create function to make one.
	local ids = {};
	local modelIndex = 1;    
	self.items = self.items or {};
	for _, element in pairs(model) do
		ids[element] = true;
		local item = self:FindItem(element);
		if (not item) then
			item = Mixin(createItemCallback(self, element), ItemBase);
			item:SetModel(element);
			table.insert(self.items, item);
		else
			refreshItemCallback(self, item, element);
		end

		item:SetModelIndex(modelIndex);
		modelIndex = (modelIndex + 1);
	end

	-- Remove any elements which are no-longer present in the list
	if (self.items) then
		local index = 1;
		while (index <= #self.items) do
			local item = self.items[index];
			if (not ids[item:GetModel()]) then
				table.remove(self.items, index);
				item:Hide();
				item:SetParent(nil);
				item:SetModel(nil);
			else
				index = (index + 1);
			end
		end
	end

	-- After we've created the view give our subclass a chance do something
	-- with the items.
	local onViewBuilt = self.OnViewBuilt or __noop;
	if (type(self.OnViewBuild) == "function") then
		xpcall(self.OnViewBuilt, CallErrorHandler, self);
	end

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
		if (not background) then
			background = self:CreateTexture(nil, "BACKGROUND", -2);
			background:SetColorTexture(0.0, 0.0, 0.0, 0.50);
		end
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

function ListBase:OnUpdate()
	if (self.frames) then
		for _, frame in ipairs(self.frames) do
			if (frame:IsVisible()) then
				Addon.invoke(frame, "OnUpdate");
			end
		end
	end
end

--[[===========================================================================
	| setEmptyText (local):
	|   This is a local helper which shows/hide the optional empty text
	|   element for the view.
	========================================================================--]]
function ListBase:SetEmptyText(show)
	local empty = self.EmptyText;
	if (empty) then
		if (show) then
			empty:Show();
		else
			empty:Hide();
		end
	end
end

--[[===========================================================================
	| ListBase:OnVerticalScroll
	|   Handles implementing the vertical scroll event, this should be hooked
	|   to the item via XML or SetScript.
	========================================================================--]]
function ListBase:OnVerticalScroll(offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, self.ItemHeight or 1, self.Update);
end

function ListBase:CreateItem()
	local subclass = nil;

	-- Determine if we have an implementation to attach	
	local class = self.ItemClass;
	if ((type(class) == "string") and (string.len(class) ~= 0)) then
		local scope = Addon;
		for _, t in ipairs(string.split(class, ".")) do
			if (scope) then
				subclass = scope[t];
				scope = scope[t];
			end
		end
	elseif (type(class) == "table") then
		subclass = class;
	end

	local frame = CreateFrame(self.FrameType or "Button", nil, self, self.ItemTemplate);
	frame = Mixin(frame, (subclass or {}));
	frame = ListItem:Attach(frame);
	invoke(frame, "OnCreated");
	invoke(self, "OnItemCreated", frame);
	return frame;
end

--[[===========================================================================
	| ListBase:Update:
	|   Called to handle updating both the FauxScrollFrame and the items 
	|   layout to synchronize the view state.
	========================================================================--]]
function ListBase:Update()
	local items = invoke(self, "GetItems");
	if (not items or (table.getn(items) == 0)) then
		self:SetEmptyText(true);
	else
		self:SetEmptyText(false);
		
		self.frames = self.frames or {};
		local offset = FauxScrollFrame_GetOffset(self);
		local itemHeight = (self.ItemHeight or 1);
		local visible = math.ceil(self:GetHeight() / itemHeight);
		local modelIndex = (1 + offset);
		local width = (self:GetWidth() - self.ScrollBar:GetWidth() - 1);
		local top = 0;
		
		FauxScrollFrame_Update(self, table.getn(items), visible, itemHeight, nil, nil, nil, nil, nil, nil, true);
		for i = 1, visible do 
			local item = self.frames[i];
			if (not item) then
				item = self:CreateItem();
				self.frames[i] = item;
			end

			item:ClearAllPoints();
			if (items[modelIndex]) then
				item:SetModel(items[modelIndex]);
				item:SetModelIndex(modelIndex);
				item:SetWidth(width);
				item:Show();
				item:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -top);

				top = top + itemHeight;
			else
				item:Hide();
			end
			modelIndex = modelIndex + 1;
		end
	end
end

Addon.Controls = Addon.Controls or {}
Addon.Controls.List = ListBase;
	