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
		BDUI_SAVE = BDUI_SAVE or {}
		BDUI_SAVE.persistent = BDUI_SAVE.persistent or {}
		bdUI.persistent = BDUI_SAVE.persistent

		-- set save for bdMove, so that we're not vulnerable to UI errors resetting positioning
		bdMove:set_save(bdUI.config_instance.save)
		bdMove.spacing = bdUI.border

		bdUI:debug(l['LOAD_MSG'])
		bdUI:do_action("loaded")
		bdUI:do_action("post_loaded")
	end
end)