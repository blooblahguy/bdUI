local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["focus"] = function(self, unit)
	local config = mod:get_save()

	self:SetSize(config.playertargetwidth, config.playertargetheight)
	mod.align_text(self)
	
	mod.additional_elements.power(self, unit)
	mod.additional_elements.castbar(self, unit)
	mod.additional_elements.auras(self, unit)

	self.Power:SetHeight(config.focuspower)
	self.Health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, config.focuspower + bdUI.border)

	self.Auras.CustomFilter = function(element, unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		local castByPlayer = caster and UnitIsUnit(caster, "player") or false
				
		if (not caster or UnitIsUnit(caster, "player") or (not UnitIsPlayer(caster))) then
			return true
		end
		
		if (bdUI:filter_aura(name, castByPlayer, isBossDebuff, nameplateShowAll, false)) then
			return true
		end
	end
	
end