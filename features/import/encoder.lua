local _, Addon = ...
local Encoder = {}

local BYTE_NUMBER_CODE = string.byte("n")
local BYTE_STRING_CODE = string.byte("s")
local BYTE_OPEN_TABLE = string.byte("+")
local BYTE_CLOSE_TABLE = string.byte("-")
local BYTE_SEPARATOR = string.byte("|")
local BYTE_TRUE = string.byte("t")
local BYTE_FALSE = string.byte("f")
local BYTE_EQUAL = string.byte("=")

local CHAR_EQUAL = "="
local CHAR_TRUE = "t"
local CHAR_FALSE = "f"
local CHAR_SEPARATOR = "|"
local CHAR_OPEN_TABLE = "+"
local CHAR_CLOSE_TABLE = "-"
local CHAR_NUMBER = "n"
local CHAR_STRING = "s"

local L_SHIFT_8 = math.pow(2, 8)
local L_SHIFT_6 = math.pow(2, 6)
local R_SHIFT_6 = math.pow(2, 6)
local R_SHIFT_8 = math.pow(2, 8)
local R_SHIFT_12 = math.pow(2, 12)
local R_SHIFT_16 = math.pow(2, 16)
local R_SHIFT_18 = math.pow(2, 18)

local BASE64_CHARS = {
    [0] = "A", [1] = "B", [2] = "C", [3] = "D", [4] = "E", [5] = "F", [6] = "G", [7] = "H", [8] = "I", [9] = "J",
    [10] = "K", [11] = "L", [12] = "M", [13] = "N", [14] = "O", [15] = "P", [16] = "Q", [17] = "R", [18] = "S", [19] = "T",
    [20] = "U", [21] = "V", [22] = "W", [23] = "X", [24] = "Y", [25] = "Z",
    [26] = "a", [27] = "b", [28] = "c", [29] = "d", [30] = "e", [31] = "f", [32] = "g", [33] = "h", [34] = "i", [35] = "j", 
    [36] = "k", [37] = "l", [38] = "m", [39] = "n", [40] = "o", [41] = "p", [42] = "q", [43] = "r", [44] = "s", [45] = "t",
    [46] = "u", [47] = "v", [48] = "w", [49] = "x", [50] = "y", [51] = "z", 
    [52] = "0", [53] = "1", [54] = "2", [55] = "3", [56] = "4", [57] = "5", [58] = "6", [59] = "7", [60] = "8", [61] = "9", [62] = "+", [63] = "/"
}

local BASE64_INV = {
    62, -1, -1, -1, 63, 52, 53, 54, 55, 56, 57, 58,
    59, 60, 61, -1, -1, -1, -1, -1, -1, -1, 0, 1, 2, 3, 4, 5,
    6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
    21, 22, 23, 24, 25, -1, -1, -1, -1, -1, -1, 26, 27, 28,
    29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,
    43, 44, 45, 46, 47, 48, 49, 50, 51 
}

--[[ (private) Given a LUA value this encoded is to a persitable string ]]
function Encoder.EncodeValue(value)
    if (type(value) == "boolean") then
        if  (value) then
            return CHAR_TRUE
        else
            return CHAR_FALSE
        end
    elseif (type(value) == "number") then
        return CHAR_NUMBER .. tostring(value) .. CHAR_SEPARATOR
    elseif (type(value) == "string") then
        return CHAR_STRING .. tostring(string.len(value)) .. CHAR_SEPARATOR .. value .. CHAR_SEPARATOR
    elseif (type(value) == "table") then
        local s = CHAR_OPEN_TABLE
        for name, tvalue in pairs(value) do
            assert(type(name) == "string" or type(name) == "number", "Only number and string keys are suppored got : " .. type(name))
            s = s .. Encoder.EncodeValue(name)
            s = s .. Encoder.EncodeValue(tvalue)
        end
        s = s .. CHAR_CLOSE_TABLE
        return s
    end
end

--[[ Read the next seperator, returns then ntext character after the seperator ]]
local function getNextPart(str, start)
    local next = string.find(str, CHAR_SEPARATOR, start, true)
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

    --print("nextValue:", next, type(next), nextEnd, str:sub(nextEnd, nextEnd + 10))
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

--[[ (private) Convert the given string to base64 ]]
function Encoder.EncodeBase64(str)
    local encoded = ""

    local i = 1
    local n = string.len(str)

    while (i <= n) do
        local v = (string.byte(str, i, i + 1) * L_SHIFT_8)

        if (i + 1 <= n) then
            v = v | string.byte(str, i + 1, i + 2)
        else
            v = v << 8
        end

        if (i + 2 <= n) then
            v = (v << 8) | string.byte(str, i + 2, i + 3)
        else
            v = (v << 8)
        end

        if (not BASE64_CHARS[(v / R_SHIFT_6) & 0x3f]) then
            print("v=", v, ((v / R_SHIFT_6) & 0x3f))
        end

        encoded = encoded .. BASE64_CHARS[(v / R_SHIFT_18) & 0x3f]
        encoded = encoded .. BASE64_CHARS[(v / R_SHIFT_12) & 0x3f]
        
        if (i + 1 <= n) then
            encoded = encoded .. BASE64_CHARS[(v / R_SHIFT_6) & 0x3f]
        else
            encoded = encoded .. "="
        end

        if (i + 2 <= n) then
            encoded = encoded .. BASE64_CHARS[v & 0x3f]
        else
            encoded = encoded .. "="
        end

        i = i + 3
    end

    return encoded
end

--@debug@
local function isValidChar(base64, i)
    local c = string.byte(base64, i, i + 1)

	if (c >= string.byte("0") and c <= string.byte("9")) then
		return true
    end

    if (c >= string.byte('A') and c <= string.byte('Z')) then
		return true;
    end

    if (c >= string.byte('a') and c <= string.byte('z')) then
		return true;
    end

	if (c == string.byte('+') or c == string.byte('/') or c == BYTE_EQUAL) then
		return true
    end
end
--@end-debug@

--[[ (private) Convert the given string from base64 ]]
function Encoder.DecodeBase64(base64)
    local n = string.len(base64)
    local str = ""
    local i = 1

    --@debug@
    for k = 1,n do
        assert(isValidChar(base64, k), "Received an invalid character '" .. base64:sub(k, k + 1) .. "' at " .. tostring(k))
    end
    --@end-debug@

    while (i < n) do
        local v = BASE64_INV[string.byte(base64, i, i + 1) - 42]
        v = (v * L_SHIFT_6) | BASE64_INV[string.byte(base64, i + 1, i + 2) - 42]
        
        local b2 = string.byte(base64, i + 2, i + 3)
        if (b2 == BYTE_EQUAL) then
            v = v * L_SHIFT_6
        else
            v = (v * L_SHIFT_6) | (BASE64_INV[b2 - 42])
        end

        local b3 = string.byte(base64, i + 3, i + 4)
        if (b3 == BYTE_EQUAL) then
            v = (v * L_SHIFT_6)
        else
            v = (v * L_SHIFT_6) | (BASE64_INV[b3 - 42])
        end

        str = str .. string.char((v / R_SHIFT_16) & 0xff)
        if (b2 ~= BYTE_EQUAL) then
            str = str .. string.char((v / R_SHIFT_8) & 0xff)
        end
        if (b3 ~= BYTE_EQUAL) then
            str = str .. string.char(v & 0xff)
        end
        i = i + 4
    end
    
    return str
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