local bdUI, c, l = unpack(select(2, ...))

local loader = CreateFrame("frame", nil, bdParent)
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addon)
	if (addon == bdUI.name) then
		loader:UnregisterEvent("ADDON_LOADED")
		bdUI:do_action("pre_loaded")

		-- Load bdConfig now that we have saved variables
		bdUI.config_instance = bdUI.bdConfig:load()
		bdUI.persistent = BDUI_SAVE.persistent

		-- set save for bdMove, so that we're not vulnerable to UI errors resetting positioning
		local profile = bdUI.bdConfig:get_save("BDUI_SAVE")
		bdMove:set_save(bdUI.bdConfig:get_save("BDUI_SAVE"))

		-- pass new profile to bdMove when profile changes
		bdUI:add_action("profile_change", function()
			local sv = bdUI.bdConfig:get_save("BDUI_SAVE")
			bdMove:set_save(sv)
		end, 5)
		bdMove.spacing = bdUI.border

		bdUI:debug(l['LOAD_MSG'])
		bdUI:do_action("loaded")
		bdUI:do_action("post_loaded")

		-- if (not BDUI_SAVE.first_run) then
		-- 	BDUI_SAVE.first_run = true
		-- 	bdUI:do_action("setup")
		-- end
	end
end)

local sharedmedia = CreateFrame("frame", nil, bdParent)
sharedmedia:RegisterEvent("LOADING_SCREEN_DISABLED")
sharedmedia:SetScript("OnEvent", function()
	bdUI:do_action("bdUI/fonts")
	-- local fonts = bdUI.shared:List("font")
	-- for k, v in pairs(fonts) do
	-- 	print(k, v)
	-- 	local font = bdUI.shared:Fetch("font", v)
	-- 	print(font)
	-- end
	-- print(fonts)
end)