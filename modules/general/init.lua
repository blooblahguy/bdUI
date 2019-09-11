--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

-- Config Table
local config = {
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
	}

}

local mod = bdUI:register_module("General", config)