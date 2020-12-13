local bdUI, c, l = unpack(select(2, ...))
bdUI.aura_lists = bdUI.aura_lists or {}

local special = {
	['Sentence of Sargeras'] = true,
	['Soulblight'] = true,
	['Soulbomb'] = true,
	['Fulminating Pulse'] = true,
	['Chilled Blood'] = true,

	["Ember Blast"] = true,
	["Soul Infusion"] = true,
}

bdUI.aura_lists.special = special