-- Titan Plugin for Vendor
local AddonName, Addon = ...

if _G[AddonName] then
    error("Addon conflict detected. Addon already exists with this name: "..AddonName)
end
_G[AddonName] = Addon

Addon.id = "VendorTitan"
Addon.addon = AddonName
Addon.button_label = "Vendor: "
Addon.menu_text = "Vendor"
Addon.tooltip_header = "Vendor test"
Addon.tooltip_hint_1 = "HINT: clicky"
Addon.menu_option = "Options"
Addon.menu_hide = "Hide"
Addon.version = "1.0"
Addon.author = "Fuckoff"

function Addon:Load()
    self.registry =
    {
        id = "VendorTitan",
        version = "1.0",
        category = "General",
        menuText = "Vendor",
        buttonTextFunction = "VendorTitan_GetButtonText",
        tooltipTitle = "Vendor",
        tooltipTextFunction = "VendorTitan_GetTooltipText",
        icon = nil,
        iconWidth = 16,
        savedVariables =
        {
            -- Titan required
            ShowIcon = 1,
            ShowLabelText = 1,
            ShowColoredText = 1,
        },
    }

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

local sellCount = 0
local function updateSellCount()
    sellCount = Vendor.GetSellCount()
    TitanPanelButton_UpdateButton(Addon.id);
end

function Addon:OnEvent(event, ...)
    if (event == "PLAYER_ENTERING_WORLD") then
        self:RegisterEvent("BAG_UPDATE")
        updateSellCount()
        return
    end
    
    if (event == "BAG_UPDATE") then
        updateSellCount()
        return
    end
end

-- Left click will call Vendor's menu toggle. Right click opens the menu.
function Addon:OnClick(button)
    if (button == "LeftButton") then
        -- Open Vendor Menu
        VendorRulesDialog:Toggle()
    end
end

function VendorTitan_GetButtonText(id)
	--local button, id = TitanUtils_GetButton(id, true);
	-- SDK : "TitanUtils_GetButton" is used to get a reference to the button Titan created.
	--       The reference is not needed by this example.

	return "Vendor: " .. tostring(sellCount)
end


function VendorTitan_GetTooltipText()
    return "Vendor Tooltip Test"
end

function TitanPanelRightClickMenu_PrepareVendorTitanMenu()
    -- Titan Menu
    local info
	
	-- level 1 menu
	if L_UIDROPDOWNMENU_MENU_LEVEL == 1 then
		TitanPanelRightClickMenu_AddTitle(TitanPlugins[Addon.registry.id].menuText);
		 
		info = {};
		info.text = "Options v1"
		info.value = "Options"
		info.hasArrow = 1;
		L_UIDropDownMenu_AddButton(info);

		TitanPanelRightClickMenu_AddSpacer();     
		-- SDK : "TitanPanelRightClickMenu_AddSpacer" is used to put a blank line in the menu
		TitanPanelRightClickMenu_AddToggleLabelText(Addon.registry.id);
		-- SDK : "TitanPanelRightClickMenu_AddToggleLabelText" is used to put a "Show label text" (localized) in the menu.
		--        registry.savedVariables.ShowLabelText
		TitanPanelRightClickMenu_AddToggleColoredText(Addon.registry.id);
		-- SDK : "TitanPanelRightClickMenu_AddToggleLabelText" is used to put a "Show colored text" (localized) in the menu.
		--        registry.savedVariables.ShowColoredText
		TitanPanelRightClickMenu_AddSpacer();     
		TitanPanelRightClickMenu_AddCommand("Hide", Addon.registry.id, TITAN_PANEL_MENU_FUNC_HIDE);
		-- SDK : The routine above is used to put a "Hide" (localized) in the menu.
	end
end

-- Vendor Extension for callback when rules change.
-- This will register a callback to Ark with Vendor
local function registerTitanExtension()
    local titanExtension =
    {
        -- Vendor will check this source is loaded prior to registration.
        -- It will also be displayed in the Vendor UI.
        Source = "VendorTitan",
        Addon = AddonName,

        -- This is called by Vendor whenever its rules change
        OnRuleUpdate = function()
            updateSellCount()
        end
    }

    assert(Vendor and Vendor.RegisterExtension, "Vendor RegisterExtension not found, cannot register extension: "..tostring(titanExtension.Source))
    if (not Vendor.RegisterExtension(titanExtension)) then
        -- something went wrong
    end
end
registerTitanExtension()


