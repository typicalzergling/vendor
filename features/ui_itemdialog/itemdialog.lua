local _, Addon = ...
local locale = Addon:GetLocale()
local ItemDialog = {}

function ItemDialog:GetName()
    return "ItemDialog"
end

function ItemDialog:GetDependencies()
    return { "rules", "system:itemproperties" }
end

--[[ Initialize the list feature ]]
function ItemDialog:OnInitialize()
    self.itemProps = Addon:GetSystem("itemproperties")
    return { "CreateModels", "CreateModelTemplate" }
end

--[[ 
    Given anitem (ItemProperties) create a list of models which represents that item
]]
function ItemDialog:CreateModels(item)
    if not item or type(item) ~= "table" then
        return {}
    end

    local categories = {}

    for name, value in pairs(item) do

        local isApplicable = true
        local hideType = 0

        local defined = self.itemProps:IsPropertyDefined(name)
        if not defined then
            Addon:Debug("items", "Undefined property: " .. name)
        end

        if defined then
            -- Hide has 3 states, never hidden, always hidden, and hidden if default
            hideType = self.itemProps:IsPropertyHidden(name)

            -- Two types of applicability:
            -- 1) parent is specified and is false
            -- 2) conditional hide is specified and it is the default value
            -- Property is considered non-applicable if either of these are true.

            -- If property has a parent, it is not applicable unless the parent
            -- has a non-false value.

            local parent = self.itemProps:GetPropertyParent(name)
            if parent and not item[parent] then
                -- Parent is false, this is not applicable
                isApplicable = false
            end

            -- Conditional hide state
            if hideType == 2 then
                local default = self.itemProps:GetPropertyDefault(name)
                if value == default then
                    isApplicable = false
                end
            end
        end

        -- TODO: add setting to show non-applicable values
        -- This effectively would override the applicability test, but not the
        -- always-hidden test.

        -- TODO: Add debug setting to override to show all properties regardless
        -- of applicability or hide state.
        local category = self.itemProps:GetPropertyCategory(name)
        local rank = self.itemProps:GetPropertyRank(name)

        if (hideType ~= 1) and isApplicable and category then
            categories[category] = categories[category] or {}
            table.insert(categories[category],  { Name = name, Value = value, Rank = rank or 0 })
        end
    end

    -- Create the list of model in category order
    local models = {}
    for _, category in ipairs(self.itemProps:GetPropertyCategories()) do
        local items = categories[category]
        if type(items) == "table" and table.getn(items) >= 1 then
            table.insert(models, {
                    Name = category,
                    Header = true
                })

            table.sort(items, function(a, b)
                if a.Rank ~= b.Rank then
                    return a.Rank < b.Rank 
                end
                
                return a.Name < b.Name
            end)

            for _, model in ipairs(items) do
                table.insert(models, model)
            end            
        end
    end

    return models
end

--[[
    Given a model create from "CreateModels", return the frame used to display the model
]]
function ItemDialog:CreateItemForModel(model)
    if not model or type(model) ~= "table" then 
        error("Usage: CreateItemForModel: nodel")
        return
    end

    if model.Header then
        return Mixin(CreateFrame("Frame", nil, self.properties, "Vendor_ItemDialog_ItemCategory"), Addon.Features.ItemDialog.HeaderItem)
    end

    return Mixin(CreateFrame("Button", nil, self.properties, "Vendor_ItemDialog_ItemProperty"), Addon.Features.ItemDialog.PropertyItem)
end

Addon.Features.ItemDialog = ItemDialog