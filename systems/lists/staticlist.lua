local _, Addon = ...

function Addon:SetupSpecialList()
    local mgr = Addon:GetExtensionManger()

    --[[
    if (not mgr:GetList("test.list")) then
	mgr:RegisterList({ 
		Name = 'Non-extension'
	}, {
		Name = "Ext. Test",
		Description = "Tooltip - Text",
		Items = function() return { 50349, 33470, 152494 } end,
		Id = "test.list",
	})
	end
    ]]
end


