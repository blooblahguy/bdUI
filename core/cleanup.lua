local bdUI, c, l = unpack(select(2, ...))

-- clean up saved variables that no longer exist inside of configs
function bdUI:cleanup_db()
	local profile = BDUI_SAVE.users[""]
	for profile, saves in pairs(BDUI_SAVE.profiles) do
		for module_name, settings in pairs(BDUI_SAVE.profiles[profile]) do

		end
	end
	for k, module in pairs(bdUI.modules) do
		local save = module:get_save()
	end
end
