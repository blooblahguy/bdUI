--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

local function tags_config(title, frame, options)
	local defaults = {
		outside_left = "",
		inside_left = "",
		inside_center = "[name]",
		inside_right = "",
		outside_right = "",
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
				key = frame .. "_outside_left",
				type = "input",
				value = defaults.outside_left,
				label = "Outside Left",
			},
			{
				key = frame .. "_outside_right",
				type = "input",
				value = defaults.outside_right,
				label = "Outside Right",
				align = "right"
			},
			{
				key = "clear",
				type = "clear",
			},
			{
				key = frame .. "_inside_left",
				type = "input",
				value = defaults.inside_left,
				label = "Inside Left",
				size = "third"
			},
			{
				key = frame .. "_inside_center",
				type = "input",
				value = defaults.inside_center,
				label = "Inside Center",
				size = "third"
			},
			{
				key = frame .. "_inside_right",
				type = "input",
				value = defaults.inside_right,
				label = "Inside Right",
				size = "third"
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
	--=========================================
	-- General / Global settings
	--=========================================
	{
		key = "general_tab",
		type = "tab",
		label = "General",
		args = {
			{
				key = "enablecastbars",
				value = true,
				type = "toggle",
				label = "Enable Castbars"
			},
			{
				key = "enable_rested_indicator",
				value = true,
				type = "toggle",
				label = "Rested Indicator"
			},
			{
				key = "enable_combat_indicator",
				value = true,
				type = "toggle",
				label = "Combat Indicator"
			},
			{
				key = "clear",
				type = "clear",
			},
			{
				key = "inrangealpha",
				value = 1,
				min = 0.1,
				max = 1,
				step = 0.1,
				type = "range",
				label = "In Range Frame Alpha"
			},
			{
				key = "outofrangealpha",
				value = 0.6,
				min = 0.1,
				max = 1,
				step = 0.1,
				type = "range",
				label = "Out of Range Frame Alpha"
			},
			{
				key = "textlocation",
				value = "Outside",
				type = "select",
				options = { "Outside", "Inside", "Minimal" },
				label = "Text Display"
			},
			{
				key = "aurastyle",
				value = "Bars",
				type = "select",
				options = { "Icons", "Bars", "None" },
				label = "Aura Style"
			},
			{
				key = "clear",
				type = "clear",
			},
			{
				key = "unitframe_ic_alpha",
				value = 1,
				min = 0.1,
				max = 1,
				step = 0.1,
				type = "range",
				label = "In Combat Alpha"
			},
			{
				key = "unitframe_resting_alpha",
				value = 1,
				min = 0,
				max = 1,
				step = 0.1,
				type = "range",
				label = "Inn / City Alpha"
			},
		}
	},

	--=========================================
	-- PLAYER & TARGET
	--=========================================
	{
		key = "tags_tab",
		type = "tab",
		label = "Frame Text",
		args = {
			tags_config("Player", "player", {
				outside_left = "",
				inside_left = "[bd:curpp]",
				inside_center = "[bd:combat][bd:resting][pvp]",
				inside_right = "[hpcolor][bd:curhp] - [perhp][/hpcolor]",
				outside_right = "",
			}),
			tags_config("Target", "target", {
				inside_left = "[bd:curpp]",
				inside_center = "[status]",
				outside_right = "[bd:name] [bd:rarity]",
				inside_right = "[hpcolor][bd:curhp] - [perhp][/hpcolor]",
			}),
			tags_config("Target Of Target", "targettarget"),
			tags_config("Pet", "pet"),
			tags_config("Focus", "focus", {
				inside_left = "[bd:curpp]",
				inside_center = "[name]",
				inside_right = "[hpcolor][bd:curhp] - [perhp][/hpcolor]",
			}),
			tags_config("Boss", "boss", {
				inside_left = "[bd:curpp]",
				inside_center = "[name]",
				inside_right = "[hpcolor][bd:curhp] - [perhp][/hpcolor]",
			}),
		}
	},
	{
		key = "playertarget_tab",
		type = "tab",
		label = "Player & Target",
		args = {
			{
				key = "enableplayertarget",
				value = true,
				type = "toggle",
				label = "Enable Player, Target, ToT, & Pet"
			},
			{
				key = "showtargetbuffs",
				value = true,
				type = "toggle",
				label = "Show Target's Buffs"
			},
			{
				key = "playertargetwidth",
				value = 220,
				min = 100,
				max = 400,
				step = 2,
				type = "range",
				label = "Width"
			},
			{
				key = "playertargetheight",
				value = 32,
				min = 4,
				max = 60,
				step = 2,
				type = "range",
				label = "Height"
			},
			{
				key = "playerpowerheight",
				value = 2,
				min = 0,
				max = 10,
				step = 1,
				type = "range",
				label = "Player Power Height"
			},
			{
				key = "targetpowerheight",
				value = 2,
				min = 0,
				max = 10,
				step = 1,
				type = "range",
				label = "Target Power Height"
			},
			{
				key = "castbarheight",
				value = 20,
				step = 1,
				min = 6,
				max = 30,
				type = "range",
				label = "Castbar height"
			},
			{
				key = "castbaricon",
				value = 28,
				step = 1,
				min = 6,
				max = 50,
				type = "range",
				label = "Castbar Icon Size"
			},
			-- {
			-- 	key = "hideplayertext",
			-- 	type = "toggle",
			-- 	value = false,
			-- 	label = "Hide player text"
			-- },
			--=========================================
			-- BUFFS
			--=========================================
			{
				key = "uf_buffs",
				type = "group",
				label = "Buffs",
				args = {
					{
						key = "player_uf_buff_size",
						value = 22,
						step = 1,
						min = 6,
						max = 50,
						type = "range",
						label = "Player Buff size"
					},

					{
						key = "target_buff_location",
						value = "Top Right",
						type = "select",
						options = { "Top Right", "Right", "Bottom Right", "Bottom Left" },
						label = "Target Buff Start Point",
					},

					{
						key = "target_uf_debuff_size",
						value = 22,
						step = 1,
						min = 6,
						max = 50,
						type = "range",
						label = "Target debuff size"
					},

					{
						key = "target_uf_buff_size",
						value = 14,
						step = 1,
						min = 6,
						max = 50,
						type = "range",
						label = "Target Buff size"
					},

					-- {
					-- 	key = "uf_buff_target_match_player",
					-- 	type = "toggle",
					-- 	value = false,
					-- 	label = "target buffs match player"
					-- }

					-- {
					-- 	key = "uf_buff_size",
					-- 	value = 20,
					-- 	step = 1,
					-- 	min = 6,
					-- 	max = 50,
					-- 	type = "range",
					-- 	label = "Debuff Icon size"
					-- },
				}
			}

		}
	},
	--=========================================
	-- FOCUS
	--=========================================
	{
		key = "focustab",
		type = "tab",
		label = "Focus",
		args = {
			{
				key = "enablefocus",
				value = true,
				type = "toggle",
				label = "Enable Focus"
			},
			{
				key = "focuswidth",
				type = "range",
				label = "Width",
				value = 220,
				min = 50,
				max = 300,
				step = 2,
			},
			{
				key = "focusheight",
				type = "range",
				label = "Height",
				value = 30,
				min = 4,
				max = 40,
				step = 2,
			},
			{
				key = "focuspower",
				type = "range",
				label = "Power Height",
				value = 3,
				min = 0,
				max = 10,
				step = 1,
			},
		}
	},
	--=========================================
	-- ToT & Pet
	--=========================================
	{
		key = "totpettab",
		type = "tab",
		label = "Target's Target & Pet",
		args = {
			{
				key = "targetoftargetwidth",
				type = "range",
				label = "Width",
				value = 120,
				min = 60,
				max = 220,
				step = 2,
			},
			{
				key = "targetoftargetheight",
				type = "range",
				label = "Height",
				value = 16,
				min = 6,
				max = 30,
				step = 2,
			},
		}
	},
	--=========================================
	-- BOSS & Arena
	--=========================================
	{
		key = "bosstab",
		type = "tab",
		label = "Boss",
		args = {
			{
				key = "bossenable",
				value = true,
				type = "toggle",
				label = "Enable Boss Frames"
			},
			{
				key = "bossdebuffsize",
				type = "range",
				label = "Aura Size",
				value = 30,
				min = 10,
				max = 100,
				step = 2,
			},
			{
				key = "bosswidth",
				type = "range",
				label = "Width",
				value = 200,
				min = 60,
				max = 420,
				step = 5,
			},
			{
				key = "bossheight",
				type = "range",
				label = "Height",
				value = 34,
				min = 5,
				max = 200,
				step = 5,
			},
			{
				key = "bosspower",
				type = "range",
				label = "Power Height",
				value = 3,
				min = 0,
				max = 10,
				step = 1,
			},
		}
	}
}

local mod = bdUI:register_module("Unitframes", config)

--=============================================
-- Initialize function
--=============================================
function mod:initialize()
	mod.config = mod:get_save()
	if (not mod.config.enabled) then return false end

	mod:create_unitframes()
end
