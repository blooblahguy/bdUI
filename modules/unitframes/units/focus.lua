local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["focus"] = function(self, unit)
	local config = mod.save

	self:SetSize(config.focuswidth, config.focusheight)

	mod.additional_elements.power(self, unit)
	mod.additional_elements.buffs(self, unit)
	mod.additional_elements.debuffs(self, unit)
	mod.additional_elements.castbar(self, unit)
	-- power
	mod.tags.pp(self, unit)

	-- text
	self.Name:SetPoint("LEFT", 4, 0)
	self.Name:SetFontObject(bdUI:get_font(13))
	
	self.Curhp:ClearAllPoints()
	self.Curhp:SetPoint("RIGHT", -4, 0)
	self.Curhp:SetFontObject(bdUI:get_font(11))
	
	self.Curpp:ClearAllPoints()
	self.Curpp:SetPoint("CENTER")
	self.Curpp:SetFontObject(bdUI:get_font(11))

	self.Debuffs.initialAnchor = "TOPLEFT"
	self.Debuffs['growth-x'] = "RIGHT"
	self.Debuffs.size = 20
	self.Debuffs:SetSize(config.focuswidth, config.focusheight)
	self.Debuffs:ClearAllPoints()
	self.Debuffs:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 4, 0)
	self.Debuffs.CustomFilter  = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		nameplateShowPersonal = nameplateShowPersonal or false
		local castByMe = source and UnitIsUnit(source, "player") or false

		if (not castByPlayer or not source or isBossDebuff) then -- this may have been casted by no one or by a boss
			return true
		end
		if (not castByMe) then return false end

		if (bdUI:is_blacklisted(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
			return false
		end

		return true
	end


	self.Buffs.initialAnchor = "TOPRIGHT"
	self.Buffs['growth-x'] = "LEFT"
	self.Buffs['growth-y'] = "DOWN"
	self.Buffs.size = 20
	self.Buffs:SetSize(config.focuswidth, config.focusheight)
	self.Buffs:ClearAllPoints()
	self.Buffs:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -4, 0)
	self.Buffs.CustomFilter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		nameplateShowPersonal = nameplateShowPersonal or false
		local castByMe = source and UnitIsUnit(source, "player") or false

		if (bdUI:is_blacklisted(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
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

		
	end
	
	-- config callback
	self.callback = function()
		self.Power:SetHeight(config.focuspower)
		self.Power:Show()
		if (config.focuspower == 0) then
			self.Power:Hide()
		end
		self.Health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, config.focuspower + bdUI.border)

		self.Debuffs.size = self.Health:GetHeight()
		self.Buffs.size = self.Health:GetHeight()
	end
end