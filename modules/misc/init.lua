--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

-- Config Table
local config = {
	{
		key = "doubleclickbo",
		type = "toggle",
		value = true,
		label = "Enable Double-click Buyouts"
	},
	{
		key = "errorblock",
		type = "toggle",
		value = true,
		label = "Block common errors"
	},
	{
		key = "gmotd",
		type = "toggle",
		value = true,
		label = "Alert new Guild Messages"
	},
	{
		key = "interrupt",
		type = "toggle",
		value = true,
		label = "Announce interrupts"
	},
}

local mod = bdUI:register_module("Misc", config)