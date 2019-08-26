local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Databars")

function mod:create_altpower()
	local config = mod:get_save()

	if (not PlayerPowerBarAlt) then return end
	
	local bar = mod:create_databar("bdUI Alt Power")
	bar:SetSize(config.alt_width, config.alt_height)
	bar:SetPoint("CENTER", UIParent, "CENTER", 0, -160)
	bar:Hide()
	bdUI:set_backdrop(bar)
	bdMove:set_moveable(bar, "Alternative Power")

	--Event handling
	bar:RegisterEvent("UNIT_POWER_UPDATE")
	bar:RegisterEvent("UNIT_POWER_BAR_SHOW")
	bar:RegisterEvent("UNIT_POWER_BAR_HIDE")
	bar:RegisterEvent("PLAYER_ENTERING_WORLD")
	bar.callback = function(self, event, arg1)
		if (not config.alteratepowerbar) then 
			PlayerPowerBarAlt:RegisterEvent("UNIT_POWER_BAR_SHOW")
			PlayerPowerBarAlt:RegisterEvent("UNIT_POWER_BAR_HIDE")
			PlayerPowerBarAlt:RegisterEvent("PLAYER_ENTERING_WORLD")
			if (event == "UNIT_POWER_BAR_SHOW") then
				PlayerPowerBarAlt:Show()
			end
			
			self:Hide()
			
			return
		else
			PlayerPowerBarAlt:UnregisterEvent("UNIT_POWER_BAR_SHOW")
			PlayerPowerBarAlt:UnregisterEvent("UNIT_POWER_BAR_HIDE")
			PlayerPowerBarAlt:UnregisterEvent("PLAYER_ENTERING_WORLD")
			PlayerPowerBarAlt:Hide()
			if UnitAlternatePowerInfo("player") or UnitAlternatePowerInfo("target") then
				self:Show()
				
				self:SetMinMaxValues(0, UnitPowerMax("player", ALTERNATE_POWER_INDEX))
				local power = UnitPower("player", ALTERNATE_POWER_INDEX)
				local mpower = UnitPowerMax("player", ALTERNATE_POWER_INDEX)
				self:SetValue(power)
				self.text:SetText(power.."/"..mpower)
			else
				self:Hide()
			end
		end
	end
	bar:SetScript("OnEvent", bar.callback)

	return bar
end