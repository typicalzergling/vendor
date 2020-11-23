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
local ListItem = Addon.Controls.ListItem
local ListBase = table.copy(Addon.Controls.EmptyListMixin)
local NEED_UPDATE_KEY = {}

--[[===========================================================================
	| OnLoad handler for the list base, sets some defaults and hooks up
	| some scripts.
	========================================================================--]]
function ListBase:OnLoad()
	rawset(self, "@@list@@", true)
	self:SetClipsChildren(true);
	self:AdjustScrollbar();
	self:SetScript("OnVerticalScroll", self.OnVerticalScroll);
	self:SetScript("OnShow", self.Update);
	self:SetScript("OnUpdate", self.OnUpdate);
end

--[[===========================================================================
	| Searches the list to locate the item which the specified view/model
	========================================================================--]]
function ListBase:FindItem(model)
	if (self.frames) then
		for _, item in ipairs(self.frames) do
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
	| We want the scrollbar to occupy the space inside of dimensions rather 
	| than outside, we also sometimes want a background behind it, so if we've 
	| got one the anchor it the scrollbar.  Finally we want the buttons 
	| stuck to the bottom of the scrollbar rather than a big space.
	| TODO: possibly share this as it's own mix-in.
	========================================================================--]]
function ListBase:AdjustScrollbar()
	-- than being offset
	local scrollbar = self.ScrollBar;
	if (scrollbar) then
		local buttonHeight = scrollbar.ScrollUpButton:GetHeight()
		local background = self.scrollbarBackground
		if (not background) then
			background = scrollbar:CreateTexture(nil, "BACKGROUND");
			background:SetColorTexture(0.20, 0.20, 0.20, 0.3)
		end
		if (background) then
			background:ClearAllPoints();
			background:SetPoint("TOPLEFT", scrollbar.ScrollUpButton, "BOTTOMLEFT", 0, buttonHeight / 2);
			background:SetPoint("BOTTOMRIGHT", scrollbar.ScrollDownButton, "TOPRIGHT", 0, -buttonHeight / 2);
			
			scrollbar:SetScript("OnShow", function() background:Show() end)
			scrollbar:SetScript("OnHide", function() background:Hide() end)
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
	| Selects the specified item, called from the list items, will invoke
	| OnSelection only if the selection has changed.
	========================================================================--]]
function ListBase:Select(item)
	if (self.frames) then
		local sel = nil;
		local currentSel = self:GetSelected();
		local newSel = nil;

		if (type(item) == "number") then
			sel = self.frames[item];
		elseif (type(item) == "table") then
			sel = self:FindItem(item);
		end

		for _, frame in ipairs(self.frames) do
			if (frame == sel) then
				newSel = frame;
				frame:SetSelected(true);
			else
				frame:SetSelected(false);
			end
		end

		if (newSel ~= currentSel) then
			local model = nil;
			if (newSel) then
				model = newSel:GetModel();
			end
			Addon.Invoke(self, "OnSelection", model);
		end
	end
end

--[[===========================================================================
	| Gets the currently selected item in the view.
	========================================================================--]]
function ListBase:GetSelected()
	if (self.frames) then
		for _, frame in ipairs(self.frames) do
			if (frame:IsVisible()) then
				if (frame:IsSelected()) then
					return frame:GetModel();
				end
			end
		end
	end

	return nil;
end

--[[===========================================================================
	| Update handler, delegates to each of the frames (if they are visible)
	========================================================================--]]
function ListBase:OnUpdate()
	if (rawget(self, NEED_UPDATE_KEY)) then
		rawset(self, NEED_UPDATE_KEY, nil)
		self:Update()
	end
	if (self.frames) then
		for _, frame in ipairs(self.frames) do
			if (frame:IsVisible()) then
				Addon.Invoke(frame, "OnUpdate");
			end
		end
	end
end

--[[===========================================================================
	| Marks the list as needing update
	========================================================================--]]
function ListBase:FlagForUpdate()
	rawset(self, NEED_UPDATE_KEY, true)
end

--[[===========================================================================
	| Reset the list positino to the top.
	========================================================================--]]
function ListBase:ResetOffset()
	FauxScrollFrame_SetOffset(self, 0);
end

--[[===========================================================================
	| Handles implementing the vertical scroll event, this should be hooked
	|  to the item via XML or SetScript.
	========================================================================--]]
function ListBase:OnVerticalScroll(offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, self.ItemHeight or 1, self.Update);
end

--[[===========================================================================
	| Handles the creation of new item in the list, these items are recycled
	| and gave the model changed.  
	========================================================================--]]
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
	Addon.Invoke(frame, "OnCreated");
	Addon.Invoke(self, "OnItemCreated", frame);
	return frame;
end

--[[===========================================================================
	| ListBase:Update:
	|   Called to handle updating both the FauxScrollFrame and the items 
	|   layout to synchronize the view state.
	========================================================================--]]
function ListBase:Update()
	local items = Addon.Invoke(self, "GetItems");
	self.frames = self.frames or {};
	local itemHeight = (self.ItemHeight or 1);
	local visible = math.floor(self:GetHeight() / itemHeight);

	if (not items or (table.getn(items) == 0)) then
		for _, frame in ipairs(self.frames) do
			frame:ResetAll();
		end

		self:ShowEmptyText(true);
		FauxScrollFrame_SetOffset(self, 0);
		FauxScrollFrame_Update(self, 0, visible, itemHeight, nil, nil, nil, nil, nil, nil, true);
	else
		self:ShowEmptyText(false);

		local offset = FauxScrollFrame_GetOffset(self);
		local modelIndex = (1 + offset);
		local width = (self:GetWidth() - self.ScrollBar:GetWidth() - 1);
		local top = 0;
		
		FauxScrollFrame_Update(self, table.getn(items), visible, itemHeight, nil, nil, nil, nil, nil, nil, true);
		for i = 1, visible + 1 do 
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
				item:SetPoint("TOPRIGHT", self, "TOPLEFT", width, -top);

				top = top + itemHeight;
			else
				item:ResetAll();
			end
			modelIndex = modelIndex + 1;
		end
	end
end

Addon.Controls = Addon.Controls or {}
Addon.Controls.List = ListBase
	