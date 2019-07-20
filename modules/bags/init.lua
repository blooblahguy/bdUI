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
	},
	{
		key = "buttonsize",
		type = "range",
		label = "Bag Buttons Size",
		value = 32,
		step = 2,
		min = 20,
		max = 40,
	},
	{
		key = "buttonsperrow",
		type = "range",
		value = 16,
		min = 8,
		max = 30,
		step = 1,
		label = "Bag Buttons Per Row",
	},
	{
		key = "bankbuttonsize",
		type = "range",
		label = "Bank Buttons Size",
		value = 30,
		step = 2,
		min = 20,
		max = 50,
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
	{
		key = "skinloot",
		type = "toggle",
		value = true,
		label = "Skin the Loot Windows",
	},
	{
		key = "autorepair",
		type = "toggle",
		value = true,
		label = "Automatically repair",
	},
	{
		key = "sellgreys",
		type = "toggle",
		value = true,
		label = "Automatically sell trash at vendor.",
	},
	{
		key = "fastloot",
		type = "toggle",
		value = true,
		label = "Fast Loot",
		tooltip="Loots items automatically and much faster than the default UI.",
	},
	{
		key = "resetgold",
		type = "button",
		value = "Reset Gold Tracker",
		callback = function(self) core:resetTracker() end
	}
}

local mod = bdUI:register_module("Bags", config)