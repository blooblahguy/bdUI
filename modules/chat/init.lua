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
		label = "Enable Chat"
	},
	{
		key = "skinchatbubbles",
		type = "select",
		value = "Removed",
		options={"Default*","Skinned","Removed"},
		label = "Chat Bubbles Skin",
	},
	{
		key = "bgalpha",
		type = "range",
		value = 1,
		step = 0.1,
		min = 0,
		max = 1,
		label = "Chat background opacity."
	},
	{
		key = "chatHide",
		type = "toggle",
		value = false,
		label = "Hide communities chat until focus, for streamers."
	},
	{
		key = "hideincombat",
		type = "toggle",
		value = false,
		label = "Hide all chat frames in boss combat."
	},

}

local mod = bdUI:register_module("Chat", config)