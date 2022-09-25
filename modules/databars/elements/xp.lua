local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Databars")

function mod:create_xp()
	local config = mod.config

	local bar = mod:create_databar("bdXP")
	bar:SetSize(config.databars_width, config.databars_height)
	bar.tex = {}

	for i = 1, 19 do
		local tex = bar:CreateTexture(nil, "OVERLAY")
		local offset = (bar:GetWidth() / 20) * i
		tex:SetPoint("TOP", bar, "TOP")
		tex:SetPoint("BOTTOM", bar, "BOTTOM")
		tex:SetPoint("LEFT", bar, "LEFT", offset, 0)
		tex:SetWidth(bdUI.border)
		tex:SetAlpha(0.06)
		tex:SetTexture(bdUI.media.flat)
		tex:SetVertexColor(1, 1, 1)
		bar.tex[i] = tex
	end
	bar:RegisterEvent("PLAYER_XP_UPDATE")
	bar:RegisterEvent("PLAYER_LEVEL_UP")
	bar:RegisterEvent("PLAYER_ENTERING_WORLD")
	bar:RegisterEvent("UPDATE_FACTION")
	bar.callback = function(self, event)
		local xp = UnitXP("player")
		local mxp = UnitXPMax("player")
		local rxp = GetXPExhaustion("player")

		-- make sure it's enabled
		if (config.xpbar == "Always Hide" or (config.xpbar == "Show When Leveling" and (UnitLevel("player") == bdUI.level_cap or IsXPUserDisabled() == true))) then 
			self:Hide()
			return
		end

		self:Show()
		self:SetMinMaxValues(0, mxp)
		self:SetValue(xp)
		self:SetStatusBarColor(.4, .1, 0.6, 1)

		if (mxp > 0) then
			local text = FormatLargeNumber(xp).." / "..FormatLargeNumber(mxp).." - "..floor((xp / mxp) * 1000) / 10 .."%"

			if rxp then
				self.text:SetText(text .. " (+"..FormatLargeNumber(rxp)..")")
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
			elseif (mxp > 0) then
				self.text:SetText(text)
				self.layer:Hide()
			end
		end
	end
	bar:SetScript("OnEvent", bar.callback)

	return bar
end