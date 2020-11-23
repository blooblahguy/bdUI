local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["player"] = function(self, unit)
	local config = mod.save

	self:SetSize(config.playertargetwidth, config.playertargetheight)

	mod.additional_elements.power(self, unit)
	mod.additional_elements.castbar(self, unit, "left")
	mod.additional_elements.buffs(self, unit)
	mod.additional_elements.resting(self, unit)
	mod.additional_elements.combat(self, unit)
	mod.additional_elements.aurabars(self, unit)

	self.Buffs.CustomFilter = function(element, unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		local castByPlayer = caster and UnitIsUnit(caster, "player") or false

		-- filter from whitelist/blacklist
		if ( not bdUI:filter_aura(name, castByPlayer, isBossDebuff, nameplateShowAll, true)) then return false end

		-- but also only show player and with durations
		if (caster == "player" and duration ~= 0 and duration < 300) then return true end

		-- return true
	end

	self.AuraBars.CustomFilter = function(element, unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		local castByPlayer = caster and UnitIsUnit(caster, "player") or false

		-- filter from whitelist/blacklist
		if ( not bdUI:filter_aura(name, castByPlayer, isBossDebuff, nameplateShowAll, true)) then return false end

		-- but also only show player and with durations
		if (caster == "player" and duration ~= 0 and duration < 300) then return true end

		-- return true
	end

	-- create standalone resource bar
	mod.create_resources(self, unit)
	
	-- config callback
	self.callback = function(self, unit, config)
		self:SetSize(config.playertargetwidth, config.playertargetheight)

		-- text
		if (config.hideplayertext) then
			self.Name:Hide()
			self.Curhp:Hide()
		else
			mod.align_text(self)
			self.Name:Show()
			self.Curhp:Show()
		end

		-- auras
		if (config.aurastyle == "Bars") then
			self.DisabledBuffs = self.Buffs or self.DisabledBuffs
			if (self.Buffs) then
				self.Buffs:Hide()
				self.Buffs = nil
			end
			self:EnableElement("AuraBars")
			self.AuraBars:Show()
		else
			self.Buffs = self.DisabledBuffs or self.Buffs
			self.Buffs:Show()
			self.Buffs.size = config.uf_buff_size
			self:DisableElement("AuraBars")
			self.AuraBars:Hide()
		end

		-- health
		self.Health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, config.playertargetpowerheight + bdUI.border)

		-- power
		if (config.playertargetpowerheight > 0) then
			self:EnableElement("Power")
			self.Power:SetHeight(config.playertargetpowerheight)
		else
			self:DisableElement("Power")
		end

		-- resting
		if (config.enable_rested_indicator) then
			self:EnableElement("RestingIndicator")
			self.RestingIndicator:ClearAllPoints()
			if (config.textlocation == "Outside") then
				self.RestingIndicator:SetPoint("LEFT", self.Health, mod.padding, 1)
			elseif (config.textlocation == "Inside") then
				self.RestingIndicator:SetPoint("LEFT", self.Health, "CENTER", mod.padding, 1)
			end
		else
			self:DisableElement("RestingIndicator")
		end

		-- combat
		if (config.enable_combat_indicator) then
			self:EnableElement("CombatIndicator")
			self.CombatIndicator:ClearAllPoints()
			if (config.textlocation == "Outside") then
				self.CombatIndicator:SetPoint("RIGHT", self.Health, -mod.padding, 1)
			elseif (config.textlocation == "Inside") then
				self.CombatIndicator:SetPoint("RIGHT", self.Health, "CENTER", -mod.padding, 1)
			end
		else
			self:DisableElement("CombatIndicator")
		end

	end
end
