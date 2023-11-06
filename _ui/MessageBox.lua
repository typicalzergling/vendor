local _, Addon = ...
local locale = Addon:GetLocale()
local MessageBox = Mixin({}, Addon.CommonUI.Mixins.Border, CallbackRegistryMixin)
local Colors = Addon.CommonUI.Colors
local UI = Addon.CommonUI.UI

function MessageBox:OnLoad()
    CallbackRegistryMixin.OnLoad(self)
    self:GenerateCallbackEvents({ "OnClose" })
    self:OnBorderLoaded()
    Mixin(self.host, Addon.CommonUI.Mixins.Border)
    self.host:OnBorderLoaded()
    UI.Attach(self.titlebar.close, Addon.CommonUI.CloseButton)
    self.buttons = {}
    self.tabgroup = CreateTabGroup()
    self:SetClampedToScreen(true)
    self:RegisterForDrag("LeftButton")
end

--[[ Sets the title bar of our dialog ]]
function MessageBox:SetCaption(name)
    local addon = locale.ADDON_NAME
    local caption = locale:GetString(name) or name
    self.titlebar.text:SetFormattedText("%s - %s", addon, caption)
end

--[[ Handle a message box button clicked ]]
local function onButtonClicked(button)
    button.close:Hide()

    if (type(button.callback) == "function") then
        xpcall(button.callback, CallErrorHandler, button.id)
    end

    button.close:TriggerEvent("OnClose", button, button.id)
end

--[[ Add a button and handler to the dialog ]]
function MessageBox:AddButton(id, text, handler, default)
    local button = CreateFrame("Button", nil, self.host, "CommonUI_CommandButton")
    button:SetLabel(text)
    if (type(handler) == "function") then
        button.callback = handler
    end

    button.close = self
    button.id = id
    button.default = default
    button:SetScript("OnClick", onButtonClicked)
    table.insert(self.buttons, button)

    return button
end

--[[ Sets the content for this message box ]]
function MessageBox:SetContent(frame)
    if (frame:GetParent() ~= self) then
        frame:SetParent(self)
    end

    self.contentsFrame = frame
end

--[[ Handle drag start ]]
function MessageBox:OnDragStart()
    self:StartMoving()
end

--[[ Handle drag stop ]]
function MessageBox:OnDragStop()
    self:StopMovingOrSizing()
end

function MessageBox:OnShow()
    self:Layout()
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
    self:SetScript("OnKeyDown", self.OnKeyUp)
    self:Raise()
    self.tabgroup:SetFocus()
end

function MessageBox:OnHide()
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
    self:SetScript("OnKeyDown", nil)
end

--[[ Handle keyboard navigation with the buttons ]]
function MessageBox:OnKeyUp(key)
    if (key == "ENTER") then
        for _, button in ipairs(self.buttons) do
            if (button.default == true) then
                onButtonClicked(button)
                return
            end
        end
    elseif (key == "TAB") then
        --self.tabgroup:OnTabPressed()
    end

    self:Raise()
end

--[[ If the use clicks on the message box make sure it's topmost ]]
function MessageBox:OnMouseDown()
    self:SetToplevel(true)
    self:Raise()
end

local function messagebox_LayoutButtons(messagebox)
    local last
    local width = 0
    local height = 0

    if (table.getn(messagebox.buttons)) then
        local maxWidth = 0
        local maxHeight = 0

        -- Compute the button size
        for _, button in ipairs(messagebox.buttons) do
            local bh = button:GetHeight()
            local bw = button:GetWidth()

            if (bh > maxHeight) then
                maxHeight = bh
            end

            if (bw > maxWidth) then
                maxWidth = bw
            end
        end

        -- Layout the buttons
        for _, button in ipairs(messagebox.buttons) do
            button:SetHeight(maxHeight)
            button:SetWidth(maxWidth)

            if (last) then
                last:SetPoint("RIGHT", button, "LEFT", -10, 0)
                width = width + 10
            end
            last = button
            width = width + maxWidth
        end

        height = maxHeight
    end

    return width, height, last
end

--[[ Layout the content and return our height ]]
local function mbLayoutContent(messagebox, width)
    local content = messagebox.contentsFrame

    content:ClearAllPoints()
    content:SetWidth(width)

    -- Layuout the contnet with the width
    if (type(content.Layout) == "function") then
        content:Layout()
    end

    return content:GetHeight()
end

--[[ Determine our border thickness ]]
local function mbGetContentPadding(messagebox)
    local paddingX = 0
    local paddingY = 0

    if (type(messagebox.ContentPaddingX) == "number") then
        paddingX = messagebox.ContentPaddingX
    end

    if (type(messagebox.ContentPaddingY) == "number") then
        paddingY = messagebox.ContentPaddingY
    end

    return paddingX, paddingY
end

--[[ Determine our border thickness ]]
local function mbGetBorderThickness(messagebox)
    local thicknessX = 1
    local thicknessY = 1

    if (type(messagebox.BorderThickness) == "number") then
        thicknessX = messagebox.BorderThickness
        thicknessY = thicknessX
    end

    return thicknessX, thicknessY
end

function MessageBox:OnSizeChanged(_, height)
    local _, borderY = mbGetBorderThickness(self)
    local _, paddingY = mbGetContentPadding(self)
    local captionHeight = self.titlebar:GetHeight()
    local contentHeight = self.contentsFrame:GetHeight()

    if (self.buttons and table.getn(self.buttons)) then
        contentHeight = contentHeight + self.buttons[1]:GetHeight() + 16
    end

    local newHeight = contentHeight + (2 * paddingY) + (2 * borderY) + captionHeight
    if (height < newHeight) then
        self:SetHeight(newHeight)
    end
end

--[[ Handle laying out the message box ]]
function MessageBox:Layout()
    local buttonWidth, _, button = messagebox_LayoutButtons(self)
    local borderX, borderY = mbGetBorderThickness(self)
    local paddingX, paddingY = mbGetContentPadding(self)
    local captionHeight = self.titlebar:GetHeight()
    local host = self.host
    
    local contentWidth = 360
    if (buttonWidth > contentWidth) then
        contentWidth = buttonWidth
    end

    local h = mbLayoutContent(self, contentWidth)
    
    host:SetWidth(contentWidth + (2 * paddingX))
    host:SetPoint("TOPLEFT", borderX, -(borderY + captionHeight))
    host:SetPoint("BOTTOMRIGHT", -borderX, borderY)
    
    self.contentsFrame:SetPoint("TOPLEFT", host, "TOPLEFT", paddingX, -paddingY)
    if (button) then
        button:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -paddingX, paddingY)
    end
    
    self:SetHeight(captionHeight + host:GetHeight())
    self:SetWidth((2 * borderX) + host:GetWidth())
end

--[[
    Cretes a new message box using the provide parameters

    caption - The text to use in the caption bar
    content - The content to use 
    buttons - The buttons to use (see dialog for a descriptino of the buttons arary)
]]
function MessageBox.Create(params)
    assert(type(params) == "table", "Expected MessageBox parameters to be a table")

    local messagebox = CreateFrame("Frame", nil, params.parent or UIParent, "CommonUI_MessageBox")
    UI.Attach(messagebox, MessageBox)
    messagebox:SetCaption(params.caption or "")

    -- Setup the buttons
    if (not params.buttons) then
        messagebox:AddButton("close", CLOSE, nil, true)
    else
        for i, button in ipairs(params.buttons) do
            messagebox:AddButton(button.id or i, button.text, button.handler, button.default)
        end
    end

    -- Create the markdown
    local frame = CreateFrame("frame")
    local markdownFrames = Addon.CommonUI.CreateMarkdownFrames(frame, params.content or "")
    frame.Layout = function(self, width)
            Addon.CommonUI.Layouts.Stack(frame, markdownFrames, 0, 10, width)
        end
    frame:SetScript("OnSizeChanged",
            function(_, width) 
                frame:Layout(width)
            end)

    for _, mf in ipairs(markdownFrames) do
        mf:SetScript("OnSizeChanged", function()
        end)
    end

    if (not params.parent or params.parent == UIParent) then
        -- Compute the location?
    end

    messagebox:SetContent(frame)
    messagebox:SetFrameStrata("TOOLTIP")
    messagebox:Show()

    return messagebox
end

Addon.CommonUI.MessageBox = MessageBox