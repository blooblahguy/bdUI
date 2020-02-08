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
		label = "Enable New Bag Code (not ready)",
		value = false,
	},

	{
		key = "bag_size",
		type = "range",
		min = 10,
		max = 50,
		step = 2,
		value = 28,
		label = "Bag Button Size"
	},

	-- {
	-- 	key = "categories",
	-- 	type = "tab",
	-- 	label = "Categories",
	-- 	args = {
	-- 		{
	-- 			key = "categories",
	-- 			type = "repeater",
	-- 			label = "Bag Categories",
	-- 			args = {
	-- 				{
	-- 					key = "category_name",
	-- 					type = "input",
	-- 					label = "Category Name",
	-- 				},
	-- 				{
	-- 					key = "category_color",
	-- 					type = "color",
	-- 					label = "Category Color",
	-- 					value = {1, 1, 1, 1}
	-- 				}
	-- 			}
	-- 		}
	-- 	}
	-- }
}

local mod = bdUI:register_module("New Bags", config, {
	hide_ui = not developer
})