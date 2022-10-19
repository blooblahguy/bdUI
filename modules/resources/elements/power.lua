local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Player Bars")
local config
local coclors 

local combat_checker = CreateFrame("frame")

-- local function update(self, event)
-- 	-- set values first
-- 	local cur, max = UnitPower("player"), UnitPowerMax("player")
-- 	self:SetMinMaxValues(0, max)
-- 	self:SetValue(cur)
-- 	self.text:SetText(bdUI:numberize(cur))

-- 	-- color the bar
-- 	local ptype, ptoken, altR, altG, altB = UnitPowerType("player")
-- 	local r, g, b = unpack(bdUI.oUF.colors.power[ptoken or ptype])
-- 	self:SetStatusBarColor(r * 0.8, g * 0.8, b * 0.8)
-- end

function mod:create_power(self)
	config = mod.config

	-- bar
	self.Power = CreateFrame("statusbar", "bdPowerResource", mod.Resources)
	self.Power:SetSize(config.resources_width, config.resources_power_height)
	self.Power:SetStatusBarTexture(bdUI.media.flat)
	self.Power:EnableMouse(false)
	self.Power.frequentUpdates = true
	self.Power.colorPower = true
	self.Power.Smooth = true
	bdUI:set_backdrop(self.Power)

	-- text
	self.Power.text = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.text:SetFontObject(bdUI:get_font(11))
	self.Power.text:SetJustifyV("MIDDLE")
	self.Power.text:SetPoint("CENTER", self.Power)

	-- tick
	self.Power.tick = self.Power:CreateTexture(nil, "OVERLAY")
	self.Power.tick:SetVertexColor(1, 1, 1, 0.7)
	self.Power.tick:SetTexture(bdUI.media.flat)
	self.Power.tick:SetSize(bdUI.border, config.power_height)
	self.Power.tick:SetPoint("LEFT", self.Power, self.Power:GetWidth() * (config.power_tick / 100), 0)

	self.Power.PostUpdate = function(power, unit, cur, min, max)
		power.text:SetText(cur)
	end
end

local function path() end

local function enable()
	if (not mod.config.power_enable) then return end

	mod.player:EnableElement("Power")
	combat_checker:RegisterEvent("PLAYER_REGEN_DISABLED")
	combat_checker:RegisterEvent("PLAYER_REGEN_ENABLED")
	combat_checker:SetScript("OnEvent", function(self, event)
		local config = mod:get_save()
		if (config.power_ooc_alpha == 0 and not UnitAffectingCombat("player")) then
			mod.player.Power:Hide()
		else
			mod.player.Power:Show()
		end
		if (UnitAffectingCombat("player")) then
			mod.player.Power:SetAlpha(config.power_ic_alpha)
		else
			mod.player.Power:SetAlpha(config.power_ooc_alpha)
		end
	end)
	
	return true
end
local function disable()
	mod.player:DisableElement("Power")
	combat_checker:UnregisterEvent("PLAYER_REGEN_DISABLED")
	combat_checker:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

mod:add_element('power', path, enable, disable)