local bdUI, c, l = unpack(select(2, ...))

--=========================================
-- RESOURCES
--=========================================
local config = {
	{
		key = "resources_enable",
		value = true,
		type = "toggle",
		label = "Enable"
	},
	{
		key = "resources_enable",
		type = "text",
		value = "The resource settings show things like mana, combo points, totems, stagger, and more.",
	},
	{
		key = "resources_width",
		value = 200,
		min = 40,
		max = 400,
		step = 2,
		type = "range",
		size = "full",
		label = "Global Width"
	},
	{
		key = "resources_power_height",
		value = 14,
		min = 0,
		max = 30,
		step = 1,
		type = "range",
		size = "full",
		label = "Power Height"
	},

	{
		key = "resources_primary_height",
		value = 5,
		min = 0,
		max = 20,
		step = 1,
		type = "range",
		size = "full",
		label = "Primary Resource Height"
	},
	{
		key = "resources_secondary_height",
		value = 3,
		min = 0,
		max = 20,
		step = 1,
		type = "range",
		size = "full",
		label = "Secondary Resource Height"
	},
}

local mod = bdUI:register_module("Resources & Power", config)