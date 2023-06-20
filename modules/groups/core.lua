--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Groups")
local config
local oUF = bdUI.oUF
mod.frames = {}

local dispelColors = {
	['Magic'] = {.16, .5, .81, 1},
	['Poison'] = {.12, .76, .36, 1},
	['Disease'] = {.76, .46, .12, 1},
	['Curse'] = {.80, .33, .95, 1},
}

--===============================================
-- Core functionality
-- place core functionality here
--===============================================
-- upcoming features
-- fully custom sorting, custom player positions
-- bouqets / positioning
-- specific spell positioning
-- [buffs] [debuffs] [raid cooldowns] [my casts] [personals]
-- [name] [status] [raid target] [readycheck]

--======================================================
-- Callback on creation and configuration change
--======================================================
local function update_frame(self)
	if (InCombatLockdown()) then return end

	self:SetSize(config.width, config.height)
	self.Short:SetWidth(config.width)
	if (not UnitIsPlayer(self.unit)) then
		self:SetSize(config.pets_width, config.pets_height)
		self.Short:SetWidth(config.pets_width)
	end	

	local role = UnitGroupRolesAssigned(self.unit)

	local show_power = false
	if (config.powerdisplay == "All") then
		show_power = true
	elseif (config.powerdisplay == "Healers" and role == "HEALER") then
		show_power = true
	end

	if (not show_power) then
		self.Power:SetHeight(1)
		self.Power:SetAlpha(0)
		self.Short:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 1, 0)
	else
		self.Power:SetHeight(config.powerheight)
		self.Power:SetAlpha(1)
		self.Short:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", 1, 2)
	end

	self.Buffs.size = config.buffSize
	self.Debuffs.size = config.debuffSize

	if (config.showGroupNumbers and IsInRaid()) then
		self.Group:Show()
	else
		self.Group:Hide()
	end

	self.Range = {
		insideAlpha = config.inrangealpha,
		outsideAlpha = config.outofrangealpha,
	}

	if (not config.roleicon) then
		self.GroupRoleIndicator:Hide()
	end

	
	if (config.showGroupNumbers and IsInRaid()) then
		self.Group:Show()
	else
		self.Group:Hide()
	end
end


function mod:config_callback()
	mod.config = mod:get_save()
	config = mod.config
	if (not config.enabled_raid) then return false end

	mod.highlights = bdUI:lowercase_table(config.specialalerts)
	
	-- prevent case where callback is called before frameHeader initialization
	if (not mod.frameHeader) then return end

	mod:resize_container(mod.frameHeader)

	for k, self in pairs(mod.frames) do
		update_frame(self)
	end
end

--===============================================
-- Layout
--===============================================
local index = 0;
local function layout(self, unit)
	self:RegisterForClicks('AnyDown')
	index = index + 1
	self.index = index

	local border = bdUI:get_border(self)
	mod.border = border

	-- Unit doesn't always include index
	if (unit == "raid" or unit == "party") then
		self.unit = "raid"..index
	else
		self.unit = unit
	end
	
	-- Disable tooltips			
	self:SetScript('OnEnter', function(self)
		-- self.Health.highlight:Show()
		if (not config.hidetooltips) then
			UnitFrame_OnEnter(self)
			GameTooltip:SetUnit(self.unit)
		end
	end)
	self:SetScript('OnLeave', function(self)
		-- self.Health.highlight:Hide()
		if (not config.hidetooltips) then
			UnitFrame_OnLeave(self)
			GameTooltip:SetUnit(self.unit)
		end
	end)

	--===============================================
	-- Health
	--===============================================
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(bdUI.media.smooth)
	self.Health:SetPoint("TOPLEFT", self)
	self.Health:SetPoint("BOTTOMRIGHT", self)
	self.Health.frequentUpdates = true
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.colorHealth = true
	bdUI:set_backdrop(self.Health)
	function self.Health.PostUpdateColor(s, unit, r, g, b)
		-- local r, g, b = self.Health:GetStatusBarColor()
		if (r == nil) then return end
		local bg = bdUI.media.backdrop
		
		if (config.invert) then
			self.Health:SetStatusBarColor(unpack(bdUI.media.backdrop))
			self.Health._background:SetVertexColor(r / 2, g / 2, b / 2)
			self.Short:SetTextColor(r*1.1, g*1.1, b*1.1)
			self.bdHealthPrediction.absorbBar:SetStatusBarColor(1, 1, 1, .1)
			self.bdHealthPrediction.overAbsorb:SetStatusBarColor(1, 1, 1, .1)
		else
			self.Health:SetStatusBarColor(r / 1.5, g / 1.5, b / 1.5)
			self.Health._background:SetVertexColor(unpack(bdUI.media.backdrop))
			self.Short:SetTextColor(1, 1, 1)
			self.bdHealthPrediction.absorbBar:SetStatusBarColor(0, 0, 0, .4)
			self.bdHealthPrediction.overAbsorb:SetStatusBarColor(0, 0, 0, .4)
		end
	end

	--===============================================
	-- Healing & Damage Absorbs
	--===============================================
	-- Heal predections
	local incomingHeals = CreateFrame('StatusBar', nil, self.Health)
	incomingHeals:SetStatusBarTexture(bdUI.media.flat)
	incomingHeals:SetStatusBarColor(0.6,1,0.6,.2)
	incomingHeals:Hide()

	-- Damage Absorbs
	local absorbBar = CreateFrame('StatusBar', nil, self.Health)
	absorbBar:SetStatusBarTexture(bdUI.media.flat)
	absorbBar:SetStatusBarColor(.1, .1, .1, .6)
	absorbBar:Hide()
	local overAbsorbBar = CreateFrame('StatusBar', nil, self.Health)
	overAbsorbBar:SetAllPoints()
	overAbsorbBar:SetStatusBarTexture(bdUI.media.flat)
	overAbsorbBar:SetStatusBarColor(.1, .1, .1, .6)
	overAbsorbBar:Hide()

	-- Healing Absorbs
	local healAbsorbBar = CreateFrame('StatusBar', nil, self.Health)
	healAbsorbBar:SetReverseFill(true)
	healAbsorbBar:SetStatusBarTexture(bdUI.media.flat)
	healAbsorbBar:SetStatusBarColor(.3, 0, 0, .5)
	healAbsorbBar:Hide()
	local overHealAbsorbBar = CreateFrame('StatusBar', nil, self.Health)
	overHealAbsorbBar:SetReverseFill(true)
	overHealAbsorbBar:SetStatusBarTexture(bdUI.media.flat)
	overHealAbsorbBar:SetStatusBarColor(.3, 0, 0, .5)
	overHealAbsorbBar:Hide()

	-- Register and callback
	self.bdHealthPrediction = {
		incomingHeals = incomingHeals,

		absorbBar = absorbBar,
		overAbsorb = overAbsorbBar,

		healAbsorbBar = healAbsorbBar,
		overHealAbsorb = overHealAbsorbBar,
	}

	-- Resurrect 
	self.ResurrectIndicator = self.Health:CreateTexture(nil, 'OVERLAY')
	self.ResurrectIndicator:SetSize(16, 16)
    self.ResurrectIndicator:SetPoint('TOPRIGHT', self)

	-- Summon
	self.SummonIndicator = self.Health:CreateTexture(nil, 'OVERLAY')
	self.SummonIndicator:SetSize(16, 16)
	self.SummonIndicator:SetPoint('TOPRIGHT', self)

	-- Phase
	self.PhaseIndicator = self.Health:CreateTexture(nil, 'OVERLAY')
	self.PhaseIndicator:SetSize(16, 16)
	self.PhaseIndicator:SetPoint('BOTTOMLEFT', self)

	-- Power
	self.Power = CreateFrame("StatusBar", nil, self.Health)
	self.Power:SetStatusBarTexture(bdUI.media.flat)
	self.Power:ClearAllPoints()
	self.Power:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT", 0, 0)
	self.Power:SetPoint("BOTTOMRIGHt", self.Health, "BOTTOMRIGHt", 0, 0)
	self.Power:SetSize(config.width, config.powerheight)
	self.Power:SetAlpha(0.8)
	self.Power.colorPower = true
	bdUI:set_backdrop(self.Power)
	
	-- Raid Icon
	self.RaidTargetIndicator = self.Health:CreateTexture(nil, "OVERLAY", nil, 1)
	self.RaidTargetIndicator:SetSize(12, 12)
	self.RaidTargetIndicator:SetPoint("TOP", self, "TOP", 0, -2)
	
	-- roll icon
	self.GroupRoleIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.GroupRoleIndicator:SetSize(12, 12)
	self.GroupRoleIndicator:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT",2,2)
	self.GroupRoleIndicator.Override = function(self, event)
		self.GroupRoleIndicator:Hide()

		local role = UnitGroupRolesAssigned(self.unit)
		if (config.roleicon) then
			if (role and (role == "HEALER" or role == "TANK")) then
				self.GroupRoleIndicator:SetTexCoord(GetTexCoordsForRoleSmallCircle(role))
				self.GroupRoleIndicator:Show()
			end
		end

		update_frame(self)
	end

	self.LeaderIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetSize(12, 12)
	self.LeaderIndicator:SetPoint("TOPLEFT", self.Health, "TOPLEFT",2,2)
	self.LeaderIndicator.PostUpdate = function(self, isLeader)
		if (not config.showpartyleadericon) then
			self:Hide()
		end
	end
	
	self.Range = {
		insideAlpha = config.inrangealpha,
		outsideAlpha = config.outofrangealpha,
	}
	
	-- Readycheck
	self.ReadyCheckIndicator = self.Health:CreateTexture(nil, 'OVERLAY', nil, 7)
	self.ReadyCheckIndicator:SetPoint('CENTER', self, 'CENTER', 0, 2)
	self.ReadyCheckIndicator:SetSize(12, 12)
	
	-- ResurrectIcon
	self.ResurrectIndicator = self.Health:CreateTexture(nil, 'OVERLAY')
	self.ResurrectIndicator:SetPoint('CENTER', self, "CENTER", 0,0)
	self.ResurrectIndicator:SetSize(16, 16)
	
	-- Threat
	local pixel = bdUI:get_pixel(self)
	self.ThreatLite = CreateFrame('frame', nil, self.Health, BackdropTemplateMixin and "BackdropTemplate")
	self.ThreatLite:SetPoint('TOPRIGHT', pixel, pixel)
	self.ThreatLite:SetPoint('BOTTOMLEFT', -pixel, -pixel)
	self.ThreatLite:SetBackdrop({bgFile = bdUI.media.flat, edgeFile = bdUI.media.flat, edgeSize = bdUI.pixel})
	self.ThreatLite:SetBackdropBorderColor(1, 0, 0,1)
	self.ThreatLite:SetBackdropColor(0,0,0,0)
	-- self.ThreatLite:SetSize(60, 50)
	self.ThreatLite:Hide()
	
	-- Buffs
	self.Buffs = CreateFrame("Frame", "bdGrid_buffs", self.Health)
	self.Buffs:SetPoint("TOPLEFT", self.Health, "TOPLEFT", border * 2, -border * 2)
	self.Buffs:SetFrameLevel(21)
	self.Buffs:EnableMouse(false)
	self.Buffs:SetSize(64, 16)
	self.Buffs.disableMouse = true
	self.Buffs.initialAnchor  = "TOPLEFT"
	self.Buffs.size = config.buffSize
	self.Buffs.spacing = mod.border
	self.Buffs.num = 6
	self.Buffs['growth-y'] = "DOWN"
	self.Buffs['growth-x'] = "RIGHT"

	self.Buffs.CustomFilter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		local castByMe = false
		if (source) then
			castByMe = UnitIsUnit(source, "player") or UnitIsUnit(source, "pet") or UnitIsUnit(source, "vehicle")
		end

		return bdUI:filter_aura(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)
	end

	self.Buffs.PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
		local name, _, _, debuffType, duration, expiration, caster, IsStealable, _, spellID = UnitAura(unit, index, button.filter)

		local dispelColors = {
			['Magic'] = {.16, .5, .81, 1},
			['Poison'] = {.12, .76, .36, 1},
			['Disease'] = {.76, .46, .12, 1},
			['Curse'] = {.80, .33, .95, 1},
		}

		button:set_border_color(unpack(bdUI.media.border))

		bdUI:update_duration(button.cd, unit, spellID, caster, name, duration, expiration)
	end

	self.Buffs.PostCreateIcon = function(self, button) 
		local region = button.cd:GetRegions()
		button:SetAlpha(0.8)
		region:SetAlpha(1)
		region:Show()
		if (config.showBuffTimers) then
			region:SetTextHeight(config.buffSize)
			region:SetJustifyH("CENTER")
			region:SetJustifyV("MIDDLE")
			region:SetPoint("TOPLEFT", button.cd, "TOPLEFT", -config.buffSize, 0)
			region:SetPoint("BOTTOMRIGHT", button.cd, "BOTTOMRIGHT", config.buffSize, 0)
		else
			region:SetAlpha(0)
			region:Hide()
		end

		button.cd:SetReverse(true)
		button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		bdUI:set_backdrop(button)
	end
	
	-- special spell alerts
	self.Glow = CreateFrame("frame", "glow", self.Health)
	self.Glow:SetAllPoints()
	self.Glow:SetFrameLevel(3)

	-- Dispels
	local dispel_size = bdUI.pixel * 2
	self.Dispel = CreateFrame('frame', nil, self.Health, BackdropTemplateMixin and "BackdropTemplate")
	self.Dispel:SetFrameLevel(100)
	self.Dispel:SetPoint('TOPRIGHT', self, "TOPRIGHT", -0, -0)
	self.Dispel:SetPoint('BOTTOMLEFT', self, "BOTTOMLEFT", 0, 0)
	self.Dispel:SetBackdrop({bgFile = bdUI.media.flat, edgeFile = bdUI.media.flat, edgeSize = dispel_size})
	self.Dispel:SetBackdropBorderColor(1, 1, 1, 1)
	self.Dispel:SetBackdropColor(0, 0, 0, 0)
	self.Dispel:Hide()
	-- self.Dispel:SetSize(60, 50)
	
	-- look / color / show dispels and glows
	self:RegisterEvent("UNIT_AURA", mod.dispel_glow)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", mod.dispel_glow)

	-- overlays if there are multiple dispells
	self.Dispel.Magic = self.Dispel:CreateTexture(nil, "OVERLAY")
	self.Dispel.Magic:SetPoint("TOPLEFT", self.Health, "TOPLEFT")
	self.Dispel.Magic:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT")
	self.Dispel.Magic:SetWidth(dispel_size)
	self.Dispel.Magic:SetTexture(bdUI.media.flat)
	self.Dispel.Magic:SetVertexColor(unpack(dispelColors['Magic']))
	self.Dispel.Magic:Hide()

	-- -- overlays if there are multiple dispells
	self.Dispel.Disease = self.Dispel:CreateTexture(nil, "OVERLAY")
	self.Dispel.Disease:SetPoint("TOPLEFT", self.Health, "TOPLEFT")
	self.Dispel.Disease:SetPoint("TOPRIGHT", self.Health, "TOPRIGHT")
	self.Dispel.Disease:SetHeight(dispel_size)
	self.Dispel.Disease:SetTexture(bdUI.media.flat)
	self.Dispel.Disease:SetVertexColor(unpack(dispelColors['Disease']))
	self.Dispel.Disease:Hide()

	-- -- overlays if there are multiple dispells
	self.Dispel.Poison = self.Dispel:CreateTexture(nil, "OVERLAY")
	self.Dispel.Poison:SetPoint("TOPRIGHT", self.Health, "TOPRIGHT")
	self.Dispel.Poison:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT")
	self.Dispel.Poison:SetWidth(dispel_size)
	self.Dispel.Poison:SetTexture(bdUI.media.flat)
	self.Dispel.Poison:SetVertexColor(unpack(dispelColors['Poison']))
	self.Dispel.Poison:Hide()

	-- -- overlays if there are multiple dispells
	self.Dispel.Curse = self.Dispel:CreateTexture(nil, "OVERLAY")
	self.Dispel.Curse:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT")
	self.Dispel.Curse:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT")
	self.Dispel.Curse:SetHeight(dispel_size)
	self.Dispel.Curse:SetTexture(bdUI.media.flat)
	self.Dispel.Curse:SetVertexColor(unpack(dispelColors['Curse']))
	self.Dispel.Curse:Hide()
	
	-- Debuffs
	self.Debuffs = CreateFrame("Frame", "bdGrid_debuffs", self.Health)
	self.Debuffs:SetFrameLevel(21)
	self.Debuffs:SetPoint("CENTER")
	self.Debuffs:SetFrameLevel(27)
	self.Debuffs:SetSize(44, 22)
	self.Debuffs.initialAnchor = "CENTER"
	self.Debuffs.size = config.debuffSize
	self.Debuffs:EnableMouse(false)
	self.Debuffs.disableMouse = true
	self.Debuffs.spacing = 1
	self.Debuffs.num = 4
	self.Debuffs['growth-y'] = "DOWN"
	self.Debuffs['growth-x'] = "RIGHT"

	self.Debuffs.PostUpdate = function(self, unit)
		local offset =  (config.debuffSize / 2) * (self.visibleDebuffs - 1)
		self:SetPoint("CENTER", -offset, 0)
	end

	self.Debuffs.CustomFilter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		local castByMe = false
		if (source) then
			castByMe = UnitIsUnit(source, "player") or UnitIsUnit(source, "pet") or UnitIsUnit(source, "vehicle")
		end

		bdUI:update_duration(button.cd, unit, spellID, caster, name, duration, expiration)

		return bdUI:filter_aura(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)
	end

	self.Debuffs.PostCreateIcon = function(self, button)
		local region = button.cd:GetRegions()
		button:SetAlpha(0.8)
		
		if (config.showDebuffTimers) then
			region:SetAlpha(1)
			region:SetTextHeight(config.debuffSize)
			region:SetJustifyH("CENTER")
			region:SetJustifyV("MIDDLE")
			region:ClearAllPoints()
			region:SetPoint("CENTER")
			-- region:SetPoint("TOPLEFT", button.cd, "TOPLEFT", -config.debuffSize, 0)
			-- region:SetPoint("BOTTOMRIGHT", button.cd, "BOTTOMRIGHT", config.debuffSize, 0)
		else
			region:SetAlpha(0)
		end

		button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		bdUI:set_backdrop(button)
	end

	self.Debuffs.PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
		bdUI:update_duration(button.cd, unit, spellID, caster, name, duration, expiration)

		-- color borders of debuffs
		if (dispelColors[debuffType]) then
			button._border:SetVertexColor(unpack(dispelColors[debuffType]))
		else
			button._border:SetVertexColor(unpack(bdUI.media.border))
		end
	end


	--===============================================
	-- Tags
	--===============================================
	self.name_holder = CreateFrame("frame", nil, self.Health)
	mod.add_tags(self, unit)
	
	table.insert(mod.frames, self)
	update_frame(self)
end

--============================================================
-- Build positioning and attributes
--============================================================
function mod:get_attributes()
	local group_by, group_sort, sort_method, yOffset, xOffset, new_group_anchor, new_player_anchor, hgrowth, vgrowth, num_groups
	
	-- sorting options
	if (config.group_sort == "Group") then
		group_by = "GROUP"
		group_sort = "1, 2, 3, 4, 5, 6, 7, 8"
		sort_method = "INDEX"
	elseif (config.group_sort == "Role") then
		group_by = "ROLE"
		group_sort = "TANK,DAMAGE,NONE,HEAL"
		sort_method = "NAME"
	elseif (config.group_sort == "Name") then
		group_by = nil
		group_sort = "1, 2, 3, 4, 5, 6, 7, 8"
		sort_method = "NAME"
	elseif (config.group_sort == "Class") then
		group_by = "CLASS"
		group_sort = "WARRIOR,DEATHKNIGHT,PALADIN,DRUID,MONK,ROGUE,DEMONHUNTER,HUNTER,PRIEST,WARLOCK,MAGE,SHAMAN"
		sort_method = "NAME"
	end
	
	-- group growth/spacing
	if (config.group_growth == "Upwards") then
		new_group_anchor = "BOTTOM"
		yOffset = -config.spacing
	elseif (config.group_growth == "Downwards") then
		new_group_anchor = "TOP"
		yOffset = -config.spacing
	elseif (config.group_growth == "Left") then
		new_group_anchor = "RIGHT"
		xOffset = -config.spacing
	elseif (config.group_growth == "Right") then
		new_group_anchor = "LEFT"
		xOffset = config.spacing
	end
	
	-- player growth/spacing
	if (not config.new_player_reverse) then
		if (config.group_growth == "Upwards" or config.group_growth == "Downwards") then
			new_player_anchor = "LEFT"
			xOffset = config.spacing
		elseif (config.group_growth == "Left" or config.group_growth == "Right") then
			new_player_anchor = "TOP"
			yOffset = -config.spacing
		end
	elseif (config.new_player_reverse) then
		if (config.group_growth == "Upwards" or config.group_growth == "Downwards") then
			new_player_anchor = "RIGHT"
			xOffset = -config.spacing
		elseif (config.group_growth == "Left" or config.group_growth == "Right") then
			new_player_anchor = "BOTTOM"
			yOffset = config.spacing
		end
	end
	
	-- group limit
	local difficultySize = {
		[3] = 1,
		[4] = 25,
		[5] = 10,
		[6] = 25,
		[7] = 25,
		[9] = 40,
		[14] = 30,
		[15] = 30,
		[16] = 20,
		[17] = 30,
		[18] = 40,
		[20] = 25,
		[149] = 30
	}

	local difficultySize = {
		[1] = 5, -- Normal	party
		[2] = 5, -- Heroic	party	isHeroic
		[3] = 10, -- 10 Player	raid	toggleDifficultyID: 5
		[4] = 25, -- 25 Player	raid	toggleDifficultyID: 6
		[5] = 10, -- 10 Player (Heroic)	raid	isHeroic, toggleDifficultyID: 3
		[6] = 25, -- 25 Player (Heroic)	raid	isHeroic, toggleDifficultyID: 4
		[7] = 30, -- Looking For Raid	raid	(Legacy LFRs; prior to SoO)
		[8] = 5, -- Mythic Keystone	party	isHeroic, isChallengeMode
		[9] = 40, -- 40 Player	raid
		[11] = 5, -- Heroic Scenario	scenario	isHeroic
		[12] = 5, -- Normal Scenario	scenario
		[14] = 30, -- Normal	raid
		[15] = 30, -- Heroic	raid	displayHeroic
		[16] = 20, -- Mythic	raid	isHeroic, displayMythic
		[17] = 25, -- Looking For Raid	raid
		[18] = 30, -- Event	raid
		[19] = 5, -- Event	party
		[20] = 5, -- Event Scenario	scenario
		[23] = 5, -- Mythic	party	isHeroic, displayMythi
		[24] = 5, -- Timewalking	party
		[25] = 5, -- World PvP Scenario	scenario
		[29] = 5, -- PvEvP Scenario	pvp
		[30] = 5, -- Event	scenario
		[32] = 5, -- World PvP Scenario	scenario
		[33] = 40, -- Timewalking	raid
		[34] = 40, -- PvP	pvp
		[38] = 5, -- Normal	scenario
		[39] = 5, -- Heroic	scenario	displayHeroic
		[40] = 5, -- Mythic	scenario	displayMythic
		[45] = 5, -- PvP	scenario	displayHeroic
		[147] = 5, -- Normal	scenario	(Warfronts)
		[148] = 20, -- 20 Player	raid	(Classic WoW 20mans; ZG, AQ20)
		[149] = 20, -- Heroic	scenario	displayHeroic (Warfronts)
		[150] = 5, -- Normal	party
		[151] = 25, -- Looking For Raid	raid	(Timewalking)
		[152] = 5, -- Visions of N'Zoth	scenario
		[153] = 5, -- Teeming Island	scenario	displayHeroic
		[167] = 40, -- Torghast	scenario
		[168] = 5, -- Path of Ascension: Courage	scenario
		[169] = 5, -- Path of Ascension: Loyalty	scenario
		[170] = 5, -- Path of Ascension: Wisdom	scenario
		[171] = 5, -- Path of Ascension: Humility	scenario
	}

	
	num_groups = config.num_groups
	if (config.intel_groups) then
		local name, group_type, difficultyID, raidSize, dynamicDifficulty, isDynamic, instanceMapId, lfgID = GetInstanceInfo()
		local inInstance, instanceType = select(1, IsInInstance())

		local diff = select(3, GetInstanceInfo())
		local size = select(5, GetInstanceInfo())
		size = tonumber(size)

		-- print(diff, size)
		if (not inInstance) then
			num_groups = 8
		elseif (size > 0) then
			num_groups = size / 5
		elseif (difficultySize[diff]) then
			num_groups = difficultySize[diff] / 5
		end
	end

	xOffset = bdUI.pixel * (xOffset or 2)
	yOffset = bdUI.pixel * (yOffset or 2)

	-- print(xOffset)

	return group_by, group_sort, sort_method, yOffset, xOffset, new_group_anchor, new_player_anchor, hgrowth, vgrowth, num_groups
end

--======================================================
-- Update the raidframe header with new configuration values
--======================================================
function mod:update_header(header)
	if (InCombatLockdown()) then return end

	local group_by, group_sort, sort_method, yOffset, xOffset, new_group_anchor, new_player_anchor, hgrowth, vgrowth, num_groups = mod:get_attributes()

	-- reize the container if necessary
	mod:resize_container(header)

	-- growth/spacing
	header:SetAttribute("columnAnchorPoint", new_group_anchor)
	header:SetAttribute("point", new_player_anchor)

	if (config.group_growth == "Right") then
		header:SetAttribute("columnSpacing", xOffset)
	else
		header:SetAttribute("columnSpacing", -yOffset)
	end

	header:SetAttribute("yOffset", yOffset)
	header:SetAttribute("xOffset", xOffset)

	-- what to show
	header:SetAttribute("showpartyleadericon", config.showpartyleadericon)
	
	-- when to show
	header:SetAttribute("showSolo", config.showsolo)
	header:SetAttribute("maxColumns", num_groups)
	
	-- width/height
	header:SetAttribute("initial-width", config.width)
	header:SetAttribute("initial-height", config.height)
	
	-- grouping/sorting
	header:SetAttribute("groupBy", group_by)
	header:SetAttribute("groupingOrder", group_sort)
	header:SetAttribute("sortMethod", sort_method)
end

function style_callback(self)
	-- print(self.unit)
end

local function newlayout_test(...)
	print("test", ...)
end



--======================================================
-- Initialize
--======================================================
function mod:initialize()
	mod.config = mod:get_save()
	config = mod.config

	-- exit if not initialized
	if (not config.enabled_raid) then return false end

	mod.highlights = bdUI:lowercase_table(config.specialalerts)

	-- make sure we can store grid aliases
	bdUI.persistent.GridAliases = bdUI.persistent.GridAliases or {}

	-- hold the raid and pet frames
	mod:create_containers()

	-- send to factory
	oUF:RegisterStyle('bdGrid', layout)
	oUF:Factory(function(self)
		self:SetActiveStyle('bdGrid')

		-- Initial header spawning
		local group_by, group_sort, sort_method, yOffset, xOffset, new_group_anchor, new_player_anchor, hgrowth, vgrowth, num_groups = mod:get_attributes()

		mod.frameHeader = self:SpawnHeader(nil, nil, 'raid,party,solo',
			"showParty", true,
			"showPlayer", true,
			"showSolo", config.showSolo,
			"showRaid", true,
			"initial-scale", 1,
			"unitsPerColumn", 5,
			"columnSpacing", yOffset,
			"xOffset", xOffset,
			"yOffset", yOffset,
			"maxColumns", num_groups,
			"groupingOrder", group_sort,
			"sortMethod", sort_method,
			"columnAnchorPoint", new_group_anchor,
			"initial-width", config.width,
			"initial-height", config.height,
			"point", new_player_anchor,
			"groupBy", group_by,
			'oUF-initialConfigFunction', format('self:SetWidth(%d); self:SetHeight(%d);', config.width, config.height)
		)

		mod:update_header(mod.frameHeader)

		mod.petframeHeader = self:SpawnHeader(nil, "SecureGroupPetHeaderTemplate", 'raid,party',
			"showParty", true,
			"showSolo", false,
			"showRaid", true,
			"initial-scale", 1,
			"unitsPerColumn", 5,
			"columnSpacing", yOffset,
			"xOffset", xOffset,
			"yOffset", yOffset,
			"maxColumns", num_groups,
			"groupingOrder", group_sort,
			"sortMethod", sort_method,
			"columnAnchorPoint", new_group_anchor,
			"initial-width", config.pets_width,
			"initial-height", config.pets_height,
			"point", new_player_anchor,
			"groupBy", group_by,
			'oUF-initialConfigFunction', format('self:SetWidth(%d); self:SetHeight(%d);', config.pets_width, config.pets_height)
		)

		mod.petframeHeader:SetPoint("CENTER", UIParent)

		mod:update_header(mod.petframeHeader)
	end)

	-- disable blizzard things
	mod:disable_blizzard()
end


--===============================================
-- Raid container, match layout of groups
--===============================================
function mod:create_containers()

	-- raid and party
	local raid_party = CreateFrame('frame', "bdGrid", UIParent)
	raid_party:SetSize(config['width'], config['height']*5)
	raid_party:SetPoint("LEFT", UIParent, "LEFT", 10, -90)
	bdMove:set_moveable(raid_party, "Raid Frames")

	-- register events for resizing the box/group size
	raid_party:RegisterEvent("PLAYER_REGEN_ENABLED")
	raid_party:RegisterEvent("PLAYER_ENTERING_WORLD")
	raid_party:RegisterEvent("RAID_ROSTER_UPDATE")
	raid_party:RegisterEvent("GROUP_JOINED")
	raid_party:RegisterEvent("GROUP_ROSTER_UPDATE")
	raid_party:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	raid_party:SetScript("OnEvent", function(self, event, arg1)
		if (event == "PLAYER_ENTERING_WORLD") then
			C_Timer.After(2, function()
				mod:update_header(mod.frameHeader)
			end)
		end

		mod:update_header(mod.frameHeader)
	end)

	mod.raidpartyholder = raid_party

	-- pets
	local pets_holder = CreateFrame('frame', "bdGrid", UIParent)
	pets_holder:SetSize(config['width'], config['height']*5)
	pets_holder:SetPoint("LEFT", raid_party, "RIGHT", 10, 0)
	bdMove:set_moveable(pets_holder, "Pet Frames")

	-- register events for resizing the box/group size
	pets_holder:RegisterEvent("PLAYER_REGEN_ENABLED")
	pets_holder:RegisterEvent("PLAYER_ENTERING_WORLD")
	pets_holder:RegisterEvent("RAID_ROSTER_UPDATE")
	pets_holder:RegisterEvent("GROUP_JOINED")
	pets_holder:RegisterEvent("GROUP_ROSTER_UPDATE")
	pets_holder:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	pets_holder:SetScript("OnEvent", function(self, event, arg1)
		if (event == "PLAYER_ENTERING_WORLD") then
			C_Timer.After(2, function()
				mod:update_header(mod.petframeHeader)
			end)
		end

		mod:update_header(mod.petframeHeader)
	end)

	mod.petsholder = pets_holder
end

function mod:resize_container(header)
	header:ClearAllPoints();

	local width = config.width
	local height = config.height
	if (header == mod.petframeHeader) then
		width = config.pets_width
		height = config.pets_height
	end

	local size = 5
	if (bdUI.version >= 80000) then
		size = 4
	end

	-- change where to start the growth of groups
	if (config.group_growth == "Right") then
		mod.raidpartyholder:SetSize(width*5+8, height*5+8)
		hgrowth = "LEFT"
		vgrowth = "TOP"
		if (config.new_player_reverse) then vgrowth = "BOTTOM" end
		
	elseif (config.group_growth == "Left") then
		mod.raidpartyholder:SetSize(width*5+8, height*5+8)
		hgrowth = "RIGHT"
		vgrowth = "TOP"
		if (config.new_player_reverse) then vgrowth = "BOTTOM" end
		
	elseif (config.group_growth == "Upwards") then
		mod.raidpartyholder:SetSize(width*5+8, height*4+8)
		hgrowth = "LEFT"
		vgrowth = "BOTTOM"
		if (config.new_player_reverse) then hgrowth = "RIGHT" end
		
	elseif (config.group_growth == "Downwards") then
		mod.raidpartyholder:SetSize(width*5+8, height*4+8)
		hgrowth = "LEFT"
		vgrowth = "TOP"
		if (config.new_player_reverse) then hgrowth = "RIGHT" end
	end

	if (header == mod.frameHeader) then
		header:SetPoint(vgrowth..hgrowth, mod.raidpartyholder, vgrowth..hgrowth, 0, 0)
	else
		header:SetPoint(vgrowth..hgrowth, mod.petsholder, vgrowth..hgrowth, 0, 0)
	end

end

--==============================================
-- Disable blizzard raid frames
--==============================================
function mod:disable_blizzard()
	-- local addonDisabler = CreateFrame("frame", nil)
	-- addonDisabler:RegisterEvent("ADDON_LOADED")
	-- addonDisabler:RegisterEvent("PLAYER_REGEN_ENABLED")
	-- addonDisabler:SetScript("OnEvent", function(self, event, addon)
	-- 	if (InCombatLockdown()) then return end

	-- 	if (CompactUnitFrameProfiles) then
	-- 		-- CompactUnitFrameProfiles:UnregisterAllEvents()
	-- 		-- CompactRaidFrameManagerContainerResizeFrame:Hide()
	-- 	end
	-- 	if (IsAddOnLoaded("Blizzard_CompactRaidFrames")) then
	-- 		-- CompactRaidFrameManager:UnregisterAllEvents() 
	-- 		-- CompactRaidFrameContainer:UnregisterAllEvents() 
	-- 	end
	-- 	-- addonDisabler:UnregisterEvent("PLAYER_REGEN_ENABLED")
	-- end)
end
