local bdUI, c, l = unpack(select(2, ...))
bdUI.aura_lists = bdUI.aura_lists or {}

local auras = {
	-- paladins
	["Unyielding Faith"] = true,
	["Glyph of Templar's Verdict"] = true,
	["Beacon's Tribute"] = true,
	
	-- warlocks
	["Soul Leech"] = true,
	["Empowered Grasp"] = true,
	["Twilight Ward"] = true,
	["Shadow Trance"] = true,
	["Dark Refund"] = true,
	
	-- warriors
	["Bloody Healing"] = true,
	["Flurry"] = true,
	["Victorious"] = true,
	["Deep Wounds"] = true,
	["Mortal Wounds"] = true,
	["Blood Craze"] = true,
	["Ultimatum"] = true,
	["Sword and Board"] = true,
	
	-- Death Knights
	["Purgatory"] = true,
	
	-- misc
	["Honorless Target"] = true,
	["Spirit Heal"] = true,
	["Capacitance"] = true,
	
	["Sated"] = true,
	["Exhaustion"] = true,
	["Insanity"] = true,
	["Temporal Displacement"] = true,
	["Void-Touched"] = true,
	["Awesome!"] = true,
	["Griefer"] = true,
	["Vivianne Defeated"] = true,
	["Recently Mass Resurrected"] = true,
	
	
	-- Priests
	["Weakened Soul"] = true,
	
	-- Paladins
	["Beacon's Tribute"] = true
}

bdUI.aura_lists.blacklist = auras