--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================
mod.align_text = function(self)
	local config = mod._config
	align = config.textlocation
	local icons = self.Auras or self.Debuffs or self.Buffs

	if (align == "Inside") then
		self.Name:SetPoint("LEFT", self.Health, "LEFT", 4, 0)
		self.Curhp:SetPoint("RIGHT", self.Health, "RIGHT", -4, 0)
	elseif (align == "Outside") then
		self.Name:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -4, -mod.padding)
		self.Curhp:SetPoint("TOPRIGHT", self.Name, "BOTTOMRIGHT", 0, -mod.padding)
	end
end