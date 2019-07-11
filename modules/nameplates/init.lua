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

local specialSpells = {}
specialSpells["Decaying Flesh"] = true
specialSpells["Critial Mass"] = true

-- Config Table
local config = bdConfig:helper_config()
config:add("enabled", {
	type = "checkbox",
	value = true,
	label = "Enable",
})

--=======================================
-- Positioning & Display
--=======================================
config:add("tab", {
	type="tab",
	value="Sizing & Display"
})
config:add("text", {
	type="text",
	value="Because of the way blizzard renders nameplates, you may have to type /reload to see certain changes take place."
})
config:add("scale", {
	type="slider",
	value=1,
	min=0,
	max=1,
	step=0.1,
	label="Nameplates Scale",
})

config:add("width", {
	type="slider",
	value=200,
	min=30,
	max=250,
	step=2,
	label="Nameplates Width",
})

config:add("height", {
	type="slider",
	value=20,
	min=4,
	max=50,
	step=2,
	label="Nameplates Height",
})
config:add("targetingTopPadding", {
	type="slider",
	value=10,
	min=0,
	max=30,
	step=2,
	label="Click target padding top",
	tooltip="Lets you click target units x pixels above their healthbar",
})

config:add("targetingBottomPadding", {
	type="slider",
	value=5,
	min=0,
	max=30,
	step=2,
	label="Click target padding bottom",
	tooltip="Lets you click target units x pixels below their healthbar",
})

config:add("friendnamealpha", {
	type="slider",
	value=1,
	min=0,
	max=1,
	step=0.1,
	label="Friendly Name Opacity",
})

config:add("showCenterDot", {
	type = "checkbox",
	value = false,
	label = "Show center dot, useful for tracking character",
})

config:add("highlightPurge", {
	type = "checkbox",
	value = true,
	label = "Highlist units who have auras that can be purged",
})

config:add("highlightEnrage", {
	type = "checkbox",
	value = false,
	label = "Auto whitelist enrage auras on units.",
})

config:add("friendlynamehack", {
	type = "checkbox",
	value = false,
	label = "Friendly Names in Raid",
	tooltip = "This will disable friendly nameplates in raid while keeping the friendly name. Uncheck this before uninstalling bdNameplates. ",
})
config:add("friendlyplates", {
	type = "checkbox",
	value = false,
	label = "Show friendly nameplate healthbars",
	tooltip = "Normally we hide friendly healthbars and just show names, this will let you show both. ",
})
config:add("verticalspacing", {
	type="slider",
	value=1.8,
	min=0,
	max=4,
	step=0.1,
	label="Vertical Spacing",
})
config:add("castbarheight", {
	type="slider",
	value=18,
	min=4,
	max=50,
	step=2,
	label="Castbar Height",
})
config:add("castbariconscale", {
	type="slider",
	value=1,
	min=0.1,
	max=1,
	step=0.1,
	label="Castbar Icon Scale",
})

config:add("nameplatedistance", {
	type="slider",
	value=50,
	min=10,
	max=100,
	step=2,
	label="Nameplates Draw Distance",
})
config:add("hidecasticon", {
	type = "checkbox",
	value = false,
	label = "Hide Castbar Icon",
})

--=======================================
-- TEXT
--=======================================
config:add("tab", {
	type="tab",
	value="Text"
})
config:add("hptext", {
	type = "dropdown",
	value = "HP - %",
	options = {"None","HP - %", "HP", "%"},
	label = "Nameplate Health Text",
})
config:add("showcasttarget", {
	type = "checkbox",
	value = false,
	label = "Show Health Text on target only",
})
config:add("showcastinterrupt", {
	type = "checkbox",
	value = true,
	label = "Show castbar target (experimental)",
})
config:add("showhptexttargetonly", {
	type = "checkbox",
	value = false,
	label = "Show Health Text on target only",
})
config:add("showenergy", {
	type = "checkbox",
	value = false,
	label = "Show energy value on healthbar",
})
config:add("hideEnemyNames", {
	type = "dropdown",
	value = "Always Show",
	options = {"Always Show", "Always Hide", "Only Target", "Hide in Arena"},
	label = "Hide Enemy Names",
})
config:add("hidefriendnames", {
	type = "checkbox",
	value = false,
	label = "Hide Friendly Names",
})
config:add("enemynamesize", {
	type="slider",
	value=16,
	min=8,
	max=24,
	step=1,
	label="Enemy Name Font Size",
})
config:add("friendlynamesize", {
	type="slider",
	value=16,
	min=8,
	max=24,
	step=1,
	label="Friendly Name Font Size",
})
config:add("markposition", {
	type = "dropdown",
	value = "TOP",
	options = {"LEFT","TOP","RIGHT"},
	label = "Raid Marker position",
	tooltip = "Where raid markers should be positioned on the nameplate.",
})
config:add("raidmarkersize", {
	type="slider",
	value=24,
	min=10,
	max=50,
	step=2,
	label="Raid Marker Icon Size",
})

--=======================================
-- COLORS
--=======================================
config:add("tab", {
	type="tab",
	value="Colors"
})
config:add("kickable", {
	type="color",
	value = {.1, .4, .7, 1},
	name="Interruptable Cast Color"
})
config:add("nonkickable", {
	type="color",
	value = {.7, .7, .7, 1},
	name="Non-Interruptable Cast Color"
})
config:add("glowcolor", {
	type="color",
	value = {1, 1, 1, 0.6},
	name="Target Glow Color"
})
config:add("threatcolor", {
	type="color",
	value = {.79, .3, .21, 1},
	name="Have Aggro Color"
})
config:add("nothreatcolor", {
	type="color",
	value = {0.3, 1, 0.3,1},
	name="No Aggro Color"
})
config:add("threatdangercolor", {
	type="color",
	value = {1, .55, 0.3,1},
	name="Danger Aggro Color"
})
config:add("executecolor", {
	type="color",
	value = {.1, .4, .7,1},
	name="Execute Range Color"
})
config:add("specialcolor", {
	type="color",
	value = {.8, .4, .7,1},
	name="Special Unit Color"
})
config:add("purgeColor", {
	type = "color",
	value = bdUI.media.blue,
	name = "Special Unit Color"
})
config:add("enrageColor", {
	type = "color",
	value = bdUI.media.red,
	name = "Special Unit Color"
})
config:add("clear", {
	type = "clear"
})
config:add("executerange", {
	type = "slider",
	value=20,
	min=0,
	max=40,
	step=5,
	label = "Execute range",
})
config:add("unselectedalpha", {
	type="slider",
	value=0.5,
	min=0.1,
	max=1,
	step=0.1,
	label="Unselected nameplate alpha",
})
-------------
-- Special Units
-------------
config:add("tab", {
	type="tab",
	value="Fixates & Specials"
})
config:add("fixatealert", {
	type = "dropdown",
	value = "Hide",
	options = {"Always", "Personal", "Hide"},
	label = "Target/Fixate Alert"
})
config:add("specialunits", {
	type = "list",
	value = specialMobs,
	autoadd = specialMobs,
	label = "Special Unit List",
	tooltip = "Units who's name are in this list will have their healthbar colored with the 'Special Unit Color' "
})
config:add("fixateMobs", {
	type = "list",
	value = fixateMobs,
	autoadd = fixateMobs,
	label = "Fixate Unit List",
	tooltip = "Units who's name are in this list will have a fixate icon when they target you."
})
config:add("specialSpells ", {
	type = "list",
	value = specialSpells,
	label = "Special Spell List",
	tooltip = "Units who have an aura in this list will be colored with 'Special Unit Color'."
})

-------------
-- Your Debuffs
-------------
config:add("tab", {
	type="tab",
	value="Auras"
})
config:add("automydebuff", {
	type="checkbox",
	value=false,
	label="Automatically track debuffs cast by you."
})
config:add("selfwhitelist", {
	type="list",
	value = {},
	label="Enemy Debuffs (cast by you)",
	tooltip="Use to show a specified aura cast by you."
})

config:add("raidbefuffs", {
	type="slider",
	value=50,
	min=20,
	max=100,
	step=2,
	label="Raid Debuff Size",
})
config:add("whitelist", {
	type="list",
	value=defaultwhitelist,
	label="Friendly/Enemy Auras (cast by anyone)",
	tooltip="Use to show a specified aura cast by anyone."
})

config:add("disableauras", {
	type="checkbox",
	value=false,
	label="Don't show any auras."
})
config:add("text", {
	type="text",
	value="Certain abilities are tracked by default, i.e. stuns / silences. You can stop these from showing up using the blacklist. "
})
config:add("blacklist", {
	type="list",
	value = {},
	label="Aura Blacklist",
	tooltip="Useful if you want to blacklist any auras that Blizzard tracks by default."
})

local mod = bdUI:register_module("Nameplates", config)
mod.cache = {}