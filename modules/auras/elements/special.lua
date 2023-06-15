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

	-- totgc
	["Penetrating Cold"] = true,

}

for k,v in pairs(special) do bdUI.aura_lists.special[k] = v end
-- bdUI.aura_lists.special = special