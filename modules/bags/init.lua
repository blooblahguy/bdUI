local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Bags")

local config = {
	{
		key = "enabled",
		type = "toggle",
		label = "Enable",
		value = true,
	},
	{
		key = "showfreespaceasone",
		type = "toggle",
		label = "Show free bag space as one icon",
		value = true,
	},

	{
		key = "showlabels",
		type = "toggle",
		label = "Show category labels",
		value = true,
	},

	{
		key = "skinloot",
		type = "toggle",
		label = "Skin Loot Frames",
		value = true,
	},
	{
		key = "easy_delete",
		type = "toggle",
		label = "Easy delete item shortcut",
		tooltip = "Alt+shift+ctrl + left click deletes items in bag",
		value = true,
	},

	{
		key = "dbgroup",
		type = "group",
		heading = "Bags",
		args = {
			
			{
				key = "buttonsize",
				type = "range",
				label = "Bag Buttons Size",
				value = 36,
				step = 2,
				min = 20,
				max = 40,
			},
			-- {
			-- 	key = "categorycolumns",
			-- 	type = "range",
			-- 	value = 2,
			-- 	min = 1,
			-- 	max = 6,
			-- 	step = 1,
			-- 	label = "Categories per row",
			-- },
			-- {
			-- 	key = "itemcolumns",
			-- 	type = "range",
			-- 	value = 5,
			-- 	min = 1,
			-- 	max = 16,
			-- 	step = 1,
			-- 	label = "Items per row",
			-- },
			{
				key = "buttonsperrow",
				type = "range",
				value = 12,
				min = 6,
				max = 30,
				step = 1,
				label = "Bag Buttons Per Row",
			},
		},
	},

	{
		key = "dbgroup",
		type = "group",
		heading = "Bank",
		args = {
			{
				key = "bankbuttonsize",
				type = "range",
				label = "Bank Buttons Size",
				value = 32,
				step = 2,
				min = 20,
				max = 40,
			},
			{
				key = "bankbuttonsperrow",
				type = "range",
				value = 16,
				min = 8,
				max = 30,
				step = 1,
				label = "Bank Buttons Per Row",
			},
		},
	},
}

local mod = bdUI:register_module("Bags", config)