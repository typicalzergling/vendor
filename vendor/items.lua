-- Item helper functions

local AddonName, Addon = ...

function Addon:IsItemIdValid(itemid)
    if type(itemid) ~= "number" then return false end
    local item = CreateFromMixins(ItemMixin)
    item:SetItemID(itemid)
    return not item:IsItemEmpty()
end

-- Gets item ID from an itemstring or item link
-- If a number is passed in it assumes that is the ID
function Addon:GetItemIdFromString(str)
    -- extract the id
    if type(str) == "number" or tonumber(str) then
        return tonumber(str)
    elseif type(str) == "string" then
        return tonumber(string.match(str, "item:(%d+):"))
    else
        return nil
    end
end

-- Assumes link
function Addon:GetLinkFromString(link)
    if link and type(link) == "string" then
        local _, _, lstr = link:find('|H(.-)|h')
        return lstr
    else
        return nil
    end
end

-- Returns table of link properties
function Addon:GetLinkPropertiesFromString(link)
    local lstr = self:GetLinkFromString(link)
    if lstr then
        return {strsplit(':', lstr)}
    else
        return {}
    end
end