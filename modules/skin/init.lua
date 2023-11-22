--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

-- Config Table
local config = {
	{
		key = "enabled",
		type = "toggle",
		value = true,
		label = "Enable"
	}
}

local mod = bdUI:register_module("Skinning", config, {
	hide_ui = true
})
