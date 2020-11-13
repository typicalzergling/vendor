--[[===========================================================================
    |
    ========================================================================--]]

	local AddonName, Addon = ...
	local ListItem = Addon.Controls.ListItem
	local SimpleList = table.copy(Addon.Controls.List);
	
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
	
--[[===========================================================================
	| SimpleList:Update:
	|   Called to handle updating both the FauxScrollFrame and the items 
	|   layout to synchronize the view state.
	========================================================================--]]
function SimpleList:Update()
	local items = Addon.invoke(self, "GetItems")
	self.frames = self.frames or {}

	if (not items or (table.getn(items) == 0)) then
		for _, frame in ipairs(self.frames) do
			frame:ResetAll()
		end	
		self:ShowEmptyText(true)
	else
		local container = self:GetScrollChild();
	
		local function layoutHandler()
			self:Layout()
		end

		self:ShowEmptyText(false)				
		for index, model in ipairs(items) do
			local item = self.frames[index]
			if (not item) then
				item = self:CreateItem()
				self.frames[index] = item
			end

			item:SetModel(model)
			item:SetModelIndex(index)
			item:Show()
			item:SetScript("OnSizeChanged", layoutHandler)
		end

		for index = table.getn(items) + 1, table.getn(self.frames) do
			self.frames[index]:ResetAll()
			self.frames[index]:SetScript("OnSizeChanged", nil)
		end

		self:Layout()
	end
end

function SimpleList:Layout()
	if (self.frames and (table.getn(self.frames) ~= 0)) then
		local container = self:GetScrollChild();
		local width = (self:GetWidth() - self.ScrollBar:GetWidth());
		local top = 0;

		for _, item in ipairs(self.frames) do
			if (item:IsShown()) then
				item:SetWidth(width)
				item:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -top)
				item:SetPoint("TOPRIGHT", container, "TOPLEFT", width, -top)
				item:Show()
				top = top + item:GetHeight()
			end
		end

		container:SetHeight(top);
		container:SetWidth(width);
	end
end

Addon.Controls = Addon.Controls or {}
Addon.Controls.SimpleList = SimpleList
		