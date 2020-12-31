local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.additional_elements.buffs = function(self, unit)
	if (self.Buffs) then return end
	local config = mod.config

	-- Auras
	self.Buffs = CreateFrame("Frame", nil, self)
	self.Buffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
	self.Buffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
	self.Buffs:SetSize(config.playertargetwidth, 60)
	self.Buffs.size = 18
	self.Buffs.initialAnchor  = "BOTTOMLEFT"
	self.Buffs.spacing = bdUI.border
	self.Buffs.num = 20
	self.Buffs['growth-y'] = "UP"
	self.Buffs['growth-x'] = "RIGHT"


	self.Buffs.PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
		local name, _, _, debuffType, duration, expiration, caster, IsStealable, _, spellID = UnitAura(unit, index, button.filter)

		-- for blacklisting
		button.spell = name

		-- classic
		bdUI:update_duration(button.cd, unit, spellID, caster, name, duration, expiration)

	end
	self.Buffs.PostCreateIcon = function(buffs, button)
		bdUI:set_backdrop_basic(button)
		button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button.cd:GetRegions():SetAlpha(0)

		-- blacklist
		button:SetScript("OnMouseDown", function(self, button)
			if (not IsShiftKeyDown() or not IsAltKeyDown() or not IsAltKeyDown() or not button == "MiddleButton") then return end
			local name = self.spell:lower()
			local auras = bdUI:get_module("Auras")
			
			auras:get_save().blacklist[name] = true
			auras:store_lowercase_auras()
			bdUI.caches.auras = {}

			bdUI:debug("Blacklisted "..name)

			self:GetParent():ForceUpdate()
		end)
	end
end