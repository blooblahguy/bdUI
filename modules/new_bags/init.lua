--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

-- Config Table
local config = {
	{
		key = "enabled",
		type = "toggle",
		value = false,
	}
}

local mod = bdUI:register_module("New Bags", config)