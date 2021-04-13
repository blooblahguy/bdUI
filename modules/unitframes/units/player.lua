local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

local buff_filter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
	isBossDebuff = isBossDebuff or false
	nameplateShowAll = nameplateShowAll or false
	local castByMe = source and UnitIsUnit(source, "player") or false

	-- classic
	duration, expirationTime = bdUI:update_duration(button.cd, unit, spellId, source, name, duration, expirationTime)

	if (bdUI:is_blacklisted(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
		return false
	end

	-- if (bdUI:is_whitelisted(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
	-- 	return true
	-- end

	if (castByMe and duration ~= 0 and duration < 300) then
		return true
	end

	return bdUI:is_whitelist_nameplate(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)
end

mod.custom_layout["player"] = function(self, unit)
	local config = mod.save

	self:SetSize(config.playertargetwidth, config.playertargetheight)

	mod.additional_elements.power(self, unit)
	mod.additional_elements.castbar(self, unit, "left")
	mod.additional_elements.buffs(self, unit)
	-- mod.additional_elements.resting(self, unit)
	-- mod.additional_elements.combat(self, unit)
	mod.additional_elements.aurabars(self, unit)
	-- mod.additional_elements.perhp(self, unit)

	self.Buffs.CustomFilter = buff_filter
	self.AuraBars.CustomFilter = buff_filter

	-- create standalone resource bar
	mod.create_resources(self, unit)
	
	-- config callback
	self.callback = function(self, unit, config)
		self:SetSize(config.playertargetwidth, config.playertargetheight)

		mod:display_text(self, unit, "left")

		-- text
		-- if (config.hideplayertext) then
		-- 	self.Name:Hide()
		-- 	self.Curhp:Hide()
		-- else
		-- 	mod.align_text(self)
		-- 	self.Name:Show()
		-- 	self.Curhp:Show()
		-- end

		-- if (config.textlocation == "Minimal") then
		-- 	self.Perhp:ClearAllPoints()
		-- 	self.Perpp:ClearAllPoints()
		-- 	self.Perhp:SetPoint("RIGHT", self.Health, "RIGHT", -4, 0)
		-- 	self.Perpp:SetPoint("LEFT", self.Health, "LEFT", 4, 0)
		-- end

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
		-- if (config.enable_rested_indicator) then
		-- 	self:EnableElement("RestingIndicator")
		-- 	self.RestingIndicator:ClearAllPoints()
		-- 	if (config.textlocation == "Outside") then
		-- 		self.RestingIndicator:SetPoint("LEFT", self.Health, mod.padding, 1)
		-- 	elseif (config.textlocation == "Inside") then
		-- 		self.RestingIndicator:SetPoint("LEFT", self.Health, "CENTER", mod.padding, 1)
		-- 	end
		-- else
		-- 	self:DisableElement("RestingIndicator")
		-- end

		-- combat
		-- if (config.enable_combat_indicator) then
		-- 	self:EnableElement("CombatIndicator")
		-- 	self.CombatIndicator:ClearAllPoints()
		-- 	if (config.textlocation == "Outside") then
		-- 		self.CombatIndicator:SetPoint("RIGHT", self.Health, -mod.padding, 1)
		-- 	elseif (config.textlocation == "Inside") then
		-- 		self.CombatIndicator:SetPoint("RIGHT", self.Health, "CENTER", -mod.padding, 1)
		-- 	end
		-- else
		-- 	self:DisableElement("CombatIndicator")
		-- end

	end
end
