local _, Addon = ...
local Colors = Addon.CommonUI.Colors
local locale = Addon:GetLocale()
local Layouts = Addon.CommonUI.Layouts
local UI = {}

--[[ 
    Attempts to resolve the object, resolves and string in the format:  "A.B.C"
]]
local function resolveObject(root, path)
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

--[[ Sets the color of the item, using a color nmae ]]
function UI.SetColor(item, name)
    local color = Colors:Get(name)
    local type = item:GetObjectType()

    if (type == "FontString") then
        item:SetTextColor(color:GetRGBA())
    elseif (type == "Texture" or type == "Line") then
        item:SetColorTexture(color:GetRGBA())
    end
end

--[[ Sets the text content of the target item, using either the raw string or the localized string ]]
function UI.SetText(item, text, ...)
    local loctext = locale:GetString(text) or text

    local args = { args }
    if (table.getn(args) and item:GetObjectType() == "FontString") then
        ---@diagnostic disable-next-line: deprecated
        loctext = string.format(loctext, unpack(args))
    end

    item:SetText(loctext)
end

--[[ Handle processing a particular item for loc + colors ]]
local function processItem(item)
    --@debug@
    assert(item, "expected a non-null item")
    --@end-debug@

    -- Set color
    if (type(item.Color) == "string") then
        UI.SetColor(item, item.Color)
    end

    -- Set text
    local loc = item.LocKey or item.LocText
    if (type(loc) == "string") then
        UI.SetText(item, loc)
    end
end

--[[ Process all of the frames/regions ]]
local function visitFrame(frame)
    --@debug@
    assert(frame, "expected a non-null frame")
    --@end-debug@

    for _, child in pairs({ frame:GetChildren() }) do
        processItem(child)
        visitFrame(child)
    end

    -- Handle regions
    for _, region in ipairs({ frame:GetRegions() }) do
        processItem(region)
    end
end

--[[ Prepare the frame by applying colors and localized text ]]
UI.Prepare = function(item)
    if (type(item) ~= "table") then
        error("Usage: Prepare( frame )")
    end

    visitFrame(item)
end

--[[ Attach the provided implementation or string ]]
function UI.Attach(item, class)
    local object = class
    if (type(class) == "string") then
        object = resolveObject(Addon, class)
    end

    if (type(class) ~= "table") then
        error("Unable to determine the implementation :: " .. tostring(class))
    end

    UI.Prepare(item)
    Addon.AttachImplementation(item, object, true)
end

function UI.Resolve(path)
    --@debug@
    assert(type(path) == "string", "the string must be a path")
    --@debug-end@

    return resolveObject(Addon, path)
end

--[[ Simple helper around enable/disable which takes a bool ]]
function UI.Enable(item, enable)
    if (enable and not item:IsEnabled()) then
        item:Enable()
    elseif (not enable and item:IsEnabled()) then
        item:Disable()
    end
end

--[[ 
    Shows a message box with the speciifed contents:
    
    * If buttons is not procvided the a "CLOSE" button is automatically
     added 

    * If button is a string then a single button with the provided 
      string is added

    * If buttons is table, it can contain either a string or
      a table with text/handler
]]
function UI.MessageBox(title, markdown, buttons)
    local messagebox = CreateFrame("Frame", nil, UIParent, "CommonUI_MessageBox")
    UI.Attach(messagebox, Addon.CommonUI.MessageBox)
    messagebox:SetCaption(title)

    -- Setup the buttons
    if (type(buttons) == "nil") then
        messagebox:AddButton(CLOSE)
    elseif (type(buttons) == "string") then
        messagebox:AddButton(buttons)
    elseif (type(buttons) == "table") then
        for _, button in ipairs(buttons) do
            if (type(button) == "string") then
                messagebox:AddButton(button)
            elseif (type(button) == "table") then
                messagebox:AddButton(button.text, button.handler)
            end
        end
    end

    -- Create the markdown
    local frame = CreateFrame("frame")
    local markdownFrames = Addon.CommonUI.CreateMarkdownFrames(frame, markdown)
    frame.Layout = function()
            Addon.CommonUI.Layouts.Stack(frame, markdownFrames, 0, 6)
        end
    frame:SetScript("OnSizeChanged", function() frame:Layout() end)

    -- Compute the location

    messagebox:SetContent(frame)
    messagebox:SetFrameStrata("TOOLTIP")
    messagebox:Show()
    messagebox:Raise()
end

local DialogContent = {}

--[[ Retrieve the dialog ]]
function DialogContent:GetDialog()
    return rawget(self, DialogContent)
end

--[[ Update the button state ]]
function DialogContent:SetButtonState(buttons)
    local dialog = rawget(self, DialogContent)
    dialog:SetButtonState(buttons)
end

--[[ Enable/Disable the specified button ]]
function DialogContent:EnableButton(button, enabled)
    local dialog = rawget(self, DialogContent)
    dialog:SetButtonEnabled(button, enabled)
end

--[[ Show/Hide the speciifed button ]]
function DialogContent:ShowButton(button, show)
    local dialog = rawget(self, DialogContent)
    dialog:SetButtonVisiblity(button, show)
end

--[[ Sets the dialogs caption ]]
function DialogContent:SetCaption(caption)
    local dialog = rawget(self, DialogContent)
    dialog:SetCaption(caption)
end

--[[ Close the dialog ]]
function DialogContent:Close()
    local dialog = rawget(self, DialogContent)
    dialog:Hide()
end

--[[ Helper to retrieve the feature ]]
function DialogContent:GetFeature(feature)
    return Addon:GetFeature(feature)
end

--[[ Helper for debug output ]]
function DialogContent:Debug(debugMessage, ...)
    local args = {}
    for i, arg in ipairs({...}) do
        args[i] = tostring(arg)
    end
    Addon:Debug("dialog", debugMessage, unpack(args))
end

--[[ 
    Create a new dialog from the specified paramaters
]]
function UI.Dialog(caption, template, implementation, buttons)
    local dialog = CreateFrame("Frame", nil, UIParent, "DialogBox_Base")
    local content = CreateFrame("Frame", nil, dialog, template)

    -- Initialize the dialog
    UI.Prepare(dialog)
    UI.Attach(content, implementation or {})
    rawset(content, DialogContent, dialog)
    Mixin(content, DialogContent)
    dialog:SetContent(content)
    if (type(buttons) == "table") then
        dialog:SetButtons(buttons)
    end

    -- Any non-event handler on the content should be promoted to the dialog
    -- to provide the API to caller
    if (type(implementation) == "table") then
        for name, value in pairs(implementation) do
            if type(value) == "function" then
                if (not content:HasScript(name) and not Addon:RaisesEvent(name)) then
                    dialog[name] = function(_, ...) value(content, ...) end
                end
            end
        end
    end

    return dialog
end

Addon.CommonUI.UI = UI