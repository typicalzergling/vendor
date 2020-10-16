-- Titan Plugin for Vendor
local AddonName, Addon = ...
local L = Addon:GetLocale()

if _G[AddonName] then
    error("Addon conflict detected. Addon already exists with this name: "..AddonName)
end
_G[AddonName] = Addon

Addon.id = "VendorTitan"
Addon.addon = AddonName
Addon.button_label = L["TITAN_BUTTON_LABEL"]
Addon.version = GetAddOnMetadata(AddonName, "Version")
Addon.author = GetAddOnMetadata(AddonName, "Author")

Addon.IsClassic = (WOW_PROJECT_ID  == WOW_PROJECT_CLASSIC)

function Addon:Load()
    self.registry =
    {
        id = Addon.id,
        version = Addon.version,
        category = "General",
        menuText = L["TITAN_MENU_TEXT"],
        buttonTextFunction = "VendorTitan_GetButtonText",
        tooltipTitle = L["TITAN_TOOLTIP_TITLE"],
        tooltipTextFunction = "VendorTitan_GetTooltipText",
        iconWidth = 16,
        savedVariables =
        {
            ShowValueText = true,

            -- Titan required
            ShowIcon = 1,
            ShowLabelText = 1,
            ShowColoredText = 1,
        },
    }

    -- Retail icon doesn't exist on classic
    if Addon.IsClassic then
        self.registry.icon = "Interface\\Icons\\INV_Misc_Coin_04"
    else
        self.registry.icon = "Interface\\Icons\\Achievement_Boss_Zuldazar_TreasureGolem"
    end

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

local totalCount = 0
local sellValue = 0
local sellCount = 0
local deleteCount = 0
local totalCountStr = ""
local sellCountStr = ""
local sellValueStr = ""
local deleteCountStr = ""
local function updateStats()
    totalCount, sellValue, sellCount, deleteCount = Vendor.GetStats()

    if totalCount > 0 then
        totalCountStr = TitanUtils_GetColoredText(tostring(totalCount), BATTLENET_FONT_COLOR)
    else
        totalCountStr = TitanUtils_GetColoredText(tostring(totalCount), HIGHLIGHT_FONT_COLOR)
    end

    if sellCount > 0 then
        sellCountStr = TitanUtils_GetColoredText(tostring(sellCount), GREEN_FONT_COLOR)
    else
        sellCountStr = TitanUtils_GetColoredText(tostring(sellCount), NORMAL_FONT_COLOR)
    end

    if deleteCount > 0 then
        deleteCountStr = TitanUtils_GetColoredText(tostring(deleteCount), ORANGE_FONT_COLOR)
    else
        deleteCountStr = TitanUtils_GetColoredText(tostring(deleteCount), NORMAL_FONT_COLOR)
    end
    sellValueStr = Vendor.GetPriceString(sellValue)

    TitanPanelButton_UpdateButton(Addon.id);
end

function Addon:OnEvent(event, ...)
    if (event == "PLAYER_ENTERING_WORLD") then
        self:RegisterEvent("BAG_UPDATE")
        updateStats()
        return
    end
    
    if (event == "BAG_UPDATE") then
        updateStats()
        return
    end
end

-- Left click will call Vendor's menu toggle. Right click opens the menu.
function Addon:OnClick(button)
    if (button == "LeftButton") then
        -- Open Vendor Menu
        Vendor.ShowRules()
    end
end

function VendorTitan_GetButtonText(id)
    local out = ""

    if totalCount > 0 then
        out = out..TitanUtils_GetColoredText(tostring(totalCount), BATTLENET_FONT_COLOR)
    else
        out = out..TitanUtils_GetColoredText(tostring(totalCount), HIGHLIGHT_FONT_COLOR)
    end
    
    if TitanGetVar(Addon.id, "ShowValueText") then
        out = out..TitanUtils_GetHighlightText("  ")..sellValueStr
    end

    return Addon.button_label, out
end


function VendorTitan_GetTooltipText()
    local out = ""
    out = out.."\n"..TitanUtils_GetGoldText(L["TITAN_TOOLTIP_ITEMEVALUATION"])
    out = out.."\n"..TitanUtils_GetHighlightText(L["TITAN_TOOLTIP_TOSELL"]).."\t"..sellCountStr
    out = out.."\n"..TitanUtils_GetHighlightText(L["TITAN_TOOLTIP_TODELETE"]).."\t"..deleteCountStr
    out = out.."\n\n"..TitanUtils_GetGoldText(L["TITAN_TOOLTIP_VALUE"]).."\t"..sellValueStr
    return out
end

function TitanPanelRightClickMenu_PrepareVendorTitanMenu()
    -- Titan Menu
    local info
    
    if L_UIDROPDOWNMENU_MENU_LEVEL == 2 then
		return 
	end

	-- level 1 menu
	if L_UIDROPDOWNMENU_MENU_LEVEL == 1 then
		TitanPanelRightClickMenu_AddTitle(TitanPlugins[Addon.id].menuText);
         

        -- Rules Menu
		info = {};
        info.text = L["TITAN_MENU_RULES"]
        info.notCheckable = true
        info.func = function () Vendor.ShowRules() end
        L_UIDropDownMenu_AddButton(info);
        

        -- Settings Button
		info = {};
        info.text = L["TITAN_MENU_SETTINGS"]
        info.notCheckable = true
        info.func = function () Vendor.ShowSettings() end
        L_UIDropDownMenu_AddButton(info);
        
        -- Keybinds Button
		info = {};
        info.text = L["TITAN_MENU_KEYBINDINGS"]
        info.notCheckable = true
        info.func = function () Vendor.ShowKeybindings() end
        L_UIDropDownMenu_AddButton(info);
        
        -- Default Titan options
        TitanPanelRightClickMenu_AddSpacer();     
        TitanPanelRightClickMenu_AddToggleIcon(Addon.id);
		TitanPanelRightClickMenu_AddToggleLabelText(Addon.id);
        TitanPanelRightClickMenu_AddToggleColoredText(Addon.id);

        -- Button to hide the money string
		--[[info = {};
        info.text = "Show Value Text"
        info.checked = TitanGetVar(Addon.id, "ShowValueText")
        info.keepShownOnClick = true
        info.func = function ()
            TitanToggleVar(Addon.id, "ShowValueText")
            TitanPanelButton_UpdateButton(Addon.id)
        end
        L_UIDropDownMenu_AddButton(info);]]

        TitanPanelRightClickMenu_AddToggleVar(L["TITAN_MENU_SHOWVALUETEXT"], Addon.id, "ShowValueText", nil, L_UIDROPDOWNMENU_MENU_LEVEL)

		TitanPanelRightClickMenu_AddSpacer();     
		TitanPanelRightClickMenu_AddCommand(L["TITAN_MENU_HIDE"], Addon.id, TITAN_PANEL_MENU_FUNC_HIDE);
		-- SDK : The routine above is used to put a "Hide" (localized) in the menu.
	end
end

-- Vendor Extension for callback when rules change.
local function registerTitanExtension()
    local titanExtension =
    {
        -- Vendor will check this source is loaded prior to registration.
        -- It will also be displayed in the Vendor UI.
        Source = "VendorTitan",
        Addon = AddonName,

        -- This is called by Vendor whenever its rules change
        OnRuleUpdate = function()
            updateStats()
        end
    }

    assert(Vendor and Vendor.RegisterExtension, "Vendor RegisterExtension not found, cannot register extension: "..tostring(titanExtension.Source))
    if (not Vendor.RegisterExtension(titanExtension)) then
        error("Error registering "..AddonName.." with Vendor")
    end
end
registerTitanExtension()


