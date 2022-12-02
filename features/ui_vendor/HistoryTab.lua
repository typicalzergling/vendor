local _, Addon = ...
local L = Addon:GetLocale()
local Vendor = Addon.Features.Vendor
local HistoryTab = {}
local Colors = Addon.CommonUI.Colors
local ENABLED_FILTERS = "audit-filters"

function HistoryTab:OnLoad()
    self.history = Addon:GetFeature("History")
    self.items:Sort(function(a, b)
            return a.TimeStamp > b.TimeStamp
        end)

    for _, filter in ipairs(self.history:GetFilters()) do
        self.filters:AddChip(filter.Id, filter.Name, filter.Description)
    end
    Addon:RegisterCallback("OnHistoryChanged", self, self.OnHistoryChanged)
end

--[[ Rebuild when the history changes ]]
function HistoryTab:OnHistoryChanged()
    if not self:IsVisible() then return end
    Addon:Debug("history", "HistoryChanged, rebuilding UI")
    return self.items:Rebuild()
end

function HistoryTab:OnActivate()
    local profile = Addon:GetProfile()
    local filters = profile:GetValue(ENABLED_FILTERS)
    
    if (type(filters) ~= "table") then
        filters = { sold = true, destroy = true }
    end

    self.filters:SetSelected(filters)
    self.items:Filter(self.history:CreateFilter(filters))
    self.items:Rebuild()
end

function HistoryTab:OnDeactivate()
    local profile = Addon:GetProfile()
    profile:SetValue(ENABLED_FILTERS, self.filters:GetSelected())
end

--[[ Apply the filters to our view ]]
function HistoryTab:ApplyFilter()
    local filter = self.history:CreateFilter(self.filters:GetSelected())
    local keyword = self.search:GetText()
    if (type(keyword) == "string") and (string.len(keyword) ~= 0) then
        keyword = string.lower(keyword)
    end

    self.items:Filter(function(item)
            if (string.len(keyword) ~= 0) then
                if (not string.find(item.Keywords, keyword)) then
                    return false
                end
            end
            
            return filter(item)
        end)
end

--[[ Compute the total value of the view ]]
function HistoryTab:CalculateTotal(view)
    local totalValue = 0
    for _, item in ipairs(view) do
        totalValue = totalValue + (item.Value or 0)
    end
    self.total:SetText(Addon:GetPriceString(totalValue, true))
end

--[[ Retrieve the history item ]]
function HistoryTab:GetHistory()
    return self.history:GetCharacterHistoryEntries()
end

Vendor.MainDialog.HistoryTab = HistoryTab