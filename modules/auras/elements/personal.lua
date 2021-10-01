local bdUI, c, l = unpack(select(2, ...))
bdUI.aura_lists = bdUI.aura_lists or {}

-- these only show when you are playing that class
local class = {
	PRIEST = {
		["Weakened Soul"] = true,
	},
	PALADIN = {
		
	},
	DEATHKNIGHT = {
		
	},
	ROGUE = {
		
	},
	SHAMAN = {
		
	},
	WARLOCK = {
		
	},
	MAGE = {
		
	},
	MONK = {
		
	},
	HUNTER = {
		
	},
	DRUID = {
		
	},
	WARRIOR = {
		
	},
	DEMONHUNTER = {
		
	},
}

-- These show up when you're the caster
-- these are mostly just helpful for healers
local mine = {
	-- Warlock
	['Soulstone'] = true,

	-- Monk
	['Renewing Mist'] = true,
	['Soothing Mist'] = true,
	['Essence Font'] = true,
	['Enveloping Mist'] = true,

	-- Shamans
	['Riptide'] = true,
	['Healing Rain'] = true,

	-- Druids
	["Efflorenscence"] = true,
	["Lifebloom"] = true,
	["Rejuvenation"] = true,
	["Regrowth"] = true,
	["Wild Growth"] = true,
	["Cenarion Ward"] = true,
	["Rejuvenation (Germination)"] = true,
	
	-- Paladin
	["Bestow Faith"] = true,
	["Beacon of Virtue"] = true,
	["Beacon of Light"] = true,
	["Beacon of Faith"] = true,
	["Tyr's Deliverance"] = true,
	["Glimmer of Light"] = true,
	
	-- Priest
	["Weakened Soul"] = true,
	["Renew"] = true,
	["Prayer of Mending"] = true,
	["Atonement"] = true,
	["Penance"] = true,
	["Shadow Mend"] = true,
	["Power Word: Shield"] = true,
}

-- bdUI.aura_lists.mine = mine
-- bdUI.aura_lists.class = class
--  merge auras
for k,v in pairs(mine) do bdUI.aura_lists.mine[k] = v end
for k,v in pairs(class) do bdUI.aura_lists.class[k] = v end