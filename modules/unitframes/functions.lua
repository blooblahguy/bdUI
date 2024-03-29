--===============================================
-- FUNCTIONS
--===============================================
local bdUI, c, l = unpack(select(2, ...))
local mod = bdUI:get_module("Unitframes")

local colors = {}
colors.tapped = { .6, .6, .6 }
colors.offline = { .6, .6, .6 }
colors.reaction = {}
colors.class = {}

-- class colors
for eclass, color in next, RAID_CLASS_COLORS do
	if not colors.class[eclass] then
		colors.class[eclass] = { color.r, color.g, color.b }
	end
end

-- faction colors
for eclass, color in next, FACTION_BAR_COLORS do
	if not colors.reaction[eclass] then
		colors.reaction[eclass] = { color.r, color.g, color.b }
	end
end

--===============================================
-- Custom functionality
-- place custom functionality here
--===============================================
function mod:display_text(self, unit, align)
	local config = mod:get_save()

	self.Name:ClearAllPoints()
	self.Curhp:ClearAllPoints()
	self.Status:ClearAllPoints()
	self.Curpp:ClearAllPoints()

	local LEFT = "LEFT"
	local RIGHT = "RIGHT"
	local offset = 4
	self.Name:Show()
	if (align == "right") then
		offset = -4
		LEFT = "RIGHT"
		RIGHT = "LEFT"
	end


	if (config.textlocation == "Inside") then
		self.Name:SetFontObject(bdUI:get_font(11, "THINOUTLINE"))
		self.Curhp:SetFontObject(bdUI:get_font(10, "THINOUTLINE"))

		self.Name:SetPoint(LEFT, self.TextHolder, offset, 0)
		self.Curhp:SetPoint(RIGHT, self.TextHolder, RIGHT, -offset, 0)

		self.Status:SetPoint("CENTER")
	elseif (config.textlocation == "Outside") then
		self.Name:SetFontObject(bdUI:get_font(13, "THINOUTLINE"))
		self.Curhp:SetFontObject(bdUI:get_font(10, "THINOUTLINE"))

		self.Name:SetPoint("TOP" .. RIGHT, self.TextHolder, "TOP" .. LEFT, -offset, 0)
		self.Curhp:SetPoint("TOP" .. RIGHT, self.Name, "BOTTOM" .. RIGHT, 0, -mod.padding)
		self.Curpp:SetPoint(LEFT, offset, 0)

		self.Status:SetPoint(RIGHT, -offset, 0)
	elseif (config.textlocation == "Minimal") then
		if (unit == "player") then
			self.Name:Hide()
		end
	end
end

mod.align_text = function(self, align)
	local config = mod:get_save()
	local icons = self.Auras or self.Debuffs or self.Buffs

	self.Name:ClearAllPoints()
	self.Curhp:ClearAllPoints()

	if (config.textlocation == "Inside") then
		if (align == "right") then
			self.Name:SetPoint("RIGHT", self.Health, "RIGHT", -4, 0)
			self.Curhp:SetPoint("LEFT", self.Health, "LEFT", 4, 0)
		else
			self.Name:SetPoint("LEFT", self.Health, "LEFT", 4, 0)
			self.Curhp:SetPoint("RIGHT", self.Health, "RIGHT", -4, 0)
		end
	elseif (config.textlocation == "Outside") then
		if (align == "right") then
			self.Name:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 4, -mod.padding)
			self.Curhp:SetPoint("TOPLEFT", self.Name, "BOTTOMLEFT", 0, -mod.padding)
		else
			self.Name:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -4, -mod.padding)
			self.Curhp:SetPoint("TOPRIGHT", self.Name, "BOTTOMRIGHT", 0, -mod.padding)
		end
	end
end

-- basic class coloring
function mod:autoUnitColor(unit)
	if (not UnitExists(unit)) then
		return unpack(colors.tapped)
	end
	if UnitIsPlayer(unit) then
		return unpack(colors.class[select(2, UnitClass(unit))])
	elseif UnitIsTapDenied(unit) then
		return unpack(colors.tapped)
	else
		return unpack(colors.reaction[UnitReaction(unit, 'player')])
	end
end

function mod:autoUnitColorHex(unit)
	return RGBPercToHex(mod:autoUnitColor(unit))
end
