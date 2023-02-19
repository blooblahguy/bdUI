local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

local buff_filter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
	isBossDebuff = isBossDebuff or false
	nameplateShowAll = nameplateShowAll or false
	local castByMe = false
	if (source) then
		castByMe = UnitIsUnit(source, "player") or UnitIsUnit(source, "pet") or UnitIsUnit(source, "vehicle")
	end

	-- classic
	duration, expirationTime = bdUI:update_duration(button.cd, unit, spellId, source, name, duration, expirationTime)

	if (bdUI:is_blacklisted(name)) then
		return false
	end

	if (castByMe and duration ~= 0 and duration < 300) then
		return true
	end

	return bdUI:is_whitelist_nameplate(castByMe, nameplateShowPersonal, nameplateShowAll)
end

mod.custom_layout["player"] = function(self, unit)
	local config = mod.save

	self:SetSize(config.playertargetwidth, config.playertargetheight)

	-- if (mod.additional_elements.runes) then mod.additional_elements.runes(self, unit) end
	mod.additional_elements.power(self, unit)
	mod.additional_elements.castbar(self, unit, "left")
	mod.additional_elements.buffs(self, unit)
	mod.additional_elements.aurabars(self, unit)

	local size = math.restrict(config.playertargetheight * 0.75, 8, config.playertargetheight)

	-- Combat indicator
	-- self.CombatIndicator = self.TextHolder:CreateTexture(nil, "OVERLAY")
	-- self.CombatIndicator:SetSize(size, size)
	-- self.CombatIndicator:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
	-- self.CombatIndicator:SetTexCoord(.5, 1, 0, .49)

	-- if (config.textlocation == "Outside") then
	-- 	self.CombatIndicator:SetPoint("RIGHT", self.TextHolder, -mod.padding, 1)
	-- elseif (config.textlocation == "Inside") then
	-- 	self.CombatIndicator:SetPoint("RIGHT", self.TextHolder, "CENTER", -mod.padding, 1)
	-- end

	self.Buffs.CustomFilter = buff_filter
	self.AuraBars.CustomFilter = buff_filter
	
	-- config callback
	self.callback = function(self, unit, config)
		self:SetSize(config.playertargetwidth, config.playertargetheight)

		-- auras
		if (config.aurastyle == "Bars") then
			self.DisabledBuffs = self.Buffs or self.DisabledBuffs
			if (self.Buffs) then
				self.Buffs:Hide()
				self.Buffs = nil
			end
			self:EnableElement("AuraBars")
			self.AuraBars:Show()
		elseif (config.aurastyle == "Icons") then
			self.Buffs = self.DisabledBuffs or self.Buffs
			self.Buffs:Show()
			self.Buffs.size = config.player_uf_buff_size
			self:DisableElement("AuraBars")
			self.AuraBars:Hide()
		else
			self.DisabledBuffs = self.Buffs or self.DisabledBuffs
			if (self.Buffs) then
				self.Buffs:Hide()
				self.Buffs = nil
			end
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
	end
end
