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
config:add("enablecastbars", {
	type = "checkbox",
	value = true,
	label = "Enable Castbars",
}) 

config:add("showtargetbuffs", {
	type = "checkbox",
	value = true,
	label = "Show Target's Buffs",
})
config:add("inrangealpha", {
	type = "slider",
	min = 0.1,
	max = 1,
	step = 0.1,
	value = 1,
	label = "In Range Alpha",
}) 

config:add("outofrangealpha", {
	type = "slider",
	min = 0.1,
	max = 0.5,
	step = 0.1,
	value = 1,
	label = "Out of Range Alpha",
}) 

--=========================================
-- PLAYER & TARGET
--=========================================
	config:add("tab", {
		type = "tab",
		value = "Player & Target"
	})
	config:add("textlocation", {
		type = "dropdown",
		value = "Outside",
		options = {"Outside","Inside","Top/Bottom"},
		label = "Text Location",
	}) 
	config:add("bufftrackerstyle", {
		type = "dropdown",
		value = "Aurabars",
		options = {"Aurabars","Icons","None"},
		label = "Buff Display Style",
	}) 
	config:add("playertargetwidth", {
		type = "slider",
		value = 280,
		label = "Width",
		step = 2,
		min = 100,
		max = 300,
	}) 
	config:add("playertargetheight", {
		type = "slider",
		value = 32,
		label = "Height",
		step = 2,
		min = 4,
		max = 60,
	}) 
	config:add("playertargetpowerheight", {
		type = "slider",
		value = 3,
		label = "Power height",
		step = 1,
		min = 2,
		max = 10,
	})

	config:add("castbarheight", {
		type = "slider",
		value = 14,
		label = "Castbar height",
		step = 1,
		min = 6,
		max = 30,
	}) 
	config:add("castbaricon", {
		type = "slider",
		value = 28,
		label = "Castbar Icon Size",
		step = 1,
		min = 6,
		max = 50,
	}) 
--=========================================
-- Focus
--=========================================
	config:add("tab", {
		type = "tab",
		value = "Focus"
	})
	config:add("focuswidth", {
		type = "slider",
		value = 240,
		label = "Width",
		step = 2,
		min = 50,
		max = 300,
	}) 
	config:add("focusheight", {
		type = "slider",
		value = 20,
		label = "Height",
		step = 2,
		min = 4,
		max = 40,
	}) 
	config:add("focuscastwidth", {
		type = "slider",
		value = 240,
		label = "Castbar Width",
		step = 2,
		min = 50,
		max = 300,
	}) 
	config:add("focuscastheight", {
		type = "slider",
		value = 20,
		label = "Castar Height",
		step = 2,
		min = 4,
		max = 40,
	}) 
	config:add("focuscasticon", {
		type = "slider",
		value = 30,
		label = "Castbar Icon Height",
		step = 2,
		min = 4,
		max = 60,
	}) 
	config:add("focuspower ", {
		type = "slider",
		value = 2,
		label = "Power height",
		step = 1,
		min = 2,
		max = 10,
	}) 

--=========================================
-- ToT
--=========================================
	config:add("tab", {
		type = "tab",
		value = "Target's Target & Pet"
	})

	config:add("targetoftargetwidth", {
		type = "slider",
		value = 120,
		label = "Width",
		step = 2,
		min = 60,
		max = 220,
	})
	config:add("targetoftargetheight", {
		type = "slider",
		value = 16,
		label = "Height",
		step = 2,
		min = 6,
		max = 30,
	})

--=========================================
-- Boss
--=========================================
	config:add("tab", {
		type = "tab",
		value = "Boss"
	})
	config:add("bossenable", {
		type = "checkbox",
		value = true,
		label = "Enable Boss Frames",
	})
	config:add("bosswidth", {
		type = "slider",
		value = 200,
		label = "Width",
		step = 5,
		min = 60,
		max = 420,
	})
	config:add("bossdebuffsize", {
		type = "slider",
		value = 30,
		label = "Aura Size",
		step = 2,
		min = 10,
		max = 100,
	})
	config:add("bossheight", {
		type = "slider",
		value = 40,
		label = "Height",
		step = 5,
		min = 5,
		max = 200,
	})
	config:add("bosspower ", {
		type = "slider",
		value = 10,
		label = "Power height",
		step = 1,
		min = 2,
		max = 20,
	}) 

local mod = bdUI:register_module("Unitframes", config)

--=============================================
-- Initialize function
--=============================================
function mod:initialize(config)
	if (not config.enabled) then return false end

	bdUI.oUF.colors.power[0] = {46/255, 130/255, 215/255}
	bdUI.oUF.colors.power["MANA"] = {46/255, 130/255, 215/255}
	mod:create_unitframes()
end