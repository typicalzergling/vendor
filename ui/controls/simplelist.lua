--[[===========================================================================
    |
    ========================================================================--]]

local AddonName, Addon = ...
local ListItem = Addon.Controls.ListItem
local SimpleList = Addon.DeepTableCopy(Addon.Controls.List);

--[[===========================================================================
	| OnLoad handler for the list base, sets some defaults and hooks up
	| some scripts.
	========================================================================--]]
function SimpleList:OnLoad()
	rawset(self, "@@list@@", true)
	self:SetClipsChildren(true);
	self:AdjustScrollbar();
	self:SetScript("OnShow", self.Update);
	self:SetScript("OnUpdate", self.OnUpdate);
end

function SimpleList:OnUpdate()
	if (self.needsLayout) then
		self.needsLayout = false
		self:Layout()
	end
	Addon.Controls.List.OnUpdate(self)
end

function SimpleList:HideAllFrames()
	if (self.frames) then
		for _, frame in ipairs(self.frames) do
			frame:ClearAllPoints()
			frame:Hide()
		end
	end
end
	
--[[===========================================================================
	| SimpleList:Update:
	|   Called to handle updating both the FauxScrollFrame and the items 
	|   layout to synchronize the view state.
	========================================================================--]]
function SimpleList:Update()
	local items = Addon.Invoke(self, "GetItems")
	local managesFrames = (type(self.GetItemForModel) == "function")
	self.frames = self.frames or {}

	if (not items or (table.getn(items) == 0)) then
		self:HideAllFrames()
		self:ShowEmptyText(true)
		self:GetScrollChild():SetHeight(10)
		self:SetVerticalScroll(0)
	else
		local container = self:GetScrollChild();

		if (managesFrames) then
			self:HideAllFrames()
			self.frames = {}
		end
	
		local function layoutHandler()
			self.needsLayout = true
		end

		self:ShowEmptyText(false)	
		for index, model in ipairs(items) do
			local item = Addon.Invoke(self, "GetItemForModel", model)
			if (not item) then
				item = self.frames[index]
				if (not item) then
					item = self:CreateItem()
					self.frames[index] = item
				end
				item:SetModel(model)
			else
				self.frames[index] = item
			end

			item:SetModelIndex(index)
			item:Show()
			item:SetScript("OnSizeChanged", layoutHandler)
		end

		for index = table.getn(items) + 1, table.getn(self.frames) do
			self.frames[index]:ClearAllPoints()
			self.frames[index]:Hide()
			self.frames[index]:SetScript("OnSizeChanged", nil)
		end

	end
	self:Layout()
end

function SimpleList:Layout()
	if (self.frames and (table.getn(self.frames) ~= 0)) then
		local container = self:GetScrollChild();
		local width = (self:GetWidth() - self.ScrollBar:GetWidth());
		local top = 0;

		for _, item in ipairs(self.frames) do
			if (item:IsShown()) then
				item:ClearAllPoints()
				item:SetWidth(width)
				item:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -top)
				item:SetPoint("TOPRIGHT", container, "TOPLEFT", width, -top)
				item:Show()
				top = top + item:GetHeight()
			end
		end

		container:SetHeight(top);
		container:SetWidth(width);

		if (top == 0) then
			self.ScrollBar:Disable()
			self.ScrollBar:Hide()
		else
			self.ScrollBar:Enable()
			self.ScrollBar:Show()
		end
	end
end

Addon.Controls = Addon.Controls or {}
Addon.Controls.SimpleList = SimpleList
		