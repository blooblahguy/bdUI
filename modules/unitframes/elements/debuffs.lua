local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.additional_elements.debuffs = function(self, unit)
	if (self.Debuffs) then return end
	local config = mod.config

	-- Auras
	self.Debuffs = CreateFrame("Frame", "bdUF_Debuffs", self)
	self.Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
	self.Debuffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
	self.Debuffs:SetHeight(60)
	self.Debuffs.size = 18
	self.Debuffs.initialAnchor = "BOTTOMRIGHT"
	self.Debuffs.spacing = bdUI.border
	self.Debuffs.num = 20
	self.Debuffs['growth-y'] = "UP"
	self.Debuffs['growth-x'] = "LEFT"

	self.Debuffs.PostUpdateButton = function(self, unit, button, index, position, duration, expiration, debuffType,
		isStealable)
		local name, _, _, debuffType, duration, expiration, caster, IsStealable, _, spellID = UnitAura(unit, index,
			button.filter)
		bdUI:update_duration(button.Cooldown, unit, spellID, caster, name, duration, expiration)
	end

	self.Debuffs.PostCreateButton = function(Debuffs, button)
		bdUI:set_backdrop_basic(button)
		button.Cooldown:GetRegions():SetAlpha(0)
		button.Icon:SetTexCoord(.07, .93, .07, .93)
	end
end
