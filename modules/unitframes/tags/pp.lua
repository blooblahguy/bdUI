local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")
local oUF = bdUI.oUF

mod.tags.pp = function(self, unit)
	if (self.Curpp) then return end

	self.Curpp = self.TextHolder:CreateFontString(nil, "OVERLAY")
	self.Curpp:SetFontObject(bdUI:get_font(11))
	self.Curpp:SetPoint("LEFT", -4, 0)
	self.Curpp:SetTextColor(self.Power:GetStatusBarColor())

	-- self.pp_color = CreateFrame("frame", nil)
	-- self.pp_color:RegisterEvent("UNIT_POWER_UPDATE")
	-- self.pp_color:RegisterEvent("UNIT_MAXPOWER")
	-- self.pp_color:RegisterEvent("PLAYER_TARGET_CHANGED")
	-- self.pp_color:RegisterEvent("UNIT_NAME_UPDATE")
	-- self.pp_color:SetScript("OnEvent", function()
	-- 	self.Curpp:SetTextColor(self.Power:GetStatusBarColor())
	-- end)
	
	local curpp = self.Curpp
	self.Power.PostUpdateColor = function(self, unit, r, g, b)
		curpp:SetTextColor(r, g, b)
		-- print(unit, r, g, b)
	end
	
	oUF.Tags.Events['bdUI:Curpp'] = 'UNIT_POWER_UPDATE UNIT_MAXPOWER PLAYER_TARGET_CHANGED'
	oUF.Tags.Methods['bdUI:Curpp'] = function(unit)
		local pp, ppMax = UnitPower(unit), UnitPowerMax(unit)

		if (ppMax == 0) then return "" end

		return bdUI:round(pp / ppMax * 100)
		-- local hp, hpMax = UnitHealth(unit), UnitHealthMax(unit)
		-- if (bdUI.mobhealth) then -- foir classic
		-- 	hp, hpMax = bdUI.mobhealth:GetUnitHealth(unit)
		-- end

		-- if hpMax == 0 then return end

		-- local hpPercent = hp / hpMax
		-- local r, g, b = bdUI:ColorGradient(hpPercent, 1,0,0, 1,1,0, 1,1,1)
		-- local hex = RGBPercToHex(r, g, b)
		-- local perc = table.concat({"|cFF", hex, bdUI:round(hpPercent * 100), "|r"}, "")

		-- if (perc == 0 or perc == "0") then
		-- 	return "0 / "..numberize(UnitHealthMax(unit))
		-- end

		-- hp = "|cFF"..hex..bdUI:numberize(hp).."|r"

		-- return table.concat({hp, "|", perc}, " ")
	end

	self:Tag(self.Curpp, '[bdUI:Curpp]')
end