--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

local developer_names = {}
developer_names["Padder"] = true
developer_names["Nodis"] = true
developer_names["Bloo"] = true
developer_names["Redh"] = true
local developer = developer_names[UnitName("player")]

-- Config Table
local config = {
	{
		key = "enabled",
		type = "toggle",
		label = "Enable New Bag Code (in beta)",
		value = false,
	},
	{
		key = "text",
		type = "text",
		label = "New bags function similar to popular addons like adibags, with categories and auto sorting.",
		value = false,
	},

	{
		key = "bags",
		type = "tab",
		value = "Bags",
		args = {
			{
				key = "bag_size",
				type = "range",
				min = 10,
				max = 50,
				step = 2,
				value = 40,
				label = "Bag Button Size"
			},

			{
				key = "bag_height",
				type = "range",
				min = 200,
				max = 800,
				step = 20,
				value = 400,
				label = "Bag Max Height"
			},

			{
				key = "bag_max_column",
				type = "range",
				min = 2,
				max = 20,
				step = 1,
				value = 11,
				label = "Bag Category Max Columns"
			},
		}
	},

	{
		key = "banks",
		type = "tab",
		value = "Banks",
		args = {
			{
				key = "bank_size",
				type = "range",
				min = 10,
				max = 50,
				step = 2,
				value = 30,
				label = "Bank Button Size"
			},

			{
				key = "bank_height",
				type = "range",
				min = 200,
				max = 800,
				step = 20,
				value = 300,
				label = "Bank Max Height"
			},

			{
				key = "bank_max_column",
				type = "range",
				min = 2,
				max = 20,
				step = 1,
				value = 11,
				label = "Bank Category Max Columns"
			},
		}
	},

	{
		key = "regeants",
		type = "tab",
		value = "Reagents",
		args = {
			{
				key = "reagent_size",
				type = "range",
				min = 10,
				max = 50,
				step = 2,
				value = 30,
				label = "Reagent Button Size"
			},

			{
				key = "reagent_columns",
				type = "range",
				min = 1,
				max = 50,
				step = 1,
				value = 15,
				label = "Reagent Max Columns"
			},
		}
	},


	
}

local hide = false
if (not developer) then 
	hide = true
elseif (bdUI:isClassicAny()) then
	hide = true
end

local mod = bdUI:register_module("Bags (beta)", config, {
	hide_ui = hide
})