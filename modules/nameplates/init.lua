--===============================================
-- INIT
--===============================================
local bdUI, c, l = unpack(select(2, ...))

-- populate configuration lists
local defaultwhitelist = {}
defaultwhitelist['Arcane Torrent'] = true
defaultwhitelist['War Stomp'] = true

local fixateMobs = {}
fixateMobs['Tormented Fragment'] = true
fixateMobs['Razorjaw Gladiator'] = true
fixateMobs['Sickly Tadpole'] = true
fixateMobs['Soul Residue'] = true
fixateMobs['Nightmare Ichor'] = true
fixateMobs['Atrigan'] = true
fixateMobs['Tester'] = true

local specialMobs = {}
specialMobs["Fel Explosives"] = true
specialMobs["Fanatical Pyromancer"] = true
specialMobs["Felblaze Imp"] = true
specialMobs["Hungering Stalker"] = true
specialMobs["Fel-Powered Purifier"] = true
specialMobs["Fel-Infused Destructor"] = true
specialMobs["Fel-Charged Obfuscator"] = true
specialMobs["Ember of Taeshalach"] = true
specialMobs["Screaming Shrike"] = true
specialMobs["Explosives"] = true
specialMobs["Web Wrap"] = true
specialMobs["Dreadsoul Devil"] = true
specialMobs["Dreadsoul Concordance"] = true

local specialSpells = {}
specialSpells["Decaying Flesh"] = true
specialSpells["Critial Mass"] = true

-- Config Table
-- Config Table
local config = {
	{
		key = "enabled",
		type = "toggle",
		value = true,
		label = "Enable Nameplates"
	},
	--============================================
	-- Positioning & Display
	--============================================
	{
		key = "sizing_display_tab",
		type = "tab",
		label = "Sizing & Display",
		args = {
			{
				key = "text",
				type = "text",
				value = "*Because of the restrictions blizzard places on nameplates, you may have to type /reload to see certain changes take place."
			},
			{
				key = "heading",
				type = "heading",
				value = "Sizing"
			},
			{
				key = "scale",
				type = "range",
				value = 0.7,
				step = 0.1,
				min = 0,
				max = 1,
				label = "Global Nameplate Scale",
			},
			{
				key = "width",
				type = "range",
				value = 200,
				min = 30,
				max = 250,
				step = 2,
				label = "Nameplates Width",
			},
			{
				key = "height",
				type = "range",
				value = 22,
				min = 4,
				max = 50,
				step = 2,
				label = "Nameplates Height",
			},
			{
				key= "targetingTopPadding",
				type = "range",
				value = 10,
				min = 0,
				max = 30,
				step = 2,
				label = "Click target padding top",
			},
			{
				key = "targetingBottomPadding",
				type = "range",
				value = 5,
				min = 0,
				max = 30,
				step = 2,
				label = "Click target padding bottom",
			},
			{
				key = "castbarheight",
				type = "range",
				value = 18,
				min = 4,
				max = 50,
				step = 2,
				label = "Castbar Height",
			},
			{
				key = "castbariconscale",
				type = "range",
				value = 1,
				min = 0.1,
				max = 1,
				step = 0.1,
				label = "Castbar Icon Scale",
			},
			{
				key = "heading",
				type = "heading",
				value = "Display"
			},
			{
				key = "friendnamealpha",
				type = "range",
				value = 1,
				min = 0,
				max = 1,
				step = 0.1,
				label = "Friendly Name Opacity",
			},
			{
				key = "highlightPurge",
				type = "toggle",
				value = false,
				label = "Highlight units who have purgeable auras",
			},
			{
				key = "highlightEnrage",
				type = "toggle",
				value = false,
				label = "Auto whitelist enrage auras on units.",
			},
			{
				key = "friendlynamehack",
				type = "toggle",
				value = false,
				label = "Friendly Names in Raid",
			},
			{
				key = "friendlyplates",
				type = "toggle",
				value = false,
				label = "Show friendly nameplate healthbars",
			},
			-- {
			-- 	key = "verticalspacing",
			-- 	type = "range",
			-- 	value = 1.8,
			-- 	min = 0,
			-- 	max = 4,
			-- 	step = 0.1,
			-- 	label = "Vertical Spacing",
			-- },
			
			{
				key = "nameplatedistance",
				type = "range",
				value = 50,
				min = 10,
				max = 100,
				step = 2,
				label = "Nameplates Draw Distance",
			},
			{
				key = "hidecasticon",
				type = "toggle",
				value = false,
				label = "Hide Castbar Icon",
			},
			{
				key = "enablequests",
				type = "toggle",
				value = true,
				label = "Enable Quest Display on Nameplates",
			},
		}
	},
	{
		key = "cvars",
		type = "tab",
		label = "CVars",
		args = {
			{
				key = "stacking",
				type = "select",
				options = {"Stacking", "Overlapping"},
				value = "Stacking",
				label = "Positioning Behavior",
			},
			{
				key = "stackingspeed",
				type = "range",
				value = 0.025,
				min = 0,
				max = 1,
				step = 0.05,
				label = "Positioning speed",
			},
			{
				key = "largerscale",
				type = "range",
				value = 1.2,
				min = 0.8,
				max = 2,
				step = 0.1,
				label = "Boss nameplate scale",
			},
			{
				key = "unselectedalpha",
				type = "range",
				value = 0.5,
				min = 0.1,
				max = 1,
				step = 0.1,
				label = "Unselected alpha",
			},
			{
				key = "selectedscale",
				type = "range",
				value = 1,
				min = 0.1,
				max = 2,
				step = 0.1,
				label = "Selected Scale",
			},
			{
				key = "occludedalpha",
				type = "range",
				value = 0.6,
				min = 0.1,
				max = 1,
				step = 0.1,
				label = "Occluded nameplate alpha",
			},
			-- {
			-- 	key = "oocalpha",
			-- 	type = "range",
			-- 	value = 0.6,
			-- 	min = 0,
			-- 	max = 1,
			-- 	step = 0.1,
			-- 	label = "Out of combat nameplates alpha",
			-- },
			-- {
			-- 	key = "oocscale",
			-- 	type = "range",
			-- 	value = 0.7,
			-- 	min = 0,
			-- 	max = 1,
			-- 	step = 0.1,
			-- 	label = "Out of combat nameplates scale",
			-- },
			
		}
	},
	--=======================================
	-- TEXT
	--=======================================
	{
		key = "tab",
		type = "tab",
		label = "Text",
		args = {
			{
				key = "hptext",
				type = "select",
				value = "HP - %",
				options = {"None","HP - %", "HP", "%"},
				label = "Nameplate Health Text",
			},
			{
				key = "showcasttarget",
				type = "toggle",
				value = false,
				label = "Show castbar target (experimental)",
			},
			{
				key = "showcastinterrupt",
				type = "toggle",
				value = true,
				label = "Show who interrupted casts",
			},
			{
				key = "showhptexttargetonly",
				type = "toggle",
				value = true,
				label = "Show Health Text on target only",
			},
			{
				key = "showenergy",
				type = "toggle",
				value = false,
				label = "Show energy value on healthbar",
			},
			{
				key = "hideEnemyNames",
				type = "select",
				value = "Always Show",
				options = {"Always Show", "Always Hide", "Only Target", "Hide in Arena"},
				label = "Hide Enemy Names",
			},
			{
				key = "hidefriendnames",
				type = "toggle",
				value = false,
				label = "Hide Friendly Names",
			},
			{
				key = "enemynamesize",
				type = "range",
				value = 16,
				min = 8,
				max = 24,
				step = 1,
				label = "Enemy Name Font Size",
			},
			{
				key = "friendlynamesize",
				type = "range",
				value = 16,
				min = 8,
				max = 24,
				step = 1,
				label = "Friendly Name Font Size",
			},
			{
				key = "markposition",
				type = "select",
				value = "TOP",
				options = {"LEFT","TOP","RIGHT"},
				label = "Raid Marker position",
				tooltip = "Where raid markers should be positioned on the nameplate.",
			},
			{
				key = "raidmarkersize",
				type = "range",
				value = 24,
				min = 10,
				max = 50,
				step = 2,
				label = "Raid Marker Icon Size",
			},
		}
	},
	--=======================================
	-- COLORS
	--=======================================
	{
		key = "tab",
		type = "tab",
		value = "Colors",
		args = {
			{
				key = "kickable",
				type = "color",
				value = {.1, .4, .7, 1},
				label = "Interruptable Cast Color"
			},
			{
				key = "nonkickable",
				type = "color",
				value = {.7, .7, .7, 1},
				label = "Non-Interruptable Cast Color"
			},
			{
				key = "glowcolor",
				type = "color",
				value = {1, 1, 1, 0.6},
				label = "Target Glow Color"
			},
			{
				key = "threatcolor",
				type = "color",
				value = {.79, .3, .21, 1},
				label = "Have Aggro Color"
			},
			{
				key = "nothreatcolor",
				type = "color",
				value = {0.3, 1, 0.3,1},
				label = "No Aggro Color"
			},
			{
				key = "threatdangercolor",
				type = "color",
				value = {1, .55, 0.3,1},
				label = "Danger Aggro Color"
			},
			{
				key = "executecolor",
				type = "color",
				value = {.1, .4, .7,1},
				label = "Execute Range Color"
			},
			{
				key = "specialcolor",
				type = "color",
				value = {.8, .4, 1, 1},
				label = "Special Unit Color"
			},
			{
				key = "purgeColor",
				type = "color",
				value = bdUI.media.blue,
				label = "Special Unit Color"
			},
			{
				key = "enrageColor",
				type = "color",
				value = bdUI.media.red,
				label = "Enrage Unit Color"
			},
			{
				key = "clear",
				type = "clear"
			},
			{
				key = "executerange",
				type = "range",
				value = 20,
				min = 0,
				max = 40,
				step = 5,
				label = "Execute range",
			},
		}
	},
	-------------
	-- Special Units
	-------------
	{
		key = "tab",
		type = "tab",
		value = "Fixates & Specials",
		args = {
			{
				key = "fixatealert",
				type = "select",
				value = "Hide",
				options = {"Always", "Personal", "Hide"},
				label = "Target/Fixate Alert"
			},
			{
				key = "specialunits",
				type = "list",
				value = specialMobs,
				autoadd = specialMobs,
				label = "Special Unit List",
				tooltip = "Units who's name are in this list will have their healthbar colored with the 'Special Unit Color' "
			},
			{
				key = "fixateMobs",
				type = "list",
				value = fixateMobs,
				autoadd = fixateMobs,
				label = "Fixate Unit List",
				tooltip = "Units who's name are in this list will have a fixate icon when they target you."
			},
			{
				key = "specialSpells ",
				type = "list",
				value = specialSpells,
				label = "Special Spell List",
				tooltip = "Units who have an aura in this list will be colored with 'Special Unit Color'."
			},
		}
	},
	-------------
	-- Auras
	-------------
	{
		key = "tab",
		type = "tab",
		value = "Auras",
		args = {
						{
				key = "automydebuff",
				type = "toggle",
				value = true,
				label = "Automatically track debuffs cast by you."
			},
			{
				key = "raidbefuffs",
				type = "range",
				value = 50,
				min = 20,
				max = 100,
				step = 2,
				label = "Raid Debuff Size",
			},
			{
				key = "disableauras",
				type = "toggle",
				value = false,
				label = "Don't show any auras."
			},
			{
				key = "selfwhitelist",
				type = "list",
				value = {},
				label = "Debuffs Cast By You",
				tooltip="Use to show a specified aura cast by you."
			},
			{
				key = "whitelist",
				type = "list",
				value = defaultwhitelist,
				label = "Auras Cast by Anyone",
				tooltip="Use to show a specified aura cast by anyone."
			},
			{
				key = "blacklist",
				type = "list",
				value = {},
				label = "Aura Blacklist",
				tooltip="Useful if you want to blacklist any auras that Blizzard tracks by default.",
			},
		}
	},
}

local mod = bdUI:register_module("Nameplates", config)
mod.cache = {}