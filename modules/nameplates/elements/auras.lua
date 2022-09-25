local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")

local function auraFilter(self, name, castByPlayer, debuffType, isStealable, nameplateShowSelf, nameplateShowAll)
	-- blacklist is priority
	if (config.highlightPurge and (isStealable or debuffType == "Magic")) then
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