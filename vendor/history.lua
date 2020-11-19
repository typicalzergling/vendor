local _, Addon = ...
local L = Addon:GetLocale()

local debugp = function (...) Addon:Debug("history", ...) end


local VERSION = 1
local historyVariable = Addon.SavedVariable:new("History")

function Addon:ClearAllHistory()
    debugp("Clearing Entire History")
    historyVariable:Replace({})
    local history = historyVariable:GetOrCreate()
    history.Characters = {}
    history.Version = VERSION
end

function Addon:ClearCharacterHistory()
    debugp("Clearing History for character %s", Addon:GetCharacterFullName())
    local history = historyVariable:GetOrCreate()
    if history.Characters then
        history.Characters[Addon:GetCharacterFullName()] = nil
    end
end

local function getOrCreateCharacterHistory()
    local history = historyVariable:GetOrCreate()
    if not history.Characters then history.Characters = {} end
    local chars = history.Characters
    if not chars[Addon:GetCharacterFullName()] then
        chars[Addon:GetCharacterFullName()] = {}
        chars[Addon:GetCharacterFullName()].Entries = {}
    end
    return chars[Addon:GetCharacterFullName()]
end

function Addon:GetCharacterHistory()
    return getOrCreateCharacterHistory().Entries
end

function Addon:GetHistoryVersion()
    local history = historyVariable:GetOrCreate()
    if not history.Version then history.Version = VERSION end
    return history.Version
end

function Addon:AddEntryToHistory(link, action, rule, ruleid, count, value)
    local entry = {}
    entry.Profile = Addon:GetProfile():GetName()
    entry.TimeStamp = time()
    entry.Action = action
    entry.Link = link
    entry.Rule = rule
    entry.RuleId = ruleid
    entry.Count = count
    entry.Value = value
    debugp("Adding entry: [%s] %s (%s)", tostring(action), tostring(link), tostring(rule))
    local charHistory = getOrCreateCharacterHistory()
    table.insert(charHistory.Entries, entry)
end

function Addon:PruneHistory(hours, character)
    local seconds = hours * 3600

    local history = nil
    if character and character ~= Addon:GetCharacterFullName() then
        history = historyVariable:GetOrCreate().Characters[character]
    else
        character = Addon:GetCharacterFullName()
        history = getOrCreateCharacterHistory()
    end
    assert(history, "Error loading history for character "..tostring(character))
    
    -- Find entries to remove that are older than seconds
    local toremove = {}
    for key, entry in pairs(history.Entries) do
        if time() - entry.TimeStamp >= seconds then
            table.insert(toremove, key)
        end
    end

    -- Remove the old entries
    local count = 0
    for _, v in pairs(toremove) do
        debugp("Pruning %s history: removing entry %s: [%s] %s", character, tostring(v), history.Entries[v].TimeStamp, history.Entries[v].Link)
        history.Entries[v] = nil
        count = count + 1
    end
    Addon:Debug("historystats", "Pruned %s history entries from %s", tostring(count), character)
    return count
end

function Addon:PruneAllHistory(hours)
    local history = historyVariable:GetOrCreate()
    local total = 0
    for char, _ in pairs(history.Characters) do
        local count = Addon:PruneHistory(hours, char)
        total = total + count
    end
    Addon:Debug("historystats", "Pruned %s history entries across all characters.", tostring(total))
    return total
end

function Addon:History_Cmd(arg1, arg2, arg3)
    if arg1 == "clear" then
        if arg2 == "all" then
            Addon:Print(L.CMD_CLEAR_ALL_HISTORY)
            Addon:ClearAllHistory()
            return
        else
            Addon:Print(L.CMD_CLEAR_CHAR_HISTORY, Addon:GetCharacterFullName())
            Addon:ClearCharacterHistory()
            return
        end
    end

    if arg1 == "prune" then
        if not arg2 then
            Addon:Print(L.CMD_PRUNE_HISTORY_ARG)
            return
        end
        if arg3 == "all" then
            
            Addon:Print(L.CMD_PRUNE_ALL_HISTORY, arg2)
            local count = Addon:PruneAllHistory(tonumber(arg2))
            Addon:Print(L.CMD_PRUNE_SUMMARY, tostring(count))
            return
        else
            Addon:Print(L.CMD_PRUNE_CHAR_HISTORY, Addon:GetCharacterFullName(), arg2)
            local count = Addon:PruneHistory(tonumber(arg2))
            Addon:Print(L.CMD_PRUNE_SUMMARY, tostring(count))
            return
        end
    end

    local charsToPrint = {}
    local history = historyVariable:GetOrCreate()
    local totalsummary = false
    if arg1 == "all" then
        -- Add all characters to print list.
        for char, _ in pairs(history.Characters) do
            table.insert(charsToPrint, char)
        end
        totalsummary = true
    else
        -- Just current character only.
        table.insert(charsToPrint, Addon:GetCharacterFullName())
    end

    -- Print the current history for each character listed.
    local allcount = 0
    local allvalue = 0
    for _, char in pairs(charsToPrint) do
        Addon:Print(L.CMD_PRINT_HISTORY_HEADER, char)
        local count = 0
        local total = 0
        for _, entry in pairs(history.Characters[char].Entries) do
            count = count + 1
            total = total + entry.Value
            Addon:Print("  [%s] (%s) %s - %s", date('%c',tonumber(entry.TimeStamp)), tostring(entry.Action), tostring(entry.Link), Addon:GetPriceString(entry.Value))
        end
        allcount = allcount + count
        allvalue = allvalue + total
        Addon:Print(L.CMD_PRINT_HISTORY_SUMMARY, char, count, Addon:GetPriceString(total))
    end

    if totalsummary then
        Addon:Print(L.CMD_PRINT_HISTORY_SUMMARY_ALL, tostring(allcount), Addon:GetPriceString(allvalue))
    end
end
