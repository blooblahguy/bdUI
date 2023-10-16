--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")
local oUF = bdUI.oUF
local config
mod.padding = bdUI.border
mod.units = {}
mod.custom_layout = {}
mod.additional_elements = {}
mod.tags = {}

local UFParent = CreateFrame('Frame', 'bdUI_UFParent', UIParent, 'SecureHandlerStateTemplate')
UFParent:SetFrameStrata('LOW')
RegisterStateDriver(UFParent, 'visibility', '[petbattle] hide; show')

local uf_holder = CreateFrame('Frame', nil, UFParent)
uf_holder:SetFrameStrata('LOW')

function mod:disable_castbars()
	if (CastingBarFrame_SetUnit) then
		CastingBarFrame_SetUnit(_G.CastingBarFrame)
		CastingBarFrame_SetUnit(_G.PetCastingBarFrame)
	else
		bdUI:HideFrame(_G.CastingBarFrame)
		bdUI:HideFrame(_G.PlayerCastingBarFrame)
		bdUI:HideFrame(_G.PetCastingBarFrame)		
	end
end

function mod:enable_castbars()
	if (CastingBarFrame_SetUnit) then
		CastingBarFrame_OnLoad(_G.CastingBarFrame, 'player', true, false)
		PetCastingBarFrame_OnLoad(_G.PetCastingBarFrame)
	else
		bdUI:UnHideFrame(_G.CastingBarFrame)
		bdUI:UnHideFrame(_G.PlayerCastingBarFrame)
		bdUI:UnHideFrame(_G.PetCastingBarFrame)
	end
end

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

		if (config.enablecastbars) then
			mod:disable_castbars()
		else
			mod:enable_castbars()
		end

		-- tags
		mod:update_tags(self, unit)
	end
	
	bdUI:set_frame_fade(uf_holder, config.unitframe_ic_alpha, config.unitframe_resting_alpha)
	bdUI:do_frame_fade()
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
		-- if (UnitIsPlayer(unit) or (UnitPlayerControlled(unit) and not UnitIsPlayer(unit))) then
		if (UnitIsPlayer(unit)) then
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

	-- holds tracking resources
	self.ResourceHolder = CreateFrame("frame", nil, self)
	self.ResourceHolder:SetHeight(bdUI.border * 3)
	self.ResourceHolder:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, bdUI.border)
	self.ResourceHolder:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, bdUI.border)
	bdUI:set_backdrop(self.ResourceHolder)
	self.ResourceHolder:Hide()

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

	-- Raid Icon
	self.RaidTargetIndicator = self.Health:CreateTexture(nil, "OVERLAY", nil, 7)
	self.RaidTargetIndicator:SetSize(13, 13)
	self.RaidTargetIndicator:SetPoint('CENTER', self.Health, 0, 0)

	-- frame specific layouts
	local func = unit
	if (string.find(func, "boss")) then func = "boss" end
	if (string.find(func, "arena")) then func = "arena" end
	mod.custom_layout[func](self, unit)

	-- configurable text layouts
	mod.create_all_tags(self)
	mod:create_location_tags(self, func)
end

function mod:create_unitframes()
	config = mod:get_save()
	oUF:RegisterStyle("bdUnitFrames", layout)
	oUF:SetActiveStyle("bdUnitFrames")

	local xoff = 180
	local yoff = 178

	if (config.enableplayertarget) then
		-- player
		local player = oUF:Spawn("player")
		player:SetPoint("RIGHT", bdParent, "CENTER", -xoff, -yoff)
		player:SetParent(uf_holder)
		bdMove:set_moveable(player, "Player")
	
		-- target
		local target = oUF:Spawn("target")
		target:SetPoint("LEFT", bdParent, "CENTER", xoff, -yoff)
		target:SetParent(uf_holder)
		bdMove:set_moveable(target, "Target")

		-- targetoftarget
		local targettarget = oUF:Spawn("targettarget")
		targettarget:SetPoint("TOPRIGHT", target, "BOTTOMRIGHT", 0, -config.castbarheight-20)
		targettarget:SetParent(uf_holder)
		bdMove:set_moveable(targettarget, "Target of Target")
	
		-- pet
		local pet = oUF:Spawn("pet")
		pet:SetPoint("TOPLEFT", player, "BOTTOMLEFT", 0, -config.castbarheight-20)
		pet:SetParent(uf_holder)
		bdMove:set_moveable(pet, "Pet")
	end
	
	-- focus
	if (config.enablefocus) then
		local focus = oUF:Spawn("focus")
		focus:SetPoint("LEFT", bdParent, "CENTER", xoff, 100)
		focus:SetParent(uf_holder)
		bdMove:set_moveable(focus, "Focus")
	end
	
	if (config.bossenable and Boss1TargetFrame) then
		local arena_boss = CreateFrame("frame", "bdArenaBoss", uf_holder)
		arena_boss:SetPoint("RIGHT", UIParent, -400, 30)
		arena_boss:SetSize(config.bosswidth, (config.bossheight + 30) * 5)
		bdMove:set_moveable(arena_boss, "Boss Frames")
		
		-- boss
		local lastboss = nil
		for i = 1, 5 do
			local boss = oUF:Spawn("boss"..i, nil)
			if (not lastboss) then
				boss:SetPoint("TOP", arena_boss, "TOP", 0, 0)
			else
				boss:SetPoint("TOP", lastboss, "BOTTOM", -2, -50)
			end
			boss:SetSize(config.bosswidth, config.bossheight)
			lastboss = boss
		end
		
		-- -- arena
		-- local lastarena = nil
		-- for i = 1, 5 do
		-- 	local arena = oUF:Spawn("arena"..i, nil)
		-- 	if (not lastarena) then
		-- 		arena:SetPoint("TOP", arena_boss, "TOP", 0, 0)
		-- 	else
		-- 		arena:SetPoint("TOP", lastarena, "BOTTOM", -2, -30)
		-- 	end
		-- 	arena:SetSize(config.bosswidth, config.bossheight)
		-- 	arena:SetAttribute('oUF-enableArenaPrep', 1)
		-- 	lastarena = arena
		-- end
	end

	-- mod:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	-- mod:RegisterEvent("PLAYER_TARGET_CHANGED")
	-- mod:SetScript("OnEvent", update_borders_pre)
end