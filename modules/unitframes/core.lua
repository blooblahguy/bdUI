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
mod.additional_elements = {}

--===============================================
-- Config callback
--===============================================
function mod:config_callback()
	config = mod:get_save()
	if (not config.enabled) then return false end

	for unit, self in pairs(mod.units) do
		local func = unit
		if (string.find(func, "boss")) then func = "boss" end
		if (string.find(func, "arena")) then func = "arena" end

		if (self.callback) then
			self.callback(self, unit, config)
		end
	end
end

--===============================================
-- Core functionality
-- place core functionality here
--===============================================

local function layout(self, unit)
	mod.units[unit] = self
	self:RegisterForClicks('AnyDown')
	self:SetScript('OnEnter', function(self)
		self.Health.highlight:Show()
		UnitFrame_OnEnter(self)
	end)
	self:SetScript('OnLeave', function(self)
		self.Health.highlight:Hide()
		UnitFrame_OnLeave(self)
	end)

	-- Health
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(bdUI.media.smooth)
	self.Health:SetAllPoints()
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

	-- Health highlight
	self.Health.highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Health.highlight:SetTexture(bdUI.media.flat)
	self.Health.highlight:SetAllPoints()
	self.Health.highlight:SetVertexColor(1,1,1,.05)
	self.Health.highlight:Hide()

	-- Range
	self.Range = {
		insideAlpha = config.inrangealpha,
		outsideAlpha = config.outofrangealpha,
	}

	-- Borders
	self.Border = CreateFrame("Frame", nil, self.Health)
	self.Border:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -bdUI.border, bdUI.border)
	self.Border:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", bdUI.border, -bdUI.border)

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
	self.TextHolder = CreateFrame('frame', nil, self.Health)
	self.TextHolder:SetAllPoints()

	self.Name = self.TextHolder:CreateFontString(nil, "OVERLAY")
	self.Name:SetFont(bdUI.media.font, 13, "OUTLINE")

	self.Status = self.TextHolder:CreateFontString(nil, "OVERLAY")
	self.Status:SetFont(bdUI.media.font, 10, "OUTLINE")
	self.Status:SetPoint("CENTER", self.TextHolder, "CENTER")
	
	self.Curhp = self.TextHolder:CreateFontString(nil, "OVERLAY")
	self.Curhp:SetFont(bdUI.media.font, 10, "OUTLINE")

	-- Raid Icon
	self.RaidTargetIndicator = self.Health:CreateTexture(nil, "OVERLAY", nil, 7)
	self.RaidTargetIndicator:SetSize(12, 12)
	self.RaidTargetIndicator:SetPoint('CENTER', self, 0, 0)

	

	-- Tags
	oUF.Tags.Events['name'] = 'UNIT_NAME_UPDATE'
	oUF.Tags.Methods["name"] = function(unit)
		local c = UnitClassification(u)
		-- print(c)
		if(c == 'rare') then
			c = 'R'
		elseif(c == 'rareelite') then
			c = 'R+'
		elseif(c == 'elite') then
			c = '+'
		elseif(c == 'worldboss') then
			c = 'B'
		elseif(c == 'minus' or c == 'trivial') then
			c = '-'
		else
			c = ""
		end

		c = c or ""
		unit = UnitName(unit) or ""
		local name = unit.." "..c

		if (IsActiveBattlefieldArena()) then
			for i = 1, 5 do
				if UnitIsUnit(unit, "arena"..i) then
					name = i
				end
			end
		end

		return unit.." "..c
	end


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

		if (perc == 0 or perc == "0") then
			return "0 / "..numberize(UnitHealthMax(unit))
		end

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

	if (config.enableplayertarget) then
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
	end
	
	-- focus
	if (config.enablefocus) then
		local focus = oUF:Spawn("focus")
		focus:SetPoint("TOP", bdParent, "TOP", 0, -120)
		bdMove:set_moveable(focus, "Focus")
	end
	
	if (config.bossenable) then
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
			arena:SetAttribute('oUF-enableArenaPrep', 1)
			lastarena = arena
		end
	end

	-- mod:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	-- mod:RegisterEvent("PLAYER_TARGET_CHANGED")
	-- mod:SetScript("OnEvent", update_borders_pre)
end