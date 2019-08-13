--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

-- Config Table
local config = {
	{
		key = "group",
		type "group",
		heading = "Databars",
		args = {
			{
				key = "alteratepowerbar",
				type = "toggle",
				value = true,
				label = "Alternate Power Bar"
			},
			{key = "clear", type = "clear"},
			{
				key = "alt_width",
				type = "range",
				label = "Alternative Power Width",
				min = 40,
				max = 1200,
				step = 5,
				value = 300,	
			},
			{
				key = "alt_height",
				type = "range",
				label = "Alternative Power Height",
				min = 4,
				max = 60,
				step = 4,
				value = 16,	
			},
		}
	},

	{
		key = "group",
		type "group",
		heading = "Databars",
		args = {
			{
				key = "databars_width",
				type = "range",
				label = "Databars Width",
				min = 40,
				max = 1200,
				step = 5,
				value = 300,	
			},
			{
				key = "databars_height",
				type = "range",
				label = "Databars Height",
				min = 4,
				max = 60,
				step = 4,
				value = 16,	
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
	},

}

local mod = bdUI:register_module("Databars", config, {
	hide_ui = true
})