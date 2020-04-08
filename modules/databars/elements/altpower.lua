local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Databars")

function mod:create_altpower()
	local config = mod.config

	if (not PlayerPowerBarAlt) then return end
	
	local bar = mod:create_databar("bdUI Alt Power")
	bar:SetSize(config.alt_width, config.alt_height)
	bar:SetPoint("CENTER", UIParent, "CENTER", 0, -160)
	bar:Hide()
	bdUI:set_backdrop(bar)
	bdMove:set_moveable(bar, "Alternative Power")
	bar.texture = bar:CreateTexture(nil, "OVERLAY")
	

	--Event handling
	bar:RegisterEvent("UNIT_POWER_UPDATE")
	bar:RegisterEvent("UNIT_POWER_BAR_SHOW")
	bar:RegisterEvent("UNIT_POWER_BAR_HIDE")
	bar:RegisterEvent("PLAYER_ENTERING_WORLD")
	bar.callback = function(self, event, arg1)
		if (not config.alteratepowerbar) then 
			self:Hide()
		else
			PlayerPowerBarAlt:Hide()

			if UnitAlternatePowerInfo("player") or UnitAlternatePowerInfo("target") then
				local power = UnitPower("player", ALTERNATE_POWER_INDEX)
				local mpower = UnitPowerMax("player", ALTERNATE_POWER_INDEX)
				local info = PowerBarColor[ADDITIONAL_POWER_BAR_NAME];

				self:Show()
				self:SetMinMaxValues(0, UnitPowerMax("player", ALTERNATE_POWER_INDEX))
				self:SetValue(power)
				self:SetStatusBarColor(bdUI.media.blue.r, bdUI.media.blue.g, bdUI.media.blue.b);
				self:SetStatusBarColor(unpack(bdUI.media.blue));

				-- print(config.alt_height)
				local extra = config.alt_height / 4
				local top = (2 + extra)

				self.texture:SetPoint("TOPLEFT", self, "TOPLEFT", -22, top)
				self.texture:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 22, -top)
				self.texture:SetTexture(PlayerPowerBarAlt.frame:GetTexture())

				self.text:SetText(power.."/"..mpower)
			else
				self:Hide()
			end
		end
	end
	bar:SetScript("OnEvent", bar.callback)

	return bar
end