local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Databars")

function mod:create_xp()
	local config = mod._config
	
	local bar = CreateFrame("frame", "bdXP", UIParent)
	bar:SetPoint("TOPLEFT", Minimap.background, "BOTTOMLEFT", 2, 0)
	bar:SetPoint("BOTTOMRIGHT", Minimap.background, "BOTTOMRIGHT", -2, -20)
	bar:SetFrameStrata("LOW")
	bar:SetFrameLevel(6)
	bdUI:setBackdrop(bar)

	bar.xp = CreateFrame('StatusBar', nil, bar)
	bar.xp:SetAllPoints(bar)
	bar.xp:SetStatusBarTexture(bdUI.media.flat)
	bar.xp:SetValue(0)

	bar.rxp = CreateFrame('StatusBar', nil, bar)
	bar.rxp:SetAllPoints(bar)
	bar.rxp:SetStatusBarTexture(bdUI.media.flat)
	bar.rxp:SetValue(0)
	bar.rxp:SetStatusBarColor(.2, .4, 0.8, 1)
	bar.rxp:SetAlpha(0.4)
	bar.rxp:Hide()

	bar:SetScript("OnEnter", function() bar.xp.text:Show() end)
	bar:SetScript("OnLeave", function() bar.xp.text:Hide() end)
	
	function bar:Update()
		local bar = self
		local xp = UnitXP("player")
		local mxp = UnitXPMax("player")
		local rxp = GetXPExhaustion("player")
		local name, standing, minrep, maxrep, value = GetWatchedFactionInfo()

		if (config.xptracker) then
		
			bar:Show()
			bar.xp:SetMinMaxValues(0,mxp)
			if UnitLevel("player") == MAX_PLAYER_LEVEL or IsXPUserDisabled == true then
				if name then
					bar.xp:SetStatusBarColor(FACTION_BAR_COLORS[standing].r, FACTION_BAR_COLORS[standing].g, FACTION_BAR_COLORS[standing].b, 1)
					bar.xp:SetMinMaxValues(minrep,maxrep)
					bar.xp:SetValue(value)
					bar.xp.text:SetText(value-minrep.." / "..maxrep-minrep.." - "..floor(((value-minrep)/(maxrep-minrep))*1000)/10 .."% - ".. name)
				else
					bar:Hide()
				end
			else
				bar.xp:SetStatusBarColor(.4, .1, 0.6, 1)
				bar.xp:SetValue(xp)
				if rxp then
					bar.xp.text:SetText(bdUI:numberize(xp).." / "..bdUI:numberize(mxp).." - "..floor((xp/mxp)*1000)/10 .."%" .. " (+"..bdUI:numberize(rxp)..")")
					bar.xp:SetMinMaxValues(0,mxp)
					bar.rxp:SetMinMaxValues(0, mxp)
					bar.xp:SetStatusBarColor(.2, .4, 0.8, 1)
					bar.xp:SetValue(xp)
					if (rxp+xp) >= mxp then
						bar.rxp:SetValue(mxp)
					else
						bar.rxp:SetValue(xp+rxp)
					end
					bar.rxp:Show()
				elseif xp > 0 and mxp > 0 then
					bar.xp.text:SetText(bdUI:numberize(xp).." / "..bdUI:numberize(mxp).." - "..floor((xp/mxp)*1000)/10 .."%")
					bar.rxp:Hide()
				end
			end
		else
			bar:Hide()
		end
	end

	bar:SetScript("OnEvent", bar.Update)
end