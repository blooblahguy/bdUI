local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.additional_elements.buffs = function(self, unit)
	if (self.Buffs) then
		return
	end
	local config = mod.config

	-- Auras
	self.Buffs = CreateFrame("Frame", "bdUF_Buffs", self)
	-- if (self.ResourceHolder:IsShown()) then
	-- 	self.Buffs:SetPoint("BOTTOMLEFT", self.ResourceHolder, "TOPLEFT", 0, bdUI.border)
	-- 	self.Buffs:SetPoint("BOTTOMRIGHT", self.ResourceHolder, "TOPRIGHT", 0, bdUI.border)
	-- else
	-- self.Buffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 2, 0)
	-- self.Buffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
	-- end
	self.Buffs:SetHeight(60)
	self.Buffs.size = 18
	self.Buffs.initialAnchor = "BOTTOMLEFT"
	self.Buffs.spacing = bdUI.border
	self.Buffs.num = 20
	self.Buffs['growth-y'] = "UP"
	self.Buffs['growth-x'] = "RIGHT"

	self.Buffs.PostUpdateButton = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
		local name, _, _, debuffType, duration, expiration, caster, IsStealable, _, spellID = C_UnitAuras.GetAuraDataByIndex(unit, index, button.filter)

		-- for blacklisting
		button.spell = name

		bdUI:update_duration(button.Cooldown, unit, spellID, caster, name, duration, expiration)
	end
	self.Buffs.PostCreateButton = function(buffs, button)
		bdUI:set_backdrop(button)
		button.Icon:SetTexCoord(.07, .93, .07, .93)
		button.Cooldown:GetRegions():SetAlpha(0)

		-- blacklist
		button:SetScript("OnMouseDown", function(self, button)
			if (not IsShiftKeyDown() or not IsAltKeyDown() or not IsAltKeyDown() or not button == "MiddleButton") then
				return
			end
			local name = self.spell:lower()
			local auras = bdUI:get_module("Auras")

			auras:get_save().blacklist[name] = true
			auras:store_lowercase_auras()
			bdUI.caches.auras = {}

			bdUI:debug("Blacklisted " .. name)

			self:GetParent():ForceUpdate()
		end)
	end
end
