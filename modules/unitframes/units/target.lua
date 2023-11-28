local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")


local function position_buffs(self, unit, config, side)
	self.Buffs:ClearAllPoints()
	if (side == "Top Right") then
		self.Buffs:SetPoint("BOTTOMLEFT", self.Health, "TOPRIGHT", 2, 2)
		self.Buffs:SetSize(config.playertargetwidth / 2.5, 60)
		self.Buffs.size = config.target_uf_buff_size
		self.Buffs.initialAnchor = "BOTTOMLEFT"
	elseif (side == "Top") then
		self.Buffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
		self.Buffs:SetSize(config.playertargetwidth / 2.5, 60)
		self.Buffs.size = config.target_uf_buff_size
		self.Buffs.initialAnchor = "BOTTOMRIGHT"
		self.Buffs["growth-x"] = "LEFT"
	elseif (side == "Right") then
		self.Buffs:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 4, 0)
		self.Buffs:SetSize(config.playertargetwidth / 2.5, 60)
		self.Buffs.size = config.target_uf_buff_size
		self.Buffs.initialAnchor = "TOPLEFT"
		self.Buffs["growth-x"] = "RIGHT"
		self.Buffs["growth-y"] = "DOWN"
	elseif (side == "Bottom Right") then
		self.Buffs:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -4)
		self.Buffs:SetSize(config.playertargetwidth / 2.5, 60)
		self.Buffs.size = config.target_uf_buff_size
		self.Buffs.initialAnchor = "TOPRIGHT"
		self.Buffs["growth-x"] = "LEFT"
		self.Buffs["growth-y"] = "DOWN"
	elseif (side == "Bottom Left") then
		self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -4)
		self.Buffs:SetSize(config.playertargetwidth / 2.5, 60)
		self.Buffs.size = config.target_uf_buff_size
		self.Buffs.initialAnchor = "TOPLEFT"
		self.Buffs["growth-x"] = "RIGHT"
		self.Buffs["growth-y"] = "DOWN"
	end
end


local buff_filter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source,
	isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
	isBossDebuff = isBossDebuff or false
	nameplateShowAll = nameplateShowAll or false
	nameplateShowPersonal = nameplateShowPersonal or false
	local castByMe = false
	if (source) then
		castByMe = UnitIsUnit(source, "player") or UnitIsUnit(source, "pet") or UnitIsUnit(source, "vehicle")
	end

	-- don't show if blacklisted
	if (bdUI:is_blacklisted(name)) then
		return false
	end

	-- force show if whitelisted
	if (bdUI:is_whitelisted(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
		return true
	end

	-- always show boss or stealable buffs
	if (isStealable or isBossDebuff) then
		return true
	end

	-- now show my stuff
	if (castByPlayer) then -- cast by a player, but not a mount or an aura
		return true
	end

	return not castByPlayer or not source -- this may have been casted by no one or by a boss
end

-- debuff filter for both icons and bars
local debuff_filter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source,
	isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
	isBossDebuff = isBossDebuff or false
	nameplateShowAll = nameplateShowAll or false
	nameplateShowPersonal = nameplateShowPersonal or false
	local castByMe = false
	if (source) then
		castByMe = UnitIsUnit(source, "player") or UnitIsUnit(source, "pet") or UnitIsUnit(source, "vehicle")
	end

	-- don't show if blacklisted
	if (bdUI:is_blacklisted(name)) then
		return false
	end

	-- check if this is a nameplate whitelist thing from blizzard
	if (bdUI:is_whitelist_nameplate(castByMe, nameplateShowPersonal, nameplateShowAll)) then
		-- print("whitelisted nameplate", name)
		return true
	end

	-- force show if whitelisted
	if (bdUI:is_whitelisted(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
		-- print("whitelisted", name)
		return true
	end

	-- if its cast by me and isn't permanent
	if (duration < 300 and castByMe) then -- cast by a player, but not a mount or an aura
		-- print("me", name)
		return true
	end

	if (not castByPlayer and not source) then
		-- print("else", name, castByPlayer, source, nameplateShowPersonal, nameplateShowAll)
		return true
	end
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

	-- icon buffs
	-- self.Buffs:ClearAllPoints()

	-- self.Buffs:SetSize(config.playertargetwidth / 2.5, 60)
	-- self.Buffs.size = config.target_uf_buff_size
	-- self.Buffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
	-- self.Buffs['growth-x'] = "LEFT"
	-- self.Buffs.initialAnchor = "BOTTOMRIGHT"
	-- self.Buffs.CustomFilter = buff_filter

	-- if (config.target_buff_location == "Top Right") then

	-- elseif (config.target_buff_location == "Right") then
	-- 	self.Buffs:SetPoint("LEFT", self.Health, "RIGHT", 0, 4)
	-- 	self.Buffs['growth-x'] = "LEFT"
	-- 	self.Buffs.initialAnchor = "BOTTOMRIGHT"
	-- end

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

	-- config callback
	self.callback = function()
		local makeupHeight = 0
		-- power
		self.Power:SetHeight(config.targetpowerheight)
		self.Power:Show()
		if (config.targetpowerheight == 0) then
			self.Power:Hide()
			makeupHeight = 2
		end

		-- sizing
		self:SetSize(config.playertargetwidth, config.playertargetheight + makeupHeight)
		self.Health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, config.targetpowerheight + bdUI.border)



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
			position_buffs(self, unit, config, config.target_buff_location)
		elseif (config.aurastyle == "Icons") then
			self.Debuffs = self.DisabledDebuffs or self.Debuffs
			self.Debuffs.size = config.target_uf_debuff_size
			self.Debuffs:Show()

			self:DisableElement("AuraBars")
			self.AuraBars:Hide()

			self.DisabledBuffs = self.Buffs or self.DisabledBuffs
			self.Buffs = self.DisabledBuffs or self.Buffs
			self.Buffs:Show()
			position_buffs(self, unit, config, "Top")
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
