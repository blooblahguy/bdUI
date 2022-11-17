--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Auras")
local auras

-- for classic cooldown spirals
function bdUI:update_duration(cd_frame, unit, spellID, caster, name, duration, expiration)
	if (not bdUI.spell_durations or duration ~= 0 or expiration ~= 0) then
		return duration, expiration
	end

	local durationNew, expirationTimeNew = bdUI.spell_durations:GetAuraDurationByUnit(unit, spellID, caster, name)
	if duration == 0 and durationNew then
		duration = durationNew
		expirationTime = expirationTimeNew
	end

	local enabled = expirationTime and expirationTime ~= 0;
	if enabled then
		cd_frame:SetCooldown(expirationTime - duration, duration)
		cd_frame:Show()
	else
		cd_frame:Hide()
	end

	return duration, expiration
end

--===============================================
-- Whitelist
--===============================================
local is_whitelisted = function(self, name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)
	auras = mod.auras
	name = bdUI:sanitize(name)

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
local is_blacklisted = function(self, name)
	auras = mod.auras
	name = bdUI:sanitize(name)

	if (auras and auras["blacklist"][name]) then
		return true
	end

	return false
end

--===============================================
-- Nameplates
--===============================================
local is_whitelist_nameplate = function(self, castByMe, nameplateShowPersonal, nameplateShowAll)
	if ((nameplateShowPersonal and castByMe) or nameplateShowAll) then
		return true
	end
	
	return false
end


--===============================================
-- Personal
--===============================================
local is_whitelist_mine = function(self, name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)
	auras = mod.auras
	name = bdUI:sanitize(name)

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
	auras = mod.auras
	name = bdUI:sanitize(name)

	if (auras and auras[bdUI.class][name]) then	
		return true
	end
	
	return false
end

--===============================================
-- Raid
--===============================================
local is_whitelist_raid = function(self, name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)
	auras = mod.auras
	name = bdUI:sanitize(name)

	local inInstance, instanceType = IsInInstance()
	if (inInstance and (instanceType == "party" or instanceType == "raid")) then
		if (isBossDebuff or bdUI.aura_lists.raid[name]) then	
			return true
		end
	end
	
	return false
end

-- bdUI.is_blacklisted = memoize(is_blacklisted, bdUI.caches.auras)
bdUI.is_whitelisted = is_whitelisted --, bdUI.caches.auras.white)
bdUI.is_blacklisted = is_blacklisted --, bdUI.caches.auras.black)
bdUI.is_whitelist_nameplate = memoize(is_whitelist_nameplate, bdUI.caches.auras.nameplate)
bdUI.is_whitelist_mine = is_whitelist_mine --, bdUI.caches.auras.mine)
bdUI.is_whitelist_class = is_whitelist_class --, bdUI.caches.auras.class)
bdUI.is_whitelist_raid = is_whitelist_raid --, bdUI.caches.auras.raid)

--===============================================
-- Intelligent Filtering
--===============================================
local filter_aura = function(self, name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)
	auras = mod.auras
	name = bdUI:sanitize(name)

	if (bdUI:is_blacklisted(name)) then
		return false
	end

	return bdUI:is_whitelisted(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)
end

bdUI.filter_aura = memoize(filter_aura, bdUI.caches.auras)
-- bdUI.filter_aura = filter_aura