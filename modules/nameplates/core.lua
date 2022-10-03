--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Nameplates")
local oUF = bdUI.oUF
local config
local nameplates = {}
local border
mod.elements = {}

local tanks = {}
local meTank = false

-- Fonts we use
mod.font = bdUI:get_font(14)
mod.font_friendly = bdUI:get_font(14)
mod.font_small = bdUI:get_font(14)
mod.font_castbar = bdUI:get_font(14)

--===============================================
-- Core functionality
-- place core functionality here
--===============================================
local forced = false
function mod:force_size()
	if (not forced) then
		forced = true
		mod:nameplate_size()
		forced = false
	end
end
function mod:nameplate_size()
	if (InCombatLockdown()) then return end

	C_NamePlate.SetNamePlateFriendlySize(config.width, 0.1)
	C_NamePlate.SetNamePlateEnemySize(config.width, (config.height + config.targetingTopPadding + config.targetingBottomPadding))
	C_NamePlate.SetNamePlateSelfSize(config.width, (config.height / 2 + config.targetingTopPadding + config.targetingBottomPadding))
	C_NamePlate.SetNamePlateFriendlyClickThrough(true)
	C_NamePlate.SetNamePlateSelfClickThrough(true)
end

local ooc = CreateFrame("frame", nil)
ooc:RegisterEvent("PLAYER_REGEN_ENABLED")
ooc:SetScript("OnEvent", mod.nameplate_size)

function bdUI:get_nameplate(unit)
	for k, self in pairs(nameplates) do
		if (UnitIsUnit(self.unit, unit)) then
			return self
		end
	end
end

function mod:show_class_resources(self)
	if (self.ClassicComboPointsHolder) then
		local show = false
		if (config.show_class_resources == "ALL") then
			show = true
		end
		if (config.show_class_resources == select(2, UnitClass("player"))) then
			show = true
		end

		if (show) then
			self.ClassicComboPointsHolder:Show()
		else
			self.ClassicComboPointsHolder:Hide()
		end
	end
end

local function store_tanks()
	-- store a list of the tanks in the group
	tanks = {}
	for i = 1, IsInRaid() and 25 or 5 do
		local unit = IsInRaid() and "raid"..i or "party"..i
		if (UnitExists(unit)) then
			if UnitGroupRolesAssigned(unit) == "TANK" or GetPartyAssignment("MAINTANK", unit) then
				tanks[select(1, UnitName(unit))] = true
			end
		end
	end

	-- don't include me in other tanks for comparison
	meTank = tanks[select(1, UnitName("player"))]
	tanks[select(1, UnitName("player"))] = nil
end
local role_collection = CreateFrame("frame", nil)
role_collection:RegisterEvent("PLAYER_ENTERING_WORLD")
role_collection:RegisterEvent("PLAYER_REGEN_ENABLED")
role_collection:RegisterEvent("PLAYER_REGEN_DISABLED")
role_collection:RegisterEvent("PLAYER_ROLES_ASSIGNED")
role_collection:RegisterEvent("GROUP_ROSTER_UPDATE")
role_collection:SetScript("OnEvent", store_tanks)

function mod:config_callback()
	mod.config = mod:get_save()
	config = mod.config
	if (not config.enabled) then return false end

	mod.cache = {}
	collectgarbage()

	-- store lowercase tables
	mod.lists = {}
	mod.lists.specialunits = bdUI:lowercase_table(config.specialunits)
	mod.lists.fixateMobs = bdUI:lowercase_table(config.fixateMobs)

	mod:show_class_resources(self)
	
	-- Update nameplate sizing
	mod:nameplate_size()

	-- Update from bdConfig
	for k, self in pairs(nameplates) do
		border = bdUI:get_border(self)

		-- health
		self.Health._shadow:SetColor(unpack(config.glowcolor))
		-- self.Health._shadow:SetBackdropBorderColor(unpack(config.glowcolor))

		-- castbar
		local cbi_size = (config.height+config.castbarheight) * config.castbariconscale
		self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", 2, 0)
		self.Castbar.Icon:SetSize( cbi_size, cbi_size )
		self.Castbar.Icon.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -border, border)
		self.Castbar.Icon.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", border, -border)

		self.Name:SetPoint("BOTTOM", self, "TOP", 0, config.hpoffset)
		self.Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 24+config.hpoffset)

		-- Disabled auras
		if (config.disableauras) then
			self.Auras:Hide()
		else
			self.Auras:Show()
		end
		self.Auras.size = config.raidbefuffs * config.scale

		self.RaidTargetIndicator:ClearAllPoints()
		if (config.markposition == "RIGHT") then
			self.RaidTargetIndicator:SetPoint('LEFT', self, "RIGHT", (config.raidmarkersize/2), 0)
		elseif (config.markposition == "LEFT") then
			self.RaidTargetIndicator:SetPoint('RIGHT', self, "LEFT", -config.raidmarkersize/2, 0)
		else
			self.RaidTargetIndicator:SetPoint('BOTTOM', self, "TOP", 0, config.raidmarkersize)
		end
	end

	local small = math.max(config.height * 0.6, config.height - 20)
	local castbar = math.max(config.castbarheight * 0.74, config.castbarheight - 20)

	mod.font = bdUI:get_font(config.enemynamesize)
	mod.font_small = bdUI:get_font(small)
	mod.font_castbar = bdUI:get_font(castbar)
	mod.font_friendly = bdUI:get_font(config.friendlynamesize)

	bdUI:SetCVar("nameplateShowAll", 1)
	bdUI:SetCVar("nameplateMotion", config.stacking == "Stacking" and 1 or 0)
	bdUI:SetCVar("nameplateMotionSpeed", config.stackingspeed)

	-- scale
	bdUI:SetCVar("nameplateGlobalScale", config.scale)
	bdUI:SetCVar("nameplateSelfScale", config.scale)
	bdUI:SetCVar("nameplateSelectedScale", config.selectedscale)
	bdUI:SetCVar("nameplateLargerScale", config.largerscale)
	bdUI:SetCVar("nameplateMinScale", 1)
	bdUI:SetCVar("nameplateMaxScale", 1)

	-- alpha
	bdUI:SetCVar("nameplateSelfAlpha", 1)
	bdUI:SetCVar("nameplateNotSelectedAlpha", config.unselectedalpha)
	bdUI:SetCVar("nameplateMinAlpha", config.unselectedalpha)
	bdUI:SetCVar("nameplateMaxAlpha", config.unselectedalpha)
	bdUI:SetCVar("nameplateOccludedAlphaMult", config.occludedalpha)

	-- misc
	bdUI:SetCVar("nameplateMaxDistance", config.nameplatedistance) -- for some reason there is a 6yd diff
	-- , ['nameplateShowDebuffsOnFriendly'] = 0
	-- , ['nameplateShowOnlyNames'] = config.friendlynamehack and 1 or 0 -- friendly names and no plates in raid
end

--==============================================
-- Target Visuals
--==============================================
local function find_target(self, event, unit)
	unit = unit or self.unit
	-- self:SetAlpha(self:GetParent():GetAlpha())

	-- global alpha/glow change on target
	if (UnitIsUnit(unit, "target")) then
		self.isTarget = true
		self:SetAlpha(1)
		if (not UnitIsUnit(unit, "player")) then
			self.Health._shadow:Show()
		end
	else
		self.isTarget = false
		-- print(self:GetParent():GetAlpha())
		-- self:SetAlpha(self:GetParent():GetAlpha())
		self.Health._shadow:Hide()
	end

	-- on target callback per specific nameplate
	if (self.OnTarget) then
		self.OnTarget(self, event, unit)
	end
end

--==============================================
-- Unit Information Variables
--==============================================
local function store_unit_information(self, unit)
	self.tapDenied = UnitIsTapDenied(unit) or false

	self.status = UnitThreatSituation("player", unit)
	if (self.status == nil) then
		self.inCombat = false
		self.status = false
	end
	self.inCombat = true
	self.isPlayer = UnitIsPlayer(unit) and select(2, UnitClass(unit)) or false
	self.reaction = UnitReaction(unit, "player") or false -- faction reaction

	-- I'm a tank
	-- self.meTank = tanks[select(1, UnitName("player"))]
	
	-- Tank has aggro
	self.themTank = false
	for player, v in pairs(tanks) do
		if (player and unit and UnitExists(player) and UnitExists(unit)) then
			local threat = UnitThreatSituation(player, unit)
			if (threat ~= nil and threat >= 2) then
				self.themTank = player
				break
			end
		end
	end

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
	store_unit_information(self, unit)

	local healthbar = self.Health
	local cur, max = UnitHealth(unit), UnitHealthMax(unit)
	healthbar:SetMinMaxValues(0, max)
	healthbar:SetValue(cur)

	if (self.tapDenied) then
		healthbar:SetStatusBarColor(unpack(self.smartColors))
	elseif (meTank and self.themTank) then
		healthbar:SetStatusBarColor(unpack(config.othertankcolor))
	elseif (((cur / max) * 100) <= config.executerange) then
		healthbar:SetStatusBarColor(unpack(config.executecolor))
	elseif (mod.lists.specialunits[UnitName(unit):lower()]) then
		healthbar:SetStatusBarColor(unpack(config.specialcolor))
	else
		healthbar:SetStatusBarColor(unpack(self.smartColors))
	end

	return true
end

local function get_unit_type(self, unit)
	if (UnitCanAttack("player", unit)) then
		return "enemy"
	elseif (UnitIsUnit(unit, "player")) then
		return "personal"
	elseif (self.isPlayer) then
		return "friendly"
	else
		return "npc"
	end
end

--==============================================
-- Primary callback
--==============================================
local function nameplate_callback(self, event, unit)
	if (not self) then return end
	nameplates[self] = self
	-- self.unit = unit

	-- store these values for reuse
	store_unit_information(self, unit)

	local frame = C_NamePlate.GetNamePlateForUnit(unit)
	if (frame and frame.UnitFrame and frame.UnitFrame.WidgetContainer) then
		frame.UnitFrame.WidgetContainer:SetParent(self)
		frame.UnitFrame.WidgetContainer:ClearAllPoints()
		frame.UnitFrame.WidgetContainer:SetPoint("TOP", self, "BOTTOM", 0, 0)
	end

	--==========================================
	-- Style by unit type
	--==========================================
	local unit_type = get_unit_type(self, unit)
	if (unit_type == "enemy") then
		mod.enemy_style(self, event, unit)
	elseif (unit_type == "personal") then
		mod.personal_style(self, event, unit)
	elseif (unit_type == "friendly") then
		mod.friendly_style(self, event, unit)
	elseif (unit_type == "npc") then
		mod.npc_style(self, event, unit)
	end

	-- select correct target
	find_target(self, event, unit)
	update_threat(self, event, unit)
end

--==============================================
-- Nameplate first time creation
--==============================================
local function nameplate_create(self, unit)
	border = bdUI:get_border(self)
	nameplates[self] = self
	
	self:SetPoint("BOTTOMLEFT", 0, math.floor(config.targetingBottomPadding))
	self:SetPoint("BOTTOMRIGHT", 0, math.floor(config.targetingBottomPadding))
	self:SetPoint("TOPLEFT", 0, -math.floor(config.targetingTopPadding))
	self:SetPoint("TOPRIGHT", 0, -math.floor(config.targetingTopPadding))
	self:RegisterEvent("PLAYER_TARGET_CHANGED", find_target, true)

	--==========================================
	-- HEALTHBAR
	--==========================================
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(bdUI.media.smooth)
	self.Health:SetAllPoints()
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.frequentUpdates = true
	bdUI:create_shadow(self.Health, 10)
	self.Health._shadow:SetColor(unpack(config.glowcolor))

	-- THREAT
	self.Health.UpdateColor = noop -- this is done by update_threat
	local total = 0
	self:HookScript("OnUpdate", function(self, elapsed)
		total = total + elapsed
		if (total < 0.1) then return end
		if (self.currentStyle ~= "enemy") then return end
		
		total = 0
		update_threat(self, "", self.unit)
	end)

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

	function self.HealthPrediction.PostUpdate(self, unit, myIncomingHeal, otherIncomingHeal, absorba, healAbsorb, hasOverAbsorb, hasOverHealAbsorb)
		-- if (not self.__owner:IsElementEnabled("HealthPrediction")) then return end
		
		local absorb = UnitGetTotalAbsorbs and UnitGetTotalAbsorbs(unit) or 0
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

	self.OverlayHolder = CreateFrame("frame", nil, self)
	self.OverlayHolder:SetFrameLevel(20)
	self.OverlayHolder:SetAllPoints()

	--==========================================
	-- UNIT NAME
	--==========================================
	self.Name = self.OverlayHolder:CreateFontString(nil, "OVERLAY")
	self.Name:SetFontObject(mod.font)
	self.Name:SetPoint("BOTTOM", self.OverlayHolder, "TOP", 0, config.hpoffset)	
	self:Tag(self.Name, '[name]')

	--==========================================
	-- QUEST ICON
	--==========================================
	self.QuestProgress = CreateFrame("Frame", "bdUF_QuestProgress", self.Health)
	self.QuestProgress:SetPoint("LEFT", self.Name, "RIGHT", 4, 0)
	self.QuestProgress:SetSize(20, 20)
	self.QuestProgress.PostUpdateIcon = function(self, texture, key)
		-- local border = bdUI:get_border(self.QuestProgress.icon) 
		self.Name:SetTextColor(1, 0, 0)
		if (not self.QuestProgress.icon.bg) then
			self.QuestProgress.icon.bg = self.QuestProgress:CreateTexture(nil, "BACKGROUND")
			self.QuestProgress.icon.bg:SetTexture(bdUI.media.flat)
			self.QuestProgress.icon.bg:SetVertexColor(unpack(bdUI.media.backdrop))
			self.QuestProgress.icon.bg:SetPoint("TOPLEFT", self.QuestProgress.icon, "TOPLEFT", -border, border)
			self.QuestProgress.icon.bg:SetPoint("BOTTOMRIGHT", self.QuestProgress.icon, "BOTTOMRIGHT", border, -border)
		end

		if (key == "item") then
			self.QuestProgress.icon.bg:Show()
		else
			self.QuestProgress.icon.bg:Hide()
		end
		-- self.Health.bg
	end
	self.QuestProgress.PostHide = function(texture, key)
		self.Name:SetTextColor(1, 1, 1)
		-- self.Health.bg
	end

	--==========================================
	-- UNIT HEALTH
	--==========================================
	self.Curhp = self.Health:CreateFontString(nil, "OVERLAY")
	self.Curhp:SetFontObject(mod.font_small)
	self.Curhp:SetJustifyH("RIGHT")
	self.Curhp:SetAlpha(0.8)
	self.Curhp:SetPoint("RIGHT", self.Health, "RIGHT", -4, 0)

	oUF.Tags.Events["bdncurhp"] = "UNIT_HEALTH UNIT_MAXHEALTH"
	oUF.Tags.Methods["bdncurhp"] = function(unit)
		if (config.hptext == "None") then return '' end
		local hp, hpMax = UnitHealth(unit), UnitHealthMax(unit)
		if (bdUI.mobhealth) then
			hp, hpMax, found = bdUI.mobhealth:GetUnitHealth(unit)
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
	self.Curpower = self.Health:CreateFontString(nil, "OVERLAY")
	self.Curpower:SetFontObject(mod.font_small)
	self.Curpower:SetJustifyH("LEFT")
	self.Curpower:SetAlpha(0.8)
	self.Curpower:SetPoint("LEFT", self.Health, "LEFT", 4, 0)
	local pp, ppMax, ppPercent
	oUF.Tags.Events['bdncurpower'] = 'UNIT_POWER_UPDATE'
	oUF.Tags.Methods['bdncurpower'] = function(unit)
		pp, ppMax, ppPercent = UnitPower(unit), UnitPowerMax(unit), 0
		if (pp == 0 or ppMax == 0) then return '' end
		ppPercent = (pp / ppMax) * 100

		return floor(ppPercent);
	end
	self:Tag(self.Curpower, '[bdncurpower]')

	--==========================================
	-- RAID MARKER
	--==========================================
	self.RaidTargetIndicator = self.OverlayHolder:CreateTexture(nil, "OVERLAY", nil, 7)
	self.RaidTargetIndicator:SetSize(config.raidmarkersize, config.raidmarkersize)
	if (config.markposition == "RIGHT") then
		self.RaidTargetIndicator:SetPoint('LEFT', self, "RIGHT", (config.raidmarkersize/2), 0)
	elseif (config.markposition == "LEFT") then
		self.RaidTargetIndicator:SetPoint('RIGHT', self, "LEFT", -config.raidmarkersize/2, 0)
	else
		self.RaidTargetIndicator:SetPoint('BOTTOM', self, "TOP", 0, config.raidmarkersize)
	end

	--==========================================
	-- FIXATES / TARGETS
	--==========================================
	self.FixateAlert = self:CreateFontString(nil, "OVERLAY")
	self.FixateAlert:SetFontObject(mod.font_small)
	self.FixateAlert:SetPoint("LEFT", self.Health, "RIGHT", 4, -1)
	self.FixateAlert:SetSize(self.Health:GetSize())
	function self.FixateAlert:PostUpdate(unit, target, isTargeting, isTargetingPlayer)
		self:Hide()

		if (not UnitExists(target)) then return end

		if (mod.lists.fixateMobs[UnitName(unit):lower()]) then
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
	self.Auras = CreateFrame("Frame", "bdNameplates_Auras", self)
	self.Auras:SetFrameLevel(0)
	self.Auras:ClearAllPoints()
	self.Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 24+config.hpoffset)
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
	
	self.Auras.CustomFilter = function(self, unit, button, name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
		isBossDebuff = isBossDebuff or false
		nameplateShowAll = nameplateShowAll or false
		nameplateShowPersonal = nameplateShowPersonal or false
		local castByMe = source and UnitIsUnit(source, "player") or false

		if (bdUI.is_blacklisted(self, name)) then
			return false
		end

		if (config.highlightPurge and (isStealable or debuffType == "Magic") and source and not UnitIsFriend("player", source) and self.currentStyle == "enemy" and UnitCanAttack("player", unit)) then
			-- print(source)
			return true
		end

		if (bdUI:filter_aura(name, spellID, castByMe, isBossDebuff, nameplateShowPersonal, nameplateShowAll)) then
			return true
		end
		if (bdUI:is_whitelist_nameplate(castByMe, nameplateShowPersonal, nameplateShowAll)) then
			return true
		end

		return mod:auraFilter(name, castByMe, debuffType, isStealable, nameplateShowPersonal, nameplateShowAll)
	end
	
	self.Auras.PostCreateIcon = function(self, button)
		bdUI:set_backdrop(button, true)

		local cdtext = button.cd:GetRegions()
		cdtext:SetFontObject(bdUI:get_font(config.debuff_timer_size)) 
		cdtext:SetJustifyH("CENTER")
		cdtext:ClearAllPoints()
		cdtext:SetAllPoints(button)
		self.last_timer_size = config.debuff_timer_size
		
		button.count:SetFontObject(bdUI:get_font(11)) 
		button.count:SetTextColor(1,.8,.3)
		button.count:SetJustifyH("RIGHT")
		button.count:ClearAllPoints()
		button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
		
		button.icon:SetTexCoord(0.08, 0.9, 0.20, 0.74)
		
		button.cd:SetReverse(true)
		button.cd:SetHideCountdownNumbers(false)
	end
	self.Auras.PostUpdateIcon = function(self, unit, button, index, position)
		local name, _, _, debuffType, duration, expiration, caster, IsStealable, _, spellID = UnitAura(unit, index, button.filter)
		bdUI:update_duration(button.cd, unit, spellID, caster, name, duration, expiration)

		if (self.last_timer_size ~= config.debuff_timer_size) then
			local cdtext = button.cd:GetRegions()
			cdtext:SetFontObject(bdUI:get_font(config.debuff_timer_size))
		end
		self.last_timer_size = config.debuff_timer_size

		button:SetHeight(config.raidbefuffs * 0.6 * config.scale)
		if (config.highlightPurge and (isStealable or debuffType == "Magic")) then -- purge alert
			button._border:SetVertexColor(unpack(config.purgeColor))
		elseif (config.highlightEnrage and debuffType == "") then -- enrage alert
			button._border:SetVertexColor(unpack(config.enrageColor))
		else -- neither
			button._border:SetVertexColor(unpack(bdUI.media.border))
		end
	end

	--==========================================
	-- Combo Points
	--==========================================
	local class = select(2, UnitClass("player"))
	if (mod.elements.combopoints) then
		if (class == "ROGUE" or class == "DRUID") then
			mod.elements.combopoints(self, unit)
		end
    end

	--==========================================
	-- CASTBARS
	--==========================================
	mod.elements.castbar(self, unit)

	--==========================================
	-- Pixel Perfect
	--==========================================
	self:HookScript("OnSizeChanged", function(self, elapsed)
		local border = bdUI:get_border(self)

		bdUI:set_backdrop(self.Health, true)

		-- castbars
		if (self.Castbar) then
			bdUI:set_backdrop(self.Castbar, true)

			self.Castbar.Icon.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -border, border)
			self.Castbar.Icon.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", border, -border)
			self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -border)
			self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -border, 0)
		end

		if (self.ClassicComboPointsHolder) then
			bdUI:set_backdrop(self.ClassicComboPointsHolder, true)
			local last
			local gap = border * 4
			local width = (config.width - (gap * 4)) / 5
			for index = 1, 5 do
				local bar = self.ClassicComboPoints[index]
				bdUI:set_backdrop(bar, true)
				bar:SetSize(width, border * 3)
				bar:ClearAllPoints()
				
				if (not last) then
					bar:SetPoint("BOTTOMLEFT", self.Health)
				else
					bar:SetPoint('LEFT', last, "RIGHT", gap, 0)
				end

				last = bar
			end
		end
	end)
end

local function disable_class_power()
	if (not ClassNameplateManaBarFrame) then return end
	-- ClassNameplateManaBarFrame:UnregisterEvent("UNIT_DISPLAYPOWER")
	-- ClassNameplateManaBarFrame:UnregisterEvent("UNIT_POWER_FREQUENT")
	-- ClassNameplateManaBarFrame:UnregisterEvent("UNIT_MAXPOWER")
	-- ClassNameplateManaBarFrame:UnregisterEvent("UNIT_SPELLCAST_START")
	-- ClassNameplateManaBarFrame:UnregisterEvent("UNIT_SPELLCAST_STOP")
	-- ClassNameplateManaBarFrame:UnregisterEvent("UNIT_SPELLCAST_FAILED")
	ClassNameplateManaBarFrame:Hide()
	hooksecurefunc(ClassNameplateManaBarFrame, "Show", function(self) self:Hide() end)
end

function mod:initialize()
	mod.config = mod:get_save()
	config = mod.config

	if (not config.enabled) then return end

	-- woopsie reset from before
	if (config.stackingspeed == 0) then
		config.stackingspeed = 0.25
	end

	bdUI.using_nameplates = true

	hooksecurefunc(C_NamePlate, "SetNamePlateEnemySize", mod.force_size)
	hooksecurefunc(C_NamePlate, "SetNamePlateSelfSize", mod.force_size)

	-- handle some blizzard things
	disable_class_power()

	oUF:RegisterStyle("bdNameplates", nameplate_create)
	oUF:SetActiveStyle("bdNameplates")
	oUF:SpawnNamePlates("bdNameplates", nameplate_callback)
	-- oUF:SpawnNamePlates("bdNameplates", function(frame, event, unit)
	-- 	local frame = C_NamePlate.GetNamePlateForUnit(unit)
	-- 	if (frame and frame.UnitFrame) then
	-- 		print(frame.UnitFrame)
	-- 		frame:SetParent(UIParent)
	-- 		frame:Show()
	-- 		frame.UnitFrame:Show()
	-- 		frame.UnitFrame.WidgetContainer:Show()
	-- 	end
	-- end)

	mod:config_callback()

	C_Timer.After(1, function()
		mod:config_callback()
	end)
end