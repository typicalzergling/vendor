local _, Addon = ...
local L = Addon:GetLocale()
local debugp = function (...) Addon:Debug("history", ...) end

local VERSION = 1
local historyVariable = Addon.SavedVariable:new("History")
Addon.OnHistoryChanged = Addon.CreateEvent("History.OnChanged")

-- Called whenever a history entry is added, or history is pruned / cleared.
function Addon:HistoryUpdated()
    Addon.OnHistoryChanged()
end

-- Root history variable tracks Version, Rules, and Profiles
-- Rules and Profiles are lookup tables to save space for each entry.
function Addon:ClearAllHistory()
    debugp("Clearing Entire History")
    historyVariable:Replace({})
    local history = historyVariable:GetOrCreate()
    history.Characters = {}
    history.Version = VERSION
    history.Rules = {}
    history.Profiles = {}
    Addon.Invoke(Addon, "HistoryUpdated")
end

function Addon:ClearCharacterHistory()
    debugp("Clearing History for character %s", Addon:GetCharacterFullName())
    local history = historyVariable:GetOrCreate()
    if history.Characters then
        history.Characters[Addon:GetCharacterFullName()] = nil
    end
    Addon.Invoke(Addon, "HistoryUpdated")
end

local function getOrCreateCharacterHistory()
    local history = historyVariable:GetOrCreate()
    local key = Addon:GetCharacterFullName()
    if (not key) then
        return {}
    end
    if not history.Characters then history.Characters = {} end
    local chars = history.Characters
    if not Addon:GetCharacterFullName() then return nil end
    if not chars[key] then
        chars[key] = {}
        chars[key].Entries = {}
        chars[key].Window = time()
    end
    return chars[key]
end

-- Returns the table of entries and the time window covering those entries.
function Addon:GetCharacterHistory()
    local charHistory = getOrCreateCharacterHistory()
    if not charHistory then return nil end
    return charHistory.Entries, charHistory.Window
end

function Addon:GetHistoryVersion()
    local history = historyVariable:GetOrCreate()
    if not history.Version then history.Version = VERSION end
    return history.Version
end


-- We're optimizing for space here and performance on lookup, not on insert
-- So we will take a little more computation to input the data, but the storage
-- size will be small and the lookup will be fast
local function getOrCreateRuleId(ruleid, rule)
    -- Create the table and data if doesn't exist.
    local history = historyVariable:GetOrCreate()
    if not history.Rules then history.Rules = {} end

    -- find our ruleid in the list - these should be unique (with close enough certainty for us to not care)
    for k, v in pairs(history.Rules) do
        if v.Id == ruleid then
            return k
        end
    end

    -- No match, do insert.
    local entry = {}
    entry.Id = ruleid
    entry.Name = rule or L.UNKNOWN
    table.insert(history.Rules, entry)

    -- Now need to find what index insert used since list isn't ordered.
    for k, v in pairs(history.Rules) do
        if v.Id == ruleid then
            return k
        end
    end
    error("Failed creating history entry rule id")
end

-- As above, optimized for storage and lookup, not insert.
local function getOrCreateProfileId()
    -- Create the table and data if doesn't exist.
    local history = historyVariable:GetOrCreate()
    if not history.Profiles then history.Profiles = {} end

    -- find our ruleid in the list - these should be unique (with close enough certainty for us to not care)
    for k, v in pairs(history.Profiles) do
        if v.Id == Addon:GetProfile():GetId() then
            return k
        end
    end

    -- No match, do insert.
    local entry = {}
    entry.Id = Addon:GetProfile():GetId()
    entry.Name = Addon:GetProfile():GetName()
    table.insert(history.Profiles, entry)

    -- Now need to find what index insert used since list isn't ordered.
    for k, v in pairs(history.Profiles) do
        if v.Id == Addon:GetProfile():GetId() then
            return k
        end
    end
    error("Failed creating history entry profile id")
end

function Addon:AddEntryToHistory(link, action, rule, ruleid, count, value)
    local entry = {}
    entry.TimeStamp = time()
    entry.Action = action
    entry.Id = Addon:GetItemIdFromString(link)
    entry.Count = count
    entry.Value = value
    entry.Profile = getOrCreateProfileId()
    entry.Rule = getOrCreateRuleId(ruleid, rule)

    debugp("Adding entry: [%s] %s (%s)", action, link, rule)
    local charHistory = getOrCreateCharacterHistory()
    table.insert(charHistory.Entries, entry)
    Addon.Invoke(Addon, "HistoryUpdated")
end

local currentChar = nil
function Addon:PruneHistory(hours, character)
    local seconds = hours * 3600

    local history = nil
    if not currentChar then
        local status, err = xpcall(
            function()
                currentChar = Addon:GetCharacterFullName()
            end,
            CallErrorHandler)
        if status then
            debugp("Error getting Character Full Name, skipping pruning of this character.")
            return 0
        end
    end
    if character and currentChar ~= character then
        history = historyVariable:GetOrCreate().Characters[character]
    else
        character = currentChar
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
        debugp("Pruning %s history: removing entry %s: [%s] %s", character, v, history.Entries[v].TimeStamp, history.Entries[v].Id)
        history.Entries[v] = nil
        count = count + 1
    end

    -- Set the new history window to this set of hours
    history.Window = time() - seconds
    Addon:Debug("historystats", "Pruned %s history entries from %s", count, character)
    return count
end

function Addon:PruneAllHistory(hours)
    local history = historyVariable:GetOrCreate()
    local total = 0
    if history.Characters then
        for char, _ in pairs(history.Characters) do
            local count = Addon:PruneHistory(hours, char)
            total = total + count
        end
    end

    -- Prune the lookup tables when we are done.
    Addon:PruneHistoryLookupTables()

    Addon:Debug("historystats", "Pruned %s history entries across all characters.", total)
    Addon.Invoke(Addon, "HistoryUpdated")
    return total
end

local function isLookupIdInUse(index, name)
    local history = historyVariable:GetOrCreate()
    local total = 0
    if history.Characters then
        for char, _ in pairs(history.Characters) do
            if history.Characters[char] and history.Characters[char].Entries then
                for _, entry in pairs(history.Characters[char].Entries) do
                    if entry[name] == index then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Loops through all lookup tables and sees if any are in use
-- anywhere in the history
function Addon:PruneHistoryLookupTables()
    local history = historyVariable:GetOrCreate()
    if history.Rules then
        local toremove = {}
        for k, _ in pairs(history.Rules) do
            -- See if this rule id appears anywhere in the history
            if not isLookupIdInUse(k, "Rule") then
                table.insert(toremove, k)
            end
        end
        for _, v in pairs(toremove) do
            debugp("Removing unused Rule lookup %s - %s", v, history.Rules[v].Id)
            history.Rules[v] = nil
        end
    end

    if history.Profiles then
        local toremove = {}
        for k, _ in pairs(history.Profiles) do
            -- See if this rule id appears anywhere in the history
            if not isLookupIdInUse(k, "Profile") then
                table.insert(toremove, k)
            end
        end
        for _, v in pairs(toremove) do
            debugp("Removing unused Profile lookup %s - %s", v, history.Profiles[v].Id)
            history.Profiles[v] = nil
        end
    end
end

function Addon:GetActionTypeFromId(id)
    for k, v in pairs(Addon.ActionType) do
        if v == id then
            return k
        end
    end
    return L.UNKNOWN
end

function Addon:GetRuleInfoFromHistoryId(id)
    local history = historyVariable:GetOrCreate()
    if history.Rules and history.Rules[id] then
        return history.Rules[id].Id, history.Rules[id].Name
    end
    return tostring(id), L.UNKNOWN
end

function Addon:GetProfileInfoFromHistoryId(id)
    local history = historyVariable:GetOrCreate()
    if history.Profiles and history.Profiles[id] then
        return history.Profiles[id].Id, history.Profiles[id].Name
    end
    return tostring(id), L.UNKNOWN
end

-- Stats tracked:
-- Total items sold
-- Total items destroyed
-- Total items sold or destroyed
-- Total gold from vendoring
-- Time window for this information
function Addon:GetCharacterHistoryStats()
    local stats = {}
    stats.sold = 0
    stats.destroyed = 0
    stats.value = 0
    stats.oldestTimestamp = time()

    local entries, timeWindow = Addon:GetCharacterHistory()
    for _, entry in pairs(entries) do

        -- Action type
        if entry.Action == Addon.ActionType.SELL then
            stats.sold = stats.sold + 1
            stats.value = stats.value + entry.Value
        elseif entry.Action == Addon.ActionType.DESTROY then
            stats.destroyed = stats.destroyed + 1
        end

        -- Find oldest entry
        if entry.TimeStamp < stats.oldestTimestamp then
            stats.oldestTimestamp = entry.TimeStamp
        end
    end

    stats.count = stats.sold + stats.destroyed
    return stats.count, stats.value, stats.sold, stats.destroyed, stats.oldestTimestamp
end

function Addon:History_Cmd(arg1, arg2, arg3)
    if arg1 == "clear" then
        if arg2 == "all" then
            Addon:Print(L.CMD_CLEAR_ALL_HISTORY)
            Addon:ClearAllHistory()
            return
        else
            Addon:Print(L.CMD_CLEAR_CHAR_HISTORY, Addon:GetCharacterFullName() or "")
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
            Addon:Print(L.CMD_PRUNE_CHAR_HISTORY, Addon:GetCharacterFullName() or "", arg2)
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
        if history.Characters then
            for char, _ in pairs(history.Characters) do
                table.insert(charsToPrint, char)
            end
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
        if history.Characters and history.Characters[char] and history.Characters[char].Entries then
            for _, entry in pairs(history.Characters[char].Entries) do
                count = count + 1
                total = total + entry.Value
                local _, display = GetItemInfo(entry.Id)
                if not display then display = entry.Id end
                local ruleid, rule = Addon:GetRuleInfoFromHistoryId(entry.Rule)
                local profileid, profile = Addon:GetProfileInfoFromHistoryId(entry.Profile)
                local debugextra = ""
                if Addon.IsDebug then
                    debugextra = string.format(" {%s | %s}", ruleid, profile)
                end
                Addon:Print("  [%s] (%s) %s - %s %s",
                    date(L.CMD_HISTORY_DATEFORMAT,tonumber(entry.TimeStamp)),
                    Addon:GetActionTypeFromId(entry.Action),
                    display,
                    Addon:GetPriceString(entry.Value),
                    debugextra)
            end
            allcount = allcount + count
            allvalue = allvalue + total
            Addon:Print(L.CMD_PRINT_HISTORY_SUMMARY, char, count, Addon:GetPriceString(total))
        end
    end

    if totalsummary then
        Addon:Print(L.CMD_PRINT_HISTORY_SUMMARY_ALL, tostring(allcount), Addon:GetPriceString(allvalue))
    end
end
