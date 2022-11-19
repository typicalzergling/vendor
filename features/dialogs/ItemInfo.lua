local _, Addon = ...
local locale = Addon:GetLocale()
local Dialog = Addon.CommonUI.Dialog
local EditRuleEvents = Addon.Features.Dialogs.EditRuleEvents
local Colors = Addon.CommonUI.Colors

local PropertyItem = {
    OnLoad = function(item)
        item.value:SetWordWrap(true)
        item:RegisterForClicks("LeftButton", "RightButton")
    end,

    OnModelChange = function(item, model)
        item.name:SetText(model.Name)

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

        item.value:SetText(valueText)
        item.value:SetTextColor(valueColor:GetRGBA())
    end,

    OnSizeChanged = function(item, width, height)
        local max = 0
        for _, child in pairs({ item:GetRegions() }) do
            if (child ~= item.hilite) then
                local h = child:GetHeight()
                if h > max then
                    max = h
                end
            end
        end

        item:SetHeight(max + (item.PaddingY or 0))
    end,

    GetDocumentation = function(item, model)
        local doc = Addon.ScriptReference.ItemProperties[model.Name]
        if (doc) then
            local text = doc;
            if (type(doc) == "table") then
                text = doc.Text
            end
            
            return text
        end
    end,

    GetInsertText = function(item, button, modifier)
        local model = item:GetModel()

        local valueText = model.Value
        if (type(valueText)== "string") then
            valueText = "\"" .. valueText .. "\""
        else
            valueText = tostring(valueText)
        end

        if (button == "RightButton") then
            if (modifier ~= "ALT") then
                return model.Name
            else
                return valueText
            end
        elseif (button == "LeftButton") then
            if (modifier ~= "ALT") then
                if (type(model.Value) == "boolean") then
                    return model.Name
                else
                    return string.format("%s == %s", model.Name, valueText)
                end
            else
                if (type(model.Value) == "boolean") then
                    return string.format("not %s", model.Name)
                else
                    return string.format("%s ~= %s", model.Name, valueText)
                end
            end
        end
    end,

    OnEnter = function(item)
        item.hilite:Show()

        local model = item:GetModel()
        local documentation = item:GetDocumentation(model)

        GameTooltip:SetOwner(item, "ANCHOR_NONE")
        GameTooltip:AddLine(model.Name, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        GameTooltip:SetPoint("TOPLEFT", item, "BOTTOMLEFT", 0, -4)

        if (type(documentation) == "string") then
            GameTooltip:AddLine(documentation, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
            GameTooltip:AddLine(" ")
        end

        GameTooltip:AddDoubleLine("Left-click", item:GetInsertText("LeftButton"),
            YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b,
            GREEN_FONT_COLOR.r,  GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
        GameTooltip:AddDoubleLine("Alt + Left-cLick", item:GetInsertText("LeftButton", "ALT"),
            YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b,
            GREEN_FONT_COLOR.r,  GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
        GameTooltip:AddDoubleLine("Right-cLick", item:GetInsertText("RightButton"),
            YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b,
            GREEN_FONT_COLOR.r,  GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
        GameTooltip:AddDoubleLine("Alt + Right-click", item:GetInsertText("RightButton", "ALT"),
            YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b,
            GREEN_FONT_COLOR.r,  GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)

        GameTooltip:Show()
    end,

    OnLeave = function(item)
        item.hilite:Hide()
        if (GameTooltip:GetOwner() == item) then
            GameTooltip:Hide()
        end
    end,

    OnMouseDown = function(item, button)
        local modifier = nil
        if (IsShiftKeyDown()) then
            modifier = "SHIFT"
        elseif (IsAltKeyDown()) then
            modifier = "ALT"
        elseif (IsControlKeyDown()) then
            modifier = "CTRL"
        end

        local text = item:GetInsertText(button, modifier)
        if (text) then
            item:Notify("OnInsertText", text)
        end
        
        --local model = item:GetModel()
        --Dialog.RaiseEvent(item, EditRuleEvents.HELP_CONTEXT, model.Name, "property")
    end
}

Addon.Features.Dialogs.ItemInfoTab = {

    OnLoad = function(iteminfo)
        iteminfo.properties:Sort(function(a, b)
                return a.Name < b.Name
            end)
    end,

    ShowItemProperties = function(iteminfo, item)
        iteminfo.properties:Rebuild()
    end,

    GetItemProperties = function(iteminfo)
        if (not iteminfo.item:IsItemEmpty()) then
            local models = {}
            local itemproperties = Addon:GetSystem("ItemProperties")
            for name, value in pairs(itemproperties:GetItemPropertiesFromItem(iteminfo.item)) do
                if not itemproperties:IsPropertyHidden(name) then
                    --print("Inserting "..name)
                    table.insert(models, {
                        Name = name,
                        Value = value
                    })
                end
            end

            return models
        end

        return {}
    end,

    CreatePropertyItem = function(iteminfo, model)
        return Mixin(CreateFrame("Frame", nil, iteminfo.properties, "Vendor_EditRule_ItemProperty"), PropertyItem)
    end,

    InsertScriptText = function(iteminfo, item, text)
        iteminfo:TriggerEvent("INSERT_TEXT", item, text)
    end,
}