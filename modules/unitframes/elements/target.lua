local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["target"] = function(self, unit)
	local config = mod._config
	
	self:SetSize(config.playertargetwidth, config.playertargetheight)
	
	mod.additional_elements.power(self, unit)
	mod.additional_elements.castbar(self, unit, "right")
	mod.additional_elements.buffs(self, unit)
	mod.additional_elements.debuffs(self, unit)

	self.Debuffs.initialAnchor  = "BOTTOMLEFT"
	self.Debuffs['growth-x'] = "RIGHT"
	self.Debuffs.CustomFilter = function(element, unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		local castByPlayer = caster and UnitIsUnit(caster, "player") or false
		if (bdUI:filter_aura(name, castByPlayer, isBossDebuff, nameplateShowAll, true)) then
			if (caster and UnitIsUnit(caster,"player") and duration ~= 0 and duration < 300) then
				return true 
			end
		end
	end

	self.Buffs:ClearAllPoints()
	self.Buffs:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 7, 2)
	self.Buffs:SetSize(80, 60)
	self.Buffs.size = 12
	self.Buffs.CustomFilter = function(element, unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		local castByPlayer = caster and UnitIsUnit(caster, "player") or false

		-- allow it if it's tracked in the ui and not blacklisted
		if ( bdUI:filter_aura(name, castByPlayer, isBossDebuff, nameplateShowAll, true) ) then
			return true
		end
		-- also allow anything that might be casted by the boss
		if (not caster and not UnitIsPlayer("target")) then
			return true
		end
		-- look for non player casters
		if (caster and not strfind(caster, "raid") and not strfind(caster, "party") and not caster == "player") then
			return true
		end
	end
	

	mod.align_text(self, "right")
end