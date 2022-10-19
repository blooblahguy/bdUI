local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Player Bars")
local config
local coclors 

local function update(self, event)
	-- set values first
	local cur, max = UnitPower("player"), UnitPowerMax("player")
	self:SetMinMaxValues(0, max)
	self:SetValue(cur)
	self.text:SetText(bdUI:numberize(cur))

	-- color the bar
	local ptype, ptoken, altR, altG, altB = UnitPowerType("player")
	local r, g, b = unpack(bdUI.oUF.colors.power[ptoken or ptype])
	self:SetStatusBarColor(r * 0.8, g * 0.8, b * 0.8)
end

function mod:create_power(self)
	local config = mod.config

	-- bar
	self.Power = CreateFrame("statusbar", "bdPowerResource", mod.Resources)
	self.Power:SetSize(config.resources_width, config.resources_power_height)
	self.Power:SetStatusBarTexture(bdUI.media.flat)
	self.Power:EnableMouse(false)
	self.Power.frequentUpdates = true
	self.Power.colorPower = true
	bdUI:set_backdrop(self.Power)

	-- text
	self.Power.text = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.text:SetFontObject(bdUI:get_font(11))
	self.Power.text:SetJustifyV("MIDDLE")
	self.Power.text:SetPoint("CENTER", self.Power)

	self.Power.PostUpdate = function(power, unit, cur, min, max)
		power.text:SetText(cur)
	end
end

local function path() end

local function enable()
	if (not mod.config.power_enable) then return end
	print("power made")
	self:EnableElement("Castbar")
end
local function disable()
	self:DisableElement("Castbar")
end

mod:add_element('filters', path, enable, disable)