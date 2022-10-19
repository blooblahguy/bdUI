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
	mod.player = oUF:Spawn("player")
	mod.player:SetParent(mod.Resources)
	mod.player:SetAllPoints(mod.Resources)
	mod.player:SetAlpha(1)
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
	mod.player.Castbar:SetWidth(config.resources_width - config.castbar_height - bdUI.border)
	mod.Resources:SetSize(config.resources_width, 40)
	mod.player.CastbarHolder:SetSize(config.resources_width, config.castbar_height)
	mod.player.Power:SetSize(config.resources_width, config.power_height)
	if (config.power_tick == 0) then
		mod.player.Power.tick:Hide()
	else
		mod.player.Power.tick:Show()
		mod.player.Power.tick:SetSize(bdUI.border, config.power_height)
		mod.player.Power.tick:SetPoint("LEFT", mod.player.Power, mod.player.Power:GetWidth() * (config.power_tick / 100), 0)
	end

	mod.bars = {}
	
	-- mod.player.CastbarHolder:SetAlpha(1)
	-- mod.player.Castbar:SetAlpha(1)
	table.insert(mod.bars, mod.player.Power)
	table.insert(mod.bars, mod.swing_timer)
	table.insert(mod.bars, mod.player.CastbarHolder)

	-- position them in a stack
	bdUI:frame_group(mod.Resources, "downwards", unpack(mod.bars))--, mod.Resources.swing, mod.Resources.primary, mod.Resources.secondary)
end