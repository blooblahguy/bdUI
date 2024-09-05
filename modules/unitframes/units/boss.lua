local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["boss"] = function(self, unit)
	local config = mod.save

	mod.additional_elements.power(self, unit)
	self.Power.displayAltPower = true
	mod.additional_elements.auras(self, unit)
	mod.additional_elements.debuffs(self, unit)
	mod.additional_elements.castbar(self, unit)

	-- auras
	self.Debuffs.initialAnchor = "BOTTOMLEFT"
	self.Debuffs['growth-x'] = "RIGHT"
	self.Debuffs['growth-y'] = "UP"
	self.Debuffs.size = 20
	self.Debuffs:SetSize(config.bosswidth / 2, config.bossheight)
	self.Debuffs:ClearAllPoints()
	self.Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", -bdUI.border, bdUI.border * 2)
	-- debuff filter for both icons and bars
	self.Debuffs.CustomFilter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime,
		source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		nameplateShowPersonal = nameplateShowPersonal or false
		local castByMe = false
		if (source) then
			castByMe = UnitIsUnit(source, "player") or UnitIsUnit(source, "pet") or UnitIsUnit(source, "vehicle")
		end

		if (not castByMe) then return false end

		if (bdUI:is_blacklisted(name)) then
			return false
		end

		return true
	end

	self.Auras.initialAnchor = "BOTTOMRIGHT"
	self.Auras['growth-x'] = "LEFT"
	self.Auras['growth-y'] = "UP"
	self.Auras.size = 20
	self.Auras:SetSize(config.bosswidth / 2, config.bossheight)
	self.Auras:ClearAllPoints()
	self.Auras:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, bdUI.border * 2)
	self.Auras.CustomFilter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime,
		source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		nameplateShowPersonal = nameplateShowPersonal or false
		local castByMe = false
		if (source) then
			castByMe = UnitIsUnit(source, "player") or UnitIsUnit(source, "pet") or UnitIsUnit(source, "vehicle")
		end

		if (bdUI:is_blacklisted(name) or castByPlayer) then
			return false
		end

		if (isStealable or isBossDebuff) then
			return true
		end

		return bdUI:is_whitelist_nameplate(castByMe, nameplateShowPersonal, nameplateShowAll) or not castByPlayer or
			not source or
			not UnitIsPlayer(source)     -- this may have been casted by no one or by a boss
	end

	-- self.Auras.initialAnchor = "TOPLEFT"
	-- self.Auras['growth-x'] = "RIGHT"
	-- self.Auras['growth-y'] = "DOWN"

	-- self.Auras:ClearAllPoints()
	-- self.Auras:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", bdUI.border*3, -bdUI.border)

	-- self.Debuffs.CustomFilter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
	-- 	isBossDebuff = isBossDebuff or false
	-- 	nameplateShowAll = nameplateShowAll or false
	-- 	local castByMe = source and UnitIsUnit(source, "player") or false

	-- 	if (castByMe) then
	-- 		if (bdUI:filter_aura(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
	-- 			return true
	-- 		end
	-- 	end
	-- end

	-- self.Auras.CustomFilter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
	-- 	isBossDebuff = isBossDebuff or false
	-- 	nameplateShowAll = nameplateShowAll or false
	-- 	local castByMe = source and UnitIsUnit(source, "player") or false

	-- 	if (not source or not castByPlayer) then
	-- 		return not bdUI:is_blacklisted(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)
	-- 	end
	-- end

	-- config callback
	self.callback = function(self, unit, config)
		self:SetSize(config.bosswidth, config.bossheight)

		self.Power:SetHeight(config.bosspower)
		self.Power:Show()
		if (config.bosspower == 0) then
			self.Power:Hide()
		end

		self.Health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, config.bosspower + bdUI.border)

		-- self.Debuffs.size = self.Health:GetHeight()
		-- self.Debuffs:SetSize(config.bosswidth, config.bossheight)

		-- self.Auras.size = self.Health:GetHeight()
		-- self.Auras:SetSize(config.bosswidth, config.bossheight)

		self.Debuffs.size = math.restrict(self.Health:GetHeight() * .8, 8, 20)
		self.Auras.size = math.restrict(self.Health:GetHeight() * .8, 8, 20)
	end
end
