local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["focus"] = function(self, unit)
	local config = mod._config
	
	mod.additional_elements.power(self, unit)
	mod.additional_elements.castbar(self, unit)

	self:SetSize(config.playertargetwidth, config.playertargetheight)

	self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, mod.padding)
	self.Curhp:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, mod.padding)
end