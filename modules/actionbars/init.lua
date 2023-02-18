--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

--[[
	Significat thanks and props to Zork for rActionbars and zLib functionality that makes this all way less of a nightmare
]]
--==================================================================================
-- Initialize configuration
local size_md = 36
local size_lg = 50
local size_sm = 20

--==================================================================================
-- since most of the bars share identical conf, let's just use a function to save space and time
local function addBarConf(title, key, options)
	local defaults = {
		mouseover = false,
		rows = 1,
		buttons = 12,
		size = size_md,
		spacing = 0,
		scale = 1,
		alpha = 1,
		hotkeys = false,
	}
	options = options or {}
	for k, v in pairs(options) do
		defaults[k] = v
	end

	return { 
		key = "tab",
		type = "tab",
		label = title,
		args = {
			{
				key = key.."_mouseover",
				type = "toggle",
				value = defaults.mouseover,
				label = "Hide Until Mouseover",
			},
			{
				key = key.."_hidehotkeys",
				type = "toggle",
				value = defaults.hotkeys,
				label = "Hide Bar Hotkeys until Mouseover"
			},
			{
				key = key.."_hidemacros",
				type = "toggle",
				value = defaults.hotkeys,
				label = "Hide Macros until Mouseover"
			},
			{
				key = key.."_size",
				type = "range",
				min = 4,
				max = 100,
				step = 2,
				value = defaults.size,
				label = "Button Size"
			},
			{
				key = key.."_spacing",
				type = "range",
				min = 0,
				max = 20,
				step = 1,
				value = defaults.spacing,
				label = "Button Spacing"
			},
			{
				key = key.."_scale",
				type = "range",
				min = 0,
				max = 1,
				step = 0.1,
				value = defaults.scale,
				label = "Bar Scale"
			},
			{
				key = key.."_alpha",
				type = "range",
				min = 0,
				max = 1,
				step = 0.1,
				value = defaults.alpha,
				label = "Bar Alpha"
			},
			{
				key = key.."_buttons",
				type = "range",
				min = 1,
				max = 12,
				step = 1,
				value = defaults.buttons,
				label = "Number of Buttons"
			},
			{
				key = key.."_rows",
				type = "range",
				min = 1,
				max = 12,
				step = 1,
				value = defaults.rows,
				label = "Number of Rows"
			},
		}
	}
end

-- Config Table
local config = {
	{
		key = "enabled",
		type = "toggle",
		label = "Enable",
		value = true,
	},
	{
		key = "clear", 
		type = "clear"
	},

	--=========================================
	-- General
	--=========================================
	{
		key = "general",
		type = "tab",
		label = "General",
		args = {
			{
				key = "font_size",
				type = "range",
				min = 1,
				max = 30,
				step = 1,
				value = 12,
				label = "Main Font Size"
			},
			{
				key = "cd_font_size",
				type = "range",
				min = 1,
				max = 30,
				step = 1,
				value = 18,
				label = "Cooldown Font Size"
			},
			{
				key = "fade_duration",
				type = "range",
				min = 0,
				max = 1,
				step = 0.1,
				value = 0.2,
				label = "Bar Fade Duration"
			},
			{
				key = "showMicro",
				type = "toggle",
				value = true,
				label = "Show Micro Menu",
			},
			{
				key = "microbar_size",
				type = "range",
				min = 4,
				max = 100,
				step = 2,
				value = size_md,
				label = "Micro Menu Button Size"
			},

			-- bagbar
			{
				key = "showBags",
				type = "toggle",
				value = true,
				label = "Show Bag Menu",
			},
			{
				key = "bagbar_size",
				type = "range",
				min = 10,
				max = 140,
				step = 2,
				value = size_lg,
				label = "Bags Bar Button Size"
			},

			-- vehicle
			{
				key = "showVehicle",
				type = "toggle",
				value = true,
				label = "Show Vehicle Exit",
			},
			{
				key = "vehiclebar_size",
				type = "range",
				min = 4,
				max = 100,
				step = 2,
				value = size_md,
				label = "Vehicle Exit Size"
			},

			-- possess
			{
				key = "showPossess",
				type = "toggle",
				value = true,
				label = "Show Possess Exit",
			},
			{
				key = "possessbar_size",
				type = "range",
				min = 4,
				max = 100,
				step = 2,
				value = size_md,
				label = "Possess Exit Size"
			},

			-- extra
			{
				key = "extrabar_size",
				type = "range",
				min = 4,
				max = 100,
				step = 2,
				value = size_lg,
				label = "Extra Button Size"
			},
		},
	},

--=========================================
-- Main Bar
--=========================================
	addBarConf("Main Bar", "bar1"),

--=========================================
-- Bar 2
--=========================================
	addBarConf("Bar 2", "bar2"),

--=========================================
-- Bar 3
--=========================================
	addBarConf("Bar 3", "bar3"),

--=========================================
-- Bar 4
--=========================================
	addBarConf("Bar 4", "bar4", {
		rows = 12,
		mouseover = true,
	}),

--=========================================
-- Bar 5
--=========================================
	addBarConf("Bar 5", "bar5", {
		rows = 12, 
		mouseover = true, 
	}),

--=========================================
-- Stance & Pet
--=========================================
	-- STANCE
	addBarConf("Stance", "stancebar", {
		scale = 0.8
	}),
	-- PET
	addBarConf("Pet", "petbar", {
		scale = 0.8,
		buttons = 10
	})
}

local mod = bdUI:register_module("Actionbars", config)
mod.variables = {} -- variables
mod.variables.hidden = CreateFrame("Frame")
mod.variables.hidden:Hide()
mod.variables.callbacks = {}

function mod:unpack()
	return self[1], self[2], self[3]
end