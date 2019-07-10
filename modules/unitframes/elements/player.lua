local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["player"] = function(self, unit)
	local config = mod._config

	mod.additional_elements.castbar(self, unit, "left")
	mod.additional_elements.resting(self, unit)
	mod.additional_elements.combat(self, unit)
	mod.additional_elements.power(self, unit)
	mod.additional_elements.buffs(self, unit)

	self.Buffs.CustomFilter = function(element, unit, button, name, rank, texture, count, debuffType, duration, expiration)
		if (UnitIsUnit(unit, "player") and duration ~= 0 and duration < 180) then
			return true 
		end

		return false
	end

	self:SetSize(config.playertargetwidth, config.playertargetheight)
	self.Buffs.size = 22
	self.Name:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -4, -mod.padding)
	self.Curhp:SetPoint("TOPRIGHT", self.Name, "BOTTOMRIGHT", 0, -mod.padding)
end