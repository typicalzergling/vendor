local AddonName, Addon = ...
local locale = Addon:GetLocale()
local UI = Addon.CommonUI.UI
local ImportList = {}

local function debugp(...) Addon:Debug("importlist", ...) end

--[[ Validate the list payload ]]
function ImportList:Validate(payload)
    if (type(payload.Items) ~= "table") then
        debugp("There item field is invalid")
        return false
    end

    local list = payload.Items[1]
    if (type(list.Name) ~= "string") then
        debugp("The name of the list is invalid")
        return false
    end

    if (type(list.Description) ~= "string") then
        debugp("The description of the list is invalid")
        return false
    end

    if (type(list.Items) ~= "table") then
        debugp("The list does not have the 'Items' collection")
        return false
    end

    return true
end

--[[ Ensure the imported list has a unique name ]]
function ImportList:CreateListName(imported)
    local canidate = imported
    local unique = false
    local loop = 1

    while (not unique) do
        unique = true
        local name = string.lower(canidate)
        for _, list in ipairs(Addon:GetLists()) do
            if (name == string.lower(list:GetName())) then
                unique = false
                break
            end
        end

        if (not unique) then
            if (loop == 1) then
                canidate = locale:FormatString("IMPORTLIST_UNIQUE_NAME0", imported)
            else
                canidate = locale:FormatString("IMPORTLIST_UNIQUE_NAME1", imported, loop)
            end
            loop = loop + 1
        end
    end

    return canidate
end

--[[ Create the UI to show what you are importing ]]
function ImportList:CreateUI(parent, payload)
    local list = payload.Items[1]
    list.ImportName = self:CreateListName(list.Name)
    
    local items = 0
    for id, _ in pairs(list.Items) do
        if (C_Item.DoesItemExistByID(id)) then
            items = items + 1
        end
    end

    -- 1 is the name of the list
    -- 2 is the descrpiton
    -- 3 & 4 are plauyer/relam
    -- 5 - 6 are items and plural 

    local pluaral = "s"
    if (items == 1) then
        pluaral = ""
    end

    local markdown = locale:FormatString("IMPORTLIST_MARKDOWN_FMT", 
            list.ImportName, list.Description, 
            payload.Player, payload.Realm, items, pluaral)

    return Addon.CommonUI.MarkdownView.Create(parent, markdown)
end

--[[ Handle the importing of the actual list ]]
function ImportList:Import(payload)
    local list = payload.Items[1]
    assert(type(list) == "table", "Expected a valid list for import")

    local newList = Addon:CreateList(list.ImportName, list.Description)
    for id, v in pairs(list.Items) do
        if (v) then
            newList:Add(id)
        end
    end

    local editDialog = Addon:GetFeature("lists")
    if (editDialog) then
        Addon.Features.Lists.ShowEditDialog(newList)
    end
end

Addon.Features.Import.ImportList = ImportList