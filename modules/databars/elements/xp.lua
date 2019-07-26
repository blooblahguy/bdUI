local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Databars")

function mod:create_xp()
	local config = mod._config

	local bar = mod:create_databar("bdXP")

	bar:RegisterEvent("PLAYER_XP_UPDATE")
	bar:RegisterEvent("PLAYER_LEVEL_UP")
	bar:RegisterEvent("PLAYER_ENTERING_WORLD")
	bar:RegisterEvent("UPDATE_FACTION")
	bar:SetScript("OnEvent", function(self, event)
		local xp = UnitXP("player")
		local mxp = UnitXPMax("player")
		local rxp = GetXPExhaustion("player")
		local name, standing, minrep, maxrep, value = GetWatchedFactionInfo()

		-- make sure it's enabled
		if (not config.xptracker or UnitLevel("player") == MAX_PLAYER_LEVEL or IsXPUserDisabled == true) then 
			self:Hide()
			return
		end

		self:Show()
		self:SetMinMaxValues(0, mxp)
		self:SetValue(xp)
		self:SetStatusBarColor(.4, .1, 0.6, 1)

		if rxp then
			self.text:SetText(bdUI:numberize(xp).." / "..bdUI:numberize(mxp).." - "..floor((xp/mxp)*1000)/10 .."%" .. " (+"..bdUI:numberize(rxp)..")")
			self:SetMinMaxValues(0, mxp)
			self.layer:SetMinMaxValues(0, mxp)
			self:SetStatusBarColor(.2, .4, 0.8, 1)
			self:SetValue(xp)
			if ((rxp + xp) >= mxp) then
				self.layer:SetValue(mxp)
			else
				self.layer:SetValue(xp+rxp)
			end
			self.layer:Show()
		elseif xp > 0 and mxp > 0 then
			self.text:SetText(bdUI:numberize(xp).." / "..bdUI:numberize(mxp).." - "..floor((xp / mxp) * 1000) / 10 .."%")
			self.layer:Hide()
		end

	end)
end