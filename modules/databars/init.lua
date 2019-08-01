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
		key = "xp_rep_bar",
		type = "toggle",
		value = true,
		label = "XP & Rep Bar"
	},
	{
		key = "honorbar",
		type = "toggle",
		value = true,
		label = "Honor Bar"
	},
	{
		key = "apbar",
		type = "toggle",
		value = true,
		label = "AP Bar"
	},
}

local mod = bdUI:register_module("Databars", config, {
	hide_ui = true
})