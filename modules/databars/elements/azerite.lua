local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Databars")

function mod:create_azerite()
	local config = mod.config

	if (not C_AzeriteItem) then return end

	-- local animaCurrencyID, maxDisplayableValue = C_CovenantSanctumUI.GetAnimaInfo()
	-- local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(animaCurrencyID);

	-- print(animaCurrencyID)
	-- dump(currencyInfo)

	local bar = mod:create_databar("bdAzerite")
	bar:SetSize(config.databars_width, config.databars_height)
	bar:RegisterEvent("PLAYER_ENTERING_WORLD")
	bar:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
	bar.callback = function(self, event)
		local azerite = C_AzeriteItem.FindActiveAzeriteItem()
		local isMaxLevel = C_AzeriteItem.IsAzeriteItemAtMaxLevel();
		local disable = false

		-- make sure it's enabled
		if (config.apbar == "Always Hide") then
			disable = true
		elseif (config.apbar == "Only At Max Level" and UnitLevel("player") ~= MAX_PLAYER_LEVEL) then
			disable = true
		elseif (config.apbar == "Always Show") then
			disable = false
		end
		if (disable or not azerite or isMaxLevel) then 
			self:Hide()
			return
		end

		local xp, totalXP = C_AzeriteItem.GetAzeriteItemXPInfo(azerite)
		local level = C_AzeriteItem.GetPowerLevel(azerite)
		local color = {0.9, 0.8, 0.5, 1}

		self:Show()
		self:SetMinMaxValues(0, totalXP)
		self:SetValue(xp)
		self:SetStatusBarColor(unpack(color))
		self.text:SetText(string.format("%s - %s / %s - %s", level, xp, totalXP, bdUI:round((xp / totalXP) * 100, 1)).."%")
	end
	bar:SetScript("OnEvent", bar.callback)

	return bar
end