local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Groups")

local dispelClass = {
	["PRIEST"] = { ["Disease"] = true, ["Magic"] = true, }, --Purify
	["SHAMAN"] = { ["Curse"] = true, ["Magic"] = true, ["Poison"] = true, }, --Purify Spirit
	["PALADIN"] = { ["Poison"] = true, ["Disease"] = true, ["Magic"] = true, }, --Cleanse
	["MAGE"] = { ["Curse"] = true, }, --Remove Curse
	["DRUID"] = { ["Curse"] = true, ["Poison"] = true, ["Magic"] = true, }, --Nature's Cure
	["MONK"] = { ["Poison"] = true, ["Disease"] = true, ["Magic"] = true, }, --Detox
	["WARLOCK"] = { ["Magic"] = true, }, -- Devour magic
}

local dispelColors = {
	['Magic'] = {.16, .5, .81, 1},
	['Poison'] = {.12, .76, .36, 1},
	['Disease'] = {.76, .46, .12, 1},
	['Curse'] = {.80, .33, .95, 1},
}
local lib_glow = LibStub("LibCustomGlow-1.0")
local class = select(2, UnitClass("player"))

--===========================================
-- DISPEL / GLOWING
--===========================================
mod.dispel_glow = function(self, event, unit)
	local config = mod.config
	if (unit ~= self.unit) then return end

	local found = {}
	local primaryDispel = {0, 0, 0, 0}
	local glow = false
	local dispel = false

	-- find debuffs
	for i = 1, 40 do
		local debuff, icon, count, debuffType = UnitDebuff(unit, i)

		if (not debuff) then break end

		-- if (not found[debuffType] and dispelClass[class][debuffType]) then
		if (not found[debuffType]) then
			if (dispelColors[debuffType] and not bdUI:is_blacklisted(debuff)) then
				found[debuffType] = true
				dispel = true
				if ((dispelClass[class] and dispelClass[class][debuffType]) or not dispelClass[class]) then
					primaryDispel = dispelColors[debuffType]
				end
			end
		end

		if (mod.highlights[debuff:lower()]) then -- or bdUI:isGlow(debuff)) then
			glow = true
		end
	end

	-- find buffs
	if (not glow) then
		for i = 1, 40 do
			local buff = UnitBuff(unit, i)

			if (not buff) then break end

			if (mod.highlights[buff:lower()]) then
				glow = true
				break
			end
		end
	end

	-- show dispels
	if (dispel) then
		self.Dispel:Show()
		self.Dispel:SetBackdropBorderColor(unpack(primaryDispel))

		-- show priority overlays
		for k, v in pairs(dispelColors) do
			if (found[k]) then
				self.Dispel[k]:Show()
			else
				self.Dispel[k]:Hide()
			end
		end
	else
		self.Dispel:Hide()
	end

	-- show glow
	if (glow) then
		lib_glow.PixelGlow_Start(self.Glow, false, 8, 0.25, false, mod.border, 0, false, false)
		-- lib_glow.ShowOverlayGlow(self.Glow)
	else
		lib_glow.PixelGlow_Stop(self.Glow)
		-- lib_glow.HideOverlayGlow(self.Glow)
	end
end