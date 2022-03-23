--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

local config = {
	{
		key = "enabled",
		type = "toggle",
		value = true,
		label = "Enable"
	},
}


local mod = bdUI:register_module("Buffs and Debuffs", config)