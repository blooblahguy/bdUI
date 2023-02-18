local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.additional_elements.auras = function(self, unit)
	if (self.Auras) then return end
	local config = mod.config

	-- Auras
	self.Auras = CreateFrame("Frame", "bdUF_Auras", self)

	if (self.ResourceHolder:IsShown()) then
		self.Auras:SetPoint("BOTTOMLEFT", self.ResourceHolder, "TOPLEFT", 0, 8)
		self.Auras:SetPoint("BOTTOMRIGHT", self.ResourceHolder, "TOPRIGHT", 0, 8)
	else
		self.Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 4)
		self.Auras:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 4)
	end
	self.Auras:SetSize(config.playertargetwidth, 60)
	self.Auras.size = 18
	self.Auras.initialAnchor  = "BOTTOMLEFT"
	self.Auras.spacing = bdUI.border
	self.Auras.num = 20
	self.Auras['growth-y'] = "UP"
	self.Auras['growth-x'] = "RIGHT"

	self.Auras.PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
		local name, _, _, debuffType, duration, expiration, caster, IsStealable, _, spellID = UnitAura(unit, index, button.filter)
		bdUI:update_duration(button.cd, unit, spellID, caster, name, duration, expiration)
	end

	self.Auras.PostCreateIcon = function(Debuffs, button)
		bdUI:set_backdrop_basic(button)
		button.icon:SetTexCoord(.07, .93, .07, .93)
		button.cd:GetRegions():SetAlpha(0)
		-- button:SetAlpha(0.8)
	end
end