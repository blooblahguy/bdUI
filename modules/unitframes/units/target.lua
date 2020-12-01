local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.custom_layout["target"] = function(self, unit)
	local config = mod.save
	
	mod.additional_elements.power(self, unit)
	mod.additional_elements.castbar(self, unit, "right")
	mod.additional_elements.buffs(self, unit)
	mod.additional_elements.debuffs(self, unit)
	mod.additional_elements.aurabars(self, unit)

	-- self.Classification = self.TextHolder:CreateFontString(nil, "OVERLAY")
	-- self.Classification:SetFont(bdUI.media.font, 13, "OUTLINE")
	-- self.Classification:SetPoint("TOPLEFT", self.Health, "BOTTOMRIGHT", 0, -4)
	-- self:Tag(self.Classification, '[shortclassification]')

	mod.version = bdUI:get_game_version()

	self.Debuffs.initialAnchor = "BOTTOMLEFT"
	self.Debuffs.size = 22
	self.Debuffs['growth-x'] = "RIGHT"
	self.Debuffs.CustomFilter = function(element, unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		duration, expiration = bdUI:update_duration(button.cd, unit, spellID, caster, name, duration, expiration)
		local castByPlayer = caster and UnitIsUnit(caster, "player") or false

		-- filter from whitelist/blacklist
		if ( not bdUI:filter_aura(name, castByPlayer, isBossDebuff, nameplateShowAll, true)) then return false end

		-- but also only show player and with durations
		if (castByPlayer and duration ~= 0 and duration < 300) then return true end

		if (castByPlayer and nameplateShowSelf) then return true end
	end

	self.AuraBars.CustomFilter = function(element, unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		duration, expiration = bdUI:update_duration(button.cd, unit, spellID, caster, name, duration, expiration)
		local castByPlayer = caster and UnitIsUnit(caster, "player") or false

		-- filter from whitelist/blacklist
		if ( not bdUI:filter_aura(name, castByPlayer, isBossDebuff, nameplateShowAll, true)) then return false end

		-- but also only show player and with durations
		if (castByPlayer and duration ~= 0 and duration < 300) then return true end

		if (castByPlayer and nameplateShowSelf) then return true end
	end
	

	self.Buffs.CustomFilter = function(element, unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false

		-- allow it if it's tracked in the ui and not blacklisted
		if ( bdUI:filter_aura(name, casterIsPlayer, isBossDebuff, nameplateShowAll, true) ) then
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

	-- config callback
	self.callback = function()
		-- sizing
		self:SetSize(config.playertargetwidth, config.playertargetheight)
		self.Health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, config.playertargetpowerheight + bdUI.border)

		-- power
		self.Power:SetHeight(config.playertargetpowerheight)
		self.Power:Show()
		if (config.playertargetpowerheight == 0) then
			self.Power:Hide()
		end
		-- auras
		self.Buffs:ClearAllPoints()

		if (config.uf_buff_target_match_player) then
			self.Buffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
			self.Buffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
			self.Buffs:SetSize(config.playertargetwidth, 60)
			self.Buffs.size = config.uf_buff_size
			self.Buffs['growth-x'] = "RIGHT"
			self.Buffs.initialAnchor  = "BOTTOMLEFT"
		else
			self.Buffs:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 7, 2)
			self.Buffs:SetSize(80, 60)
			self.Buffs.size = 12
		end

		if (config.aurastyle == "Bars") then
			self.Debuffs:Hide()
			self.DisabledDebuffs = self.Debuffs
			self.Debuffs = nil
			self:EnableElement("AuraBars")
			self.AuraBars:Show()
		else
			self.Debuffs = self.DisabledDebuffs or self.Debuffs
			self.Debuffs.size = config.uf_buff_size
			self.Debuffs:Show()
			self:DisableElement("AuraBars")
			self.AuraBars:Hide()
		end
	end
end
