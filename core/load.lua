local bdUI, c, l = unpack(select(2, ...))

local loader = CreateFrame("frame", nil, bdParent)
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addon)
	if (addon == bdUI.name) then
		loader:UnregisterEvent("ADDON_LOADED")
		bdUI:do_action("pre_loaded")

		-- Register with bdConfig
		bdUI.bdConfig.media.font = bdUI.media.font
		bdUI.config_instance = bdUI.bdConfig:register("bdUI", "BDUI_SAVE", bdMove.toggle_lock)
		bdUI.persistent = BDUI_SAVE.persistent

		-- set save for bdMove, so that we're not vulnerable to UI errors resetting positioning
		bdMove:set_save(bdUI.config_instance.save)
		-- pass new profile to bdMove when profile changes
		bdUI:add_action("profile_changed", function()
			local sv = bdUI.bdConfig:get_save("BDUI_SAVE", nil)
			bdMove:set_save(sv)
		end)
		bdMove.spacing = bdUI.border

		bdUI:debug(l['LOAD_MSG'])
		bdUI:do_action("loaded")
		bdUI:do_action("post_loaded")
	end
end)