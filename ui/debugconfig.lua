-- This is exclusively for the debug options panel and Debug-specific commands that do not appear in a normal build.
-- This entire file is excluded from packaging and it is not localized intentionally.

Vendor.debugconfig = {
    name = "Debug",
    handler = Vendor,
    type = 'group',
    args = {
        -- CORE
        debug = {
            name = "Debug Mode",
            desc = "Toggles Debug Mode. Enables generic debugging settings and behaviors.",
            type = 'toggle',
            set = function(info,val) info.handler.db.profile.debug = val end,
            get = function(info) return info.handler.db.profile.debug end,
            order = 10,
        },
        debugrules = {
            name = "Rule Debugging",
            desc = "Toggles debugging mode for rules This will output LOTS of messages to console.",
            type = 'toggle',
            set = function(info,val) info.handler.db.profile.debugrules = val end,
            get = function(info) return info.handler.db.profile.debugrules end,
            order = 10,
        },
        link = {
            name = "Dump Link",
            guiHidden = true,
            cmdHidden = false,
            type = 'execute',       
            func = 'DumpLink_Cmd',
        },
        test = {
            name = 'Test Function',
            desc = "Runs the test function! It could do anything! Or nothing. Or break the addon. Use at own risk.",
            guiHidden = true,
            cmdHidden = false,
            type = 'execute',
            func = 'Test_Cmd',
        },
    },
}

-- Debug Commands

function Vendor:DumpLink_Cmd(info)
    local _, arg = info.input:match("([^%s]+)%s+([^%s].*)")
    self:Print("Link: "..tostring(arg))
    self:Print("Raw: "..gsub(arg, "\124", "\124\124"))
    self:Print("ItemString: "..tostring(self:GetLinkString(arg)))
    local props = self:GetLinkProperties(arg)
    for i, v in pairs(props) do
        self:Print("["..tostring(i).."] "..tostring(v)) 
    end
    self:Print("ItemInfo:")
    local itemInfo = {GetItemInfo(tostring(arg))}
    for i, v in pairs(itemInfo) do
        self:Print("["..tostring(i).."] "..tostring(v)) 
    end
end

function Vendor:Test_Cmd(info)
    -- split arg from command line
    local _, arg = info.input:match("([^%s]+)%s+([^%s].*)")

    local iteminfo = self:GetAllBagItemInformation()
    for k, item in pairs(iteminfo) do
        local v = item.Properties
        self:Print(string.format("Item %s [%s] %s - %s (%s) / %s (%s)  Xpac=%s", tostring(v.Link), tostring(v.Level),tostring(v.Quality), tostring(v.Type), tostring(v.TypeId), tostring(v.SubType), tostring(v.SubTypeId), tostring(v.ExpansionPackId)))
        self:Print(string.format("   SB=%s BOE=%s BOU=%s AP=%s XMOG=%s Value=%s", tostring(v.IsSoulbound), tostring(v.IsBindOnEquip), tostring(v.IsBindOnUse), tostring(v.IsArtifactPower), tostring(v.IsUnknownAppearance), tostring(v.UnitValue)))
    end
end

function Vendor:GetAllBagItemInformation()
    local items = {}
    for bag=0, NUM_BAG_SLOTS do
        for slot=1, GetContainerNumSlots(bag) do            
            local item = self:GetBagItemFromCache(bag, slot)
            if item then
                table.insert(items, item)
            end
        end
    end

    self:Print("Items count: "..tostring(self:TableSize(items)));
    return items
end

