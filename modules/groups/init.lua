--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))


-- Config Table
local config = {
	-- raid frames
	{
		key = "tab",
		type = "tab",
		label = "Raid",
		args = {
			{
				key = "enabled_raid",
				type = "toggle",
				value = true,
				label = "Enable Raid Frames"
			},
			{
				key = "link_to_auras",
				type = "link",
				value = "Go to Auras configuration",
				callback = function() bdUI.bdConfig:get_module("Auras"):select() end
			},
			--=============================================
			-- Frames Display
			--=============================================
			{
				key = "tab",
				type = "tab",
				label = "Display",
				args = {
					{
						key = "tab",
						type = "tab",
						label = "Sizing",
						args = {
							{
								key = "spacing",
								type = "range",
								value = 2,
								min = 0,
								max = 8,
								step = 1,
								label = "Frame Spacing",
								size = "third"
							},
							{
								key = "width",
								type = "range",
								value = 62,
								min = 20,
								max = 100,
								step = 2,
								label = "Width",
								tooltip = "The width of each player in the raid frames",
								size = "third"
							},
							{
								key = "height",
								type = "range",
								value = 50,
								min = 20,
								max = 100,
								step = 2,
								label = "Height",
								tooltip = "The height of each player in the raid frames",
								size = "third"
							},
						},
					},
					{
						key = "tab",
						type = "tab",
						label = "Pets",
						args = {
							-- {
							-- 	key = "pets_spacing",
							-- 	type = "range",
							-- 	value = 2,
							-- 	min = 0,
							-- 	max = 8,
							-- 	step = 1,
							-- 	label = "Frame Spacing",
							-- 	size = "third"
							-- },
							{
								key = "pets_enable",
								type = "toggle",
								value = true,
								label = "Enable pet frames",
								size = "full"
							},
							{
								key = "pets_width",
								type = "range",
								value = 52,
								min = 20,
								max = 100,
								step = 2,
								label = "Width",
								tooltip = "The width of each pet in the raid frames",
								size = "half"
							},
							{
								key = "pets_height",
								type = "range",
								value = 36,
								min = 20,
								max = 100,
								step = 2,
								label = "Height",
								tooltip = "The height of each pet in the raid frames",
								size = "half"
							},
						},
					},
					{
						key = "tab",
						type = "tab",
						label = "Power",
						args = {
							{
								key = "powerdisplay",
								type = "select",
								value = "All",
								options = {"None","Healers","All"},
								label = "Power Bar Display",
								tooltip = "Show mana/energy/rage bars on frames.",
							},
							{
								key = "powerheight",
								type = "range",
								value = 2,
								min = 2,
								max = 20,
								step = 1,
								label = "Power Bar Height",
								tooltip = "The height of mana/energy/rage",
							},
						},
					},
					{
						key = "tab",
						type = "tab",
						label = "Misc",
						args = {
							{
								key = "showsolo",
								type = "toggle",
								value = true,
								label = "Show raid frames when solo",
							},
							{
								key = "hideabsorbs",
								type = "toggle",
								value = false,
								label = "Hide Absorbs",
								tooltip = "Not recommended, hide absorbs for units",
							},
							{
								key = "hidetooltips",
								type = "toggle",
								value = true,
								label = "Hide Tooltips",
								tooltip = "Hide tooltips when mousing over each unit",
							},
							{
								key = "showGroupNumbers",
								type = "toggle",
								value = false,
								label = "Show group numbers in raid",
							},
							{
								key = "invert",
								type = "toggle",
								value = false,
								label = "Invert Frame Colors",
								tooltip = "Make the main color of the frames a dark grey, and the backgrounds the class color.",
							},
							{
								key = "clear",
								type = "clear",
							},
							{
								key = "inrangealpha",
								type = "range",
								value = 1,
								min = 0.1,
								max = 1,
								step = 0.1,
								label = "In Range Alpha",
								tooltip = "The transparency of a player who's in range",
							},
							{
								key = "outofrangealpha",
								type = "range",
								value = 0.4,
								min = 0.0,
								max = 1.0,
								step = 0.1,
								label = "Out of Range Alpha",
								tooltip = "The transparency of a player who's out of range",
							},
						},
					},
				},
			},
			--=============================================
			-- Spell Highlights
			--=============================================
			{
				key = "tab",
				type = "tab",
				label = "Highlights",
				args = {
					{
						key = "text",
						type = "text",
						value = "Spells in the following list will create a 'Glow' animation around the frame when the unit has the bufff OR debuff.",
					},
					{
						key = "showspecialicons",
						type = "toggle",
						value = true,
						label = "Show Special Spell icons by default",
					},

					{
						key = "specialalerts",
						type = "list",
						value = bdUI.aura_lists.special,
						label = "Special Alerts",
					},
				}
			},
			--=============================================
			-- Aura Display
			--=============================================
			{
				key = "tab",
				type = "tab",
				label = "Icon Displays",
				args = {
					{
						key = "buffSize",
						type = "range",
						value = 14,
						min = 8,
						max = 40,
						step = 2,
						label = "Buff Size",
						tooltip = "Size of each buff icon.",
					},
					{
						key = "debuffSize",
						type = "range",
						value = 16,
						min = 8,
						max = 40,
						step = 2,
						label = "Debuff Size",
						tooltip = "Size of each debuff icon.",
					},
					{
						key = "showBuffTimers",
						type = "toggle",
						value = false,
						label = "Show buff cooldown timers",
					},
					{
						key = "showDebuffTimers",
						type = "toggle",
						value = false,
						label = "Show debuff cooldown timers",
					},

					{
						key = "roleicon",
						type = "toggle",
						value = true,
						label = "Show role icon for tanks and healers",
						tooltip = "Will only show icon for tanks/healers (only in groups)",
					},
					{
						key = "showpartyleadericon",
						type = "toggle",
						value = true,
						label = "Show Party Leader Indicator",
					},

				}
			},
			--=============================================
			-- Growth & Grouping
			--=============================================
			{
				key = "tab",
				type = "tab",
				label = "Growth & Grouping",
				args = {
					{
						key = "num_groups",
						type = "range",
						value = 4,
						min = 1,
						max = 8,
						step = 1,
						label = "Default number of Groups",
						tooltip = "How many groups should be shown at a time",
					},
					{
						key = "intel_groups",
						type = "toggle",
						value = true,
						label = "Automatically set group size.",
						tooltip = "When in LFR, show 5 groups, mythic show 4, etc.",
					},
					{
						key = "group_growth",
						type = "select",
						value = "Right",
						options = {"Left","Right","Upwards","Downwards"},
						label = "Group stack direction",
						tooltip = "Group stacking direction for when a new group is added.",
					},
					{
						key = "new_player_reverse",
						type = "toggle",
						value = false,
						label = "Reverse new player growth.",
						tooltip = "When a new player is added the default growth direction is Downward or Right depending on your group growth.",
					},
					{
						key = "group_sort",
						type = "select",
						value = "Group",
						options = {"Group","Role","Class","Name"},
						label = "Group By",
						tooltip = "Method by which the groups should be formed.",
					},
				}
			},
			--=============================================
			-- Names
			--=============================================
			{
				key = "tab",
				type = "tab",
				label = "Names",
				args = {
					{
						key = "namewidth",
						type = "range",
						value = 5,
						min = 0,
						max = 12,
						step = 1,
						label = "Truncate names to: ",
						tooltip = "Longer names will be trucated to this size",
					},
					-- {
					-- 	key = "aliases",
					-- 	type = "repeater",
					-- 	label = "Player Aliases",
					-- 	args = {
					-- 		{
					-- 			key = "player_name",
					-- 			type = "input",
					-- 			label = "Player Name",
					-- 		},
					-- 		{
					-- 			key = "player_alias",
					-- 			type = "input",
					-- 			label = "Player Alias"
					-- 		}
					-- 	}
					-- },
				}
			},
		},
	},

	-- party frames
	{
		key = "tab",
		type = "tab",
		label = "Party",
		args = {
			{
				key = "enabled_party",
				type = "toggle",
				value = true,
				label = "Enable Party Frames"
			},
			{
				key = "text",
				type = "text",
				value = "This area is a work in progress, check back later!",
			},
		}
	},

	-- arena frames
	{
		key = "tab",
		type = "tab",
		label = "Arena",
		args = {
			{
				key = "enabled_arena",
				type = "toggle",
				value = true,
				label = "Enable Arena Frames"
			},
			{
				key = "text",
				type = "text",
				value = "This area is a work in progress, check back later!",
			},
		}
	},
}

local mod = bdUI:register_module("Groups", config)