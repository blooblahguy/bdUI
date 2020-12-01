--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Maps")


--===============================================
-- Core functionality
-- place core functionality here
--===============================================

--=============================================
-- Initialize function
--=============================================
function mod:initialize()
	mod.config = mod:get_save()
	if (not mod.config.enabled) then 
		mod:set_shape()
		return false
	end

	mod:create_minimap()
	mod:create_button_frame()
	mod:worldmap_coords()
	-- mod:save_map_zoom()
	mod:create_objective_tracker()

	mod:config_callback()
end