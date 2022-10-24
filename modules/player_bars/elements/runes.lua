local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Player Bars")

local function wotlk_runes(self)
	if (self.Runes) then return end
	local config = mod:get_save()

	local runes = {}
	local last
	local gap = bdUI.border --border * 4
	local width = (config.resources_width - (gap * 5)) / 6
	for index = 1, 6 do
		-- Position and size of the rune bar indicators
		local rune = CreateFrame('StatusBar', "bdPlayerBarsRune"..index, self.RuneHolder)
		rune:SetStatusBarTexture(bdUI.media.flat)
		rune:ClearAllPoints()
		bdUI:set_backdrop(rune)
		
		if (not last) then
			rune:SetPoint("LEFT", self.RuneHolder, 0, bdUI.border)
		else
			rune:SetPoint('LEFT', last, "RIGHT", gap, 0)
		end

		last = rune
		runes[index] = rune
	end

    -- Register with oUF
	self.WOTLKRunes = runes
	self.bdUIRunes = runes
end

function mod:create_runes(self)
	self.RuneHolder = CreateFrame("frame", nil, mod.Resources)
	if (select(2, UnitClass("player")) ~= "DEATHKNIGHT") then
		self.RuneHolder:Hide()
		return
	end

	if (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC) then
		self.RuneHolder:Show()
		wotlk_runes(self)
	end
	
end

local function path() end

local function enable()
	if (mod.config.runes_enable == false or select(2, UnitClass("player")) ~= "DEATHKNIGHT") then
		mod.ouf.RuneHolder:Hide()
		return false
	end
	mod.ouf.RuneHolder:Show()

	mod.ouf:EnableElement("WOTLKRunes")
	bdUI:set_frame_fade(mod.ouf.RuneHolder, mod.config.runes_ic_alpha, mod.config.runes_ooc_alpha)

	return true
end
local function disable()
	mod.ouf:DisableElement("WOTLKRunes")
	mod.ouf.RuneHolder:Hide()
end


mod:add_element('runes', path, enable, disable)