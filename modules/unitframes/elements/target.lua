local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["target"] = function(self, unit)
	local config = mod._config
	
	mod.additional_elements.power(self, unit)
	mod.additional_elements.castbar(self, unit, "right")
	mod.additional_elements.buffs(self, unit)
	mod.additional_elements.debuffs(self, unit)

	self.Debuffs.initialAnchor  = "BOTTOMLEFT"
	self.Debuffs['growth-x'] = "RIGHT"
	-- self.Auras.CustomFilter = function(element, unit, button, name, rank, texture, count, debuffType, duration, expiration)
	-- 	print(unit)
	-- 	print(duration)
	-- end

	self.Buffs:ClearAllPoints()
	self.Buffs:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 7, 2)
	self.Buffs:SetSize(80, 60)
	self.Buffs.size = 12
	
	self:SetSize(config.playertargetwidth, config.playertargetheight)

	self.Name:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 4, -mod.padding)
	self.Curhp:SetPoint("TOPLEFT", self.Name, "BOTTOMLEFT", 0, -mod.padding)
end