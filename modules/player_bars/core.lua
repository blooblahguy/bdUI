local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Player Bars")
local oUF = bdUI.oUF
local config = {}
mod.bars = {}

-- Primary Display
local function create_primary(self, unit)
	self:SetParent(mod.Resources)
	self:SetSize(mod.config.resources_width, mod.config.resources_primary_height)
	self:EnableMouse(false)
	self:Hide()
	bdUI:set_backdrop(self)

	if (class == "SHAMAN") then

	elseif (class == "DEATHKNIGHT") then

	elseif (class == "MONK") then

	else

	end
end

-- Secondary Display
local function create_secondary(self, unit)
	self:SetParent(mod.Resources)
	self:SetSize(mod.config.resources_width, mod.config.resources_secondary_height)
	self:EnableMouse(false)
	self:Hide()
	bdUI:set_backdrop(self)

	if (class == "DEATHKNIGHT") then

	elseif (class == "MONK") then

	end
end

-- use ouf built-ins
local function create_ouf_player_unit(self, unit)
	mod:create_castbar(self)
	mod:create_power(self)
	mod:create_runes(self)
	mod:create_class_power(self)
end

-- Start the addon
function mod:initialize()
	mod.config = mod:get_save()
	config = mod.config

	-- main holder frame
	mod.Resources = CreateFrame("frame", "bdResources", UIParent)
	mod.Resources:SetPoint("CENTER", bdParent, "CENTER", 0, -180)
	mod.Resources:EnableMouse(false)
	bdMove:set_moveable(mod.Resources, "Player Bars")

	-- initialize ouf backend
	oUF:RegisterStyle("bdPlayerBars", create_ouf_player_unit)
	oUF:SetActiveStyle("bdPlayerBars")
	mod.ouf = oUF:Spawn("player", "bdUI_playerbar")
	mod.ouf:EnableMouse(false)
	mod.ouf:SetParent(mod.Resources)
	mod.ouf:SetAllPoints(mod.Resources)
	mod.ouf:SetAlpha(1)

	bdUI:do_frame_fade()
end

-- on load AND on change
function mod:config_callback()
	mod.config = mod:get_save()
	config = mod.config

	if (mod.config.resources_enable) then
		mod.Resources:Show()
	else
		mod.Resources:Hide()
		return
	end

	-- callbacks
	mod.Resources:SetSize(config.resources_width, 40)
	-- castbar
	mod.ouf.Castbar:SetWidth(config.resources_width - config.castbar_height - bdUI.border)
	mod.ouf.CastbarHolder:SetSize(config.resources_width, config.castbar_height)
	-- power
	mod.ouf.Power:SetSize(config.resources_width, config.power_height)
	if (config.power_tick == 0) then
		mod.ouf.Power.tick:Hide()
	else
		mod.ouf.Power.tick:Show()
		mod.ouf.Power.tick:SetSize(bdUI.border, config.power_height)
		mod.ouf.Power.tick:SetPoint("LEFT", mod.ouf.Power, mod.ouf.Power:GetWidth() * (config.power_tick / 100), 0)
	end
	-- runes
	if (config.runes_height) then
		mod.ouf.RuneHolder:SetSize(config.resources_width, config.runes_height - bdUI.border * 2)
		local width = (config.resources_width - (bdUI.border * 5)) / 6
		for i, rune in pairs({ mod.ouf.RuneHolder:GetChildren() }) do
			rune:SetSize(width, config.runes_height)
		end
	end
	-- swing
	if (mod.swing_timer) then
		mod.swing_timer.mainhand:SetWidth(config.resources_width)
		mod.swing_timer.offhand:SetWidth(config.resources_width)
	end
	-- class power
	if (mod.ouf.ClassPowerHolder) then
		mod.ouf.ClassPowerHolder:SetSize(config.resources_width, config.power_height)
	end

	mod:position_bars()
	bdUI:do_frame_fade()
end

function mod:position_bars()
	if (InCombatLockdown()) then
		return
	end
	-- add things to the frame stack
	mod.bars = {}
	if (mod.ouf.RuneHolder) then
		table.insert(mod.bars, mod.ouf.RuneHolder)
	end
	table.insert(mod.bars, mod.ouf.Power)
	table.insert(mod.bars, mod.swing_timer)
	if (mod.ouf.ClassPowerHolder) then
		table.insert(mod.bars, mod.ouf.ClassPowerHolder)
	end
	table.insert(mod.bars, mod.ouf.CastbarHolder)

	-- position them in a stack
	bdUI:frame_group(mod.Resources, "downwards", unpack(mod.bars))
end
