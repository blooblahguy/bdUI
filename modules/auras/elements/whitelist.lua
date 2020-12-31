local bdUI, c, l = unpack(select(2, ...))
bdUI.aura_lists = bdUI.aura_lists or {}

local auras = {
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
	
	-- Mages
	["Ice Block"] = true,
	["Temporal Shield"] = true,
	["Cauterize"] = true,
	["Greater Invisibility"] = true,
	["Amplify Magic"] = true,
	["Evanesce"] = true,
	["Polymorph"] = true,
	["Polymorph: Fish"] = true,
	
	-- Warlocks
	["Dark Bargain"] = true,
	["Unending Resolve"] = true,
	
	-- Paladins
	["Divine Shield"] = true,
	["Divine Protection"] = true,
	["Blessing of Freedom"] = true,
	["Blessing of Sacrifice"] = true,
	["Ardent Defender"] = true,
	["Guardian of Ancient Kings"] = true,
	["Forbearance"] = true,
	["Hammer of Justice"] = true,
	
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
	
	-- Priests
	["Dispersion"] = true,
	["Spectral Guise"] = true,
	["Pain Suppression"] = true,
	["Fear"] = true,
	["Mind Bomb"] = true,
	["Surrender Soul"] = true,
	["Guardian Spirit"] = true,
	
	-- Demon hunters
	['Blur'] = true,
	['Demon Spikes'] = true,
	['Metamorphosis'] = true,
	['Empower Wards'] = true,
	['Netherwalk'] = true,
	
	-- all palyers
	['Draenic Channeled Mana Potion'] = true,
	['Leytorrent Potion'] = true,
	['Sanguine Ichor'] = true,
}

bdUI.aura_lists.whitelist = auras