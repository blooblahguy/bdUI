--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local fonts = bdUI:get_fonts()

-- Config Table
local config = {
	{
		key = "tab",
		type = "tab",
		label = "Style",
		args = {
			{
				key = "font",
				type = "select",
				value = bdUI.media.font,
				options = fonts,
				label = "Font",
				size = "full",
				action = "bdUI/fonts",
				lookup = bdUI.get_fonts
			},
			{
				key = "change_fonts",
				type = "toggle",
				value = true,
				label = "Change Fonts UI-Wide"
			},
			{
				key = "background_color",
				type = "color",
				label = "Background Color",
				value = bdUI.media.backdrop
			},
			{
				type = "color",
				key = "border_color",
				label = "Border Color",
				value = bdUI.media.border
			},
			{
				type = "range",
				key = "border_size",
				label = "Border Thickness",
				value = 2,
				min = 0,
				max = 6,
				step = 1,
				callback = function() bdUI:do_action("bdUI/border_size") end,
			},
			{
				key = "skin_was",
				type = "toggle",
				value = true,
				label = "Skin WeakAuras"
			},
		}
	},
	{
		key = "tab",
		type = "tab",
		label = "Viewports",
		args = {
			{
				key = "topViewport",
				type = "range",
				value = 0,
				step = 5,
				min = 0,
				max = 300,
				label = "Top Viewport Size"
			},
			{
				key = "topViewportBGColor",
				type = "color",
				value = bdUI.media.backdrop,
				label = "Top Viewport Color"
			},
			{
				key = "bottomViewport",
				type = "range",
				value = 0,
				step = 5,
				min = 0,
				max = 300,
				label = "Bottom Viewport Size"
			},
			{
				key = "bottomViewportBGColor",
				type = "color",
				value = bdUI.media.backdrop,
				label = "Bottom Viewport Color"
			},
		}
	},
	{
		key = "tab",
		type = "tab",
		label = "Quality of Life",
		args = {
			{
				key = "autorelease",
				type = "toggle",
				value = true,
				label = "Auto Release in BGs"
			},
			{
				key = "autosell",
				type = "toggle",
				value = true,
				label = "Auto Sell Greys"
			},
			{
				key = "autorepair",
				type = "toggle",
				value = true,
				label = "Auto Repair"
			},
			{
				key = "autodismount",
				type = "toggle",
				value = true,
				label = "Auto Dismount & Stand"
			},
			{
				key = "doubleclickbo",
				type = "toggle",
				value = true,
				label = "Enable Double-click Buyouts"
			},
			{
				key = "errorblock",
				type = "toggle",
				value = true,
				label = "Block common errors"
			},
			{
				key = "gmotd",
				type = "toggle",
				value = true,
				label = "Alert new Guild Messages"
			},
			{
				key = "interrupt",
				type = "toggle",
				value = true,
				label = "Announce interrupts"
			},
		}
	},
	

}

local mod = bdUI:register_module("General", config)