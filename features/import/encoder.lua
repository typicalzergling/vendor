local _, Addon = ...
local Encoder = {}

local BYTE_NUMBER_CODE = string.byte("n")
local BYTE_STRING_CODE = string.byte("s")
local BYTE_OPEN_TABLE = string.byte("+")
local BYTE_CLOSE_TABLE = string.byte("-")
local BYTE_SEPARATOR = string.byte(";")
local BYTE_TRUE = string.byte("t")
local BYTE_FALSE = string.byte("f")
local BYTE_EQUAL = string.byte("=")

local BASE64_CHARS = {
    [0] = "A", [1] = "B", [2] = "C", [3] = "D", [4] = "E", [5] = "F", [6] = "G", [7] = "H", [8] = "I", [9] = "J",
    [10] = "K", [11] = "L", [12] = "M", [13] = "N", [14] = "O", [15] = "P", [16] = "Q", [17] = "R", [18] = "S", [19] = "T",
    [20] = "U", [21] = "V", [22] = "W", [23] = "X", [24] = "Y", [25] = "Z",
    [26] = "a", [27] = "b", [28] = "c", [29] = "d", [30] = "e", [31] = "f", [32] = "g", [33] = "h", [34] = "i", [35] = "j", 
    [36] = "k", [37] = "l", [38] = "m", [39] = "n", [40] = "o", [41] = "p", [42] = "q", [43] = "r", [44] = "s", [45] = "t",
    [46] = "u", [47] = "v", [48] = "w", [49] = "x", [50] = "y", [51] = "z",
    [52] = "0", [53] = "1", [54] = "2", [55] = "3", [56] = "4", [57] = "5", [58] = "6", [59] = "7", [60] = "8", [61] = "9", [62] = "+", [63] = "/"
}

local BASE64_PADDING = {
    [0] = "",
    [1] = "==",
    [2] = "=",
 }

--[[ (private) Given a LUA value this encoded is to a persitable string ]]
function Encoder.EncodeValue(value)
    if (type(value) == "boolean") then
        if  (value) then
            return "t"
        else
            return "f"
        end
    elseif (type(value) == "number") then
        return string.format("n%d;", value)
    elseif (type(value) == "string") then
        return string.format("s%d;%s;", string.len(value), value)
    elseif (type(value) == "table") then
        local s = "+"
        for name, tvalue in pairs(value) do
            assert(value ~= nil, "Cannot encode nil values")
            assert(type(name) == "string" or type(name) == "number", "Only number and string keys are suppored got : " .. type(name))
            s = s .. Encoder.EncodeValue(name) .. Encoder.EncodeValue(tvalue)
        end
        s = s .. "-"
        return s
    end
end

--[[ Read the next seperator, returns then ntext character after the seperator ]]
local function getNextPart(str, start)
    local next = string.find(str, ";", start, true)
    if (next) then
        return string.sub(str, start, next - 1), next
    end
    return string.sub(str, start), string.len(str) + 1
end

--[[ Extracts the next value from the given string starting at start ]]
function Encoder.NextValue(str, start)
    local next
    local nextEnd = start

    local code = string.byte(str, start, start + 1)
    if (code == nil) then
        return nil, nil
    end

    if (code == BYTE_TRUE) then
        next = true
        nextEnd = start + 1
    elseif (code == BYTE_FALSE) then
        next = false
        nextEnd = start + 1
    elseif (code == BYTE_NUMBER_CODE) then
        next, nextEnd = getNextPart(str, start + 1)
        next = tonumber(next)
    elseif (code == BYTE_STRING_CODE) then
        local len, lenEnd = getNextPart(str, start + 1)
        len = tonumber(len)
        next = string.sub(str, lenEnd + 1, lenEnd + len)
        nextEnd = lenEnd + len + 1
    elseif (code == BYTE_OPEN_TABLE) then
        next, nextEnd = Encoder.DecodeTable(str, start)
    end

    if (string.byte(str, nextEnd, nextEnd + 1) == BYTE_SEPARATOR) then
        nextEnd = nextEnd + 1
    end

    return next, nextEnd
end

--[[ (private) Decodes a table from the specified string ]]
function Encoder.DecodeTable(str, start)
    local table = {}

    local code = string.byte(str, start, start + 1)
    assert(code == BYTE_OPEN_TABLE, "Expected an open table but '" .. string.char(code) .. "' instead")
    start = start + 1

    while (code ~= 0 and code ~= BYTE_CLOSE_TABLE) do
        local key, keyEnd = Encoder.NextValue(str, start)
        local value, valueEnd = Encoder.NextValue(str, keyEnd)
        rawset(table, key, value)

        start = valueEnd
        code = string.byte(str, start, start + 1)
    end

    return table, start + 1
end

local decodingTable

--[[ Retrieve/Generate the decoding table ]]
local function getDecodingTable()
    if (not decodingTable) then
        decodingTable = {}

        for i=0,63 do
            decodingTable[string.byte(BASE64_CHARS[i])] = i
        end

        C_Timer.After(120, function()
                decodingTable = nil
            end)
    end

    return decodingTable
end


--[[ (private) Convert the given string to base64 ]]
function Encoder.EncodeBase64(str)
    local encoded = ""
    local i = 1
    local n = string.len(str)

    while (i <= n) do
        local b1, b2, b3 = string.byte(str, i, i + 3)
        local octets = bit.lshift(b1 or 0, 0x10) + bit.lshift(b2 or 0, 0x08) + (b3 or 0)

        encoded = encoded .. BASE64_CHARS[bit.band(bit.rshift(octets, 18), 0x3f)]
        encoded = encoded .. BASE64_CHARS[bit.band(bit.rshift(octets, 12), 0x3f)]
        encoded = encoded .. BASE64_CHARS[bit.band(bit.rshift(octets, 6), 0x3f)]
        encoded = encoded .. BASE64_CHARS[bit.band(octets, 0x3f)]

        i = i + 3
    end

    local en = 4 * ((n + 2) / 3)
    local padding = BASE64_PADDING[n % 3]
    encoded = string.sub(encoded, 1, en - string.len(padding)) .. padding
    return encoded
end

local function isValidChar(ch)
    local A, Z = string.byte("AZ", 1, 2)
    if (ch >= A and ch <= Z) then
        return true
    end

    local a, z = string.byte("az", 1, 2)
    if (ch >= a and ch <= z) then
        return true
    end

    local _0, _9 = string.byte("09", 1, 2)
    if (ch >= _0 and ch <= _9) then
        return true
    end

    ch = string.char(ch)
    if (ch == "=" or ch == "/" or ch == "+") then
        return true
    end

    return false
end

--[[ Verify the base64 string only contains acceptable characters ]]
function Encoder.VerifyString(base64)
    -- Must be a string
    if (type(base64) ~= "string") then
        return false
    end

    -- Must be non-empty
    base64 = Addon.StringTrim(base64)
    if (string.len(base64) == 0) then
        return false
    end

    -- Must be divisble by 4
    if (string.len(base64) % 4 ~= 0) then
        return false
    end

    -- This is not effecient but it isn't a common operation
    for i = 1,string.len(base64) do
        if (not isValidChar(string.byte(base64, i, i+1))) then
            return false
        end
    end

    return true
end

--[[ (private) Convert the given string from base64 ]]
function Encoder.DecodeBase64(base64)
    local decoding = getDecodingTable()
    local n = string.len(base64)
    local o = (n / 4 * 3)
    local decoded = ""
    local i = 1
    local j = 1

    while (i < n) do
        local b1, b2, b3, b4 = string.byte(base64, i, i + 4)

        if (b1 ~= nil and b1 ~= BYTE_EQUAL) then b1 = decoding[b1] else b1 = 0 end
        if (b2 ~= nil and b2 ~= BYTE_EQUAL) then b2 = decoding[b2] else b2 = 0 end
        if (b3 ~= nil and b3 ~= BYTE_EQUAL) then b3 = decoding[b3] else b3 = 0 end
        if (b4 ~= nil and b4 ~= BYTE_EQUAL) then b4 = decoding[b4] else b4 = 0 end

        local octets = bit.lshift(b1, 18) + bit.lshift(b2, 12) + bit.lshift(b3, 6) + b4
        if (j <= o) then
            decoded = decoded .. string.char(bit.band(bit.rshift(octets, 16), 0xff))
        end
        if (j + 1 <= o) then
            decoded = decoded .. string.char(bit.band(bit.rshift(octets, 8), 0xff))
        end
        if (j + 2 <= o) then
            decoded = decoded .. string.char(bit.band(octets, 0xff))
        end

        i = i + 4
        j = j + 3
    end

    return decoded
end

--[[ (public) Encode the provided value ]]
function Encoder.Encode(value)
    return Encoder.EncodeBase64(Encoder.EncodeValue(value))
end

--[[ (public) Decode the provided value ]]
function Encoder.Decode(value)
    return Encoder.NextValue(Encoder.DecodeBase64(value), 1)
end

Addon.Features.Import.Encoder = Encoder