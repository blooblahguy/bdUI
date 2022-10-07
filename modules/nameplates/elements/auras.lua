local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")

local function auraFilter(self, nameplate, unit, name, source, castByMe, debuffType, isStealable, isBossDebuff, nameplateShowPersonal, nameplateShowAll, automydebuff, highlightPurge, highlightEnrage)
	-- print(nameplate, unit, name, source, castByMe, debuffType, isStealable, isBossDebuff, nameplateShowPersonal, nameplateShowAll, automydebuff, highlightPurge, highlightEnrage)
	-- blacklist is priority
	if (bdUI:is_blacklisted(name)) then
		-- print("blacklisted", name)
		return false
	end

	-- if we've whitelisted this inside of bdCore defaults
	if (automydebuff and castByMe) then
		-- print("casted by me", name)
		return true
	end

	-- auto purge / stealable highlight
	if (highlightPurge and (isStealable or debuffType == "Magic") and source and UnitIsEnemy("player", source) and nameplate.currentStyle == "enemy" and UnitCanAttack("player", unit)) then
		-- print("purgable", name)
		return true
	end

	-- see if this is auto whitelisted by blizzard
	if (bdUI:is_whitelist_nameplate(castByMe, nameplateShowPersonal, nameplateShowAll)) then
		-- print("auto whitelisted", name)
		return true
	end

	-- see if this is whitelisted by us
	if (bdUI:is_whitelisted(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
		-- print("whitelisted", name)
		return true
	end

	-- this is an enrage
	if (highlightEnrage and debuffType == "") then
		-- print("enrage", name)
		return true
	end
	
	return false
end
mod.auraFilter = memoize(auraFilter, mod.cache)