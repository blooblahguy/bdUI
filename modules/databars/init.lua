--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

-- Config Table
local config = {
	{
		key = "dbgroup",
		type = "group",
		heading = "Alternative Power",
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
				max = 400,
				step = 5,
				value = 200,	
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
		key = "dbgroup2",
		type = "group",
		heading = "Databars",
		args = {
			{
				key = "databars",
				type = "toggle",
				value = true,
				label = "Enable Databars"
			},
			{
				key = "databars_width",
				type = "range",
				label = "Databars Width",
				min = 40,
				max = 1200,
				step = 5,
				value = 320,	
			},
			{
				key = "databars_height",
				type = "range",
				label = "Databars Height",
				min = 4,
				max = 60,
				step = 4,
				value = 14,	
			},
			{
				key = "repbar",
				type = "select",
				value = "Show When Tracking & Max Level",
				options = {"Always Hide", "Show When Tracking", "Show When Tracking & Max Level"},
				label = "Rep Bar"
			},
			{
				key = "xpbar",
				type = "select",
				value = "Show When Leveling",
				options = {"Always Hide", "Show When Leveling"},
				label = "XP Bar"
			},
			{
				key = "honorbar",
				type = "toggle",
				value = false,
				label = "Honor Bar"
			},
			{
				key = "apbar",
				type = "select",
				value = "Only At Max Level",
				options = {"Always Show", "Always Hide", "Only At Max Level"},
				label = "AP Bar"
			},
		}
	},

}

local mod = bdUI:register_module("Databars", config)