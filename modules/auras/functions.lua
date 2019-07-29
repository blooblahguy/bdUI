--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Auras")
local auras
bdUI.caches.auras = {}

--===============================================
-- Blacklisting
--===============================================

local is_blacklisted = function(self, name)
	auras = auras or mod._config

	if (auras[name]) then	
		return true	
	end	
	return false
end

bdUI.is_blacklisted = memoize(is_blacklisted, bdUI.caches.auras)

--===============================================
-- Intelligent Filtering
--===============================================
local filter_aura = function(self, name, castByPlayer, isRaidDebuff, nameplateShowAll, invert)
	auras = auras or mod._config

	local blacklist = auras["blacklist"]
	local whitelist = auras["whitelist"]
	local mine = auras["mine"]
	local class = auras[bdUI.class]
	local raid = bdUI.aura_lists.raid

	-- blacklist has priority
	if (blacklist and blacklist[name]) then
		return false
	end

	-- but let's let things through that are obvious
	if (isRaidDebuff or nameplateShowAll or invert) then
		return true
	end
	
	if (whitelist and whitelist[name]) then
		return true
	elseif (raid and raid[name]) then
		return true
	elseif (class and class[name]) then
		return true
	elseif (mine and mine[name] and castByPlayer) then
		return true
	end
	
	return false
end

bdUI.filter_aura = memoize(filter_aura, bdUI.caches.auras)