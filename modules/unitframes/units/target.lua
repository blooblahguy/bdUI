local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

local buff_filter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
	isBossDebuff = isBossDebuff or false
	nameplateShowAll = nameplateShowAll or false
	nameplateShowPersonal = nameplateShowPersonal or false
	local castByMe = source and UnitIsUnit(source, "player") or false

	if (bdUI:is_blacklisted(name)) then
		return false
	end
	
	if (bdUI:is_whitelisted(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
		return true
	end

	if (isStealable or isBossDebuff) then
		return true
	end

	if (duration > 0 and castByPlayer) then -- cast by a player, but not a mount or an aura
		return true
	end

	return not castByPlayer or not source -- this may have been casted by no one or by a boss
end

-- debuff filter for both icons and bars
local debuff_filter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
	isBossDebuff = isBossDebuff or false
	nameplateShowAll = nameplateShowAll or false
	nameplateShowPersonal = nameplateShowPersonal or false
	local castByMe = source and UnitIsUnit(source, "player") or false

	if (bdUI:is_blacklisted(name)) then
		return false
	end
	if (bdUI:is_whitelist_nameplate(castByMe, nameplateShowPersonal, nameplateShowAll)) then
		return true
	end

	if (duration > 0 and castByPlayer) then -- cast by a player, but not a mount or an aura
		return true
	end

	if (duration < 300 and castByMe) then -- cast by a player, but not a mount or an aura
		return true
	end

	return not castByPlayer or not source
end

-- target specific elements
mod.custom_layout["target"] = function(self, unit)
	local config = mod.save
	
	-- adding in the elements
	mod.additional_elements.power(self, unit)
	mod.additional_elements.castbar(self, unit, "right")
	mod.additional_elements.buffs(self, unit)
	mod.additional_elements.debuffs(self, unit)
	mod.additional_elements.aurabars(self, unit)
	-- power
	mod.tags.pp(self, unit)

	-- icon buffs
	self.Buffs:ClearAllPoints()
	self.Buffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
	self.Buffs:SetSize(config.playertargetwidth / 2.5, 60)
	self.Buffs.size = config.target_uf_buff_size
	self.Buffs['growth-x'] = "LEFT"
	self.Buffs.initialAnchor  = "BOTTOMRIGHT"
	self.Buffs.CustomFilter = buff_filter

	-- icon debuffs
	self.Debuffs:ClearAllPoints()
	self.Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
	self.Debuffs:SetWidth(config.playertargetwidth / 2)
	self.Debuffs.size = config.target_uf_debuff_size
	self.Debuffs.initialAnchor = "BOTTOMLEFT"
	self.Debuffs['growth-x'] = "RIGHT"
	self.Debuffs.CustomFilter = debuff_filter

	-- aurabar debuffs
	self.AuraBars.filter = "HARMFUL"
	self.AuraBars.CustomFilter = debuff_filter
	
	-- mod.align_text(self, "right")
	mod:display_text(self, unit, "right")

	-- config callback
	self.callback = function()
		-- sizing
		self:SetSize(config.playertargetwidth, config.playertargetheight)
		self.Health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, config.playertargetpowerheight + bdUI.border)

		mod:display_text(self, unit, "right")

		-- color target name if we're in combat with them
		local total = 0
		local name = self.Name
		self.NameTicker = CreateFrame("frame", self)
		self.NameTicker:RegisterEvent("PLAYER_TARGET_CHANGED")
		local update_color = function()
			if (UnitExists("target")) then
				local status = UnitThreatSituation("player", "target")
				if (status == nil) then
					name:SetTextColor(1, 1, 1)
				else
					name:SetTextColor(1, .2, .2)
				end
			end
		end

		self.NameTicker:SetScript("OnEvent", update_color)
		self.NameTicker:SetScript("OnUpdate", function(self, elapsed)
			total = total + elapsed
			if (total > 0.3) then
				total = 0

				update_color()
			end
		end)

		-- power
		self.Power:SetHeight(config.playertargetpowerheight)
		self.Power:Show()
		if (config.playertargetpowerheight == 0) then
			self.Power:Hide()
		end

		-- auras
		if (config.aurastyle == "Bars") then
			self.DisabledDebuffs = self.Buffs or self.DisabledDebuffs
			if (self.Debuffs) then
				self.Debuffs:Hide()
				self.Debuffs = nil
			end

			self:EnableElement("AuraBars")
			self.AuraBars:Show()

			self.DisabledBuffs = self.Buffs or self.DisabledBuffs
			self.Buffs = self.DisabledBuffs or self.Buffs
			self.Buffs:Show()
			self.Buffs:ClearAllPoints()
			self.Buffs:SetPoint("BOTTOMLEFT", self.Name, "TOPLEFT", 2, 4)
			self.Buffs:SetSize(config.playertargetwidth / 2.5, 60)
			self.Buffs.size = config.target_uf_buff_size
			self.Buffs.initialAnchor  = "BOTTOMLEFT"
			self.Buffs["growth-x"] = "RIGHT"
		elseif (config.aurastyle == "Icons") then
			self.Debuffs = self.DisabledDebuffs or self.Debuffs
			self.Debuffs.size = config.target_uf_debuff_size
			self.Debuffs:Show()
			
			self:DisableElement("AuraBars")
			self.AuraBars:Hide()
			
			self.DisabledBuffs = self.Buffs or self.DisabledBuffs
			self.Buffs = self.DisabledBuffs or self.Buffs
			self.Buffs:Show()
			self.Buffs:ClearAllPoints()
			self.Buffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
			self.Buffs:SetSize(config.playertargetwidth / 2.5, 60)
			self.Buffs.size = config.target_uf_buff_size
			self.Buffs.initialAnchor = "BOTTOMRIGHT"
			self.Buffs["growth-x"] = "LEFT"
		else
			self.DisabledDebuffs = self.Buffs or self.DisabledDebuffs
			if (self.Debuffs) then
				self.Debuffs:Hide()
				self.Debuffs = nil
			end

			self.DisabledBuffs = self.Buffs or self.DisabledBuffs
			if (self.Buffs) then
				self.Buffs:Hide()
				self.Buffs = nil
			end

			self:DisableElement("AuraBars")
			self.AuraBars:Hide()
		end
	end
end
