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
		label = "Enable Minimap"
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
				max = 600,
				step = 5,
				value = 320
			},
			{
				key = "shape",
				type = "select",
				value = "Rectangle",
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
				value = "Top",
				options = {"Disabled", "Top", "Right", "Bottom", "Left"},
				label = "Button Frame Position"
			},
			{
				key = "buttonsize",
				type = "range",
				value = 28,
				min = 10,
				max = 60,
				step = 2,
				label = "Size of buttons"
			},
			{
				key = "mouseoverbuttonframe",
				type = "toggle",
				value = false,
				label = "Hide button frame until mouseover"
			},
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