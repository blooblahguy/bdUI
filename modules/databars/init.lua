--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

-- Config Table
local config = {
	{
		key = "alteratepowerbar",
		type = "toggle",
		value = true,
		label = "Alternate Power Bar"
	},
	{
		key = "alteratepowerbar",
		type = "toggle",
		value = true,
		label = "Alternate Power Bar"
	},
	{
		key = "alteratepowerbar",
		type = "toggle",
		value = true,
		label = "Alternate Power Bar"
	},
	{
		key = "alteratepowerbar",
		type = "toggle",
		value = true,
		label = "Alternate Power Bar"
	},
}

local mod = bdUI:register_module("Databars", config, {
	hide_ui = true
})