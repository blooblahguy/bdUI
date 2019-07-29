local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["player"] = function(self, unit)
	local config = mod._config

	self:SetSize(config.playertargetwidth, config.playertargetheight)
	self.Name:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -4, -mod.padding)
	self.Curhp:SetPoint("TOPRIGHT", self.Name, "BOTTOMRIGHT", 0, -mod.padding)

	mod.additional_elements.power(self, unit)
	mod.additional_elements.castbar(self, unit, "left")
	mod.additional_elements.resting(self, unit)
	mod.additional_elements.combat(self, unit)
	mod.additional_elements.buffs(self, unit)
	self.Buffs.size = 22

	self.Buffs.CustomFilter = function(element, unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		local castByPlayer = caster and UnitIsUnit(caster, "player") or false
		if (bdUI:filter_aura(name, castByPlayer, isBossDebuff, nameplateShowAll, true)) then
			if (caster == "player" and duration ~= 0 and duration < 300) then
				return true 
			end
		end
	end
	
	
end