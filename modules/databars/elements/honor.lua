local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Databars")

function mod:create_honor()
	local config = mod.config

	if (bdUI:get_game_version() == "vanilla") then return end
	if (not UnitHonorLevel) then return end

	local bar = mod:create_databar("bdHonor")
	bar:SetSize(200, 20)
	bar:RegisterEvent("PLAYER_ENTERING_WORLD")
	bar:RegisterEvent("HONOR_XP_UPDATE")
	bar.callback = function(self, event)

		local current = UnitHonor("player");
		local maxHonor = UnitHonorMax("player");
		local level = UnitHonorLevel("player");
		local color = {0.8, 0.2, 0.2}

		-- make sure it's enabled
		if (not config.honorbar or not level) then 
			self:Hide()
			return
		end

		self:Show()
		self:SetMinMaxValues(0, maxHonor)
		self:SetValue(current)
		self:SetStatusBarColor(unpack(color))
		self.text:SetText(string.format("%s - %s / %s - %s", level, current, maxHonor, bdUI:round((current / maxHonor) * 100, 1)).."%")
		
	end
	bar:SetScript("OnEvent", bar.callback)

	return bar
end