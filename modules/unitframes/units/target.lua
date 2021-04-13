local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

-- debuff filter for both icons and bars
local debuff_filter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
	isBossDebuff = isBossDebuff or false
	nameplateShowAll = nameplateShowAll or false
	nameplateShowPersonal = nameplateShowPersonal or false
	local castByMe = source and UnitIsUnit(source, "player") or false

	if (bdUI:is_blacklisted(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
		return false
	end
	if (bdUI:is_whitelist_nameplate(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
		return true
	end

	return castByMe and duration ~= 0 and duration < 300
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
	self.Buffs:ClearAllPoints()
	self.Buffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
	self.Buffs:SetSize(config.playertargetwidth / 2.5, 60)
	self.Buffs.size = 14
	self.Buffs['growth-x'] = "LEFT"
	self.Buffs.initialAnchor  = "BOTTOMRIGHT"
	self.Buffs.PostUpdateIcon = function(self, unit, button, index, position)
		local name, _, _, debuffType, duration, expiration, caster, IsStealable, _, spellID = UnitAura(unit, index, button.filter)
		bdUI:update_duration(button.cd, unit, spellID, caster, name, duration, expiration)
	end
	self.Buffs.CustomFilter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		nameplateShowPersonal = nameplateShowPersonal or false
		local castByMe = source and UnitIsUnit(source, "player") or false

		if (bdUI:is_blacklisted(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
			return false
		end
		
		if (bdUI:is_whitelisted(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
			return true
		end

		if (isStealable or isBossDebuff) then
			return true
		end

		return duration > 0 and castByPlayer

		-- return true

		-- allow it if it's tracked in the ui and not blacklisted
		
		

		-- return true

		-- return bdUI:filter_aura(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)
		-- if ( bdUI:filter_aura(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll) ) then
		-- 	return true
		-- end

		-- if (InCombatLockdown()) then
		-- 	if (duration ~= 0 and duration > 300) then
		-- 		return true
		-- 	end
		-- else
		-- 	if (castByPlayer) then return true end
		-- 	if (source) then return true end
		-- 	if (isBossDebuff) then return true end
		-- end

		

		-- return true
		-- look for non player casters
		-- if (not strfind(source, "raid") and not strfind(source, "party") and not source == "player") then
		-- 	return true
		-- end
	end

	-- icon debuffs
	self.Debuffs:ClearAllPoints()
	self.Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
	self.Debuffs:SetWidth(config.playertargetwidth / 2)
	self.Debuffs.size = 22
	self.Debuffs.initialAnchor = "BOTTOMLEFT"
	self.Debuffs['growth-x'] = "RIGHT"
	self.Debuffs.CustomFilter = debuff_filter
	self.Debuffs.PostUpdateIcon = function(self, unit, button, index, position)
		local name, _, _, debuffType, duration, expiration, caster, IsStealable, _, spellID = UnitAura(unit, index, button.filter)
		bdUI:update_duration(button.cd, unit, spellID, caster, name, duration, expiration)
	end

	-- aurabar debuffs
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
		-- self.Buffs:ClearAllPoints()

		-- if (config.uf_buff_target_match_player) then
		-- 	self.Buffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
		-- 	self.Buffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
		-- 	self.Buffs:SetSize(config.playertargetwidth, 60)
		-- 	self.Buffs.size = config.uf_buff_size
		-- 	self.Buffs['growth-x'] = "RIGHT"
		-- 	self.Buffs.initialAnchor  = "BOTTOMLEFT"
		-- else
		-- 	self.Buffs:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 7, 2)
		-- 	self.Buffs:SetSize(80, 60)
		-- 	self.Buffs.size = 12
		-- end

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
