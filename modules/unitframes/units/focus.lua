local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["focus"] = function(self, unit)
	local config = mod.save

	self:SetSize(config.focuswidth, config.focusheight)
	self.Curhp:Hide()

	mod.additional_elements.power(self, unit)
	mod.additional_elements.auras(self, unit)
	mod.additional_elements.debuffs(self, unit)
	mod.additional_elements.castbar(self, unit)
	mod.additional_elements.perhp(self, unit)

	self.Name:SetPoint("CENTER", self.Health)
	self.Name:SetFontObject(bdUI:get_font(12))
	self.Name:SetWidth(config.focuswidth - self.Perpp:GetWidth() - self.Perhp:GetWidth() - 16)

	self.Debuffs.initialAnchor = "TOPLEFT"
	self.Debuffs['growth-x'] = "RIGHT"
	self.Debuffs.size = config.focusheight - 10
	self.Debuffs:ClearAllPoints()
	self.Debuffs:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 4, -2)

	self.Auras.initialAnchor = "TOPRIGHT"
	self.Auras['growth-x'] = "LEFT"
	self.Auras['growth-y'] = "DOWN"
	self.Auras.size = (config.focusheight - 10) / 2
	self.Auras:SetSize((config.focusheight - 10) / 2, config.focusheight)
	self.Auras:ClearAllPoints()
	self.Auras:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -bdUI.border*3, -bdUI.border)

	self.Power:SetHeight(config.focuspower)
	self.Power:Show()
	if (config.focuspower == 0) then
		self.Power:Hide()
	end
	self.Health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, config.focuspower + bdUI.border)

	self.Debuffs.CustomFilter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		local castByMe = source and UnitIsUnit(source, "player") or false
				
		if (castByMe) then
			if (bdUI:filter_aura(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
				return true
			end
		end
	end

	self.Auras.CustomFilter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		local castByMe = source and UnitIsUnit(source, "player") or false
				
		if (not caster or not castByPlayer) then
			if (bdUI:filter_aura(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
				return true
			end
		end
	end
	
	-- config callback
	self.callback = function()

	end
end