local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")
local oUF = bdUI.oUF

mod.tags.hp = function(self, unit)
	if (self.Curhp) then return end

	self.Curhp = self.TextHolder:CreateFontString(nil, "OVERLAY")
	self.Curhp:SetFontObject(bdUI:get_font(10))

	oUF.Tags.Events['bdUI:curhp'] = 'UNIT_HEALTH UNIT_MAXHEALTH'
	oUF.Tags.Methods['bdUI:curhp'] = function(unit)
		local hp, hpMax = UnitHealth(unit), UnitHealthMax(unit)
		if (bdUI.mobhealth) then -- foir classic
			hp, hpMax = bdUI.mobhealth:GetUnitHealth(unit)
		end

		if hpMax == 0 then return end

		local hpPercent = hp / hpMax * 100
		local r, g, b = bdUI:ColorGradient(hpPercent, 1,0,0, 1,1,0, 1,1,1)
		local hex = RGBPercToHex(r, g, b)
		local perc = table.concat({"|cFF", hex, bdUI:round(hpPercent), "|r"}, "")

		if (perc == 0 or perc == "0") then
			return "0 / "..numberize(UnitHealthMax(unit))
		end

		hp = "|cFF"..hex..bdUI:numberize(hp).."|r"

		return table.concat({hp, "|", perc}, " ")
	end

	self:Tag(self.Curhp, '[bdUI:curhp]')

	-- return self.Curhp
end