--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

-- Config Table
local config = {
	tooltips = {
		type = "group",
		heading = "Main Tooltips",
		args = {
			enablett = {
				type = "toggle",
				value = true,
				label = "Enable tooltips"
			},
			clear = {type = "clear"},
			showrealm = {
				type = "toggle",
				value = true,
				label = "Show Realm Name"
			},
			itemids = {
				type = "toggle",
				value = false,
				label = "Enable itemIDs in tooltip"
			},
			spellids = {
				type = "toggle",
				value = true,
				label = "Enable spellIDs in tooltip"
			},
		}
	},
	mouseovertooltips = {
		type = "group",
		heading = "Lite Tooltips",
		args = {
			enablemott = {
				type = "toggle",
				value = true,
				label = "Enable lite tooltips on unit mouseover"
			}
		}
	},
	colors = {
		type = "tab",
		value = "Colors",
		args = {
			enablelinecolors = {
				type = "toggle",
				value = true,
				label = "Enable line-coloring"
			}
		}
	},
	anothertab = {
		type = "tab",
		value = "Colors",
		args = {
			enablelinecolor2 = {
				type = "toggle",
				value = true,
				label = "Enable line-coloring 2"
			}
		}
	}
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