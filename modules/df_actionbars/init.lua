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
		value = "Dragonflight had massive changes to actionbars, and a complete rewrite will be necessary. For now, this module only skins the blizzard actionbars to match bdUI."
	}
}

local mod = bdUI:register_module("Actionbars", config)