--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

-- Config Table
local config = bdConfig:helper_config()
-- Display
config:add("text", {
	type = "text",
	value = "Tooltips Options",
})
config:add("enablett", {
	type = "checkbox",
	value = true,
	label = "Main Tooltips"
})
config:add("showrealm", {
	type = "checkbox",
	value = true,
	label = "Show Realm"
})
config:add("enableitemids", {
	type = "checkbox",
	value = true,
	label = "Show ItemIDs"
})
config:add("enablespellids", {
	type = "checkbox",
	value = true,
	label = "Show SpellIDs"
})

config:add("text", {
	type = "text",
	value = "Lite Tooltips Options",
})
config:add("mott", {
	type = "checkbox",
	value = true,
	label = "Enable lite-tooltips on unit mouseover",
})

-- Colors
config:add("tab", {
	type = "tab",
	value = "Colors",
})

local mod = bdUI:register_module("Tooltips", config)

function mod:initialize(config)
	if (config.enablett) then
		mod:create_tooltips()
	end

	if (config.enablett) then
		mod:color_tooltips()
		mod:create_mouseover_tooltips()
	end

end