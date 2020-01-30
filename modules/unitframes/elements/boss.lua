local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["boss"] = function(self, unit)
	local config = mod:get_save()
	
	self:SetSize(config.bosswidth, config.bossheight)
	self.Curhp:Hide()

	mod.additional_elements.power(self, unit)
	mod.additional_elements.auras(self, unit)
	mod.additional_elements.debuffs(self, unit)
	mod.additional_elements.castbar(self, unit)
	mod.additional_elements.perhppp(self, unit)

	self.Name:SetPoint("CENTER", self.Health)
	self.Name:SetFont(bdUI.media.font, 12, "OUTLINE")
	self.Name:SetWidth(config.bosswidth - self.Perpp:GetWidth() - self.Perhp:GetWidth() - 16)

	self.Debuffs.initialAnchor = "TOPLEFT"
	self.Debuffs['growth-x'] = "RIGHT"
	self.Debuffs.size = config.bossheight - 10
	self.Debuffs:ClearAllPoints()
	self.Debuffs:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 4, -2)

	self.Auras.initialAnchor = "TOPRIGHT"
	self.Auras['growth-x'] = "LEFT"
	self.Auras['growth-y'] = "DOWN"
	self.Auras.size = (config.bossheight - 10) / 2
	self.Auras:SetSize((config.bossheight - 10) / 2, config.bossheight)
	self.Auras:ClearAllPoints()
	self.Auras:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -bdUI.border*3, -bdUI.border)

	self.Power:SetHeight(config.bosspower)
	self.Power:Show()
	if (config.bosspower == 0) then
		self.Power:Hide()
	end
	self.Health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, config.bosspower + bdUI.border)


	self.Debuffs.CustomFilter = function(element, unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		local castByPlayer = caster and UnitIsUnit(caster, "player") or false
				
		if (castByPlayer) then
			if (bdUI:filter_aura(name, castByPlayer, isBossDebuff, nameplateShowAll, true)) then
				return true
			end
		end
	end

	self.Auras.CustomFilter = function(element, unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		local castByPlayer = caster and UnitIsUnit(caster, "player") or false
				
		if (not caster or not casterIsPlayer) then
			if (bdUI:filter_aura(name, castByPlayer, isBossDebuff, nameplateShowAll, true)) then
				return true
			end
		end
		
		
	end

end