--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

local config = {
	{
		key = "enabled",
		type = "toggle",
		label = "Enable Party Frames",
		value = true,
	},

	{
		key = "enabled",
		type = "toggle",
		label = "Enable Arena Frames",
		value = true,
	},

	{
		key = "party_tab",
		type = "tab",
		label = "Party",
		args = {

		}
	},
	{
		key = "arena_tab",
		type = "tab",
		label = "Arena",
		args = {

		}
	},
}

local mod = bdUI:register_module("Group Frames", config)