--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))
-- local config = {}

local config = {
	{
		key = "enablett",
		type = "toggle",
		value = true,
		label = "Enable Tooltips"
	},

	{
		key = "tooltips",
		type = "group",
		heading = "Main Tooltips",
		args = {
			{
				key = "showrealm",
				type = "toggle",
				value = true,
				label = "Show Realm Name"
			},
			{
				key = "itemids",
				type = "toggle",
				value = false,
				label = "Enable itemIDs in tooltip"
			},
			{
				key = "spellids",
				type = "toggle",
				value = true,
				label = "Enable spellIDs in tooltip"
			},
			{
				key = "enablelinecolors",
				type = "toggle",
				value = true,
				label = "Enable line-coloring"
			},
		}
	},
	{
		key = "mouseovertooltips",
		type = "group",
		heading = "Lite Tooltips",
		args = {
			{
				key = "enablemott",
				type = "toggle",
				value = true,
				label = "Enable lite tooltips on unit mouseover"
			}
		}
	},
	
}

local mod = bdUI:register_module("Tooltips", config)

function mod:initialize(config)
	_G['tooltipconfig'] = config
	-- dump(config)
	if (config.enablett) then
		mod:create_tooltips()
	end

	if (config.enablett) then
		mod:color_tooltips()
		mod:create_mouseover_tooltips()
	end

end