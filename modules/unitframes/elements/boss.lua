local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["boss"] = function(self, unit)
	local config = mod._config
	
	self:SetSize(config.bosswidth, config.bossheight)
	self.Name:SetPoint("LEFT", self.Health, "LEFT", 4, 0)
	self.Curhp:SetPoint("RIGHT", self.Health, "RIGHT", -4, 0)

	mod.additional_elements.auras(self, unit)
	mod.additional_elements.castbar(self, unit)

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