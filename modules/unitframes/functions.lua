--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================
mod.align_text = function(self, align)
	local config = mod._config
	local icons = self.Auras or self.Debuffs or self.Buffs

	self.Name:ClearAllPoints()
	self.Curhp:ClearAllPoints()

	if (config.textlocation == "Inside") then
		if (align == "right") then
			self.Name:SetPoint("RIGHT", self.Health, "RIGHT", -4, 0)
			self.Curhp:SetPoint("LEFT", self.Health, "LEFT", 4, 0)
		else
			self.Name:SetPoint("LEFT", self.Health, "LEFT", 4, 0)
			self.Curhp:SetPoint("RIGHT", self.Health, "RIGHT", -4, 0)
		end
	elseif (config.textlocation == "Outside") then
		if (align == "right") then
			self.Name:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 4, -mod.padding)
			self.Curhp:SetPoint("TOPLEFT", self.Name, "BOTTOMLEFT", 0, -mod.padding)
		else
			self.Name:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -4, -mod.padding)
			self.Curhp:SetPoint("TOPRIGHT", self.Name, "BOTTOMRIGHT", 0, -mod.padding)
		end
	end
end