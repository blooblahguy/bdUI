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
	if (mod.change_fonts) then
		mod:change_fonts()
	end
	if (mod.move_vehicle) then
		mod:move_vehicle()
	end

	-- General config
	mod:skin_weak_auras()
end
