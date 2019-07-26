local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Databars")

function mod:create_xp()
	local config = mod._config

	local bar = mod:create_databar("bdReputation")
	bar:RegisterEvent("PLAYER_ENTERING_WORLD")
	bar:RegisterEvent("UPDATE_FACTION")
	bar:SetScript("OnEvent", function(self, event)
		local name, standing, minrep, maxrep, value = GetWatchedFactionInfo()

		-- make sure it's enabled
		if (not config.reptracker or not name) then 
			self:Hide()
			return
		end

		self:Show()
		self:SetMinMaxValues(minrep, maxrep)
		self:SetValue(value)
		self:SetStatusBarColor(FACTION_BAR_COLORS[standing].r, FACTION_BAR_COLORS[standing].g, FACTION_BAR_COLORS[standing].b, 1)
		self.text:SetText(value - minrep.." / "..maxrep - minrep.." - "..math.floor(((value - minrep) / (maxrep - minrep)) * 1000) / 10 .."% - ".. name)
	end)
end