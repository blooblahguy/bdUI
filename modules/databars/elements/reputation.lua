local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Databars")

local standing_ids = {
	[0] = "ffffff", -- "Unknown"
	[1] = "cc0000", -- "Hated"
	[2] = "ff0000", -- "Hostile"
	[3] = "f26000", -- "Unfriendly"
	[4] = "62b800", -- "Neutral"
	[5] = "33ff33", -- "Friendly"
	[6] = "1eb01c", -- "Honored"
	[7] = "11df6a", -- "Revered"
	[8] = "18cdcd", -- "Exalted"
}
local standings = { [0] = "Unknown", [1] = "Hated", [2] = "Hostile", [3] = "Unfriendly", [4] = "Neutral", [5] = "Friendly", [6] = "Honored", [7] = "Revered", [8] = "Exalted" }

function mod:create_reputation()
	local config = mod.config

	local bar = mod:create_databar("bdReputation")
	bar:SetSize(config.databars_width, config.databars_height)
	bar:RegisterEvent("PLAYER_ENTERING_WORLD")
	bar:RegisterEvent("UPDATE_FACTION")
	bar.callback = function(self, event)
		local name, standing, minrep, maxrep, value = C_Reputation.GetWatchedFactionData
		local disable = false

		-- make sure it's enabled
		if (config.repbar == "Always Hide") then
			disable = true
		elseif (config.repbar == "Show When Tracking & Max Level" and UnitLevel("player") ~= GetMaxPlayerLevel()) then
			disable = true
		end

		-- print("rep bar", disabled, MAX_PLAYER_LEVEL)

		if (disable or not name) then
			self:Hide()
			return
		end

		self:Show()
		self:SetMinMaxValues(minrep, maxrep)
		self:SetValue(value)
		local r, g, b = HexToRGBPerc(standing_ids[standing])
		self:SetStatusBarColor(r, g, b, 1)
		local text = table.concat({ name, standings[standing], value - minrep .. " / " .. maxrep - minrep }, " - ")
		self.text:SetText(text)
		-- standings[standing].." "..value - minrep.." / "..maxrep - minrep.." - "..math.floor(((value - minrep) / (maxrep - minrep)) * 1000) / 10 .."% - ".. name
	end
	bar:SetScript("OnEvent", bar.callback)

	return bar
end
