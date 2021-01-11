--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Auras")
local auras

--===============================================
-- Whitelist
--===============================================
local is_whitelisted = function(self, name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)
	-- auras = auras or mod.config
	name = name:lower()

	

	-- whitelisted if in raid
	if (bdUI:is_whitelist_raid(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
		return true
	end

	-- whitelisted if its mine
	if (bdUI:is_whitelist_mine(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
		return true
	end

	-- whitelisted
	if (auras["whitelist"][name]) then	
		return true
	end

	-- whitelisted if i'm on the class
	if (bdUI:is_whitelist_class(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
		return true
	end
	
	return false
end

--===============================================
-- Blacklists
--===============================================
local is_blacklisted = function(self, name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)
	-- auras = auras or mod.config
	name = name:lower()

	if (auras and auras["blacklist"][name]) then
		return true
	end

	return false
end

--===============================================
-- Nameplates
--===============================================
local is_whitelist_nameplate = function(self, name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)
	-- auras = auras or mod.config
	name = name:lower()

	if ((nameplateShowPersonal and castByMe) or nameplateShowAll) then
		return true
	end
	
	return false
end


--===============================================
-- Personal
--===============================================
local is_whitelist_mine = function(self, name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)
	-- auras = auras or mod.config
	name = name:lower()

	-- print(name, auras["mine"][name])
	-- if (castByMe) then
	-- end

	-- print(auras["mine"], name)

	if (auras and auras["mine"] and auras["mine"][name] and castByMe) then
		return true
	end
	
	return false
end

--===============================================
-- Class
--===============================================
local is_whitelist_class = function(self, name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)
	-- auras = auras or mod.config
	name = name:lower()

	if (auras and auras[bdUI.class][name]) then	
		return true
	end
	
	return false
end

--===============================================
-- Raid
--===============================================
local is_whitelist_raid = function(self, name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)
	-- auras = auras or mod.config
	name = name:lower()

	local inInstance, instanceType = IsInInstance()
	if (inInstance and (instanceType == "party" or instanceType == "raid")) then
		if (isBossDebuff or bdUI.aura_lists.raid[name]) then	
			return true
		end
	end
	
	return false
end

-- bdUI.is_blacklisted = memoize(is_blacklisted, bdUI.caches.auras)
bdUI.is_whitelisted = memoize(is_whitelisted, bdUI.caches.auras.white)
bdUI.is_blacklisted = memoize(is_blacklisted, bdUI.caches.auras.black)
bdUI.is_whitelist_nameplate = memoize(is_whitelist_nameplate, bdUI.caches.auras.nameplate)
bdUI.is_whitelist_mine = is_whitelist_mine --, bdUI.caches.auras.mine)
bdUI.is_whitelist_class = is_whitelist_class --, bdUI.caches.auras.class)
bdUI.is_whitelist_raid = is_whitelist_raid --, bdUI.caches.auras.raid)

--===============================================
-- Intelligent Filtering
--===============================================
local filter_aura = function(self, name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)
	auras = mod.auras
	name = name:lower()
	-- print(name)

	if (is_blacklisted(self, name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
		return false
	end

	return is_whitelisted(self, name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)
end

-- bdUI.filter_aura = memoize(filter_aura, bdUI.caches.auras)
bdUI.filter_aura = filter_aura