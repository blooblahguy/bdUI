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
		label = "Enable Buffs & Debuffs"
	},
	--=========================================
	-- Buffs
	--=========================================
	{
		key = "tab",
		type = "tab",
		value = "Buffs",
		args = {
			{
				key = "decimalprec",
				type = "toggle",
				value = true,
				size = "full",
				label = "Show decimals on durations under 10 seconds",
			},
			{
				key = "buffsize",
				type = "range",
				min = 16,
				max = 60,
				step = 2,
				value = 40,
				label = "Buff Size",
			},
			{
				key = "buffspacing",
				type = "range",
				min = 0,
				max = 10,
				step = 2,
				value = 4,
				label = "Buff Spacing",
			},
			{
				key = "buffperrow",
				type = "range",
				min = 1,
				max = 20,
				step = 1,
				value = 11,
				label = "Buff Per Row",
			},
			{
				key = "bufffontsize",
				type = "range",
				min = 8,
				max = 30,
				step = 2,
				value = 14,
				label = "Buff Font Size",
			},
			{
				key = "buffhgrowth",
				type = "select",
				value = "Left",
				options = {"Left","Right"},
				label = "Buff Horizontal Growth",
			},
			{
				key = "buffvgrowth",
				type = "select",
				value = "Downwards",
				options = {"Upwards","Downwards"},
				label = "Buff Vertical Growth",
			},
			{
				key = "bufftimer",
				type = "select",
				value = "BOTTOM",
				options = {"BOTTOM","TOP","LEFT","RIGHT"},
				label = "Buff Timer Position",
			},
		}
	},
	--=========================================
	-- Debuffs
	--=========================================
	{
		key = "tab",
		type = "tab",
		label = "Debuffs",
		args = {
			{
				key = "debuffsize",
				type = "range",
				min = 16,
				max = 60,
				step = 2,
				value = 32,
				label = "Debuff Size",
			},
			{
				key = "debuffspacing",
				type = "range",
				min = 0,
				max = 10,
				step = 2,
				value = 0,
				label = "Debuff Spacing",
			},
			{
				key = "debuffperrow",
				type = "range",
				min = 1,
				max = 10,
				step = 1,
				value = 5,
				label = "Debuff Per Row",
			},
			{
				key = "debufffontsize",
				type = "range",
				min = 8,
				max = 30,
				step = 2,
				value = 14,
				label = "Debuff Font Size",
			},
			{
				key = "debuffhgrowth",
				type = "select",
				value = "Right",
				options = {"Left","Right"},
				label = "Debuff Horizontal Growth",
			},
			{
				key = "debuffvgrowth",
				type = "select",
				value = "Upwards",
				options = {"Upwards","Downwards"},
				label = "Debuff Vertical Growth",
			},
			{
				key = "debufftimer",
				type = "select",
				value = "BOTTOM",
				options = {"BOTTOM","TOP","LEFT","RIGHT"},
				label = "Debuff Timer Position",
			},
		}
	},
	
}

local mod = bdUI:register_module("Buffs and Debuffs", config)