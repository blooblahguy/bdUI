local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Databars")

function mod:create_altpower()
	local config = mod._config
	
	local powerbar = CreateFrame('StatusBar', 'bdUI Alt Power', UIParent)
	powerbar:SetStatusBarTexture(bdUI.media.flat)
	powerbar:SetMinMaxValues(0,200)
	powerbar:SetSize(200, 20)
	powerbar:SetStatusBarColor(.2, .4, 0.8, 1)
	powerbar:SetPoint("CENTER",UIParent,"CENTER", 0, 0)
	powerbar:Hide()
	bdUI:set_backdrop(powerbar)
	bdMove:set_moveable(powerbar)
	
	powerbar.text = powerbar:CreateFontString(nil, "OVERLAY")
	powerbar.text:SetFont(bdUI.media.font, 13, "THINOUTLINE")
	powerbar.text:SetPoint("CENTER", powerbar, "CENTER")
	powerbar.text:SetJustifyH("CENTER")

	--Event handling
	powerbar:RegisterEvent("UNIT_POWER_UPDATE")
	powerbar:RegisterEvent("UNIT_POWER_BAR_SHOW")
	powerbar:RegisterEvent("UNIT_POWER_BAR_HIDE")
	powerbar:RegisterEvent("PLAYER_ENTERING_WORLD")
	powerbar:SetScript("OnEvent", function(self, event, arg1)

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
	end)
end