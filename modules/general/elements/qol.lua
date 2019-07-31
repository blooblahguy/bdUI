local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("General")

function mod:create_qol()
	-- increase equipment sets per player
	setglobal("MAX_EQUIPMENT_SETS_PER_PLAYER", 100)
end