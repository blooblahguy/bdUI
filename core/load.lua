local bdUI, c, l = unpack(select(2, ...))

local loader = CreateFrame("frame", nil, bdParent)
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addon)
	if (addon == bdUI.name) then
		loader:UnregisterEvent("ADDON_LOADED")
		bdUI:do_action("pre_loaded")

		-- initiate SVs
		BDUI_SAVE = BDUI_SAVE or {}
		BDUI_CHARACTER = BDUI_CHARACTER or {}

		-- set save for bdMove, so that we're not vulnerable to UI errors resetting positioning
		bdMove:set_save("BDUI_SAVE")
		bdMove.spacing = bdUI.border

		-- Register with bdConfig
		bdUI.config_instance = bdUI.bdConfig:register("bdUI", bdMove.toggle_lock)

		bdUI:debug(l['LOAD_MSG'])
		bdUI:do_action("loaded")
		bdUI:do_action("post_loaded")
	end
end)