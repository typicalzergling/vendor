local _, Addon = ...

local function AttCompletionPercentage()
    if not AllTheThings or not AllTheThings.GetCachedSearchResults then return 0 end
    local cacheResult = AllTheThings.GetCachedSearchResults(AllTheThings.SearchForLink, Link)
    if cacheResult then
        return cacheResult.total>0 and (cacheResult.progress/cacheResult.total) or 1;
    end
    return 0
end

local function registerATTExtension()
    local attExtension =
    {
        Source = "ATT",
        Addon = "AllTheThings",
        Version = 1.0,

        Functions =
        {
            {
                Name="CompletionPercentage",
                Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
                Function=AttCompletionPercentage,
                Documentation="Returns the same percentage of completion that is shown on tooltips (0 <= value <= 1)",
            },
        },

        Rules =
        {
            {
                Id = "attusable",
                Type = "Keep",
                Name = "ATT - I still need it",
                Supported={ Retail=true, Classic=false, RetailNext=true, ClassicNext=false },
                Description = "Checks if you are still under 100% for that item, and keep it",
                Script = "ATT_CompletionPercentage() < 1",
                Order = 1000,
            },
        },
    }

    local extmgr = Addon.Systems.ExtensionManager
    extmgr:AddInternalExtension("AllTheThings", attExtension)
end

registerATTExtension()