--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

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
	hide_ui = true
})