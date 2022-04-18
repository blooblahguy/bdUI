local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Resources & Power")
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

function mod:create_power()
	config = mod.config

	-- bar
	power = CreateFrame("statusbar", "bdPowerResource", mod.Resources)
	power:SetSize(config.resources_width, config.resources_power_height)
	power:SetStatusBarTexture(bdUI.media.flat)
	power:EnableMouse(false)
	bdUI:set_backdrop(power)

	-- text
	power.text = power:CreateFontString(nil, "OVERLAY")
	power.text:SetFontObject(bdUI:get_font(11))
	power.text:SetJustifyV("MIDDLE")
	power.text:SetPoint("CENTER", power)

	-- events
	power:RegisterEvent('UNIT_POWER_FREQUENT')
	power:RegisterEvent('UNIT_DISPLAYPOWER')
	power:RegisterEvent('UNIT_MAXPOWER')
	power:RegisterEvent('PLAYER_ENTERING_WORLD')
	power:RegisterEvent('UNIT_FLAGS') -- For selection	
	if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) then 
		power:RegisterEvent('UNIT_POWER_POINT_CHARGE')
	end
	power:SetScript("OnEvent", update)

	return power
end