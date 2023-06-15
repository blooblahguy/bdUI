local bdUI, c, l = unpack(select(2, ...))
bdUI.aura_lists = bdUI.aura_lists or {}


local auras = {
	-- all palyers
	['Draenic Channeled Mana Potion'] = true,
	['Leytorrent Potion'] = true,
	['Sanguine Ichor'] = true,
	['Arcane Torrent'] = true,
	['War Stomp'] = true,

	-- Warriors
	["Die by the Sword"] = true,
	["Shield Wall"] = true,
	["Demoralizing Shout"] = true,
	["Piercing Howl"] = true,
	["Enrage"] = true,
	--["Enraged Regeneration"] = true,
	--["Last Stand"] = true,
	["Safeguard"] = true,
	["Vigilance"] = true,
	["Shockwave"] = true,
	['Intimidating Shout'] = true,
	['Sunder Armor'] = true,
	['Mortal Strike'] = true,
	['Disarm'] = true,
	['Intimidating Shout'] = true,
	
	-- Druids
	["Barkskin"] = true,
	["Survival Instincts"] = true,
	["Ironbark"] = true,
	["Bristling Fur"] = true,
	["Cyclone"] = true,
	["Entangling Roots"] = true,
	["Rapid Innervation"] = true,
	["Mark of Ursol"] = true,
	["Ironfur"] = true,
	["Frenzied Regeneration"] = true,
	["Rage of the Sleeper"] = true,

	-- Shamans
	["Shamanistic Rage"] = true,
	["Astral Shift"] = true,
	["Stone Bulwark Totem"] = true,
	["Hex"] = true,
	["Reincarnation"] = true,
	
	-- Death Knights
	["Icebound Fortitude"] = true,
	["Anti-Magic Shell"] = true,
	["Anti-Magic Zone"] = true,
	["Vampiric Blood"] = true,
	["Rune Tap"] = true,
	["Strangulate"] = true,
	
	-- Rogues
	["Feint"] = true,
	["Cloak of Shadows"] = true,
	["Riposte"] = true,
	["Smoke Bomb"] = true,
	["Between the Eyes"] = true,
	["Sap"] = true,
	["Evasion"] = true,
	["Crimson Vial"] = true,
	['Blind'] = true,
	
	-- Mages
	["Ice Block"] = true,
	["Temporal Shield"] = true,
	["Cauterize"] = true,
	["Greater Invisibility"] = true,
	["Amplify Magic"] = true,
	["Evanesce"] = true,
	["Polymorph"] = true,
	["Polymorph: Fish"] = true,
	['Polymorph: Sheep'] = true,
	
	-- Warlocks
	["Dark Bargain"] = true,
	["Unending Resolve"] = true,
	['Banish'] = true,
	
	-- Paladins
	["Divine Shield"] = true,
	["Divine Protection"] = true,
	["Blessing of Freedom"] = true,
	["Blessing of Sacrifice"] = true,
	["Ardent Defender"] = true,
	["Guardian of Ancient Kings"] = true,
	["Forbearance"] = true,
	["Hammer of Justice"] = true,
	['Repentance'] = true,
	
	-- Monks
	["Fortifying Brew"] = true,
	["Zen Meditation"] = true,
	["Diffuse Magic"] = true,
	["Dampen Harm"] = true,
	["Touch of Karma"] = true,
	["Paralyze"] = true,
	
	-- Hunters
	["Aspect of the Turtle"] = true,
	["Roar of Sacrifice"] = true,
	["Ice Trap"] = true,
	["Aimed Shot"] = true,
	["Wing Clip"] = true,
	
	-- Priests
	["Dispersion"] = true,
	["Spectral Guise"] = true,
	["Pain Suppression"] = true,
	["Fear"] = true,
	["Mind Bomb"] = true,
	["Surrender Soul"] = true,
	["Guardian Spirit"] = true,
	["Psychic Scream"] = true,
	["Psychic Horror"] = true,
	["Silence"] = true,
	
	-- Demon hunters
	['Blur'] = true,
	['Demon Spikes'] = true,
	['Metamorphosis'] = true,
	['Empower Wards'] = true,
	['Netherwalk'] = true,
	['Imprison'] = true,
}

for k,v in pairs(auras) do bdUI.aura_lists.whitelist[k] = v end
-- bdUI.aura_lists.whitelist = auras