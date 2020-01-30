--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")
local oUF = bdUI.oUF
local config
mod.padding = 2
mod.units = {}
mod.custom_layout = {}

--===============================================
-- Config callback
--===============================================
function mod:config_callback()
	config = mod:get_save()

	for unit, self in pairs(mod.units) do
		local func = unit
		if (string.find(func, "boss")) then func = "boss" end
		if (string.find(func, "arena")) then func = "arena" end
		mod.custom_layout[func](self, unit)
	end
end

--===============================================
-- Core functionality
-- place core functionality here
--===============================================
local function castbar_kickable(self)
	if (self.notInterruptible) then
		if (self.Icon) then
			self.Icon:SetDesaturated(1)
		end
		self:SetStatusBarColor(0.7, 0.7, 0.7, 1)
	else
		if (self.Icon) then
			self.Icon:SetDesaturated(false)
		end
		self:SetStatusBarColor(.1, .4, .7, 1)
	end
end

local function update_borders(self)
	if (UnitIsUnit(self.unit, "target")) then
		self.Border._shadow:Show()
		self.Border._shadow:SetAlpha(1)
		self.Border._shadow:SetBackdropColor(self.Health:GetStatusBarColor())
		self.Border._shadow:SetBackdropBorderColor(self.Health:GetStatusBarColor())
	elseif (UnitIsUnit(self.unit, "mouseover") or MouseIsOver(self)) then
		self.Border._shadow:Show()
		self.Border._shadow:SetAlpha(0.6)
		self.Border._shadow:SetBackdropColor(1, 1, 1, 1)
		self.Border._shadow:SetBackdropBorderColor(1, 1, 1, 1)
	else
		self.Border._shadow:Hide()
	end
end

local function update_borders_pre(self, event)
	if (self.unit) then -- unit event
		update_borders(self)
	else -- unitless event
		for unit, self in pairs(mod.units) do
			update_borders(self)
		end
	end
end

mod.additional_elements = {
	castbar = function(self, unit, align, icon)
		if (self.Castbar) then return end

		local font_size = math.restrict(config.castbarheight * 0.8, 8, 14)

		self.Castbar = CreateFrame("StatusBar", nil, self)
		self.Castbar:SetFrameLevel(3)
		self.Castbar:SetStatusBarTexture(bdUI.media.flat)
		self.Castbar:SetStatusBarColor(.1, .4, .7, 1)
		self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -bdUI.border)
		self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -(4 + config.castbarheight))
		if (self.Power) then
			self.Castbar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -bdUI.border)
			self.Castbar:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT", 0, -(4 + config.castbarheight))
		end
		
		self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
		self.Castbar.Text:SetFont(bdUI.media.font, font_size, "THINOUTLINE")
		self.Castbar.Text:SetJustifyV("MIDDLE")

		if (icon) then
			self.Castbar.Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
			self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			self.Castbar.Icon:SetDrawLayer('ARTWORK')
			self.Castbar.Icon.bg = self.Castbar:CreateTexture(nil, "BORDER")
			self.Castbar.Icon.bg:SetTexture(bdUI.media.flat)
			self.Castbar.Icon.bg:SetVertexColor(unpack(bdUI.media.border))
			self.Castbar.Icon.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -bdUI.border, bdUI.border)
			self.Castbar.Icon.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", bdUI.border, -bdUI.border)
		end

		self.Castbar.SafeZone = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.SafeZone:SetVertexColor(0.85, 0.10, 0.10, 0.20)
		self.Castbar.SafeZone:SetTexture(bdUI.media.flat)

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY")
		self.Castbar.Time:SetFont(bdUI.media.font, font_size, "THINOUTLINE")

		-- Positioning
		if (align == "right") then
			self.Castbar.Time:SetPoint("RIGHT", self.Castbar, "RIGHT", -mod.padding, 0)
			self.Castbar.Time:SetJustifyH("RIGHT")
			self.Castbar.Text:SetPoint("LEFT", self.Castbar, "LEFT", mod.padding, 0)
			if (icon) then
				self.Castbar.Icon:SetPoint("TOPLEFT", self.Castbar,"TOPRIGHT", mod.padding*2, 0)
				self.Castbar.Icon:SetSize(config.castbarheight * 1.5, config.castbarheight * 1.5)
			end
		else
			self.Castbar.Time:SetPoint("LEFT", self.Castbar, "LEFT", mod.padding, 0)
			self.Castbar.Time:SetJustifyH("LEFT")
			self.Castbar.Text:SetPoint("RIGHT", self.Castbar, "RIGHT", -mod.padding, 0)
			if (icon) then
				self.Castbar.Icon:SetPoint("TOPRIGHT", self.Castbar,"TOPLEFT", -mod.padding*2, 0)
				self.Castbar.Icon:SetSize(config.castbarheight * 1.5, config.castbarheight * 1.5)
			end			
		end

		self.Castbar.PostChannelStart = castbar_kickable
		self.Castbar.PostChannelUpdate = castbar_kickable
		self.Castbar.PostCastStart = castbar_kickable
		self.Castbar.PostCastDelayed = castbar_kickable
		self.Castbar.PostCastNotInterruptible = castbar_kickable
		self.Castbar.PostCastInterruptible = castbar_kickable

		-- bdMove:set_moveable(self.Castbar, unit.." Castbar")
		bdUI:set_backdrop(self.Castbar)
	end,

	perhppp = function(self, unit)
		if (self.Perhp) then return end

		self.Perhp = self.Health:CreateFontString(nil, "OVERLAY")
		self.Perhp:SetFont(bdUI.media.font, 12, "OUTLINE")
		self.Perhp:SetPoint("LEFT", self.Health, "LEFT", 4, 0)

		self.Perpp = self.Health:CreateFontString(nil, "OVERLAY")
		self.Perpp:SetFont(bdUI.media.font, 12, "OUTLINE")
		self.Perpp:SetPoint("RIGHT", self.Health, "RIGHT", -4, 0)
		self.Perpp:SetTextColor(self.Power:GetStatusBarColor())

		self:RegisterEvent("UNIT_POWER_UPDATE", function(self)
			self.Perpp:SetTextColor(self.Power:GetStatusBarColor())
		end, true)

		self:Tag(self.Perhp, '[perhp]')
		self:Tag(self.Perpp, '[perpp]')
	end,

	resting = function(self, unit)
		if (self.RestingIndicator) then return end

		local size = math.restrict(self:GetHeight() * 0.75, 8, self:GetHeight())

		-- Resting indicator
		self.RestingIndicator = self.Health:CreateTexture(nil, "OVERLAY")
		self.RestingIndicator:SetSize(size, size)
		self.RestingIndicator:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
		self.RestingIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

		if (config.textlocation == "Outside") then
			self.RestingIndicator:SetPoint("LEFT", self.Health, mod.padding, 1)
		elseif (config.textlocation == "Inside") then
			self.RestingIndicator:SetPoint("LEFT", self.Health, "CENTER", mod.padding, 1)
		end
	end,

	combat = function(self, unit)
		if (self.CombatIndicator) then return end

		local size = math.restrict(self:GetHeight() * 0.75, 8, self:GetHeight())

		-- Resting indicator
		self.CombatIndicator = self.Health:CreateTexture(nil, "OVERLAY")
		self.CombatIndicator:SetSize(size, size)
		self.CombatIndicator:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
		self.CombatIndicator:SetTexCoord(.5, 1, 0, .49)

		if (config.textlocation == "Outside") then
			self.CombatIndicator:SetPoint("RIGHT", self.Health, -mod.padding, 1)
		elseif (config.textlocation == "Inside") then
			self.CombatIndicator:SetPoint("RIGHT", self.Health, "CENTER", -mod.padding, 1)
		end
	end,

	power = function(self, unit)
		if (self.Power) then return end

		-- Power
		self.Power = CreateFrame("StatusBar", nil, self)
		self.Power:SetStatusBarTexture(bdUI.media.flat)
		self.Power:ClearAllPoints()
		self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -bdUI.border)
		self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -bdUI.border)
		self.Power:SetHeight(config.playertargetpowerheight)
		self.Power.frequentUpdates = true
		self.Power.colorPower = true
		self.Power.Smooth = true
		bdUI:set_backdrop(self.Power)
		
		self.Border:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT", bdUI.border, -bdUI.border)
	end,

	buffs = function(self, unit)
		if (self.Buffs) then return end

		-- Auras
		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
		self.Buffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
		self.Buffs:SetSize(config.playertargetwidth, 60)
		self.Buffs.size = 18
		self.Buffs.initialAnchor  = "BOTTOMLEFT"
		self.Buffs.spacing = bdUI.border
		self.Buffs.num = 20
		self.Buffs['growth-y'] = "UP"
		self.Buffs['growth-x'] = "RIGHT"
		self.Buffs.PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
			local name, _, _, debuffType, duration, expiration, caster, IsStealable, _, spellID = UnitAura(unit, index, button.filter)
			duration, expiration = bdUI:update_duration(button.cd, unit, spellID, caster, name, duration, expiration)
		end
		self.Buffs.PostCreateIcon = function(buffs, button)
			bdUI:set_backdrop_basic(button)
			button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			button.cd:GetRegions():SetAlpha(0)
			button:SetAlpha(0.8)
		end
	end,

	debuffs = function(self, unit)
		if (self.Debuffs) then return end

		-- Auras
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
		self.Debuffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
		self.Debuffs:SetSize(config.playertargetwidth, 60)
		self.Debuffs.size = 18
		self.Debuffs.initialAnchor  = "BOTTOMRIGHT"
		self.Debuffs.spacing = bdUI.border
		self.Debuffs.num = 20
		self.Debuffs['growth-y'] = "UP"
		self.Debuffs['growth-x'] = "LEFT"
		self.Debuffs.PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
			local name, _, _, debuffType, duration, expiration, caster, IsStealable, _, spellID = UnitAura(unit, index, button.filter)
			duration, expiration = bdUI:update_duration(button.cd, unit, spellID, caster, name, duration, expiration)
		end
		self.Debuffs.PostCreateIcon = function(Debuffs, button)
			bdUI:set_backdrop_basic(button)
			button.cd:GetRegions():SetAlpha(0)
			button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		end
	end,

	auras = function(self, unit)
		if (self.Auras) then return end

		-- Auras
		self.Auras = CreateFrame("Frame", nil, self)
		self.Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 4)
		self.Auras:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 4)
		self.Auras:SetSize(config.playertargetwidth, 60)
		self.Auras.size = 18
		self.Auras.initialAnchor  = "BOTTOMLEFT"
		self.Auras.spacing = bdUI.border
		self.Auras.num = 20
		self.Auras['growth-y'] = "UP"
		self.Auras['growth-x'] = "RIGHT"
		self.Auras.PostUpdateIcon = function(self, unit, button, index, position, duration, expiration, debuffType, isStealable)
			local name, _, _, debuffType, duration, expiration, caster, IsStealable, _, spellID = UnitAura(unit, index, button.filter)
			duration, expiration = bdUI:update_duration(button.cd, unit, spellID, caster, name, duration, expiration)
		end
		self.Auras.PostCreateIcon = function(Debuffs, button)
			bdUI:set_backdrop_basic(button)
			button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			button.cd:GetRegions():SetAlpha(0)
			-- button:SetAlpha(0.8)
		end
	end
}

local function layout(self, unit)
	mod.units[unit] = self
	self:RegisterForClicks('AnyDown')
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	self.PostUpdate = update_borders_pre 

	-- Health
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(bdUI.media.smooth)
	self.Health:SetPoint("TOPLEFT", self)
	self.Health:SetPoint("BOTTOMRIGHT", self)
	self.Health.Smooth = true
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.PreUpdate = function(self, unit)
		self.colorSmooth = true
		if (UnitIsPlayer(unit) or (UnitPlayerControlled(unit) and not UnitIsPlayer(unit))) then
			self.colorReaction = false
			local _, class = UnitClass(unit)
			local cc = oUF.colors.class[class]
			local r, g, b = unpack(cc)
			self.smoothGradient = {
				.7, 0, 0,
				r, g, b,
				r, g, b,
			}
		elseif(UnitReaction(unit, 'player')) then
			self.colorReaction = true
			local _, class = UnitClass(unit)
			local cc = oUF.colors.reaction[UnitReaction(unit, 'player')]
			local r, g, b = unpack(cc)
			self.smoothGradient = {
				.7, 0, 0,
				r, g, b,
				r, g, b,
			}
		end
	end
	bdUI:set_backdrop(self.Health)

	-- Range
	self.Range = {
		insideAlpha = config.inrangealpha,
		outsideAlpha = config.outofrangealpha,
	}

	-- Borders
	self.Border = CreateFrame("Frame", nil, self.Health)
	self.Border:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -bdUI.border, bdUI.border)
	self.Border:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", bdUI.border, -bdUI.border)
	bdUI:create_shadow(self.Border, bdUI.border)
	self.Border._shadow:Hide()

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
	absorbBar:SetStatusBarColor(.1, .1, .2, .6)
	absorbBar:Hide()
	local overAbsorbBar = CreateFrame('StatusBar', nil, self.Health)
    overAbsorbBar:SetAllPoints()
	overAbsorbBar:SetStatusBarTexture(bdUI.media.flat)
	overAbsorbBar:SetStatusBarColor(.1, .1, .2, .6)
	overAbsorbBar:Hide()

	-- Healing Absorbs
    local healAbsorbBar = CreateFrame('StatusBar', nil, self.Health)
    healAbsorbBar:SetReverseFill(true)
	healAbsorbBar:SetStatusBarTexture(bdUI.media.flat)
	healAbsorbBar:SetStatusBarColor(.3, 0, 0,.5)
	healAbsorbBar:Hide()
	local overHealAbsorbBar = CreateFrame('StatusBar', nil, self.Health)
    overHealAbsorbBar:SetReverseFill(true)
	overHealAbsorbBar:SetStatusBarTexture(bdUI.media.flat)
	overHealAbsorbBar:SetStatusBarColor(.3, 0, 0,.5)
	overHealAbsorbBar:Hide()

	-- Register and callback
    self.bdHealthPrediction = {
        incomingHeals = incomingHeals,

        absorbBar = absorbBar,
		overAbsorb = overAbsorbBar,

        healAbsorbBar = healAbsorbBar,
        overHealAbsorb = overHealAbsorbBar,
    }

	-- Name & Text
	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
	self.Name:SetFont(bdUI.media.font, 13, "OUTLINE")

	self.Status = self.Health:CreateFontString(nil, "OVERLAY")
	self.Status:SetFont(bdUI.media.font, 10, "OUTLINE")
	self.Status:SetPoint("CENTER", self.Health, "CENTER")
	
	self.Curhp = self.Health:CreateFontString(nil, "OVERLAY")
	self.Curhp:SetFont(bdUI.media.font, 10, "OUTLINE")

	-- Raid Icon
	self.RaidTargetIndicator = self.Health:CreateTexture(nil, "OVERLAY", nil, 1)
	self.RaidTargetIndicator:SetSize(12, 12)
	self.RaidTargetIndicator:SetPoint('CENTER', self, 0, 0)

	-- Tags
	oUF.Tags.Events['curhp'] = 'UNIT_HEALTH UNIT_MAXHEALTH'
	oUF.Tags.Methods['curhp'] = function(unit)
		local hp, hpMax = UnitHealth(unit), UnitHealthMax(unit)
		if (bdUI.mobhealth) then
			hp, hpMax, IsFound = bdUI.mobhealth:GetUnitHealth(unit)
		end

		local hpPercent = hp / hpMax
		if hpMax == 0 then return end
		local r, g, b = bdUI:ColorGradient(hpPercent, 1,0,0, 1,1,0, 1,1,1)
		local hex = RGBPercToHex(r, g, b)
		local perc = table.concat({"|cFF", hex, bdUI:round(hpPercent * 100, 1), "|r"}, "")

		return table.concat({bdUI:numberize(hp), "-", perc}, " ")
	end

	oUF.Tags.Events["status"] = "UNIT_HEALTH  UNIT_CONNECTION  CHAT_MSG_SYSTEM"
	oUF.Tags.Methods["status"] = function(unit)
		if not UnitIsConnected(unit) then
			return "offline"		
		elseif UnitIsDead(unit) then
			return "dead"		
		elseif UnitIsGhost(unit) then
			return "ghost"
		end
	end

	self:Tag(self.Curhp, '[curhp]')
	self:Tag(self.Name, '[name]')
	self:Tag(self.Status, '[status]')

	-- frame specific layouts
	local func = unit
	if (string.find(func, "boss")) then func = "boss" end
	if (string.find(func, "arena")) then func = "arena" end
	mod.custom_layout[func](self, unit)
end

function mod:create_unitframes()
	config = mod:get_save()

	oUF:RegisterStyle("bdUnitFrames", layout)
	oUF:SetActiveStyle("bdUnitFrames")

	local xoff = 164
	local yoff = 178

	-- player
	local player = oUF:Spawn("player")
	player:SetPoint("RIGHT", bdParent, "CENTER", -xoff, -yoff)
	bdMove:set_moveable(player, "Player")

	-- target
	local target = oUF:Spawn("target")
	target:SetPoint("LEFT", bdParent, "CENTER", xoff, -yoff)
	bdMove:set_moveable(target, "Target")

	-- targetoftarget
	local targettarget = oUF:Spawn("targettarget")
	targettarget:SetPoint("TOPRIGHT", target, "BOTTOMRIGHT", 0, -config.castbarheight-20)
	bdMove:set_moveable(targettarget, "Target of Target")

	-- pet
	local pet = oUF:Spawn("pet")
	pet:SetPoint("TOPLEFT", player, "BOTTOMLEFT", 0, -config.castbarheight-20)
	bdMove:set_moveable(pet, "Pet")

	-- focus
	local focus = oUF:Spawn("focus")
	focus:SetPoint("TOP", bdParent, "TOP", 0, -120)
	bdMove:set_moveable(focus, "Focus")

	local arena_boss = CreateFrame("frame", "bdArenaBoss", bdParent)
	arena_boss:SetPoint("TOPRIGHT", Minimap, "BOTTOMLEFT", -10, -10)
	arena_boss:SetSize(config.bosswidth, (config.bossheight + 30) * 5)
	bdMove:set_moveable(arena_boss, "Boss & Arena Frames")

	-- boss
	local lastboss = nil
	for i = 1, 5 do
		local boss = oUF:Spawn("boss"..i, nil)
		if (not lastboss) then
			boss:SetPoint("TOP", arena_boss, "TOP", 0, 0)
		else
			boss:SetPoint("TOP", lastboss, "BOTTOM", -2, -30)
		end
		boss:SetSize(config.bosswidth, config.bossheight)
		lastboss = boss
	end

	-- arena
	local lastarena = nil
	for i = 1, 5 do
		local arena = oUF:Spawn("arena"..i, nil)
		if (not lastarena) then
			arena:SetPoint("TOP", arena_boss, "TOP", 0, 0)
		else
			arena:SetPoint("TOP", lastarena, "BOTTOM", -2, -30)
		end
		arena:SetSize(config.bosswidth, config.bossheight)
		lastarena = arena
	end

	mod:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	mod:RegisterEvent("PLAYER_TARGET_CHANGED")
	mod:SetScript("OnEvent", update_borders_pre)

end