local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

mod.additional_elements.runes = function(self, unit)
	if (select(2, UnitClass("player")) ~= "DEATHKNIGHT") then return end
	if (self.Runes) then return end

	self.ResourceHolder:Show()

	local config = mod:get_save()
	local border = bdUI:get_border(self)

	local runes = {}
	local last
	local gap = border --border * 4
	local width = (config.playertargetwidth - (gap * 5)) / 6
	for index = 1, 6 do
		-- Position and size of the rune bar indicators
		local rune = CreateFrame('StatusBar', "bdUnitframesRune" .. index, self.ResourceHolder)
		rune:SetStatusBarTexture(bdUI.media.flat)
		rune:SetSize(width, border * 3)
		rune:ClearAllPoints()
		bdUI:set_backdrop(rune)

		if (not last) then
			rune:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, border)
		else
			rune:SetPoint('LEFT', last, "RIGHT", gap, 0)
		end

		last = rune
		runes[index] = rune
	end

	-- Register with oUF
	self.WOTLKRunes = runes
end
