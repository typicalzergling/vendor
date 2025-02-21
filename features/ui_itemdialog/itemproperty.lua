local _, Addon = ...
local PropertyItem = {}
local HeaderItem = {}
local Colors = Addon.CommonUI.Colors

local ACTIONS = {
    { Button = "Left",  Display = "Left-Click" },
    { Button = "Left", Mod = "ALT",  Display = "Alt + Left-Click"  },
    { Button = "Left", Mod = "CTRL",  Display = "Control + Left-Click" },
    { Button = "Left", Mod = "SHIFT",  Display = "Shift + Left-Click"  },
    { Button = "Right",  Display = "Left-Click" },
    { Button = "Right", Mod = "ALT",  Display = "Alt + Right-Click"  },
    { Button = "Right", Mod = "CTRL",  Display = "Control + Right-Click" },
    { Button = "Right", Mod = "SHIFT",  Display = "Shift + Right-Click"  }
}

-- Called when the model has cahnged
function PropertyItem:OnModelChange(model)
    self:RegisterForClicks("AnyUp")
    self.name:SetText(model.Name)

    local valueText = "nil"
    local valueColor = Colors.DISABLED_TEXT
    local valueType = type(model.Value)

    if (valueType == "string") then
        valueText = "\"" .. model.Value .. "\""
        valueColor = Colors.GREEN_FONT_COLOR
    elseif (valueType == "boolean" and not model.Value) then
        valueText = tostring(model.Value)
        valueColor = Colors.EPIC_PURPLE_COLOR
    elseif (valueType == "boolean" and model.Value) then
        valueText = tostring(model.Value)
        valueColor = Colors.HEIRLOOM_BLUE_COLOR
    elseif (valueType == "number") then
        valueText = tostring(model.Value)
        valueColor = Colors.LEGENDARY_ORANGE_COLOR
    elseif (model.Value ~= nil) then
        valueText = tostring(model.Value)
        valueColor = Colors.COMMON_GRAY_COLOR
    end

    self.value:SetText(valueText)
    self.value:SetTextColor(valueColor:GetRGBA())
end

-- Called to get the documentation for this property
function PropertyItem:GetDocumentation()
    local model = self:GetModel()
    --local doc = Addon.ScriptReference.ItemProperties[model.Name]
    local doc = Addon:GetPropertyDocumentation(model.Name)

    if (doc) then
        local text = doc;
        if (type(doc) == "table") then
            text = doc.Text
        end
        
        return text
    end
end

-- Called when our size has changed
function PropertyItem:OnSizeChanged()
    local max = 0
    local padding = self.PaddingY or 0
    for _, child in pairs({self:GetRegions()}) do
        if (child ~= self.hilite) then
            child:SetHeight(0)
            local h = child:GetHeight()
            if h > max then
                max = h
                child:SetHeight(h)
            end
        end
    end

    self:SetHeight(max + padding)
end

-- Called to ge the intert text (can be nil)
function PropertyItem:GetInsertText(button, modifier)
    local model = self:GetModel()
    return self:Notify("GetClickAction", model, button, modifier)
end

-- Called when the mouse enters the item
function PropertyItem:OnEnter()
    self.hilite:Show()

    local model = self:GetModel()
    local documentation = self:GetDocumentation()

    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:AddLine(model.Name, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
    GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -4)

    if (type(documentation) == "string") then
        GameTooltip:AddLine(documentation, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
        --GameTooltip:AddLine(" ")
    end


    local space = false
    for _, action in ipairs(ACTIONS) do 
        local text = self:GetInsertText(action.Button, action.Mod)
        if text and string.len(text) then
            if not space then
                GameTooltip:AddLine(" ")
                space = true
            end

            GameTooltip:AddDoubleLine(action.Display, text,
                YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b,
                GREEN_FONT_COLOR.r,  GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
        end
    end

    GameTooltip:Show()
end

-- Called when trhe mouse leves the frame
function PropertyItem:OnLeave()
    self.hilite:Hide()
    if (GameTooltip:GetOwner() == self) then
        GameTooltip:Hide()
    end
end

-- Called when the item is clicked
function PropertyItem:OnMouseDown(button)
    local model = self:GetModel()

    if button == "LeftButton" then
        button = "Left"
    elseif button == "RightButton" then
        button = "Right"
    else
        return
    end

    local modifier = nil
    if (IsShiftKeyDown()) then
        modifier = "SHIFT"
    elseif (IsAltKeyDown()) then
        modifier = "ALT"
    elseif (IsControlKeyDown()) then
        modifier = "CTRL"
    end

    local text = self:GetInsertText(button, modifier)
    print("===> mousedown::", button, modifier, text)
    if text and string.len(text) ~= 0 then
        self:Notify("OnHandleAction", text)
    end
end

-- Called when the model has cahnged
function HeaderItem:OnModelChange(model)
    self:OnBorderLoaded("tbk")
    self:SetBackgroundColor("HELPITEM_PROPERTY_BACK")
    self:SetBorderColor("HELPITEM_PROPERTY_BORDER")
    self.name:SetText(model.Name)
end

Addon.Features.ItemDialog.PropertyItem = PropertyItem
Addon.Features.ItemDialog.HeaderItem = Mixin(HeaderItem, Addon.CommonUI.Mixins.Border)