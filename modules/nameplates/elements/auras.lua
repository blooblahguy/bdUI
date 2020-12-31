local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")

mod.forcedWhitelist = {
	-- CC
	['Banish'] = true,
	['Repentance'] = true,
	['Polymorph: Sheep'] = true,
	['Polymorph'] = true,
	['Blind'] = true,
	['Paralyze'] = true,
	['Imprison'] = true,
	['Sap'] = true,
	
	-- ToS
	-- DI
	['Fel Squall'] = true,
	['Bone Saw'] = true,
	['Harrowing Reconstitution'] = true,
	
	-- Harjatan
	['Hardened Shell'] = true,
	['Frigid Blows'] = true,
	['Draw In'] = true,
	
	-- Host
	['Bonecage Armor'] = true,
	
	-- Maiden
	['Titanic Bulwark'] = true,
	
	-- Sisters
	['Embrace of the Eclipse'] = true,
	
	-- Avatar
	['Tainted Matrix'] = true,
	['Corrupted Matrix'] = true,
	['Matrix Empowerment'] = true,
	
	-- KJ
	['Felclaws'] = true,
}

local function auraFilter(self, name, castByPlayer, debuffType, isStealable, nameplateShowSelf, nameplateShowAll)
	-- blacklist is priority
	if (config.highlightPurge and isStealable) then
		return true
	end
	-- this is an enrage
	if (config.highlightEnrage and debuffType == "") then
		return true
	end
	-- if we've whitelisted this inside of bdCore defaults
	if (config.automydebuff and castByPlayer) then
		return true
	end
	
	return false
end
mod.auraFilter = memoize(auraFilter, mod.cache)