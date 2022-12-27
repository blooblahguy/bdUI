local bdUI, c, l = unpack(select(2, ...))

local config = {
	{
		key = "enabled",
		type = "toggle",
		label = "Enable",
		value = true,
	},
	{
		key = "clear",
		type = "clear",
	},
	{
		key = "text",
		type = "text",
		value = "Dragonflight had massive changes to maps, and a complete rewrite will be necessary. For now, this module is a work in progress."
	}
}

local mod = bdUI:register_module("Maps", config)