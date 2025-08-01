local _, Addon = ...
local L = Addon:GetLocale()
local function debugp(...) Addon:Debug("staticlists", ...) end

local MESSAGETYPE = Addon.Systems.Chat.MessageType.Console

local DefaultLists = {
    NAME = "DefaultLists",
    VERSION = 1,
    DEPENDENCIES = {
        "system:lists"
    },
}

local lists = {}
function DefaultLists:AddList(listDef)
    table.insert(lists, listDef)
    debugp("Added list: "..tostring(listDef.Id))
end

function DefaultLists:SyncDefaultLists()

    for _, def in pairs(lists) do
        local existing = Addon:GetList(def.Id)

        if existing then
            -- Existing lists need to be sync'd for additions to the list
            -- since it was created. Users can add/remove from this list,
            -- so we must only add new items.
            local currentVersion = existing:GetVersion()
            if (type(currentVersion) ~= "number") or (currentVersion < def.Version) then
                debugp("Detected new version of default list "..existing:GetName())
                -- Update the existing list with all new values above the version.
                for itemId, version in pairs(def.Items) do
                    if version > currentVersion then
                        existing:Add(itemId)
                        debugp("Added item "..tostring(itemId).." to list "..existing:GetName())
                    end
                end

                existing:SetVersion(def.Version)
            else
                debugp("List "..existing:GetName().." is current.")
            end
        else
            -- New list
            -- Update version table
            local newList = Addon:CreateListStatic(def.Id, def.Version, L[def.Name], L[def.Desc])

            -- Items may not exist on the version of the game, so add each item, which
            -- will check if the item exists before adding.
            for itemId, _ in pairs(def.Items) do
                newList:Add(itemId)
            end

            debugp("Created default list: "..newList:GetName().."  Version: "..tostring(newList:GetVersion()))
        end
    end
end

function DefaultLists:ResetDefaultLists()
    for _, listId in pairs(lists) do
        local existing = Addon:GetList(Addon.StaticListId.IMPORTANT_ITEMS)
        if existing then
            local name = existing:GetName()
            debugp("Deleting list: "..name)
            Addon:DeleteList(listId)
            Addon:Output(MESSAGETYPE, L.CMD_LIST_RESET_COMPLETE, name)
        end
    end

    DefaultLists:SyncDefaultLists();
end

function DefaultLists.ListCommand(verb, arg1)
    if not verb or verb == "all" then
        -- Enumerate the lists
        Addon:Output(MESSAGETYPE, L.CMD_LIST_HEADER)
        for _, def in pairs(lists) do
            local list = Addon:GetList(def.Id)
            Addon:Output(MESSAGETYPE, L.CMD_LIST_ENUM, list:GetName(), list:GetVersion())
        end
    elseif verb == "reset" then
        DefaultLists:ResetDefaultLists(arg1)
    else
        -- Display the Help
        Addon:Output(MESSAGETYPE, L.CMD_LIST_USAGE)
    end
end

function DefaultLists:OnInitialize()
    self:SyncDefaultLists()
    Addon:AddConsoleCommand("list", L.CMD_DEFAULTLIST_HELP, DefaultLists.ListCommand)
end

function DefaultLists:OnTerminate()
end

Addon.Features.DefaultLists = DefaultLists