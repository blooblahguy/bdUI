local bdUI, c, l = unpack(select(2, ...))

local wotlk_runes = {}
if (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC and select(2, UnitClass("player")) == "DEATHKNIGHT") then
	wotlk_runes = {
		{
			key = "runes_enable",
			value = true,
			type = "toggle",
			label = "Runes Enable"
		},
		{
			key = "runes_height",
			value = 6,
			min = 2,
			max = 30,
			step = 2,
			type = "range",
			label = "Runes Height"
		},
		{
			key = "clear",
			type = "clear",
		},
		{
			key = "runes_ic_alpha",
			value = 1,
			min = 0,
			max = 1,
			step = 0.1,
			decimals = 1,
			type = "range",
			label = "Runes In Combat Alpha"
		},
		{
			key = "runes_ooc_alpha",
			value = 1,
			min = 0,
			max = 1,
			step = 0.1,
			decimals = 1,
			type = "range",
			label = "Runes Resting Alpha"
		},
	}
end

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
		value = "The resource settings show things like mana, combo points, totems, stagger, castbar, and more.",
	},

	{
		key = "general_tab",
		type = "tab",
		label = "General",
		args = {
			{
				key = "resources_width",
				value = 300,
				min = 40,
				max = 400,
				step = 2,
				type = "range",
				size = "full",
				label = "Global Width"
			},
			{
				key = "text_scale",
				value = 0.6,
				min = 0.1,
				max = 2.0,
				step = 0.1,
				decimals = 1,
				type = "range",
				label = "Text Scale"
			},
		},
	},
	{
		key = "general_tab",
		type = "tab",
		label = "Castbar",
		args = {
			{
				key = "castbar_enable",
				value = true,
				type = "toggle",
				label = "Castbar Enable"
			},
			{
				key = "castbar_height",
				value = 22,
				min = 6,
				max = 50,
				step = 2,
				type = "range",
				label = "Castbar Height"
			},
		},
	},
	{
		key = "general_tab",
		type = "tab",
		label = "Power",
		args = {
			{
				key = "power_enable",
				value = true,
				type = "toggle",
				label = "Power Enable"
			},
			{
				key = "power_height",
				value = 10,
				min = 6,
				max = 50,
				step = 2,
				type = "range",
				label = "Power Height"
			},
			{
				key = "power_tick",
				value = 0,
				min = 0,
				max = 100,
				step = 1,
				type = "range",
				label = "Show Power Tick"
			},
			{
				key = "power_ic_alpha",
				value = 1,
				min = 0,
				max = 1,
				step = 0.1,
				decimals = 1,
				type = "range",
				label = "In Combat Alpha"
			},
			{
				key = "power_ooc_alpha",
				value = 0.4,
				min = 0,
				max = 1,
				step = 0.1,
				decimals = 1,
				type = "range",
				label = "Resting Alpha"
			},
		},
	},
	{
		key = "general_tab",
		type = "tab",
		label = "Swing",
		args = {
			{
				key = "swingbar_enable",
				value = false,
				type = "toggle",
				label = "Enable"
			},
			{
				key = "mainhand_height",
				value = 16,
				min = 6,
				max = 30,
				step = 2,
				type = "range",
				label = "Mainhand Height"
			},
			{
				key = "offhand_height",
				value = 8,
				min = 2,
				max = 30,
				step = 1,
				type = "range",
				label = "Offhand Height"
			},
			{
				key = "swing_ic_alpha",
				value = 1,
				min = 0,
				max = 1,
				step = 0.1,
				decimals = 1,
				type = "range",
				label = "In Combat Alpha"
			},
			{
				key = "swing_ooc_alpha",
				value = 0.4,
				min = 0,
				max = 1,
				step = 0.1,
				decimals = 1,
				type = "range",
				label = "Resting Alpha"
			},
			{
				key = "special_1_color",
				value = { .81, .76, .36 },
				type = "color",
				label = "Special 1 Color"
			},
			{
				key = "special_2_color",
				value = { .51, .85, .46 },
				type = "color",
				label = "Special 2 Color"
			},
		},
	},
	{
		key = "general_tab",
		type = "tab",
		label = "Class Specific",
		args = {
			{
				key = "label",
				type = "text",
				value = "If your current class has any class-specific power types, their config will be here"
			},
			unpack(wotlk_runes)
			-- {
			-- 	key = "castbar_enable",
			-- 	value = true,
			-- 	type = "toggle",
			-- 	label = "Enable"
			-- },
			-- {
			-- 	key = "castbar_height",
			-- 	value = 22,
			-- 	min = 6,
			-- 	max = 50,
			-- 	step = 2,
			-- 	type = "range",
			-- 	label = "Castar Height"
			-- },
		},
	},
}

local mod = bdUI:register_module("Player Bars", config)
