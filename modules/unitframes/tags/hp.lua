local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")
local oUF = bdUI.oUF

local function numberize(n)
	if (n >= 10^6) then -- > 1,000,000
		return string.format("%.fm", n / 10^6)
	elseif (n >= 10^4) then -- > 10,000
		return string.format("%.fk", n / 10^3)
	elseif (n >= 10^3) then -- > 10,000
		return string.format("%.1fk", n / 10^3)
	else
		return tostring(n)
	end
end

mod.tags.hp = function(self, unit)
	if (self.Curhp) then return end

	self.Curhp = self.TextHolder:CreateFontString(nil, "OVERLAY")
	self.Curhp:SetFontObject(bdUI:get_font(10, "THINOUTLINE"))

	oUF.Tags.Events['bdUI:curhp'] = 'UNIT_HEALTH UNIT_MAXHEALTH'
	oUF.Tags.Methods['bdUI:curhp'] = function(unit)
		local hp, hpMax = UnitHealth(unit), UnitHealthMax(unit)

		if (bdUI.mobhealth) then -- for classic
			hp, hpMax = bdUI.mobhealth:GetUnitHealth(unit)
		end

		if hpMax == 0 then return "0" end

		local hpPercent = bdUI:round(hp / hpMax * 100)
		if (UnitIsDead(unit) or UnitIsGhost(unit)) then
			return string.format("|cffFF00000 / %s|r", numberize(hpMax))
		end

		local r, g, b = bdUI:ColorGradient(hpPercent / 100, 1,0,0, 1,.5,0, 1,1,1)
		local hex = RGBPercToHex(r, g, b)

		return string.format("|cff%s%s|r | |cff%s%s%s|r", hex, numberize(hp), hex, hpPercent, "%")
	end

	self:Tag(self.Curhp, '[bdUI:curhp]')

	-- return self.Curhp
end