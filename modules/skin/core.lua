--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Skinning")

--===============================================
-- Core functionality
-- place core functionality here
--===============================================
function mod:initialize()
	-- mod:create_fonts()
	if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then return end
	mod:move_vehicle()

	-- General config
	mod:skin_weak_auras()
end