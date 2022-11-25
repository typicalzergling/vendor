--[[
    MinimapButton 
    This file is a bit of a mess. We always try to avoid dependencies and tried to take a shortcut
    with the minimap button by using LDBIcon, which was a mistake for numerous reasons. A minimap
    button is not a complex widget, so not worth abstracting, so we put it all here. This is similar
    to LDBIcon and supports the same LDB format of data, though it does not require LDB, nor does
    it require LDBIcon. It is more 'lightweight' in that respect, and it isn't managed by other
    addons. We maintain our state, we manage setting our state, and we don't need to update
    anything but ourselves when updates occur. We also plan some tweaks to the button behavior.
]]

local AddonName, Addon = ...
local L = Addon:GetLocale()
local function debugp(...) Addon:Debug("minimapbutton", ...) end

-- Feature Definition
local MinimapButton = {
    NAME = "MinimapButton",
    VERSION = 1,
    -- you can also use GetDependencies
    DEPENDENCIES = {
        "StatusPlugin",
    },
}

MinimapButton.c_DragRadius = 10
MinimapButton.c_DefaultPosition = 180
MinimapButton.c_ButtonFrameName = string.format("%s_%s", AddonName, "MinimapButton")
MinimapButton.c_TooltipFrameName = string.format("%s_MinimapTooltip", AddonName)

-- Map Definition
-- Much of the minimap stuff was hacked out and simplified from LDBIcon

local minimapButton = nil
local tooltip = nil

-- Taken from wowpedia
    -- quadrant booleans (same order as SetTexCoord)
	-- {upper-left, lower-left, upper-right, lower-right}
	-- true = rounded, false = squared
local shape_quadrant_map = {
    ["ROUND"] =                 {true, true, true, true},
    ["SQUARE"] =                {false, false, false, false},
    ["CORNER-TOPLEFT"] =        {false, false, false, true},
    ["CORNER-TOPRIGHT"] =       {false, false, true, false},
    ["CORNER-BOTTOMLEFT"] =     {false, true, false, false},
    ["CORNER-BOTTOMRIGHT"] =    {true, false, false, false},
    ["SIDE-LEFT"] =             {false, true, false, true},
    ["SIDE-RIGHT"] =            {true, false, true, false},
    ["SIDE-TOP"] =              {false, false, true, true},
    ["SIDE-BOTTOM"] =           {true, true, false, false},
    ["TRICORNER-TOPLEFT"] =     {false, true, true, true},
    ["TRICORNER-TOPRIGHT"] =    {true, false, true, true},
    ["TRICORNER-BOTTOMLEFT"] =  {true, true, false, true},
    ["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
}

local isDraggingButton = false    -- Used to track if we are dragging the icon to suppress mouseover

-- All the minimap code is taken from a few places, LDBIcon mostly.
local function updateButtonPosition(button, position)
    local angle = math.rad(position or 250)
    local x = math.cos(angle)
    local y = math.sin(angle)
    local q = 1
    if x < 0 then q = q + 1 end
    if y > 0 then q = q + 2 end
    local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
    local quadTable = shape_quadrant_map[shape]
    local w = (Minimap:GetWidth() / 2) + MinimapButton.c_DragRadius
    local h = (Minimap:GetHeight() / 2) + MinimapButton.c_DragRadius
    if quadTable[q] then
        x = x*w
        y = y*h
    else
        local diagRadiusW = sqrt(2*(w)^2)-10
        local diagRadiusH = sqrt(2*(h)^2)-10
        x = math.max(-w, math.min(x*diagRadiusW, w))
        y = math.max(-h, math.min(y*diagRadiusH, h))
    end
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local defaultCoords = {0, 1, 0, 1}
local function updateCoord(self)
	local coords = self:GetParent().data.iconCoords or defaultCoords
	local dX = 0
    local dY = 0
	if not self:GetParent().isMouseDown then
		dX = (coords[2] - coords[1]) * 0.05
		dY = (coords[4] - coords[3]) * 0.05
	end
	self:SetTexCoord(coords[1] + dX, coords[2] - dX, coords[3] + dY, coords[4] - dY)
end

local function onClick(self, b)
	if self.data.OnClick then
		self.data.OnClick(self, b)
	end
end

local function onMouseDown(self)
	self.isMouseDown = true
	self.icon:UpdateCoord()
end

local function onMouseUp(self)
	self.isMouseDown = false
	self.icon:UpdateCoord()
end

local function onUpdate(self)
    local mx, my = Minimap:GetCenter()
    local px, py = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    px =  px / scale
    py =  py / scale
    local pos = math.deg(math.atan2(py - my, px - mx)) % 360
    self.state.position = pos
    updateButtonPosition(self, pos)
end

local function onDragStart(self)
    self:LockHighlight()
    self.isMouseDown = true
    self.icon:UpdateCoord()
    self:SetScript("OnUpdate", onUpdate)
    isDraggingButton = true
    tooltip:Hide()
    if self.showOnMouseover then
        self.fadeOut:Stop()
        self:SetAlpha(1)
    end
end

local function onDragStop(self)
    self:SetScript("OnUpdate", nil)
	self.isMouseDown = false
	self.icon:UpdateCoord()
	isDraggingButton = false
    self:UnlockHighlight()
    if self.showOnMouseover then
        self.fadeOut:Play()
    end
    MinimapButton:SaveState()
end

local function getAnchors(frame)
	local x, y = frame:GetCenter()
	if not x or not y then return "CENTER" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

-- For refreshing the tooltip if the mouse stays over it.
local tooltipRefreshTicker = nil


local function onEnter(self)
	if isDraggingButton then return end
    if self.showOnMouseover then
        self.fadeOut:Stop()
        self:SetAlpha(1)
    end

    if self.data.OnTooltipShow then
        tooltip:SetOwner(self,"ANCHOR_NONE")
        tooltip:SetPoint(getAnchors(self))
        self.data.OnTooltipShow(tooltip)
        tooltip:Show()
    end
end
    
local function onLeave(self)
    if tooltipRefreshTicker then tooltipRefreshTicker:Cancel() end
	tooltip:Hide()
	if not isDraggingButton then
    	if self.showOnMouseover then
	    	self.fadeOut:Play()
        end
	end
end

local function getOrCreateButton(name, data, state)
    assert(name and data and state)
    if not tooltip then
        tooltip = CreateFrame("GameTooltip", MinimapButton.c_TooltipFrameName, UIParent, "GameTooltipTemplate")
    end
    debugp("In getOrCreateButton: %s %s - %s, %s", name, tostring(data), tostring(state.enabled), tostring(state.position))
	local button = CreateFrame("Button", name, Minimap)
	button.data = data                  -- LDB-like object
	button.state = state                -- table, with "enabled" and "position" members.
	button:SetFrameStrata("MEDIUM")
	button:SetFixedFrameStrata(true)
	button:SetFrameLevel(8)
	button:SetFixedFrameLevel(true)
	button:SetSize(31, 31)
	button:RegisterForClicks("anyUp")
	button:RegisterForDrag("LeftButton")
	button:SetHighlightTexture(136477) --"Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight"
	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetSize(53, 53)
	overlay:SetTexture(136430) --"Interface\\Minimap\\MiniMap-TrackingBorder"
	overlay:SetPoint("TOPLEFT")
	local background = button:CreateTexture(nil, "BACKGROUND")
	background:SetSize(20, 20)
	background:SetTexture(136467) --"Interface\\Minimap\\UI-Minimap-Background"
	background:SetPoint("TOPLEFT", 7, -5)
	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetSize(17, 17)
	icon:SetTexture(data.icon)
	icon:SetPoint("TOPLEFT", 7, -6)
	button.icon = icon
	button.isMouseDown = false

	local r, g, b = icon:GetVertexColor()
	icon:SetVertexColor(data.iconR or r, data.iconG or g, data.iconB or b)

	icon.UpdateCoord = updateCoord
	icon:UpdateCoord()

	button:SetScript("OnEnter", onEnter)
	button:SetScript("OnLeave", onLeave)
	button:SetScript("OnClick", onClick)
    button:SetScript("OnDragStart", onDragStart)
    button:SetScript("OnDragStop", onDragStop)
	button:SetScript("OnMouseDown", onMouseDown)
	button:SetScript("OnMouseUp", onMouseUp)

	button.fadeOut = button:CreateAnimationGroup()
	local animOut = button.fadeOut:CreateAnimation("Alpha")
	animOut:SetOrder(1)
	animOut:SetDuration(0.2)
	animOut:SetFromAlpha(1)
	animOut:SetToAlpha(0)
	animOut:SetStartDelay(1)
	button.fadeOut:SetToFinalAlpha(true)

    updateButtonPosition(button, button.state.position)
    if button.state.enabled then
        button:Show()
    else
        button:Hide()
    end

    return button
end

-- Default minimap state and position
local mapdefault = {}
mapdefault.enabled = true
mapdefault.position = MinimapButton.c_DefaultPosition

function MinimapButton:Get()
    return minimapButton
end

local function updateMinimapButtonVisibility()
    if not minimapButton then
        return 
    end
    local accountMapData = Addon:GetAccountSetting(Addon.c_Config_MinimapData)
    assert(accountMapData and type(accountMapData.enabled) == "boolean", "Error retrieving settings for MinimapButton")
    debugp("Updating button visibility. Hide = %s", tostring(accountMapData.hide ))
    if accountMapData.enabled then
        minimapButton.state.enabled = true
        minimapButton:Show()
    else
        minimapButton.state.enabled = false
        minimapButton:Hide()
    end
end

function MinimapButton:SaveState()
    -- It's possible the minimap button wasn't created if the dependency is missing.
    if not minimapButton then return end
    debugp("Saving Minimap Settings")
    -- The button holds truth since it can be manipulated by other addons to manage how minimap buttons
    -- appear. So another addon may disable our minimap button on the user's behalf so we will reflect
    -- that state here.
    -- It's possible the minimap button wasn't created if the dependency is missing.

    -- Remove old bad data by creating new table.
    local state = {
        enabled = minimapButton.state.enabled,
        position = minimapButton.state.position,
    }

    debugp("State:  %s - %s", tostring(state.enabled), tostring(state.position))
    Addon:SetAccountSetting(Addon.c_Config_MinimapData, state)
end

local function resetMinimapDataToDefault()
    debugp("Resetting MinimapButton data to defaults.")
    Addon:SetAccountSetting(Addon.c_Config_MinimapData, mapdefault)
end

function MinimapButton:CreateSettingForMinimapButton()
    return Addon.Features.Settings.CreateSetting(nil, true, self.IsMinimapButtonEnabled, self.SetMinimapButtonEnabled)
end

function MinimapButton.IsMinimapButtonEnabled()
    local accountMapData = Addon:GetAccountSetting(Addon.c_Config_MinimapData)
    if accountMapData then
        return accountMapData.enabled
    else
        -- Going to assume that if the data is corrupted or missing they want the minimap button.
        -- this should help get back into a good state.
        resetMinimapDataToDefault()
        return true
    end
end

function MinimapButton.SetMinimapButtonEnabled(value)
    local accountMapData = Addon:GetAccountSetting(Addon.c_Config_MinimapData)
    if value then
        accountMapData.enabled = true
    else
        accountMapData.enabled = false
    end
    Addon:SetAccountSetting(Addon.c_Config_MinimapData, accountMapData)
end

function MinimapButton:Create()
    -- If this is already created we have nothing to create.
    if minimapButton then
        return true
    end

    -- We require the StatusPlugin to be enabled.
    local statusplugin = Addon:GetFeature("StatusPlugin")
    if not statusplugin then
        debugp("StatusPlugin is not available.")
        return false
    end

    -- Get data from the account setting and migrate old date.
    local accountMapData = Addon:GetAccountSetting(Addon.c_Config_MinimapData, mapdefault)
    if accountMapData.minimapPos then
        accountMapData.enabled = true
        accountMapData.position = accountMapData.minimapPos
    end

    -- Create the minimap button.
    minimapButton = getOrCreateButton(MinimapButton.c_ButtonFrameName, statusplugin:GetStatusPluginDefinition(), accountMapData)
    if minimapButton then
        debugp("MinimapButton Starting State = %s - %s", tostring(minimapButton.state.enabled), tostring(minimapButton.state.position))
    else
        debugp("No minimap button was created")
    end
    return not not minimapButton
end

function MinimapButton:OnInitialize()
    debugp("Initializing")
    local created = self:Create()
    if not created then
        debugp("Failed to create Minimap Button")
        return
    end

    debugp("Initialize Complete")
end

function MinimapButton:OnTerminate()
    self:SaveState()
end

function MinimapButton:OnAccountSettingChange(settings)
    if (settings[Addon.c_Config_MinimapData]) then
        debugp("MinimapButton Settings Update")
        updateMinimapButtonVisibility()
    end
end

Addon.Features.MinimapButton = MinimapButton