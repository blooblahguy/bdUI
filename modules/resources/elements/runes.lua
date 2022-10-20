local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Player Bars")

local combat_checker = CreateFrame("frame")

local function wotlk_runes(self)
	if (self.Runes) then return end
	local config = mod:get_save()

	
	-- bdUI:set_backdrop(self.RuneHolder)

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
	if (not mod.config.runes_enable) then return end

	mod.ouf:EnableElement("WOTLKRunes")
	combat_checker:RegisterEvent("PLAYER_REGEN_DISABLED")
	combat_checker:RegisterEvent("PLAYER_REGEN_ENABLED")
	combat_checker:SetScript("OnEvent", function(self, event)
		local config = mod:get_save()
		if (config.runes_ooc_alpha == 0 and not UnitAffectingCombat("player")) then
			mod.ouf.RuneHolder:Hide()
		else
			mod.ouf.RuneHolder:Show()
		end
		if (UnitAffectingCombat("player")) then
			mod.ouf.RuneHolder:SetAlpha(config.runes_ic_alpha)
		else
			mod.ouf.RuneHolder:SetAlpha(config.runes_ooc_alpha)
		end
	end)

	return true
end
local function disable()
	mod.ouf:DisableElement("WOTLKRunes")
	combat_checker:UnregisterEvent("PLAYER_REGEN_DISABLED")
	combat_checker:UnregisterEvent("PLAYER_REGEN_ENABLED")
end


mod:add_element('runes', path, enable, disable)