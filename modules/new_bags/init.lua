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
	}
}

local mod = bdUI:register_module("New Bags", config, {
	hide_ui = not developer
})