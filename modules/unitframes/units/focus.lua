local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["focus"] = function(self, unit)
	local config = mod.save

	self:SetSize(config.focuswidth, config.focusheight)

	mod.additional_elements.power(self, unit)
	mod.additional_elements.buffs(self, unit)
	mod.additional_elements.debuffs(self, unit)
	mod.additional_elements.castbar(self, unit)

	self.Debuffs.initialAnchor = "BOTTOMLEFT"
	self.Debuffs['growth-x'] = "RIGHT"
	self.Debuffs['growth-y'] = "UP"
	self.Debuffs.size = 20
	self.Debuffs:SetSize(config.focuswidth / 2, config.focusheight)
	self.Debuffs:ClearAllPoints()
	self.Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", -bdUI.border, bdUI.border*2)
	self.Debuffs.CustomFilter  = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		nameplateShowPersonal = nameplateShowPersonal or false
		local castByMe = false
		if (source) then
			castByMe =  UnitIsUnit(source, "player") or UnitIsUnit(source, "pet") or UnitIsUnit(source, "vehicle")
		end

		if (bdUI:is_blacklisted(name)) then
			return false
		end

		if (bdUI:is_whitelist_nameplate(castByMe, nameplateShowPersonal, nameplateShowAll) or not castByPlayer or not source or isBossDebuff) then -- this may have been casted by no one or by a boss
			return true
		end

		if (not castByMe) then 
			return false
		end

		return true
	end

	self.Buffs.initialAnchor = "BOTTOMRIGHT"
	self.Buffs['growth-x'] = "LEFT"
	self.Buffs['growth-y'] = "UP"
	self.Buffs.size = 20
	self.Buffs:SetSize(config.focuswidth / 2, config.focusheight)
	self.Buffs:ClearAllPoints()
	self.Buffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, bdUI.border*3)
	self.Buffs.CustomFilter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		nameplateShowPersonal = nameplateShowPersonal or false
		local castByMe = false
		if (source) then
			castByMe = UnitIsUnit(source, "player") or UnitIsUnit(source, "pet") or UnitIsUnit(source, "vehicle")
		end

		if (bdUI:is_blacklisted(name)) then
			return false
		end
		
		if (bdUI:is_whitelisted(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
			return true
		end

		if (isStealable or isBossDebuff) then
			return true
		end

		if (duration > 0 and castByPlayer) then -- cast by a player, but not a mount or an aura
			return true
		end

		return not castByPlayer or not source or not UnitIsPlayer(source)
	end
	
	-- config callback
	self.callback = function()
		self.Power:SetHeight(config.focuspower)
		self.Power:Show()
		if (config.focuspower == 0) then
			self.Power:Hide()
		end
		self.Health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, config.focuspower + bdUI.border)

		self.Debuffs.size = math.restrict(self.Health:GetHeight() * .8, 8, 20)
		self.Buffs.size = math.restrict(self.Health:GetHeight() * .8, 8, 20)
	end
end