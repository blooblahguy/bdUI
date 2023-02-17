--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local config

-- Config Table
local config = {
	{
		key = "enabled",
		type = "toggle",
		value = true,
		label = "Enable"
	},
	{
		key = "minimap_tab",
		type = "tab",
		value = "Minimap",
		args = {
			{
				key = "size",
				label = "Minimap Size",
				type = "range",
				min = 50,
				max = 500,
				step = 5,
				value = 200
			},
			{
				key = "scale",
				label = "Minimap Scale",
				type = "range",
				min = 0.1,
				max = 3,
				step = .1,
				value = 1.5
			},
			{
				key = "shape",
				type = "select",
				value = "Square",
				options = {"Rectangle", "Square"},
				label = "Minimap Shape"
			}
		}
	},
	{
		key = "buttonframe_tab",
		type = "tab",
		value = "Button Frame",
		args = {
			{
				key = "buttonpos",
				type = "select",
				value = "Bottom",
				options = {"Disabled", "Top", "Right", "Bottom", "Left"},
				label = "Button Frame Position"
			},
			{
				key = "buttonsize",
				type = "range",
				value = 24,
				min = 10,
				max = 60,
				step = 2,
				label = "Size of buttons"
			},
			-- {
			-- 	key = "mouseoverbuttonframe",
			-- 	type = "toggle",
			-- 	value = false,
			-- 	label = "Hide button frame until mouseover"
			-- },
			{
				key = "showconfig",
				type = "toggle",
				value = true,
				label = "Show bdConfig button"
			},
			{
				key = "showtime",
				type = "toggle",
				value = true,
				label = "Show Time"
			},
			{
				key = "hideclasshall",
				type = "toggle",
				value = false,
				label = "Hide Class Hall Button"
			},
		}
	},
}

local mod = bdUI:register_module("Maps", config)