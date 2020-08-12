--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")
local oUF = bdUI.oUF
local config
local nameplates = {}

-- Fonts we use
mod.font = CreateFont("BDN_FONT")
mod.font:SetFont(bdUI.media.font, 14)
mod.font_friendly = CreateFont("BDN_FONT_FRIENDLY")
mod.font_small = CreateFont("BDN_FONT_SMALL")
mod.font_castbar = CreateFont("BDN_FONT_CASTBAR")

--===============================================
-- Core functionality
-- place core functionality here
--===============================================
function mod:nameplate_size()
	if (InCombatLockdown()) then return end

	C_NamePlate.SetNamePlateFriendlySize(config.width, 0.1)
	C_NamePlate.SetNamePlateEnemySize(config.width, (config.height + config.targetingTopPadding + config.targetingBottomPadding))
	C_NamePlate.SetNamePlateSelfSize(config.width, config.height)
	C_NamePlate.SetNamePlateFriendlyClickThrough(true)
	C_NamePlate.SetNamePlateSelfClickThrough(true)
end

function mod:config_callback()
	mod.config = mod:get_save()
	config = mod.config
	if (not config.enabled) then return false end
	
	-- Update nameplate sizing
	mod:nameplate_size()

	-- Update from bdConfig
	for k, self in pairs(nameplates) do
		local border = bdUI:get_border(self)

		-- health
		self.Health._shadow:SetBackdropColor(unpack(config.glowcolor))
		self.Health._shadow:SetBackdropBorderColor(unpack(config.glowcolor))

		-- castbar
		local cbi_size = (config.height+config.castbarheight) * config.castbariconscale
		self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -border, 0)
		self.Castbar.Icon:SetSize( cbi_size, cbi_size )
		self.Castbar.Icon.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -border, border)
		self.Castbar.Icon.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", border, -border)

		-- Disabled auras
		if (config.disableauras) then
			self.Auras:Hide()
		else
			self.Auras:Show()
		end
		self.Auras.size = config.raidbefuffs * config.scale

		if (config.markposition == "LEFT") then
			self.RaidTargetIndicator:SetPoint('LEFT', self, "RIGHT", -(config.raidmarkersize/2), 0)
		elseif (config.markposition == "RIGHT") then
			self.RaidTargetIndicator:SetPoint('RIGHT', self, "LEFT", config.raidmarkersize/2, 0)
		else
			self.RaidTargetIndicator:SetPoint('BOTTOM', self, "TOP", 0, config.raidmarkersize)
		end
	end

	mod.font:SetFont(bdUI.media.font, config.enemynamesize, "OUTLINE")
	mod.font_small:SetFont(bdUI.media.font, config.height * 0.78, "OUTLINE")
	mod.font_castbar:SetFont(bdUI.media.font, config.castbarheight * 0.78, "OUTLINE")
	mod.font_friendly:SetFont(bdUI.media.font, config.friendlynamesize, "OUTLINE")

	if (InCombatLockdown()) then return end
	-- set cVars
	local cvars = {
		['nameplateGlobalScale'] = config.scale
		, ['nameplateSelfScale'] = config.scale
		, ['nameplateSelfAlpha'] = 1
		, ['nameplateShowAll'] = 1
		, ['nameplateMinAlpha'] = 1
		, ['nameplateMaxAlpha'] = 1
		-- , ['nameplateMotionSpeed'] = "default"
		, ['nameplateOccludedAlphaMult'] = 1
		, ['nameplateMaxAlphaDistance'] = 1
		, ['nameplateMaxDistance'] = config.nameplatedistance+6 -- for some reason there is a 6yd diff
		, ['nameplateShowOnlyNames'] = 0
		, ['nameplateShowDebuffsOnFriendly'] = 0
		, ['nameplateSelectedScale'] = 1
		, ['nameplateMinScale'] = 1
		, ['nameplateMaxScale'] = 1
		-- , ['nameplateMaxScaleDistance'] = 80
		-- , ['nameplateMinScaleDistance'] = 5
		, ['nameplateLargerScale'] = 1 -- for bosses
		, ['nameplateShowOnlyNames'] = config.friendlynamehack and 1 or 0 -- friendly names and no plates in raid
		-- , ['showQuestTrackingTooltips'] = 1
	}

	-- loop through and set CVARS
	for k, v in pairs(cvars) do
		-- if (v == "default") then
		-- 	SetCVar(k, GetCVarDefault(k))	
		-- else
			SetCVar(k, v)
		-- end
	end
end

--==============================================
-- Show Kickable Casts
--==============================================
local function kickable_cast(self)
	self:SetAlpha(1)
	if (self.notInterruptible) then
		self.Icon:SetDesaturated(1)
		self:SetStatusBarColor(unpack(config.nonkickable))
	else
		self.Icon:SetDesaturated(false)
		self:SetStatusBarColor(unpack(config.kickable))
	end

	local border = bdUI:get_border(self)
	self.Icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", -border, 0)
	self.Icon.bg:SetPoint("TOPLEFT", self.Icon, "TOPLEFT", -border, border)
	self.Icon.bg:SetPoint("BOTTOMRIGHT", self.Icon, "BOTTOMRIGHT", border, -border)
end

--==============================================
-- Target Visuals
--==============================================
local function find_target(self, event, unit)
	unit = unit or self.unit
	if (UnitIsUnit(unit, "target")) then
		self.isTarget = true
		self:SetAlpha(1)
		if (not UnitIsUnit(unit, "player")) then
			self.Health._shadow:Show()
		end
	else
		self.isTarget = false
		self:SetAlpha(config.unselectedalpha)
		self.Health._shadow:Hide()
	end

	-- hp text
	if (config.hptext == "None" or (config.showhptexttargetonly and not self.isTarget)) then
		self.Curhp:Hide()
	else
		self.Curhp:Show()
	end
end

--==============================================
-- Unit Information Variables
--==============================================
local function unit_information(self, unit)
	self.tapDenied = UnitIsTapDenied(unit) or false
	self.status = UnitThreatSituation("player", unit)
	if (self.status == nil) then
		self.status = false
	end
	self.isPlayer = UnitIsPlayer(unit) and select(2, UnitClass(unit)) or false
	self.reaction = UnitReaction(unit, "player") or false

	self.smartColors = mod:unitColor(self.tapDenied, self.isPlayer, self.reaction, self.status)
end

--==============================================
-- THREAT
--==============================================
local function update_threat(self, event, unit)
	if(not unit or not self.unit == unit) then return false end
	
	if (event == "NAME_PLATE_UNIT_REMOVED") then return false end
	if (event == "OnShow") then return false end
	if (event == "OnUpdate") then return false end

	-- store these values for reuse
	unit_information(self, unit)

	local healthbar = self.Health
	local cur, max = UnitHealth(unit), UnitHealthMax(unit)
	healthbar:SetMinMaxValues(0, max)
	healthbar:SetValue(cur)

	if (self.tapDenied) then
		healthbar:SetStatusBarColor(unpack(self.smartColors))
	elseif (((cur / max) * 100) <= config.executerange) then
		healthbar:SetStatusBarColor(unpack(config.executecolor))
	elseif (config.specialunits[UnitName(unit)]) then
		healthbar:SetStatusBarColor(unpack(config.specialcolor))
	else
		healthbar:SetStatusBarColor(unpack(self.smartColors))
	end

	return true
end

--==============================================
-- Primary callback
--==============================================
local function nameplate_callback(self, event, unit)
	if (not self) then return end
	nameplates[self] = self

	-- store these values for reuse
	unit_information(self, unit)

	-- select correct target
	find_target(self, event, unit)

	--==========================================
	-- Style by unit type
	--==========================================
	if (UnitCanAttack("player", unit)) then
		mod:enemy_style(self, event, unit)
		mod:update_quest_marker(self, event, unit)
	elseif (UnitIsUnit(unit, "player")) then
		mod:personal_style(self, event, unit)
	elseif (self.isPlayer) then
		mod:friendly_style(self, event, unit)
	else
		mod:npc_style(self, event, unit)
	end
end

--==============================================
-- Nameplate first time creation
--==============================================
local function nameplate_create(self, unit)
	nameplates[self] = self
	self:SetPoint("BOTTOMLEFT", 0, math.floor(config.targetingBottomPadding))
	self:SetPoint("BOTTOMRIGHT", 0, math.floor(config.targetingBottomPadding))
	self:SetPoint("TOPLEFT", 0, -math.floor(config.targetingTopPadding))
	self:SetPoint("TOPRIGHT", 0, -math.floor(config.targetingTopPadding))
	self:RegisterEvent("PLAYER_TARGET_CHANGED", find_target, true)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", mod.config_callback, true)
	self:RegisterEvent("PLAYER_LOGIN", mod.config_callback, true)
	self:RegisterEvent("VARIABLES_LOADED", mod.config_callback, true)

	--==========================================
	-- HEALTHBAR
	--==========================================
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(bdUI.media.smooth)
	self.Health:SetAllPoints(self)
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.frequentUpdates = true
	bdUI:create_shadow(self.Health, 10)
	self.Health._shadow:SetBackdropColor(unpack(config.glowcolor))
	self.Health._shadow:SetBackdropBorderColor(unpack(config.glowcolor))

	--==========================================
	-- QUEST ICON
	--==========================================
	-- self.QuestIcon = self:CreateTexture("nil", "OVERLAY")
	-- self.QuestIcon:SetPoint("LEFT", self, "RIGHT", 10, 0)
	-- self.QuestIcon:SetSize(20, 20)
	-- self.QuestIcon:SetTexture(237608)
	-- self.QuestIcon:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
	-- self.QuestIcon:SetVertexColor(1, 1, 0)

	--==========================================
	-- DAMAGE ABSORBS
	--==========================================
    local absorbBar = CreateFrame('StatusBar', nil, self.Health)
    absorbBar:SetAllPoints()
	absorbBar:SetStatusBarTexture(bdUI.media.flat)
	absorbBar:SetStatusBarColor(.1, .1, .2, .6)
	absorbBar:Hide()
	local overAbsorbBar = CreateFrame('StatusBar', nil, self.Health)
    overAbsorbBar:SetAllPoints()
	overAbsorbBar:SetStatusBarTexture(bdUI.media.flat)
	overAbsorbBar:SetStatusBarColor(.1, .1, .2, .6)
	overAbsorbBar:Hide()

	-- Register and callback
    self.HealthPrediction = {
        absorbBar = absorbBar,
		overAbsorb = overAbsorbBar,

        maxOverflow = 1,
    }

	function self.HealthPrediction:PostUpdate(unit, myIncomingHeal, otherIncomingHeal, absorb, healAbsorb, hasOverAbsorb, hasOverHealAbsorb)
		if (not self.__owner:IsElementEnabled("HealthPrediction")) then return end
		
		local absorb = UnitGetTotalAbsorbs(unit) or 0
		local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)

		local overA = 0
		local overH = 0

		-- 2nd dmg absorb shield
		if (absorb > maxHealth) then
			overA = absorb - maxHealth
			self.overAbsorb:Show()
		else
			self.overAbsorb:Hide()
		end
		
		self.overAbsorb:SetMinMaxValues(0, UnitHealthMax(unit))
		self.overAbsorb:SetValue(overA)

		self.absorbBar:SetValue(absorb)
	end

	--==========================================
	-- THREAT
	--==========================================
	self.Health.Override = update_threat

	--==========================================
	-- UNIT NAME
	--==========================================
	self.Name = self:CreateFontString(nil, "OVERLAY", "BDN_FONT")
	self.Name:SetPoint("BOTTOM", self, "TOP", 0, 6)	
	self:Tag(self.Name, '[name]')

	--==========================================
	-- UNIT HEALTH
	--==========================================
	self.Curhp = self.Health:CreateFontString(nil, "OVERLAY", "BDN_FONT_SMALL")
	self.Curhp:SetJustifyH("RIGHT")
	self.Curhp:SetAlpha(0.8)
	self.Curhp:SetPoint("RIGHT", self.Health, "RIGHT", -4, 0)

	oUF.Tags.Events["bdncurhp"] = "UNIT_HEALTH UNIT_MAXHEALTH"
	oUF.Tags.Methods["bdncurhp"] = function(unit)
		if (config.hptext == "None") then return '' end
		local hp, hpMax = UnitHealth(unit), UnitHealthMax(unit)
		if (bdUI.mobhealth) then
			hp, hpMax, IsFound = bdUI.mobhealth:GetUnitHealth(unit)
		end
		local hpPercent = bdUI:round(hp / hpMax * 100,1)
		hp = bdUI:numberize(hp)
		
		if (config.hptext == "HP - %") then
			return table.concat({hp, hpPercent}, " - ")
		elseif (config.hptext == "HP") then
			return hp
		elseif (config.hptext == "%") then
			return hpPercent
		end
	end
	self:Tag(self.Curhp, '[bdncurhp]')

	--==========================================
	-- UNIT POWER
	--==========================================
	self.Curpower = self.Health:CreateFontString(nil, "OVERLAY", "BDN_FONT_SMALL")
	self.Curpower:SetJustifyH("LEFT")
	self.Curpower:SetAlpha(0.8)
	self.Curpower:SetPoint("LEFT", self.Health, "LEFT", 4, 0)
	local pp, ppMax, ppPercent
	oUF.Tags.Events['bdncurpower'] = 'UNIT_POWER_UPDATE'
	oUF.Tags.Methods['bdncurpower'] = function(unit)
		if (not config.showenergy) then return '' end
		pp, ppMax, ppPercent = UnitPower(unit), UnitPowerMax(unit), 0
		if (pp == 0 or ppMax == 0) then return '' end
		ppPercent = (pp / ppMax) * 100

		return floor(ppPercent);
	end
	self:Tag(self.Curpower, '[bdncurpower]')

	--==========================================
	-- RAID MARKER
	--==========================================
	self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY", nil, 7)
	self.RaidTargetIndicator:SetSize(config.raidmarkersize, config.raidmarkersize)

	--==========================================
	-- FIXATES / TARGETS
	--==========================================
	self.FixateAlert = self:CreateFontString(nil, "OVERLAY", "BDN_FONT_SMALL")
	self.FixateAlert:SetPoint("LEFT", self.Health, "RIGHT", 4, -1)
	self.FixateAlert:SetSize(self.Health:GetSize())
	function self.FixateAlert:PostUpdate(unit, target, isTargeting, isTargetingPlayer)
		self:Hide()

		if (not UnitExists(target)) then return end

		if (config.fixateMobs[UnitName(unit)]) then
			self:Show()
			self:SetText(UnitName(target))
		elseif (isTargeting) then
			if (config.fixatealert == "Always" or config.fixatealert == "All") then
				self:Show()
				self:SetText(UnitName(target))
			elseif (config.fixatealert == "Personal" and isTargetingPlayer) then
				self:Show()
				self:SetText(UnitName(target))
			end
		end
	end

	--==========================================
	-- AURAS
	--==========================================
	self.Auras = CreateFrame("Frame", nil, self)
	self.Auras:SetFrameLevel(0)
	self.Auras:ClearAllPoints()
	self.Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 24)
	self.Auras:SetSize(config.width, config.raidbefuffs)
	self.Auras:EnableMouse(false)
	self.Auras.size = config.raidbefuffs * config.scale
	self.Auras.initialAnchor  = "BOTTOMLEFT"
	self.Auras.showStealableBuffs = config.highlightPurge
	self.Auras.disableMouse = true
	self.Auras.spacing = 2
	self.Auras.num = 20
	self.Auras['growth-y'] = "UP"
	self.Auras['growth-x'] = "RIGHT"

	self.specialExpiration = 0
	self.enrageExpiration = 0
	
	self.Auras.CustomFilter = function(element, unit, button, name, texture, count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll, timeMod, effect1, effect2, effect3)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		local castByPlayer = caster and UnitIsUnit(caster, "player") or false

		return bdUI.filter_aura(name, castByPlayer, isBossDebuff, nameplateShowAll, false) or mod:auraFilter(name, castByPlayer, debuffType, isStealable, nameplateShowSelf, nameplateShowAll)
	end
	
	self.Auras.PostCreateIcon = function(self, button)
		bdUI:set_backdrop(button, true)

		local cdtext = button.cd:GetRegions()
		cdtext:SetFontObject("BDN_FONT_SMALL") 
		cdtext:SetJustifyH("CENTER")
		cdtext:ClearAllPoints()
		cdtext:SetAllPoints(button)
		
		button.count:SetFontObject("BDN_FONT_SMALL") 
		button.count:SetTextColor(1,.8,.3)
		button.count:SetJustifyH("RIGHT")
		button.count:ClearAllPoints()
		button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
		
		button.icon:SetTexCoord(0.08, 0.9, 0.20, 0.74)
		
		button.cd:SetReverse(true)
		button.cd:SetHideCountdownNumbers(false)
	end
	self.Auras.PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
		local name, _, _, debuffType, duration, expiration, caster, IsStealable, _, spellID = UnitAura(unit, index, button.filter)
		duration, expiration = bdUI:update_duration(button.cd, unit, spellID, caster, name, duration, expiration)

		button:SetHeight(config.raidbefuffs * 0.6 * config.scale)
		if (config.highlightPurge and isStealable) then -- purge alert
			button._border:SetVertexColor(unpack(config.purgeColor))
		elseif (config.highlightEnrage and debuffType == "") then -- enrage alert
			button._border:SetVertexColor(unpack(config.enrageColor))
		else -- neither
			button._border:SetVertexColor(unpack(bdUI.media.border))
		end
	end

	--==========================================
	-- CASTBARS
	--==========================================
	local border = bdUI:get_border(self)
	self.Castbar = CreateFrame("StatusBar", nil, self)
	self.Castbar:SetFrameLevel(3)
	self.Castbar:SetStatusBarTexture(bdUI.media.flat)
	self.Castbar:SetStatusBarColor(unpack(config.kickable))
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -border)
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -config.castbarheight)
	
	-- text
	self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY", "BDN_FONT_CASTBAR")
	self.Castbar.Text:SetJustifyH("LEFT")
	self.Castbar.Text:SetPoint("LEFT", self.Castbar, "LEFT", 10, 0)

	self.Castbar.AttributeText = self.Castbar:CreateFontString(nil, "OVERLAY", "BDN_FONT_CASTBAR")
	self.Castbar.AttributeText:SetJustifyH("RIGHT")
	self.Castbar.AttributeText:SetPoint("RIGHT", self.Castbar, "RIGHT", -10, 0)
	
	-- icon
	self.Castbar.Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	self.Castbar.Icon:SetDrawLayer('ARTWORK')
	self.Castbar.Icon:SetSize( config.height+config.castbarheight, config.height+config.castbarheight )
	self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -border, 0)
	
	-- icon bg
	self.Castbar.Icon.bg = self.Castbar:CreateTexture(nil, "BORDER")
	self.Castbar.Icon.bg:SetTexture(bdUI.media.flat)
	self.Castbar.Icon.bg:SetVertexColor(unpack(bdUI.media.border))
	self.Castbar.Icon.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -border, border)
	self.Castbar.Icon.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", border, -border)

	-- Combat log based extra information
	function self.Castbar:CastbarAttribute() 
		local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool = CombatLogGetCurrentEventInfo();

		if (event == 'SPELL_CAST_START') then
			if (self.unit ~= mod.guid_plates[sourceGUID]) then return end

			destName = mod.guid_plates[sourceGUID].."target"

			self.Castbar.AttributeText:SetText("")
			-- attribute who this cast is targeting
			if (UnitExists(destName) and config.showcasttarget) then
				self.Castbar.AttributeText:SetText(UnitName(destName))
				self.Castbar.AttributeText:SetTextColor(mod:autoUnitColor(destName))
			end
		elseif (event == "SPELL_INTERRUPT" and config.showcastinterrupt) then
			-- attribute who interrupted this cast
			if (UnitExists(sourceName)) then
				self.Castbar.AttributeText:SetText(UnitName(sourceName))
				self.Castbar.AttributeText:SetTextColor(mod:autoUnitColor(sourceName))
			end
		end
	end
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.Castbar.CastbarAttribute, true)

	-- interrupted delay
	self.Castbar.PostCastInterrupted = function(self, unit)
		self.holdTime = 0.7
		self:SetAlpha(0.7)
		self:SetStatusBarColor(unpack(bdUI.media.red))
	end

	-- Change color if cast is kickable or not
	self.Castbar.PostChannelStart = kickable_cast
	self.Castbar.PostCastNotInterruptible = kickable_cast
	self.Castbar.PostCastInterruptible = kickable_cast
	self.Castbar.PostCastStart = kickable_cast

	-- Pixel Perfect
	self:SetScript("OnSizeChanged", function(self, elapsed)
		bdUI:set_backdrop(self.Health, true)
		bdUI:set_backdrop(self.Castbar, true)
	end)
end


function mod:initialize()
	mod.config = mod:get_save()
	config = mod.config

	if (not config.enabled) then return end

	local forced = false
	hooksecurefunc(C_NamePlate, "SetNamePlateEnemySize", function()
		if (not forced) then
			forced = true
			mod:nameplate_size()
			forced = false
		end
	end)

	oUF:RegisterStyle("bdNameplates", nameplate_create)
	oUF:SetActiveStyle("bdNameplates")
	oUF:SpawnNamePlates("bdNameplates", nameplate_callback)
end