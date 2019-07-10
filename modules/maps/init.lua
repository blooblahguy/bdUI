--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

-- Config Table
local config = bdConfig:helper_config()
config:add("enabled", {
	type = "checkbox",
	value = true,
	label = "Enable",
})
config:add("size", {
	type = "slider",
	value = 320,
	step = 5,
	min = 50,
	max = 600,
	label = "Size",
	tooltip = "Width and Height of Minimap",
})

config:add("shape", {
	type = "dropdown",
	value = "Rectangle",
	options = {"Rectangle","Square"},
	label = "Minimap Shape",
})
config:add("buttonpos", {
	type = "dropdown",
	value = "Bottom",
	options = {"Disable","Top","Right","Bottom","Left"},
	label = "Minimap Buttons position",
})

config:add("buttonsize", {
	type = "slider",
	value = 28,
	step = 2,
	min = 10,
	max = 60,
	label = "Button Size",
	tooltip = "Size of button frame buttons",
})

config:add("mouseoverbuttonframe", {
	type = "checkbox",
	value = false,
	label = "Hide Minimap Button frame until mouseover"
})
config:add("showconfig", {
	type = "checkbox",
	value = true,
	label = "Show bdConfig button",
})

config:add("xptracker", {
	type ="checkbox",
	value = true,
	label = "Enable XP/Rep tracker",
})

config:add("showtime", {
	type = "checkbox",
	value = true,
	label = "Show Time",
})

config:add("hideclasshall", {
	type = "checkbox",
	value = false,
	label = "Hide Class Hall Button",
})

local mod = bdUI:register_module("Minimap", config)


function mod:initialize(config)
	if (not config.enabled) then return false end

	mod:create_minimap()
	mod:create_button_frame()
end